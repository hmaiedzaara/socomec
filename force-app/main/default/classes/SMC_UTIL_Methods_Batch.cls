/**
 * @File Name          : SMC_UTIL_Methods_Batch.cls
 * @Description        :
 * @Author             : Guillaume BONNET (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 10:56:58
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/04/2018   Guillaume BONNET (Modis)     Initial Version
 **/

public without sharing class SMC_UTIL_Methods_Batch {
  // Insert a Log with BasicLog RecordType
  public static SMC_Log__c newBasicLog(Boolean isScheduled, String batchName) {
    // Generating a SMC_Log__c sObject with "BasicLog" Recordtype
    Id basicLogId = Database.insert(
        new SMC_Log__c(
          //Scheduled__c = isScheduled,
          SMC_Process_Name__c = batchName,
          SMC_Process_Type__c = STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_AB,
          SMC_Start_Date__c = DateTime.now(),
          SMC_User__c = UserInfo.getUserId()
        )
      )
      .getId();

    // Retrieving said Log to access CreatedDate and Name fields
    return [
      SELECT
        Id,
        CreatedDate,
        Name,
        SMC_Process_Name__c,
        SMC_Process_Type__c,
        SMC_Start_Date__c,
        SMC_User__c,
        SMC_Queried_Records_Number__c,
        SMC_DML_Process_Number__c,
        SMC_Success_Number__c,
        SMC_Error_Number__c,
        SMC_End_Date__c,
        SMC_Parameters__c,
        SMC_RecordId_In_Error__c
      FROM SMC_Log__c
      WHERE Id = :basicLogId
    ];
  }

  // Insert a Log with BasicLog RecordType with dynamic ProcessType
  public static SMC_Log__c newBasicLog(
    Boolean isScheduled,
    String batchName,
    String processType
  ) {
    // Generating a SMC_Log__c sObject with "BasicLog" Recordtype
    Id basicLogId = Database.insert(
        new SMC_Log__c(
          //Scheduled__c = isScheduled,
          SMC_Process_Name__c = batchName,
          SMC_Process_Type__c = processType,
          SMC_Start_Date__c = DateTime.now(),
          SMC_User__c = UserInfo.getUserId()
        )
      )
      .getId();

    // Retrieving said Log to access CreatedDate and Name fields
    return [
      SELECT
        Id,
        CreatedDate,
        Name,
        SMC_Process_Name__c,
        SMC_Process_Type__c,
        SMC_Start_Date__c,
        SMC_User__c,
        SMC_Queried_Records_Number__c,
        SMC_DML_Process_Number__c,
        SMC_Success_Number__c,
        SMC_Error_Number__c,
        SMC_End_Date__c,
        SMC_Parameters__c,
        SMC_RecordId_In_Error__c
      FROM SMC_Log__c
      WHERE Id = :basicLogId
    ];
  }

  // Return a Detailled Log with its fields filled
  public static SMC_Log_Line__c handleException(Exception ex, Id basicLogId) {
    //insert new Log Line
    SMC_Log_Line__c newLogLine = new SMC_Log_Line__c(
      SMC_Date__c = DateTime.now(),
      SMC_Error_Message__c = ex.getTypeName() +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        ex.getMessage(),
      SMC_Error_Stacktrace__c = ex.getStackTraceString(),
      LastModifiedById = UserInfo.getUserId(),
      SMC_Log__c = basicLogId
    );

    if (
      !String.isEmpty(newLogLine.SMC_Error_Message__c) &&
      newLogLine.SMC_Error_Message__c.length() > 131070
    ) {
      newLogLine.SMC_Error_Message__c = newLogLine.SMC_Error_Message__c.substring(
        0,
        131069
      );
    }

    if (
      !String.isEmpty(newLogLine.SMC_Error_Stacktrace__c) &&
      newLogLine.SMC_Error_Stacktrace__c.length() > 131070
    ) {
      newLogLine.SMC_Error_Stacktrace__c = newLogLine.SMC_Error_Stacktrace__c.substring(
        0,
        131069
      );
    }
    return newLogLine;
  }

  // Checks that the Batch's execution hasn't exceeded the DML Queries Governor Limits
  public static boolean checkDMLGovernorLimits(
    String batchName,
    Integer nbDMLRows,
    Id basicLogId
  ) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_UTIL_Methods_Batch > checkDMLGovernorLimits: start'
    );
    if (
      ((Double) Limits.getDmlStatements() + 1) /
      (Double) Limits.getLimitDmlStatements() >= 0.9 ||
      ((Double) Limits.getDmlRows() + nbDMLRows) /
      (Double) Limits.getLimitDmlRows() >= 0.9
    ) {
      insert new SMC_Log_Line__c(
        SMC_Date__c = DateTime.now(),
        SMC_Error_Message__c = batchName +
          '\'s execution has exceeded the DML Governor Limits',
        // SMC_Error_Stacktrace__c = ex.getStackTraceString(),
        LastModifiedById = UserInfo.getUserId(),
        SMC_Log__c = basicLogId
        //SMC_Object_Name__c,
      );
      System.debug(
        LoggingLevel.INFO,
        'in SMC_UTIL_Methods_Batch > checkDMLGovernorLimits: start(if)'
      );
      return false;
    } else {
      System.debug(
        LoggingLevel.INFO,
        'in SMC_UTIL_Methods_Batch > checkDMLGovernorLimits: start(else)'
      );
      return true;
    }
  }

  // Upsert the objects passed on parameters, handle potential errors,
  // And return a List of two integers, the numbers of success and errors
  public static List<Integer> upsertObjectsWithoutField(
    List<sObject> objects,
    String batchName,
    SMC_Log__c basicLog
  ) {
    Integer nbErrors = 0;
    Integer nbSuccess = 0;
    List<SMC_Log_Line__c> errorLogs = new List<SMC_Log_Line__c>();

    try {
      // Check if there are some records to Save, and that the DML transactions won't exceed the Governor Limits
      if (
        !objects.isEmpty() &&
        checkDMLGovernorLimits(batchName, objects.size(), basicLog.Id)
      ) {
        Database.UpsertResult[] urList;
        urList = Database.upsert(objects, false);
        // Iterate through each returned result
        for (Database.UpsertResult ur : urList) {
          if (ur.isSuccess()) {
            nbSuccess++;
          } else {
            // Operation failed, so get all errors
            for (Database.Error err : ur.getErrors()) {
              // Increment the error counter
              nbErrors++;
              // Add the error into the Log object
              SMC_Log_Line__c detailledLogLine = new SMC_Log_Line__c(
                SMC_Date__c = DateTime.now(),
                SMC_Error_Message__c = err.getMessage(),
                // SMC_Error_Stacktrace__c = ex.getStackTraceString(),
                LastModifiedById = UserInfo.getUserId(),
                SMC_Log__c = basicLog.Id
                //Name //Auto Number type
                //SMC_Object_Name__c,
              );

              if (ur.getId() == null) {
                detailledLogLine.SMC_Record_id__c = getStringFromFieldList(
                    err.getFields()
                  )
                  .substring(0, 17);
              } else {
                detailledLogLine.SMC_Record_id__c = ur.getId();
              }

              errorLogs.add(detailledLogLine);
            }
          }
        }
      }
    } catch (Exception e) {
      errorLogs.add(handleException(e, BasicLog.Id));

      nbErrors++;
    }
    Database.insert(errorLogs);
    return (new List<Integer>{ nbSuccess, nbErrors });
  }

  // Upsert the objects passed on parameters, handle potential errors,
  // And return a List of two integers, the numbers of success and errors
  public static List<Integer> handleUpsertResult(
    Database.UpsertResult[] urList,
    String batchName,
    SMC_Log__c basicLog
  ) {
    Integer nbErrors = 0;
    Integer nbSuccess = 0;
    list<SMC_Log_Line__c> errorLogs = new List<SMC_Log_Line__c>();
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
            SMC_Date__c = DateTime.now(),
            SMC_Error_Message__c = err.getMessage(),
            // SMC_Error_Stacktrace__c = err.getStackTraceString(),
            LastModifiedById = UserInfo.getUserId(),
            SMC_Log__c = basicLog.Id
            //Name //Auto Number type
            //SMC_Object_Name__c,
          );

          if (ur.getId() == null) {
            logLine.SMC_Record_id__c = getStringFromFieldList(err.getFields())
              .substring(0, 17);
          } else {
            logLine.SMC_Record_id__c = ur.getId();
          }
          errorLogs.add(logLine);
        }
      }
    }
    Database.insert(errorLogs, false);
    return (new List<Integer>{ nbSuccess, nbErrors });
  }

  // Insert / Update the objects passed on parameters, handle potential errors,
  // And return a List of two integers, the numbers of success and errors
  public static List<Integer> saveObjects(
    List<sObject> objects,
    String batchName,
    SMC_Log__c basicLog,
    boolean isInsert
  ) {
    // Initialize the error and success Counters
    Integer nbSuccess = 0;
    Integer nbErrors = 0;
    List<SMC_Log_Line__c> errorLogs = new List<SMC_Log_Line__c>();
    try {
      // Check if there are some records to Save, and that the DML transactions won't exceed the Governor Limits
      if (
        !objects.isEmpty() &&
        checkDMLGovernorLimits(batchName, objects.size(), basicLog.Id)
      ) {
        Database.SaveResult[] srList;
        if (isInsert) {
          srList = Database.insert(objects, false);
        } else {
          srList = Database.update(objects, false);
        }
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
                SMC_Date__c = DateTime.now(),
                SMC_Error_Message__c = err.getMessage(),
                // SMC_Error_Stacktrace__c = ex.getStackTraceString(),
                LastModifiedById = UserInfo.getUserId(),
                SMC_Log__c = basicLog.Id
                //Name //Auto Number type
                //SMC_Object_Name__c,
              );

              if (sr.getId() == null) {
                logLine.SMC_Record_id__c = getStringFromFieldList(
                    err.getFields()
                  )
                  .substring(0, 17);
              } else {
                logLine.SMC_Record_id__c = sr.getId();
              }
              errorLogs.add(logLine);
            }
          }
        }
      }
    } catch (Exception e) {
      errorLogs.add(handleException(e, BasicLog.Id));

      nbErrors++;
    }
    Database.insert(errorLogs, false);
    return (new List<Integer>{ nbSuccess, nbErrors });
  }

  // Delete the objects passed on parameters, handle potential errors,
  // And return a List of two integers, the numbers of success and errors
  public static List<Integer> deleteObjects(
    List<sObject> objects,
    String batchName,
    SMC_Log__c basicLog
  ) {
    // Initialize the Counters
    Integer nbErrors = 0;
    Integer nbSuccess = 0;
    List<SMC_Log_Line__c> errorLogs = new List<SMC_Log_Line__c>();
    try {
      // Check if there are some records to Delete, and that the DML transactions won't exceed the Governor Limits
      if (
        !objects.isEmpty() &&
        checkDMLGovernorLimits(batchName, objects.size(), basicLog.Id)
      ) {
        Database.DeleteResult[] drList = Database.delete(objects, false);
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
                SMC_Date__c = DateTime.now(),
                SMC_Error_Message__c = err.getMessage(),
                // SMC_Error_Stacktrace__c = err.getStackTraceString(),
                LastModifiedById = UserInfo.getUserId(),
                SMC_Log__c = basicLog.Id
                //SMC_Object_Name__c,
              );

              logLine.SMC_Record_id__c = dr.getId();
              errorLogs.add(logLine);
            }
          }
        }
      }
    } catch (Exception e) {
      errorLogs.add(handleException(e, BasicLog.Id));

      nbErrors++;
    }
    Database.insert(errorLogs, false);
    return (new List<Integer>{ nbSuccess, nbErrors });
  }

  // Extract all String from a String Array
  public static String getStringFromFieldList(String[] fieldList) {
    if (fieldList.isEmpty()) {
      return 'Some mandatory fields are empty';
    } else {
      String fields =
        'List of Failing Fields : {' +
        String.join(fieldList, '} {') +
        '}';
      return fields;
    }
  }

  public static Messaging.SingleEmailMessage generateBatchReport(
    SMC_Log__c log
  ) {
    String templateId = [
      SELECT Id, Name
      FROM EmailTemplate
      WHERE DeveloperName = :STA_UtilsStatic.BATCH_TEMPLATE_NAME
    ]
    .Id;
    String userId = UserInfo.getUserId();
    String whatId;
    if (log != null) {
      whatId = log.Id;
    } else {
      whatId = null;
    }

    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
      templateId,
      userId,
      whatId
    );

    String emailSubject = email.getSubject();
    String emailTextBody = email.getPlainTextBody();

    email.setTargetObjectId(userId);
    email.setSubject(emailSubject);
    email.setPlainTextBody(emailTextBody);
    email.saveAsActivity = false;
    return email;
  }
  //make exception in an ExeptionsInWrapper
  public static List<SMC_AP_FutureCallout.ExceptionsWrapper> getExeptionsInWrapper(
    List<Exception> logs
  ) {
    list<SMC_AP_FutureCallout.ExceptionsWrapper> exceptionsWrapper = new List<SMC_AP_FutureCallout.ExceptionsWrapper>();
    for (Exception ex : logs) {
      SMC_AP_FutureCallout.ExceptionsWrapper logWrapper = new SMC_AP_FutureCallout.ExceptionsWrapper();
      logWrapper.errorName = ex.getTypeName();
      logWrapper.errorMessage = ex.getMessage();
      logWrapper.errorStackTrace = ex.getStackTraceString();
      exceptionsWrapper.add(logWrapper);
    }
    return exceptionsWrapper;
  }

  public static void createErrorLog(
    List<Exception> logs,
    String nameLog,
    String processType,
    String requestBody,
    String requestQuery,
    List<String> recordList
  ) {
    // Generating a SMC_Log__c sObject
    string logName = nameLog;
    SMC_Log__c basicLog = newBasicLog(false, logName, processType);
    basicLog.SMC_Parameters__c = requestBody;
    basicLog.SMC_Query__c = requestQuery;
    if (recordList != null) {
      basicLog.SMC_RecordId_In_Error__c = '';
      for (String oneRecord : recordList) {
        basicLog.SMC_RecordId_In_Error__c += oneRecord + '\n';
      }
    } else {
      basicLog.SMC_RecordId_In_Error__c = 'There is no record associated to this log';
    }

    update basicLog;

    //Catched error in a new log line
    List<SMC_Log_Line__c> detailledLogs = new List<SMC_Log_Line__c>();
    for (Exception e : logs) {
      detailledLogs.add(handleException(e, basicLog.Id)); //The code is temporary a magic number
    }
    insert detailledLogs;
  }
}