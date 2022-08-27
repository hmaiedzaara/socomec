/*
---------------------------------------------------------------------
-- - Name          : TEST_WS_QuoteProductManagementServiceV1
-- - Author        : David SOBCZAK (DOS) - Vincent RECASENS (VRE)
-- - Description   : Test the WS WS_QuoteProductManagementServiceV1            
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 11-Dec-2017  DOS    1.0     Initial version
-- 12-MAR-2019  VRE    1.0     Add testDeleteOldFile*
--------------------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_WS_QuoteProductManagementServiceV1 {
  /**
  * @description : test setup
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @testSetup
  static void allTheDataForThisTestClass() {

    // Generate users
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.PREFIX_NAME_STANDARD + STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.PREFIX_NAME_STANDARD + STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.PREFIX_NAME_STANDARD + STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.PREFIX_NAME_STANDARD + STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    user.Bypass_All_Processes_Builder__c = true;
    insert user;
    Id userId = user.Id;

    System.runAs(user){
      PAD.bypassAll = true;
      // Generate Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeAccCustomerId = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        userId,
        userId,
        userId,
        userId,
        userId
      );
      insert account;
      Id accId = account.Id;

      // Generate Contacts
      Contact contact1 = SMC_UTIL_TestUtils.createContact(
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
        accId
      );

      List<Contact> contacts = new List<Contact>();
      contacts.add(contact1);
      insert contacts;
      Id conId1 = contacts[0].Id;

      // Generate Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdOpp = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeIdOpp,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert opp;
      Id oppId = opp.Id;

      // Generate Opp Actors
      SMC_Opportunity_Actors__c oa = SMC_UTIL_TestUtils.createOpportunityActors(
        oppId,
        accId,
        conId1,
        true
      );
      insert oa;

      // Generate Quote
      Quote quo = SMC_UTIL_TestUtils.createQuote(
        oppId,
        STA_UtilsStatic.TEST,
        accId
      );
      insert quo;

      // Pricebook Management
      // Instantiate the Pricebook2 record first, setting the Id
      // Workaround to active standard pricebook during test
      Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
      );
      update standardPricebook;

      // Create product
      Product2 prod = new Product2(
        ProductCode = STA_UtilsStatic.TEST,
        Name = STA_UtilsStatic.TEST,
        Family = STA_UtilsStatic.TEST
      );
      insert prod;

      // Create pricebookentry
      Id pricebookId = Test.getStandardPricebookId();
      PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = prod.Id,
        UnitPrice = 1,
        IsActive = true,
        CurrencyIsoCode = STA_UtilsStatic.CURRENCY_EUR
      );
      insert standardPrice;

      PAD.bypassAll = false;
    }
  }

  /**
  * @description : test WS_QuoteProductManagementServiceV1.updateQuoteLineItem()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @IsTest
  public static void updateQuoteLineItem() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :(STA_UtilsStatic.PREFIX_NAME_STANDARD + STA_UtilsStatic.EMAIL_TEST)
    ];

    System.runAs(user){
      // Retrieve information
      Quote quo = [
        SELECT Id
        FROM Quote
        WHERE Name = :STA_UtilsStatic.TEST
        LIMIT 1
      ];

      List<WS_QuoteProductManagementServiceV1.pQuoteLineItem> lQuoLineItem = new List<WS_QuoteProductManagementServiceV1.pQuoteLineItem>();
      WS_QuoteProductManagementServiceV1.pQuoteLineItem pQuoLineItem = new WS_QuoteProductManagementServiceV1.pQuoteLineItem();
      pQuoLineItem.description = STA_UtilsStatic.TEST;
      pQuoLineItem.title = STA_UtilsStatic.TEST;
      pQuoLineItem.id = 1;
      pQuoLineItem.MAX = 1;
      pQuoLineItem.maxApplied = 1;
      pQuoLineItem.MAXSUG = 1;
      pQuoLineItem.MIN = 1;
      pQuoLineItem.minApplied = 1;
      pQuoLineItem.REM = 1;
      pQuoLineItem.weight = 1;
      lQuoLineItem.add(pQuoLineItem);

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();

      req.requestURI = '/services/apexrest/quote/product_management/v1/' + quo.Id;
      req.httpMethod = STA_UtilsStatic.PUT_METHOD;
      RestContext.request = req;
      RestContext.response = res;

      Test.startTest();
      WS_ResponseHandlerV1 results = WS_QuoteProductManagementServiceV1.upsertQuoteLine(
        lQuoLineItem,
        'Doc Last Generated Version'
      );
      //Fail test
      WS_ResponseHandlerV1 resultsFail = WS_QuoteProductManagementServiceV1.upsertQuoteLine(
        null,
        null
      );
      Test.stopTest();

      //TODO add realist test assertion
      System.assertNotEquals(null, results, 'Mock is wrong. Check the setup.');
      System.assertNotEquals(
        null,
        resultsFail,
        'Mock is wrong. Check the setup.'
      );
    }
  }

  /**
  * @description : test WS_QuoteProductManagementServiceV1.deleteOldFile()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void testDeleteOldFile() {
    PAD.bypassAll = true;

    //Set the quote as it needed
    Quote theQuote = [
      SELECT Id, QuoteNumber, SMC_Quote_Doc_Last_Generated_Version__c
      FROM Quote
      LIMIT 1
    ];
    theQuote.SMC_Quote_Doc_Last_Generated_Version__c = '1';
    update theQuote;

    PAD.bypassAll = false;

    //Create one user the set him as owner of one file
    User user = [
      SELECT Id, Name, Email
      FROM User
      WHERE
        Email = :(STA_UtilsStatic.PREFIX_NAME_STANDARD +
        STA_UtilsStatic.EMAIL_TEST)
    ];
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    String goodTitle =
      theQuote.QuoteNumber +
      STA_UtilsStatic.UNDERSCORE +
      theQuote.SMC_Quote_Doc_Last_Generated_Version__c;

    User userAdmin = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SMC_ADMIN
    );
    userAdmin.Bypass_All_Processes_Builder__c = true;
    insert new List<User>{ userAdmin };
    System.runAs(userAdmin) {
      /** CREATE FILES **/
      //File will not be deleted - Owner isn't SOC1
      String contentVersion1Tilte = 'This file will not be deleted - Owner isn\'t SOC1';
      ContentVersion contentVersion1 = new ContentVersion();
      contentVersion1.Title = contentVersion1Tilte;
      contentVersion1.PathOnClient = 'ownerIsntSOC1.txt';
      contentVersion1.VersionData = Blob.valueOf(contentVersion1Tilte);
      contentVersion1.IsMajorVersion = true;
      contentVersion1.FirstPublishLocationId = theQuote.Id;
      contentVersion1.OwnerId = user.Id;

      //File will not be deleted - No EmailMessage link to this file
      String contentVersion2Tilte = 'This file will not be deleted - Not link to an EmailMessage';
      ContentVersion contentVersion2 = new ContentVersion();
      contentVersion2.Title = contentVersion2Tilte;
      contentVersion2.PathOnClient = 'noLinkToAnEmailMEssage.txt';
      contentVersion2.VersionData = Blob.valueOf(contentVersion2Tilte);
      contentVersion2.IsMajorVersion = true;
      contentVersion2.FirstPublishLocationId = theQuote.Id;
      contentVersion2.OwnerId = soc1.UserId__c;

      //File will not be deleted - Title is not as requested
      String contentVersion3Tilte = 'This file will not be deleted - Title is not as requested';
      ContentVersion contentVersion3 = new ContentVersion();
      contentVersion3.Title = contentVersion3Tilte;
      contentVersion3.PathOnClient = 'badTitle.txt';
      contentVersion3.VersionData = Blob.valueOf(contentVersion3Tilte);
      contentVersion3.IsMajorVersion = true;
      contentVersion3.FirstPublishLocationId = theQuote.Id;
      contentVersion3.OwnerId = soc1.UserId__c;

      //File will not be deleted, but restrict to SOC1 and EmailMessage - Link to an EmailMessage,  SOC1 is Owner and title match with the request
      ContentVersion contentVersion4 = new ContentVersion();
      contentVersion4.Title = goodTitle + '_4';
      contentVersion4.PathOnClient = 'historicFile.txt';
      contentVersion4.VersionData = Blob.valueOf(goodTitle);
      contentVersion4.IsMajorVersion = true;
      contentVersion4.FirstPublishLocationId = theQuote.Id;
      contentVersion4.OwnerId = soc1.UserId__c;

      //File will be deleted - SOC1 is Owner and title match with the request
      // ContentVersion contentVersion5 = new ContentVersion();
      // contentVersion5.Title = goodTitle + '_5';
      // contentVersion5.PathOnClient = 'toDeleteFile.txt';
      // contentVersion5.VersionData = Blob.valueOf(goodTitle);
      // contentVersion5.IsMajorVersion = true;
      // contentVersion5.FirstPublishLocationId = theQuote.Id;
      // contentVersion5.OwnerId = soc1.UserId__c;

      // insert new List<ContentVersion>{contentVersion1, contentVersion2, contentVersion3, contentVersion4, contentVersion5};

      List<Database.SaveResult> insertion = Database.insert(
        new List<ContentVersion>{
          contentVersion1,
          contentVersion2,
          contentVersion3,
          contentVersion4
        }
      );

      //Create EmailMessage
      EmailMessage emailMessage = SMC_UTIL_TestUtils.createEmailMessage(
        null,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.TEST,
        user.Name,
        user.Email,
        null,
        UserInfo.getUserEmail()
      );
      emailMessage.RelatedToId = theQuote.Id;
      insert emailMessage;

      //Link ContentDocument and EmailMessage
      contentVersion4 = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion4.Id
      ];
      ContentDocumentLink contentDocumentLink4 = SMC_UTIL_TestUtils.createContentDocumentLink(
        emailMessage.Id,
        contentVersion4.ContentDocumentId,
        STA_UtilsStatic.VIEWER_PERMISSION,
        STA_UtilsStatic.ALL_USERS
      );
      insert contentDocumentLink4;

      //First check on Content 4
      List<ContentDocumentLink> contentDocumentLinks4 = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion4.ContentDocumentId
      ];
      System.assertEquals(
        3,
        contentDocumentLinks4.size(),
        'The number of ContentDocumentLink on ContentVersion4 is more or less than expected.'
      );

      //Test
      Test.startTest();
      WS_QuoteProductManagementServiceV1.WithoutSharingFunctions ws = new WS_QuoteProductManagementServiceV1.WithoutSharingFunctions();
      ws.deleteOldFile(theQuote);

      //Assertions - Content 1
      contentVersion1 = [
        SELECT ContentDocumentId, ContentDocument.Title
        FROM ContentVersion
        WHERE Id = :contentVersion1.Id
      ];

      List<ContentDocumentLink> contentDocumentLinks1 = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion1.ContentDocumentId
      ];
      System.assertEquals(
        2,
        contentDocumentLinks1.size(),
        'The number of ContentDocumentLink on ContentVersion1 is more or less than expected.'
      );
      //Assertions - Content 2
      contentVersion2 = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion2.Id
      ];
      List<ContentDocumentLink> contentDocumentLinks2 = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion2.ContentDocumentId
      ];
      System.assertEquals(
        2,
        contentDocumentLinks2.size(),
        'The number of ContentDocumentLink on ContentVersion2 is more or less than expected.'
      );
      //Assertions - Content 3
      contentVersion3 = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion3.Id
      ];
      List<ContentDocumentLink> contentDocumentLinks3 = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion3.ContentDocumentId
      ];
      System.assertEquals(
        2,
        contentDocumentLinks3.size(),
        'The number of ContentDocumentLink on ContentVersion3 is more or less than expected.'
      );
      //Assertions - Content 4
      contentDocumentLinks4 = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion4.ContentDocumentId
      ];
      System.assertEquals(
        2,
        contentDocumentLinks4.size(),
        'The number of ContentDocumentLink on ContentVersion4 is more or less than expected.'
      );
      Test.stopTest();
      //Assertions - Content 5
      // try{
      //     contentVersion5 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion5.Id];
      //     System.debug(LoggingLevel.INFO, 'CONTENT 5 - FAIL');
      // }
      // catch(Exception e){
      //     System.debug(LoggingLevel.INFO, 'CONTENT 5 - SUCCESS');
      //     System.assert(true);
      // }
      // System.assertEquals(null, [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion5.Id]);
    }
  }
}