/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Escalation_Process_CMPs 
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_AC_Escalation_Components
--
-- Maintenance History:
--
-- Date         Name      Version     Remarks
-- -----------  ----      -------     ------------------
-- 11-MAR-2019  VRECA     1.0         Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_Escalation_Process_CMPs {
  /**
  * @description : test setup
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @testSetup
  public static void setup() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];

    Id userRoleBeId;
    Id userRoleSalesManagerId;
    List<String> listUserRoleDevName = new List<String>{STA_UtilsStatic.ROLE_BE_DEVNAME, 
                                               STA_UtilsStatic.ROLE_SALES_MANAGER_SBG_PCO_SERV_DEVNAME};
    for(UserRole userRole : [SELECT Id, DeveloperName 
                             FROM UserRole 
                             WHERE DeveloperName IN :listUserRoleDevName]){
      if(userRole.DeveloperName == STA_UtilsStatic.ROLE_BE_DEVNAME){
        userRoleBeId = userRole.Id;
      }
      if(userRole.DeveloperName == STA_UtilsStatic.ROLE_SALES_MANAGER_SBG_PCO_SERV_DEVNAME){
        userRoleSalesManagerId = userRole.Id;
      }
    }

    User user3 = SMC_UTIL_TestUtils.createUser(
      'test_delegated_' + STA_UtilsStatic.USER_NICKNAME,
      'test_delegated_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'test_delegated_' + STA_UtilsStatic.USERNAME_TEST,
      'test_delegated_' + STA_UtilsStatic.USER_NICKNAME
    );
    user3.SMC_Approval_Level__c = 2;
    user3.UserRoleId = userRoleBeId;
    user3.SMC_User_Subsidiary__c = 'SSA';
    // user3.Bypass_All_Processes_Builder__c = true;
    insert user3;

    User user1 = SMC_UTIL_TestUtils.createUser(
      'test_manager_' + STA_UtilsStatic.USER_NICKNAME,
      'test_manager_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'test_manager_' + STA_UtilsStatic.USERNAME_TEST,
      'test_manager_' + STA_UtilsStatic.USER_NICKNAME
    );
    user1.SMC_Approval_Level__c = 2;
    user1.UserRoleId = userRoleBeId;
    user1.SMC_User_Subsidiary__c = 'SSA';
    insert user1;

    User user2 = SMC_UTIL_TestUtils.createUser(
      'test_submitter_' + STA_UtilsStatic.USER_NICKNAME,
      'test_submitter_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'test_submitter_' + STA_UtilsStatic.USERNAME_TEST,
      'test_submitter_' + STA_UtilsStatic.USER_NICKNAME
    );
    user2.ManagerId = user3.Id;
    user2.SMC_Approval_Level__c = 1;
    user2.DelegatedApproverId = user3.Id;
    user2.UserRoleId = userRoleSalesManagerId;
    user2.SMC_User_Subsidiary__c = 'SSA';
    user2.Bypass_All_Processes_Builder__c = true;
    insert user2;

    //Insert in 2 step because user1 is manager of user2 and we need user1.Id to set user2 manager
    Id psBusinessDevelopperId;
    Id psQuotationToolId;
    List<String> listPsName = new List<String>{STA_UtilsStatic.BUSINESS_DEVELOPPER, 
                                               STA_UtilsStatic.QUOTATION_TOOL_PERMISSION};
    for(PermissionSet ps : [SELECT ID, Name
                            FROM PermissionSet 
                            WHERE Name IN :listPsName]){
      if(ps.Name == STA_UtilsStatic.BUSINESS_DEVELOPPER){
        psBusinessDevelopperId = ps.Id;
      }
      if(ps.Name == STA_UtilsStatic.QUOTATION_TOOL_PERMISSION){
        psQuotationToolId = ps.Id;
      }
    }
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = psBusinessDevelopperId
      ),
      new PermissionSetAssignment(
        AssigneeId = user2.id,
        PermissionSetId = psBusinessDevelopperId
      ),
      new PermissionSetAssignment(
        AssigneeId = user3.id,
        PermissionSetId = psBusinessDevelopperId
      ),
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = psQuotationToolId
      ),
      new PermissionSetAssignment(
        AssigneeId = user2.id,
        PermissionSetId = psQuotationToolId
      ),
      new PermissionSetAssignment(
        AssigneeId = user3.id,
        PermissionSetId = psQuotationToolId
      )
    };

    System.runAs(user2) {
      /** SETUP **/
      PAD.bypassAll = true; //Need to bypass trigger on Account

      Id recordTypeAccCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();

      //Account
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id
      );
      account.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      //Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.OPPORTUNITY_NAME1,
        STA_UtilsStatic.OPEN
      );
      opportunity.AccountId = account.Id;
      opportunity.SMC_Primary_Contact__c = contact.Id;
      opportunity.SMC_Success_Rate_Range__c = '15';
      insert opportunity;

      //Get all RecordTypeId for quote
      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();
      Quote quote = SMC_UTIL_TestUtils.createQuote(
        opportunity.Id,
        STA_UtilsStatic.QUOTE_NAME1,
        account.Id
      );
      quote.OpportunityId = opportunity.Id;
      quote.SMC_Account__c = account.Id;
      quote.SMC_Approval_Status__c = STA_UtilsStatic.STATUS_APPROVAL_PENDING;
      quote.RecordTypeId = quoteProjectId;
      Quote quote2 = SMC_UTIL_TestUtils.createQuote(
        opportunity.Id,
        STA_UtilsStatic.QUOTE_NAME1 + 'Bis',
        account.Id
      );
      quote2.OpportunityId = opportunity.Id;
      quote2.SMC_Account__c = account.Id;
      quote2.SMC_Approval_Status__c = STA_UtilsStatic.STATUS_APPROVAL_PENDING;
      quote2.RecordTypeId = quoteProjectId;
      insert new List<Quote>{ quote, quote2 };

      opportunity.SyncedQuoteId = quote.Id;
      update opportunity;

      PAD.bypassAll = false;
    }

  }

  /**
  * @description : test SMC_AC_Escalation_Process_Components.searchApproval() [Multiple tests]
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testSearchApproval() {
    User user = [SELECT Id FROM User WHERE Name LIKE 'test_submitter_%'];

    System.runAs(user) {
      System.assertNotEquals(
        null,
        SMC_AC_Escalation_Process_Components.searchApproval(
          STA_UtilsStatic.ALL_APPROVAL_LABEL
        ),
        'There is no approval created. Check the process to launch an approval on Quote.'
      );
      System.assertNotEquals(
        null,
        SMC_AC_Escalation_Process_Components.searchApproval(
          STA_UtilsStatic.ITEM_TO_APPROVE_DELEGATED_LABEL
        ),
        'There is no approval created. Check the process to launch an approval on Quote.'
      );
      System.assertEquals(
        null,
        SMC_AC_Escalation_Process_Components.searchApproval(null),
        'The component have validated a bad parameter.'
      );
      System.assertEquals(
        null,
        SMC_AC_Escalation_Process_Components.searchApproval('badString'),
        'The component have validated a bad parameter.'
      );
    }
  }

  /**
  * @description : test SMC_AC_Escalation_Process_Components.getPermission()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetPermssion() {
    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      'wp_' + STA_UtilsStatic.USER_NICKNAME,
      'wp_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'wp_' + STA_UtilsStatic.USERNAME_TEST,
      'wp_' + STA_UtilsStatic.USER_NICKNAME
    );
    user1.SMC_User_Subsidiary__c = STA_UtilsStatic.USER_SUBSIDIARY_ITALY_EXPORT;
    User user2 = SMC_UTIL_TestUtils.createUser(
      'wop_' + STA_UtilsStatic.USER_NICKNAME,
      'wop_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'wop_' + STA_UtilsStatic.USERNAME_TEST,
      'wop_' + STA_UtilsStatic.USER_NICKNAME
    );
    user2.SMC_User_Subsidiary__c = STA_UtilsStatic.USER_SUBSIDIARY_ITALY_EXPORT;
    insert new List<User>{ user1, user2 };

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.BUSINESS_DEVELOPPER
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user1.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user1) {
      System.assert(
        SMC_AC_Escalation_Process_Components.getPermission(),
        'Check user permissions.'
      );
    }

    System.runAs(user2) {
      System.assert(
        !SMC_AC_Escalation_Process_Components.getPermission(),
        'Check user permissions.'
      );
    }
  }

  /**
  * @description : test SMC_AC_Escalation_Process_Components.getAllProcessInstance()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetAllProcessInstance() {
    User user = [SELECT Id FROM User WHERE Name LIKE 'test_submitter_%'];

    System.runAs(user) {
      Test.startTest();
      Quote quote = [
        SELECT Id
        FROM Quote
        WHERE Name = :(STA_UtilsStatic.QUOTE_NAME1)
      ];
      quote.SMC_Approval_Level_Requested__c = 2;
      update quote;

      // Create an approval request for the quote
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for approval.');
      req1.setObjectId(quote.id);
      // Submit on behalf of a specific submitter
      req1.setSubmitterId(user.Id);
      // Submit the record to specific process and skip the criteria evaluation
      req1.setProcessDefinitionNameOrId(
        STA_UtilsStatic.APPROVAL_PROCESS_QUOTE_NAME
      );
      req1.setSkipEntryCriteria(true);
      // Submit the approval request for the quote
      Approval.ProcessResult approvalResult = Approval.process(req1);

      String jsonResult = SMC_AC_Escalation_Process_Components.getAllProcessInstance();
      List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper> result = (List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper>) JSON.deserialize(
        jsonResult,
        List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper>.class
      );
      System.assertEquals(
        1,
        result.size(),
        'There is no approval created. Check the code above this "assert".'
      ); // Two Quote in Setup

      Test.stopTest();
    }
  }

  /**
  * @description : test SMC_AC_Escalation_Process_Components.getProcessInstanceDelegated()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetProcessInstanceDelegated() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Name = :('test_delegated_' + STA_UtilsStatic.USER_NICKNAME)
    ];
    User userS = [
      SELECT Id, Name
      FROM User
      WHERE Name = :('test_submitter_' + STA_UtilsStatic.USER_NICKNAME)
    ];

    System.runAs(user) {
      Test.startTest();
      Quote quote = [
        SELECT Id
        FROM Quote
        WHERE Name = :(STA_UtilsStatic.QUOTE_NAME1 + 'Bis')
      ];
      quote.SMC_Approval_Level_Requested__c = 2;
      update quote;

      // Create an approval request for the quote
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for approval.');
      req1.setObjectId(quote.id);
      // Submit on behalf of a specific submitter
      req1.setSubmitterId(userS.Id);
      // Submit the record to specific process and skip the criteria evaluation
      req1.setProcessDefinitionNameOrId(
        STA_UtilsStatic.APPROVAL_PROCESS_QUOTE_NAME
      );
      req1.setSkipEntryCriteria(true);
      // Submit the approval request for the quote
      Approval.ProcessResult approvalResult = Approval.process(req1);

      String jsonResult = SMC_AC_Escalation_Process_Components.getProcessInstanceDelegated();
      List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper> result = (List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper>) JSON.deserialize(
        jsonResult,
        List<SMC_AC_Escalation_Process_Components.EscalationProcessWrapper>.class
      );
      System.assertEquals(
        1,
        result.size(),
        'There is no approval created. Check the code above this "assert".'
      );
      Test.stopTest();
    }
  }
}