/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageContentDocumentLink
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ManageContentDocumentLink
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 29-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageContentDocumentLink {

  @TestSetup
  static void setup(){
    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '1',
      STA_UtilsStatic.EMAIL_TEST + '1',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user1.Bypass_All_Processes_Builder__c = true;
    user1.Bypass_All_Validation_Rules__c = true;
    user1.Bypass_All_Workflow_Rules__c = true;
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      STA_UtilsStatic.EMAIL_TEST + '2',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    user2.Bypass_All_Processes_Builder__c = true;
    user2.Bypass_All_Validation_Rules__c = true;
    user2.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ user1, user2 };

  }
  /**
  * @description : test SMC_AP_ManageContentDocumentLink.updateCaseNewContentDocumentLink()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testUpdateCaseNewContentDocumentLink() {

    User user1 = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];
    User user2 = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '2')];

    Case oneCase;
    ContentVersion contentVersion;

    System.runAs(user1) {
      PAD.bypassAll = true;

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
      insert oneAccount;
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
        '',
        oneAccount.Id
      );
      insert oneContact;
      Case firstCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      firstCase.AccountId = oneAccount.Id;
      firstCase.ContactId = oneContact.Id;
      firstCase.SMC_Take_Ownership__c = true;
      insert firstCase;

      PAD.bypassAll = false;

      oneCase = [
        SELECT Id, Subject, SMC_New_Attachment_Flag__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT1
      ];
      System.assert(
        oneCase.SMC_New_Attachment_Flag__c != true,
        'The case already has a file linked to it. Remove file insertion before this assert.'
      );
    }

    System.runAs(user2) {
      contentVersion = new ContentVersion();
      contentVersion.Title = 'Test';
      contentVersion.PathOnClient = 'Test.txt';
      contentVersion.VersionData = Blob.valueOf('Test Content');
      contentVersion.IsMajorVersion = true;
      contentVersion.FirstPublishLocationId = oneCase.Id;
      contentVersion.OwnerId = user2.Id;
      insert contentVersion;

      contentVersion = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion.Id
        LIMIT 1
      ];
      List<ContentDocumentLink> caseContentDocumentLinks = [
        SELECT Id, ContentDocumentId
        FROM ContentDocumentLink
        WHERE Id = :contentVersion.ContentDocumentId
      ];
    }

    System.runAs(user1) {
      Case oneCaseChecked = [
        SELECT Id, SMC_New_Attachment_Flag__c
        FROM Case
        WHERE Id = :oneCase.Id
      ];
      System.assert(
        oneCaseChecked.SMC_New_Attachment_Flag__c == true,
        'The file is not linked to the case.'
      );
    }
  }

  @isTest
  public static void testDuplicateLinkQuoteToPRMQuote(){

    User user = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

    System.runAs(user) {

      PAD.bypassAll = true;

      //Account
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
      insert oneAccount;

      //Opportunity
      Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                            .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                            .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                             STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                             STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
      insert opp;
      //Quote
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                      STA_UtilsStatic.TEST + 'Share File', 
                                                      oneAccount.Id);
      insert oneQuote;
      //PRM Quote
      SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
      insert prmQuote;

      oneQuote.SMC_PRM_Quote__c = prmQuote.Id;
      update oneQuote;

      PAD.bypassAll = false;

      Test.startTest();
        //File
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins1';
        contentVersion.PathOnClient = 'Penguins1.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.FirstPublishLocationId = oneQuote.Id;
        insert contentVersion;

      Test.stopTest();

      ContentVersion contentVersionChecker = [SELECT Id, 
                                                     Title, 
                                                     ContentDocumentId, 
                                                     SMC_Is_Visible_By_Partner__c, 
                                                     SharingPrivacy
                                              FROM ContentVersion
                                              WHERE Id = :contentVersion.Id];

      System.assertEquals(1, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :prmQuote.Id].size());
    }
  }

  @isTest
  public static void testDuplicateLinkPRMQuoteToQuote(){

    User user = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

    System.runAs(user) {

      PAD.bypassAll = true;

      //Account
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
      insert oneAccount;

      //Opportunity
      Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                            .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                            .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                             STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                             STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
      insert opp;
      //Quote
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                      STA_UtilsStatic.TEST + 'Share File', 
                                                      oneAccount.Id);
      insert oneQuote;
      //PRM Quote
      SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
      insert prmQuote;

      oneQuote.SMC_PRM_Quote__c = prmQuote.Id;
      update oneQuote;

      PAD.bypassAll = false;

      Test.startTest();
        //File
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins1';
        contentVersion.PathOnClient = 'Penguins1.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.FirstPublishLocationId = prmQuote.Id;
        insert contentVersion;

      Test.stopTest();

      ContentVersion contentVersionChecker = [SELECT Id, 
                                                     Title, 
                                                     ContentDocumentId, 
                                                     SMC_Is_Visible_By_Partner__c, 
                                                     SharingPrivacy
                                              FROM ContentVersion
                                              WHERE Id = :contentVersion.Id];

      System.assertEquals(1, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :oneQuote.Id].size());
    }
  }

  @isTest
  public static void testDeletePRMQuoteLink(){

    User user = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

    System.runAs(user) {

      PAD.bypassAll = true;

      //Account
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
      insert oneAccount;

      //Opportunity
      Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                            .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                            .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                             STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                             STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
      insert opp;
      //Quote
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                      STA_UtilsStatic.TEST + 'Share File', 
                                                      oneAccount.Id);
      insert oneQuote;
      //PRM Quote
      SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
      insert prmQuote;

      oneQuote.SMC_PRM_Quote__c = prmQuote.Id;
      update oneQuote;

      PAD.bypassAll = false;

      //File
      ContentVersion contentVersion = new ContentVersion();
      contentVersion.Title = 'Penguins1';
      contentVersion.PathOnClient = 'Penguins1.jpg';
      contentVersion.VersionData = Blob.valueOf('Test Content');
      contentVersion.IsMajorVersion = true;
      contentVersion.FirstPublishLocationId = oneQuote.Id;
      insert contentVersion;

      ContentVersion contentVersionChecker = [SELECT Id, 
                                                     Title, 
                                                     ContentDocumentId, 
                                                     SMC_Is_Visible_By_Partner__c, 
                                                     SharingPrivacy
                                              FROM ContentVersion
                                              WHERE Id = :contentVersion.Id];

      System.assertEquals(1, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :prmQuote.Id].size());

      Test.startTest();
        delete [SELECT Id 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                      LinkedEntityId = :oneQuote.Id];
      Test.stopTest();

      System.assertEquals(0, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :prmQuote.Id].size());
    }
  }

  @isTest
  public static void testDeleteQuoteLink(){

    User user = [SELECT Id FROM USer WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

    System.runAs(user) {

      PAD.bypassAll = true;

      //Account
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
      insert oneAccount;

      //Opportunity
      Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                            .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                            .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                             STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                             STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
      insert opp;
      //Quote
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                      STA_UtilsStatic.TEST + 'Share File', 
                                                      oneAccount.Id);
      insert oneQuote;
      //PRM Quote
      SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
      insert prmQuote;

      oneQuote.SMC_PRM_Quote__c = prmQuote.Id;
      update oneQuote;

      PAD.bypassAll = false;

      //File
      ContentVersion contentVersion = new ContentVersion();
      contentVersion.Title = 'Penguins1';
      contentVersion.PathOnClient = 'Penguins1.jpg';
      contentVersion.VersionData = Blob.valueOf('Test Content');
      contentVersion.IsMajorVersion = true;
      contentVersion.FirstPublishLocationId = prmQuote.Id;
      insert contentVersion;

      ContentVersion contentVersionChecker = [SELECT Id, 
                                                     Title, 
                                                     ContentDocumentId, 
                                                     SMC_Is_Visible_By_Partner__c, 
                                                     SharingPrivacy
                                              FROM ContentVersion
                                              WHERE Id = :contentVersion.Id];

      System.assertEquals(1, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :oneQuote.Id].size());

      Test.startTest();
        delete [SELECT Id 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                      LinkedEntityId = :prmQuote.Id];
      Test.stopTest();

      System.assertEquals(0, [SELECT Id 
                              FROM ContentDocumentLink 
                              WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                    LinkedEntityId = :oneQuote.Id].size());
    }
  }

  // @isTest
  // public static void testFinishedContentVersionInsertion(){

  //     //Set the User
  //     Profile profile = [SELECT Id FROM Profile WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN];
  //     User user1 = SMC_UTIL_TestUtils.createUser(STA_UtilsStatic.TEST_DIESE+'1',STA_UtilsStatic.EMAIL_TEST+'1', profile.Id, STA_UtilsStatic.USERNAME_TEST, STA_UtilsStatic.USER_NICKNAME);
  //     user1.Bypass_All_Processes_Builder__c = true;
  //     user1.Bypass_All_Validation_Rules__c = true;
  //     user1.Bypass_All_Workflow_Rules__c = true;
  //     insert user1;

  //     System.runAs(user1){

  //         PAD.bypassAll = true;

  //         Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
  //         Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
  //         insert oneAccount;
  //         Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1, STA_UtilsStatic.CONTACT_LASTNAME1, STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //         STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //         STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, '', oneAccount.Id);
  //         insert oneContact;
  //         Case firstCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT1, STA_UtilsStatic.CASE_DESCRIPTION1, STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
  //         firstCase.AccountId = oneAccount.Id;
  //         firstCase.ContactId = oneContact.Id;
  //         insert firstCase;

  //         ContentVersion contentVersion = new ContentVersion();
  //         contentVersion.Title = 'Test';
  //         contentVersion.PathOnClient = 'Test.txt';
  //         contentVersion.VersionData = Blob.valueOf('Test Content');
  //         contentVersion.IsMajorVersion = true;
  //         contentVersion.FirstPublishLocationId = firstCase.Id;
  //         contentVersion.OwnerId = user1.Id;
  //         insert contentVersion;

  //         contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
  //         List<ContentDocumentLink> caseContentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId, Visibility FROM ContentDocumentLink WHERE ContentDocumentId = :contentVersion.ContentDocumentId];
  //         System.assertEquals(2, caseContentDocumentLinks.size());

  //         Set<Id> contentDocumentIds = new Set<Id>();
  //         for(ContentDocumentLink oneCDL : caseContentDocumentLinks){
  //             contentDocumentIds.add(oneCDL.ContentDocumentId);
  //             if(oneCDL.LinkedEntityId.getSObjectType() != Schema.User.SObjectType){
  //                 oneCDL.Visibility = STA_UtilsStatic.INTERNAL_USERS;
  //             }
  //         }
  //         update caseContentDocumentLinks;

  //         Test.startTest();

  //             System.assert(SMC_AP_ManageContentDocumentLink.finishContentVersionInsertion(contentDocumentIds));

  //             caseContentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId, Visibility FROM ContentDocumentLink WHERE ContentDocumentId = :contentVersion.ContentDocumentId];

  //             Boolean checkVisibility = false;
  //             for(ContentDocumentLink oneCDL : caseContentDocumentLinks){
  //                 if(oneCDL.LinkedEntityId.getSObjectType() != Schema.User.SObjectType && oneCDL.Visibility == STA_UtilsStatic.ALL_USERS){
  //                     checkVisibility = true;
  //                 }
  //             }
  //             System.assert(checkVisibility);

  //         Test.stopTest();
  //     }
  // }
}