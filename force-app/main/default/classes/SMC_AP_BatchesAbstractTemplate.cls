/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_BatchesAbstractTemplate
-- - Author        : Guillaume BONNET
-- - Description   : This abstract template class is extended by classes which are batches
                     checkbox checked take the address of their related account.
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  SMC_AP_BatchesAbstractTemplate     1.0      Initial version 
---------------------------------------------------------------------
*/

global abstract class SMC_AP_BatchesAbstractTemplate implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
  global String query; // The Query used in the start() method, must be setted in the constructor of the batch
  global String overrideQuery; // a custom query value can be used when the batch is executed manually instead of the standard query
  global String batchName; // The name of the Batch
  global String[] batchParameters; // The Parameters of the Batch

  global SMC_Log__c basicLog; // The log for this batch
  global List<SMC_Log_Line__c> detailledLogs; // The list of detailled logs generated by a catched exception

  global boolean isScheduled; // is true if the batch has been scheduled

  // DML Operations Counters
  global Integer nbRequestedRecords; // The number of records retrieved by the query
  global Integer nbProcessingRecord; // The number of records that have to be processed
  global Integer nbSuccess; // The number of records successfully processed (Modify on mail report Number of success)
  global Integer nbErrors; // The number of errors handled

  // Used to checks that every instance of Execute() method has correctly ended.
  global Integer nbExecuteStart; // The number of Execute() method begginning
  global Integer nbExecuteEnd; // The number of Execute() method ending

  // DML Statements Lists
  global List<sObject> toBeInsertedList; // The list used for Insert DML queries
  global List<sObject> toBeUpdatedList; // The list used for Update DML queries
  global List<sObject> toBeDeletedList; // The list used for Delete DML queries

  /*
   * Needs to be Overridden when the batch has to be scheduled,
   * must contain "Database.execute(new MyBatch()) in its body"
   */
  global virtual void execute(SchedulableContext sc) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > execute'
    );
  }

  public SMC_AP_BatchesAbstractTemplate() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > constructor(): start'
    );
    // Retrieving the Name of the Batch
    batchName = String.valueOf(this)
      .substring(0, String.valueOf(this).indexOf(':'));
    overrideQuery = null;
    // Initializing the errors list
    detailledLogs = new List<SMC_Log_Line__c>();

    // Retrieving the context of the Batch
    isScheduled = System.isScheduled();

    // Initializing the counters
    nbRequestedRecords = 0;
    nbProcessingRecord = 0;
    nbSuccess = 0;
    nbErrors = 0;
    nbExecuteStart = 0;
    nbExecuteEnd = 0;

    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > constructor(): end'
    );
  }

  public SMC_AP_BatchesAbstractTemplate(String overrideQuery) {
    this();
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > constructor(String): start'
    );
    this.overrideQuery = overrideQuery;
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > constructor(String): end'
    );
  }

  global virtual Database.QueryLocator start(Database.BatchableContext bc) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > virtual start'
    );

    // Generating a SMC_Log__c sObject
    basicLog = SMC_UTIL_Methods_Batch.newBasicLog(isScheduled, batchName);
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > virtual start > basicLog' + basicLog
    );
    if (overrideQuery == null) {
      return Database.getQueryLocator(query);
    } else {
      return Database.getQueryLocator(overrideQuery);
    }
  }

  global void execute(Database.BatchableContext bc, list<sObject> objects) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > execute'
    );
    // Increment the number of execute() beginning
    nbExecuteStart++;

    // Initialize the DML operations Lists
    initializeLists();

    // Retrieve the number of requested records
    nbRequestedRecords += objects.size();

    // Try / Catch block to handle Exceptions which are non directly related to DML Operations
    try {
      // Process records
      processObjects(objects);

      // byPass the specified Triggers
      bypassTriggers();

      // Launch DML Operations
      handleDMLOperations();

      // Execute Post-DML logic
      afterDML();
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'in SMC_AP_BatchesAbstractTemplate > execute: catch,' + e.getMessage()
      );
      List<Exception> exps = new List<Exception>();
      List<SMC_AP_FutureCallout.ExceptionsWrapper> exceptions = new List<SMC_AP_FutureCallout.ExceptionsWrapper>();
      exceptions = SMC_UTIL_Methods_Batch.getExeptionsInWrapper(exps);
      // for(SMC_AP_FutureCallout.ExceptionsWrapper ex : exceptions){
      //     //detailledLogs.add(SMC_Utils_Methods_Batch.handleException(ex, BasicLog.Id, 3));
      // }
      nbErrors++;
    }

    // Increment the number of Execute() ending
    nbExecuteEnd++;
  }

  public void initializeLists() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > initializeLists'
    );
    tobeInsertedList = new List<sObject>();
    tobeUpdatedList = new List<sObject>();
    tobeDeletedList = new List<sObject>();
  }

  // Processes the requested sObjects and sets the differents sObjects Lists
  global abstract void processObjects(List<sObject> objects);

  // Bypass the specified triggers for DMlOperations
  global abstract void bypassTriggers();

  // Launch the several DML Operations
  public void handleDMLOperations() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > handleDMLOperations'
    );
    // Insert records in tobeInsertedList / Update records in tobeUpdatedList
    saveObjects();

    // Delete records in tobeDeletedList
    deleteObjects();

    //upsert records
    // upsertObjects(tobeUpdatedList);
  }

  public void saveObjects() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > saveObjects: start'
    );
    // Initialize the SaveResult List
    List<Database.SaveResult> srList = new List<Database.SaveResult>();
    // Check if there are some records to Insert, and that the DML transactions won't exceed the Governor Limits
    if (
      !tobeInsertedList.isEmpty() &&
      SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
        batchName,
        tobeInsertedList.size(),
        basicLog.Id
      )
    ) {
      System.debug(
        LoggingLevel.INFO,
        'in SMC_AP_BatchesAbstractTemplate > saveObjects > about to Insert'
      );
      // Retrieve the number of records being processed
      nbProcessingRecord += tobeInsertedList.size();
      // Insert Records and retrieve SaveResult[] for error analysis
      srList.addAll(Database.insert(tobeInsertedList, false));
    }

    // Check if there are some records to Update, and that the DML transactions won't exceed the Governor Limits
    if (!tobeUpdatedList.isEmpty()) {
      if (
        SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
          batchName,
          tobeUpdatedList.size(),
          basicLog.Id
        )
      ) {
        // Retrieve the number of records being processed
        nbProcessingRecord += tobeUpdatedList.size();
        // Update Records and retrieve SaveResult[] for error analysis
        srList.addAll(Database.update(tobeUpdatedList, false));
      }
    }

    if (!srList.isEmpty()) {
      // Iterate through each returned result
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
          nbSuccess++;
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            // Increment the error counter
            nbErrors++;
            // Add the error into the Log object
            SMC_Log_Line__c logLine = new SMC_Log_Line__c(
              SMC_Date__c = Datetime.now(),
              SMC_Log__c = basicLog.Id,
              SMC_Error_Message__c = err.getMessage()
            );
            if (sr.getId() == null) {
              logLine.SMC_Error_Message__c =
                logLine.SMC_Error_Message__c +
                '| FieldList: ' +
                SMC_UTIL_Methods_Batch.getStringFromFieldList(err.getFields());
            } else {
              logLine.SMC_Record_id__c = sr.getId();
            }
            detailledLogs.add(logLine);
          }
        }
      }
    }
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > saveObjects: end'
    );
  }

  public virtual void upsertObjects(List<sObject> tobeProcessedList) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > upsertObjects'
    );
    // Check if there are some records to Upsert, and that the DML transactions won't exceed the Governor Limits
    if (
      !tobeProcessedList.isEmpty() &&
      SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
        batchName,
        tobeProcessedList.size(),
        basicLog.Id
      )
    ) {
      Database.UpsertResult[] urList = Database.upsert(
        tobeProcessedList,
        false
      );
      handleUpsertResult(urList);
    }
  }

  // Upsert the objects passed on parameters, handle potential errors,
  // And return a List of two integers, the numbers of success and errors
  public void handleUpsertResult(Database.UpsertResult[] urList) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > handleUpsertResult'
    );
    // Iterate through each returned result to check
    for (Database.UpsertResult ur : urList) {
      if (ur.isSuccess()) {
        nbSuccess++;
      } else {
        // Operation failed, so get all errors
        for (Database.Error err : ur.getErrors()) {
          // Increment the error counter
          nbErrors++;
          // Add the error into the Log object
          SMC_Log_Line__c logLine = new SMC_Log_Line__c(
            SMC_Date__c = Datetime.now(),
            SMC_Log__c = basicLog.Id,
            SMC_Error_Message__c = err.getMessage()
          );

          if (ur.getId() == null) {
            logLine.SMC_Error_Message__c =
              logLine.SMC_Error_Message__c +
              '| FieldList: ' +
              SMC_UTIL_Methods_Batch.getStringFromFieldList(err.getFields());
          } else {
            logLine.SMC_Record_id__c = ur.getId();
          }
          detailledLogs.add(logLine);
        }
      }
    }
  }

  public void deleteObjects() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > deleteObjects'
    );
    // Check if there are some records to Delete, and that the DML transactions won't exceed the Governor Limits
    if (
      !tobeDeletedList.isEmpty() &&
      SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
        batchName,
        tobeDeletedList.size(),
        basicLog.Id
      )
    ) {
      nbProcessingRecord += tobeDeletedList.size();
      Database.DeleteResult[] drList = Database.delete(tobeDeletedList, false);
      // Iterate through each returned result
      for (Database.DeleteResult dr : drList) {
        if (dr.isSuccess()) {
          nbSuccess++;
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : dr.getErrors()) {
            // Increment the error counter
            nbErrors++;
            // Add the error into the Log object
            SMC_Log_Line__c logLine = new SMC_Log_Line__c(
              SMC_Date__c = Datetime.now(),
              SMC_Log__c = basicLog.Id,
              SMC_Error_Message__c = err.getMessage()
            );
            logLine.SMC_Record_id__c = dr.getId();
            detailledLogs.add(logLine);
          }
        }
      }
    }
  }

  // method which may be override, that is executed after insert/update/delete in execute cycle
  global virtual void afterDML() {
  }

  // insert Logs, update BasicLog and send mail report
  global virtual void finish(Database.BatchableContext bc) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > finish'
    );
    if (nbExecuteStart != nbExecuteEnd) {
      detailledLogs.add(
        new SMC_Log_Line__c(
          SMC_Date__c = Datetime.now(),
          SMC_Error_Message__c = 'LimitException: Apex CPU time limit exceeded',
          SMC_Log__c = basicLog.Id
        )
      );
      nbErrors++;
    }

    // If Exceptions have been catched, insert the Detailled Logs about them.
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > finish > beforeif > detailledLogs:' +
      detailledLogs
    );
    if (detailledLogs.size() > 0) {
      try {
        System.debug(
          LoggingLevel.INFO,
          'in SMC_AP_BatchesAbstractTemplate > finish > try > detailledLogs:' +
          detailledLogs
        );
        Database.insert(detailledLogs);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'in SMC_AP_BatchesAbstractTemplate > finish > catch: ' +
          e.getMessage()
        );
      }
    }

    updateBasicLog();

    // Check that the batch was not scheduled to send the mail report
    if (!isScheduled && !Test.isRunningTest()) {
      Messaging.sendEmail(
        new List<Messaging.Email>{
          SMC_UTIL_Methods_Batch.generateBatchReport(basicLog)
        }
      );
    }
  }

  // Update the several data in the basicLog
  global void updateBasicLog() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_BatchesAbstractTemplate > updateBasicLog'
    );
    if (basicLog.SMC_Queried_Records_Number__c == null) {
      basicLog.SMC_Queried_Records_Number__c = nbRequestedRecords;
    } else {
      basicLog.SMC_Queried_Records_Number__c += nbRequestedRecords;
    }

    if (basicLog.SMC_DML_Process_Number__c == null) {
      basicLog.SMC_DML_Process_Number__c = nbProcessingRecord;
    } else {
      basicLog.SMC_DML_Process_Number__c += nbProcessingRecord;
    }

    if (basicLog.SMC_Success_Number__c == null) {
      basicLog.SMC_Success_Number__c = nbSuccess;
    } else {
      basicLog.SMC_Success_Number__c += nbSuccess;
    }

    if (basicLog.SMC_Error_Number__c == null) {
      basicLog.SMC_Error_Number__c = nbErrors;
    } else {
      basicLog.SMC_Error_Number__c += nbErrors;
    }

    basicLog.SMC_End_Date__c = System.now();
    if (batchParameters != null) {
      basicLog.SMC_Parameters__c =
        '[' +
        String.join(batchParameters, ',') +
        ']';
    }

    if (overrideQuery != null) {
      basicLog.SMC_Query__c = 'overridden: ' + overrideQuery;
    } else {
      basicLog.SMC_Query__c = query;
    }
    // The Query can be overridden when a batch is executed manually in the Developper Console.
    // If this is the case this field value will start with "overridden: "
    Database.update(basicLog);
  }
}