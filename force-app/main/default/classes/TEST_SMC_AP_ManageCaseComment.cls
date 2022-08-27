/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageCaseComment
-- - Author : Vincent RECASENS
-- - Description : This class is the test of 
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 29-AUG-2018  Lamya AAMRI  			1.1     	Test for preventNewCommentOnClosedCase method
-- 29-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageCaseComment {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME + '_Admin',
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      STA_UtilsStatic.USERNAME_TEST + '_Admin',
      STA_UtilsStatic.USER_NICKNAME + '_Admin'
    );
    userAdmin.userRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    userAdmin.Bypass_All_Processes_Builder__c = true;
    userAdmin.Bypass_All_Validation_Rules__c = true;
    userAdmin.Bypass_All_Workflow_Rules__c = true;

      //Set Users
      Profile profileSupport = [
                SELECT Id
                FROM Profile
                WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC
            ];
    User userSupport = SMC_UTIL_TestUtils.createUser(
      'support-' + STA_UtilsStatic.USER_NICKNAME,
      'support-' + STA_UtilsStatic.USERNAME_TEST,
      profileSupport.Id,
      'support-' + STA_UtilsStatic.USERNAME_TEST,
      'support-' + STA_UtilsStatic.USER_NICKNAME
    );
    userSupport.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME
    ]
    .Id; //Support
    userSupport.Bypass_All_Processes_Builder__c = true;
    userSupport.Bypass_All_Validation_Rules__c = true;
    userSupport.Bypass_All_Workflow_Rules__c = true;

    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME + '_Standard',
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST + '_Standard',
      STA_UtilsStatic.USER_NICKNAME + '_Standard'
    );
    userStandard.Bypass_All_Processes_Builder__c = true;
    userStandard.Bypass_All_Validation_Rules__c = true;
    userStandard.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ userStandard, userAdmin, userSupport };
  }

  /**
   * @description : test SMC_AP_ManageCaseComment.updateCaseParentId()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateCaseParentId() {
    PAD.bypassAll = true;
    // User user1 = [SELECT Id FROM User WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)];
    // User user1 = [SELECT Id FROM User WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)];
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    Case oneCase;
    System.runAs(user1) {
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        oneAccount.Id
      );
      insert oneContact;

      oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.OwnerId = user1.Id;
      oneCase.SMC_Take_Ownership__c = true;
      insert new List<Case>{ oneCase };
      System.assert(
        oneCase.SMC_New_Comment_Flag__c != true,
        'There is a problem with case initialisation.'
      );
    }

    Map<Id, Boolean> oneCaseId = new Map<Id, Boolean>();
    oneCaseId.put(oneCase.Id, false);
    System.assert(
      oneCase.SMC_New_Comment_Flag__c != true,
      'There is a problem with case initialisation.'
    );

    User user2 = [
      SELECT Id
      FROM User
      WHERE Email = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    CaseComment oneCaseComment;
    PAD.bypassAll = false;
    System.runAs(user2) {
      Test.startTest();
      oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(
        oneCase.Id,
        STA_UtilsStatic.CASE_BODY,
        false
      );
      insert oneCaseComment;
      Test.stopTest();
    }

    System.runAs(user1) {
      Case oneCaseChecked = [
        SELECT Id, Subject, SMC_New_Comment_Flag__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
      ];
      oneCaseChecked = [
        SELECT Id, SMC_New_Comment_Flag__c
        FROM Case
        WHERE Id = :oneCase.Id
      ];
      System.assert(
        oneCaseChecked.SMC_New_Comment_Flag__c == false,
        'There is a problem with case initialisation.'
      );
    }
  }

  // @isTest
  // public static void testPreventNewCommentOnClosedCase(){
  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testPreventNewCommentOnClosedCase - START');

  //     PAD.bypassAll = true;

  //     //Success
  //     Case oneCaseSuccess = [SELECT Id, Subject, SMC_New_Comment_Flag__c, SMC_Sub_Status__c, Status FROM Case WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT1];
  //     oneCaseSuccess.Status = STA_UtilsStatic.OPEN;
  //     oneCaseSuccess.SMC_Sub_Status__c = STA_UtilsStatic.OPEN;

  //     //Fail
  //     List<Case> caseToUpdate = new List<Case>();
  //     Case oneCaseFail = [SELECT Id, Subject, SMC_New_Comment_Flag__c, SMC_Sub_Status__c, Status FROM Case WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2];
  //     oneCaseFail.Status = STA_UtilsStatic.CLOSED;
  //     oneCaseFail.SMC_Sub_Status__c = STA_UtilsStatic.CLOSED;
  //     oneCaseFail.SMC_Answer_To_Customer__c = 'Answer';
  //     Case oneCaseFailChild = [SELECT Id, Subject, SMC_New_Comment_Flag__c, SMC_Sub_Status__c, Status, ParentId FROM Case WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT3];
  //     oneCaseFailChild.Status = STA_UtilsStatic.OPEN;
  //     oneCaseFailChild.SMC_Sub_Status__c = STA_UtilsStatic.OPEN;
  //     caseToUpdate.add(oneCaseSuccess);
  //     caseToUpdate.add(oneCaseFail);
  //     caseToUpdate.add(oneCaseFailChild);
  //     update caseToUpdate;

  //     CaseComment oneCaseCommentSuccess = SMC_UTIL_TestUtils.createCaseComment(oneCaseSuccess.Id, STA_UtilsStatic.CASE_BODY, false);
  //     CaseComment oneCaseCommentFail = SMC_UTIL_TestUtils.createCaseComment(oneCaseFail.Id, STA_UtilsStatic.CASE_BODY, false);
  //     insert new List<CaseComment>{oneCaseCommentSuccess, oneCaseCommentFail};

  //     Test.startTest();
  //         Map<CaseComment, Boolean> mapResult = SMC_AP_ManageCaseComment.preventNewCommentOnClosedCase(new List<CaseComment>{oneCaseCommentSuccess, oneCaseCommentFail});
  //     // Database.SaveResult resultSuccess = Database.insert(oneCaseCommentSuccess, false);
  //     // Database.SaveResult resultFail = Database.insert(oneCaseCommentFail, false);
  //     Test.stopTest();

  //     System.assert(!mapResult.get(oneCaseCommentSuccess));
  //     System.assert(mapResult.get(oneCaseCommentFail));

  //     // System.debug(LoggingLevel.INFO, 'resultSuccess : ' + resultSuccess);
  //     // System.assert(resultSuccess.isSuccess());
  //     // System.debug(LoggingLevel.INFO, 'resultFail : ' + resultFail);
  //     // System.assert(!resultFail.isSuccess());
  //     // System.assert(resultFail.getErrors().size()>0);
  //     // System.assertEquals(System.Label.SMC_ErrorCaseComment,resultFail.getErrors()[0].getMessage());

  //     PAD.bypassAll = false;

  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testPreventNewCommentOnClosedCase - START');
  // }

  // @isTest
  // public static void testSendPostChatterBeforeDelete(){
  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testSendPostChatterBeforeDelete - START');

  //     PAD.bypassAll = true;

  //     Profile profileStandard = [Select Id from Profile where Name =: STA_UtilsStatic.PROFILE_SMC_ADMIN];
  //     List<User> users = new List<User>();
  //     User userBypasser = SMC_UTIL_TestUtils.createUser(STA_UtilsStatic.TEST_DIESE + '3',STA_UtilsStatic.EMAIL_TEST, profileStandard.Id, STA_UtilsStatic.USERNAME_TEST + '3', STA_UtilsStatic.USER_NICKNAME + '3');
  //     userBypasser.Bypass_All_Processes_Builder__c = true;
  //     insert userBypasser;
  //     System.runAs(userBypasser){
  //         Account oneAccount = [SELECT Id FROM Account WHERE AccountNumber = 'ACC-{000001}'];
  //         Contact oneContact = [SELECT Id FROM Contact WHERE FirstName = :STA_UtilsStatic.CONTACT_FIRSTNAME1];
  //         Case theCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT1, STA_UtilsStatic.CASE_DESCRIPTION1, STA_UtilsStatic.CASE_TYPE_TECHNICAL, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
  //         theCase.OwnerId = userBypasser.Id;
  //         theCase.AccountId = oneAccount.Id;
  //         theCase.ContactId = oneContact.Id;
  //         insert theCase;

  //         List<CaseComment> caseComments = new List<CaseComment>();
  //         CaseComment oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(theCase.Id, STA_UtilsStatic.CASE_BODY, false);
  //         caseComments.add(oneCaseComment);
  //         insert caseComments;

  //     }
  //     User userSoc1 = [SELECT Id, Alias FROM User WHERE Alias = 'SOC1'];
  //     System.runAs(userSoc1){
  //         List<CaseComment> caseComments = new List<CaseComment>();
  //         caseComments = [SELECT Id, ParentId, CreatedById FROM CaseComment];
  //         System.assert(SMC_AP_ManageCaseComment.sendPostChatterBeforeDelete(caseComments));
  //     }

  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testSendPostChatterBeforeDelete - START');
  // }

  // @isTest
  // public static void testDeleteCaseComment(){
  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testDeleteCaseComment - START');

  //     Case theCase = [SELECT Id, Subject, SMC_New_Comment_Flag__c, SMC_Sub_Status__c, Status FROM Case WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT1];

  //     List<CaseComment> caseComments = new List<CaseComment>();
  //     CaseComment oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(theCase.Id, STA_UtilsStatic.CASE_BODY, false);
  //     caseComments.add(oneCaseComment);
  //     insert caseComments;

  //     CaseComment caseCommentToDelete = [SELECT Id, ParentId FROM CaseComment WHERE ParentId = :theCase.Id];
  //     delete oneCaseComment;

  //     CaseComment caseCommentCheck;
  //     try{
  //         caseCommentCheck = [SELECT Id, ParentId FROM CaseComment WHERE ParentId = :theCase.Id];
  //     }catch(Exception e){
  //         System.debug(LoggingLevel.INFO, 'The test (deletion of CaseComment) is a success => List has no rows');
  //     }
  //     System.assertEquals(null, caseCommentCheck);

  //     System.debug(LoggingLevel.INFO, '>>>>>> TEST_SMC_AP_ManageCaseComment : testDeleteCaseComment - START');
  // }
}