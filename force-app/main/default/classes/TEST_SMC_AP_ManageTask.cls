/**
 * @File Name          : TEST_SMC_AP_ManageTask.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-15-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/03/2019   Guillaume BONNET (Modis)     Initial Version
 **/

@IsTest
public without sharing class TEST_SMC_AP_ManageTask {
  @isTest
  public static void testUpdateClosedReminderTask() {
    //USer
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    insert user;

    System.runAs(user) {
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      oneAccount.BillingCountryCode = STA_UTilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      oneAccount.SMC_Category__c = STA_UTilsStatic.ACCOUNT_CATEGORY1;
      oneAccount.SMC_PCO_Price_List__c = STA_UTilsStatic.ACCOUNT_PRICELIST;
      oneAccount.OwnerId = user.Id;
      insert oneAccount;

      //Contact
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
        oneAccount.Id
      );
      oneContact.OwnerId = user.Id;
      insert oneContact;

      //Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON,
        oneAccount,
        oneContact
      );
      insert opp;

      //Task
      Task theTask = new Task(
        WhatId = opp.Id,
        Type = 'Reminder',
        Status = 'In progress',
        ActivityDate = Date.today().addDays(1)
      );
      insert theTask;

      Test.startTest();
      SMC_AP_ManageTask.updateClosedReminderTask(new List<Opportunity>{ opp });
      Test.stopTest();

      System.assertEquals(
        'Completed',
        [SELECT Id, Status FROM task WHERE Id = :theTask.Id]
        .Status
      );
    }
  }

  @isTest
  public static void testUpdateClosedReminderTaskDMLException() {
    //USer
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];

    Profile profileAdm = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_Validation_Rule__c = 'SMC_DateMandatoryIfReminder';
    user.Bypass_All_Processes_Builder__c = true;

    User userBypassVR = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.PREFIX_NAME_ADMIN + STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.PREFIX_NAME_ADMIN + STA_UtilsStatic.USERNAME_TEST,
      profileAdm.Id,
      STA_UtilsStatic.PREFIX_NAME_ADMIN + STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.PREFIX_NAME_ADMIN + STA_UtilsStatic.USER_NICKNAME
    );
    userBypassVR.Bypass_All_Processes_Builder__c = true;
    userBypassVR.Bypass_All_Validation_Rules__c = true;
    insert new List<User> {user, userBypassVR};

    Opportunity opp;
    System.runAs(user) {
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      oneAccount.BillingCountryCode = STA_UTilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      oneAccount.SMC_Category__c = STA_UTilsStatic.ACCOUNT_CATEGORY1;
      oneAccount.SMC_PCO_Price_List__c = STA_UTilsStatic.ACCOUNT_PRICELIST;
      oneAccount.OwnerId = user.Id;
      insert oneAccount;

      //Contact
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
        oneAccount.Id
      );
      oneContact.OwnerId = user.Id;
      insert oneContact;

      //Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON,
        oneAccount,
        oneContact
      );
      insert opp;

      //Task
      Task theTask = new Task(
        WhatId = opp.Id,
        Type = 'Reminder',
        Status = 'In progress'
      );
      insert theTask;
    }

    System.runAs(userBypassVR){
      user.Bypass_Validation_Rule__c = null;
      update user;
    }

    System.runAs(user) {
      Boolean isSuccess = false;
      try {
        Test.startTest();
        SMC_AP_ManageTask.updateClosedReminderTask(
          new List<Opportunity>{ opp }
        );
        Test.stopTest();
      } catch (DMLException dmlException) {
        isSuccess = true;
      }
      System.assert(isSuccess, 'ERROR : Update is perform.');
    }
  }
}