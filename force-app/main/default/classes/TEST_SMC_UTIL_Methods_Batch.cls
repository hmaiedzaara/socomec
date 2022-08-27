/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_UTIL_Methods_Batch
-- - Author        : Guillaume BONNET
-- - Description   : This Util class is used by SMC_AP_BatchesAbstractTemplate
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  SMC_AP_BatchesAbstractTemplate     1.0      Initial version 
---------------------------------------------------------------------
*/
@isTest
public without sharing class TEST_SMC_UTIL_Methods_Batch {
  /**
   * @description : test SMC_UTIL_Methods_Batch.newBasicLog()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void newBasicLogTEST() {
    SMC_Log__c basicLog = SMC_UTIL_Methods_Batch.newBasicLog(
      true,
      STA_UTilsStatic.TEST
    );
    System.assertEquals(
      1,
      [SELECT Id FROM SMC_Log__c WHERE Id = :basicLog.Id].size(),
      'The BatchLog creation is broken.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.handleException()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void handleExceptionTEST() {
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    SMC_Log_Line__c logLine = new SMC_Log_Line__c();
    try {
      throw new NullPointerException();
    } catch (Exception e) {
      logLine = SMC_UTIL_Methods_Batch.handleException(e, basicLog.Id);
    }
    System.assertEquals(
      logLine.SMC_Log__c,
      basicLog.Id,
      'The BatchLog handleException is broken.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.checkDMLGovernorLimits()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void checkDMLGovernorLimitsTEST() {
    // Insert new basicLog record
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    // Call checkDMLGovernorLimits method with nbDMLRows = 10000 to detect a Limit Exception Detection
    SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
      STA_UtilsStatic.TEST,
      10000,
      basicLog.Id
    );

    // Call checkDMLGovernorLimits method with nbDMLRows = 10 to avoid detecting a Limit Exception Detection
    SMC_UTIL_Methods_Batch.checkDMLGovernorLimits(
      STA_UtilsStatic.TEST,
      10,
      basicLog.Id
    );

    // Checks that the Limit Exception has only been detected once
    System.assertEquals(
      1,
      [SELECT Id FROM SMC_Log__c].size(),
      'The BatchLog DMLGovernorLimit is execute more than one time.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.upsertObjectsWithoutField()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void upsertObjectsWithoutField() {
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    List<Account> accountList = new List<Account>();
    accountList.add(new Account());
    SMC_UTIL_Methods_Batch.upsertObjectsWithoutField(
      accountList,
      STA_UtilsStatic.TEST,
      basicLog
    );
    System.assertEquals(
      1,
      [SELECT Id FROM SMC_Log__c].size(),
      'The BatchLog is not created.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.handleUpsertResult()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void handleUpsertResultTEST() {
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    List<Account> accountList = new List<Account>();
    accountList.add(new Account());
    Database.UpsertResult[] urList = Database.upsert(accountList, false);
    SMC_UTIL_Methods_Batch.handleUpsertResult(
      urList,
      STA_UtilsStatic.TEST,
      basicLog
    );

    System.assertEquals(
      1,
      [SELECT Id FROM SMC_Log__c].size(),
      'The BatchLog is not created.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.saveobjects()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void saveobjectsTEST() {
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    List<Account> accountList = new List<Account>();
    accountList.add(new Account());

    System.assertEquals(
      1,
      SMC_UTIL_Methods_Batch.saveobjects(
        accountList,
        STA_UtilsStatic.TEST,
        basicLog,
        true
      )[1],
      'The new object is not inserted.'
    );
    System.assertEquals(
      1,
      SMC_UTIL_Methods_Batch.saveobjects(
        accountList,
        STA_UtilsStatic.TEST,
        basicLog,
        false
      )[1],
      'The new object is not inserted.'
    );

    // System.assertEquals(2, [
    //     SELECT Id
    //     FROM SMC_Log_Line__c
    // ].size());
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.handleDeleteSaveResultArray()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void handleDeleteSaveResultArrayTEST() {
    SMC_Log__c basicLog = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert basicLog;
    List<Case> caseList = new List<Case>();
    caseList.add(new Case());
    SMC_UTIL_Methods_Batch.upsertObjectsWithoutField(
      caseList,
      STA_UtilsStatic.TEST,
      basicLog
    );
    SMC_UTIL_Methods_Batch.saveObjects(
      caseList,
      STA_UtilsStatic.TEST,
      basicLog,
      false
    );
    SMC_UTIL_Methods_Batch.deleteobjects(
      caseList,
      STA_UtilsStatic.TEST,
      basicLog
    );
    SMC_UTIL_Methods_Batch.deleteobjects(
      caseList,
      STA_UtilsStatic.TEST,
      basicLog
    );
    System.assertEquals(
      1,
      [SELECT Id FROM SMC_Log__c].size(),
      'There are more than 1 log. An erorr occur during a process.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.getStringFromFieldList()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void getStringFromFieldListTEST() {
    List<String> stringList = new List<String>();
    stringList.add('1');
    stringList.add('2');
    stringList.add('3');
    System.assertEquals(
      'List of Failing Fields : {1} {2} {3}',
      SMC_UTIL_Methods_Batch.getStringFromFieldList(stringList),
      'Check setup and the method. Strings do not match.'
    );
    System.assertEquals(
      'Some mandatory fields are empty',
      SMC_UTIL_Methods_Batch.getStringFromFieldList(new List<String>()),
      'Check setup and the method. Strings do not match.'
    );
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.generateBatchReport()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  static void generateBatchReportTEST() {
    SMC_Log__c log = new SMC_Log__c(
      SMC_Process_Name__c = STA_UtilsStatic.LOGS_PROCESS_NAME,
      SMC_Start_Date__c = DateTime.now()
    );
    insert log;

    SMC_Log_Line__c line = new SMC_Log_Line__c(SMC_Log__c = log.Id);

    Messaging.SingleEmailMessage mail = SMC_UTIL_Methods_Batch.generateBatchReport(
      log
    );
    System.assertNotEquals(null, mail, 'The email message is not generated.');
  }

  /**
   * @description : test SMC_UTIL_Methods_Batch.createErrorLog()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testCreateErrorLog() {
    CalloutException calloutException = new CalloutException();
    List<calloutException> exceptions = new List<calloutException>();
    calloutException.setMessage(
      '>>>>>TEST<<<<<< -- The status code returned was not expected : ' + 400
    );
    exceptions.add(calloutException);
    SMC_UTIL_Methods_Batch.createErrorLog(
      exceptions,
      'Log Test',
      STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
      STA_UtilsStatic.EMPTY_STRING,
      STA_UtilsStatic.EMPTY_STRING,
      null
    );

    SMC_Log__c basicLog = [
      SELECT Id, Name, SMC_Process_Name__c
      FROM SMC_Log__c
      WHERE SMC_Process_Name__c = 'Log Test'
    ];
    System.assert(basicLog != null, 'The log is not created.');
    SMC_Log_Line__c detailledLine = [
      SELECT Id, Name, SMC_Error_Message__c
      FROM SMC_Log_Line__c
      WHERE SMC_Log__r.Id = :basicLog.Id
    ];
    System.assert(detailledLine != null, 'The detail og is not generated.');
  }
}