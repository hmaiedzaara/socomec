/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 04-08-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   12-22-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest(IsParallel = false)
public without sharing class TEST_SMC_AC_WarrantyRegistration {
  @testSetup
  public static void setup() {
    //Admin
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'admin1-' + STA_UtilsStatic.USER_NICKNAME,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      'admin1-' + STA_UtilsStatic.USER_NICKNAME
    );
    userAdmin.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_BAESprotectedField;SMC_PreventLocationWithoutAddress;SMC_Valid_Case_SerialNumber';
    userAdmin.TECH_SMC_PAD_Bypass_All_Trigger__c = true;
    insert userAdmin;
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_ADMIN_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userAdmin.id,
        PermissionSetId = ps.Id
      )
    };

    //Guest
    Profile profileWarrantyGuestUser = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFIL_WARRANTY_REGISTRATION_NAME
    ];
    User userWarrantyRegistration = SMC_UTIL_TestUtils.createUser(
      'wr-' + STA_UtilsStatic.USER_NICKNAME,
      'wr-' + STA_UtilsStatic.USERNAME_TEST,
      profileWarrantyGuestUser.Id,
      'wr-' + STA_UtilsStatic.USERNAME_TEST,
      'wr-' + STA_UtilsStatic.USER_NICKNAME
    );
    userWarrantyRegistration.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_BAESprotectedField;SMC_PreventLocationWithoutAddress';
    insert userWarrantyRegistration;
  }

  @isTest
  public static void testGetStaticInformations() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperStaticInfos result = SMC_AC_WarrantyRegistration.getStaticInformations();
      Test.stopTest();
      System.assertNotEquals(
        null,
        result,
        'The guest user can not access to the Account.Country picklist definition.'
      );
    }
  }

  @isTest
  public static void testGetStates() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperStaticInfos result = SMC_AC_WarrantyRegistration.getStates();
      Test.stopTest();
      System.assertNotEquals(
        null,
        result.statesDepenciesAndValues,
        'The guest user can not access to the Account.State picklist definition.'
      );
    }
  }

  // @isTest
  // public static void testManageAttachmentConversion() {
  //   User adminUser = [
  //     SELECT Id
  //     FROM User
  //     WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];
  //   // User guestUser = [
  //   //   SELECT Id
  //   //   FROM User
  //   //   WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
  //   // ];
  //   SMC_AC_WarrantyRegistration.WrapperInformation returnObject;
  //   Test.startTest();
  //     System.runAs(adminUser) {
  //       Case newCase = new Case(
  //         Subject = 'Temporary Case',
  //         OwnerId = UserInfo.getUserId(),
  //         Origin = 'Customer Community',
  //         Type = 'SMC_Warranty_Claims',
  //         Status = 'Open',
  //         SMC_Sub_Status__c = 'Open'
  //       );
  //       PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
  //       insert newCase;
  //       PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
        
  //       Attachment attach=new Attachment();   	
  //       attach.Name = 'Unit Test Attachment';
  //       attach.ContentType = '.txt';
  //       attach.IsPrivate = false;
  //       attach.body = Blob.valueOf('Unit Test Attachment Body');
  //       attach.parentId = newCase.Id;
  //       attach.OwnerId = adminUser.Id;
  //       insert attach;
    
  //       returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
  //       returnObject.attachmentId = attach.Id;
  //       returnObject.theCase = newCase;
  //       returnObject = SMC_AC_WarrantyRegistration.manageAttachmentConversion(returnObject);
  //     }
  //   Test.stopTest();

  //   System.assertNotEquals(
  //     null,
  //     returnObject.contentDocumentId,
  //     'The document is not retrieved.'
  //   );
  // }

  @isTest
  public static void testManageAccountNull_WithMainActivityAndYourOrganization() {
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    SMC_AC_WarrantyRegistration.WrapperInformation returnObject;
    Test.startTest();
      System.runAs(adminUser) {
        //Technical user
        SF_Technical_User__mdt soc1 = [
          SELECT UserId__c
          FROM SF_Technical_User__mdt
          WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
        ];
        returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
        returnObject.subsidiary = 'SAM';
        returnObject.countrycode = 'US';
        returnObject.soc1Id = soc1.UserId__c;
        returnObject = SMC_AC_WarrantyRegistration.manageAccount(returnObject,
                                                                 STA_UtilsStatic.ACCOUNT_NAME1, 
                                                                 STA_UtilsStatic.CONTACT_MAILINGCITY1, 
                                                                 STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, 
                                                                 STA_UtilsStatic.CONTACT_MAILINGSTREET1, 
                                                                 STA_UtilsStatic.CONTACT_MAILINGSTATE1, 
                                                                 'Maintenance Services Provider', 
                                                                 'YourOrganization');
      }
    Test.stopTest();

    System.assertNotEquals(
      null,
      returnObject.theAccount,
      'Account is not managed.'
    );
  }

  @isTest
  public static void testManageContact_Exist(){
    //Guest
    // User guestUser = [
    //   SELECT Id
    //   FROM User
    //   WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    // ];
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    System.runAs(adminUser) {
      //Set account
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.OwnerId = soc1.UserId__c;
      insert account;
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
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.contactIsDuplicate = false;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.manageContact(sendObject, STA_UtilsStatic.CONTACT_FIRSTNAME1, STA_UtilsStatic.CONTACT_LASTNAME1, STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MOBILEPHONE1, 'CEO', true);
      Test.stopTest();
      System.assert(returnObject.contactIsDuplicate, 'Contact is not inserted.');
    }
  }

  @isTest
  public static void testBuildEmail() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(guestUser) {
      Test.startTest();
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message = SMC_AC_WarrantyRegistration.buildEmailBody('ContactName', false, false, true, message);
      Test.stopTest();
      System.assertNotEquals(
        null,
        message.getHtmlBody(),
        'The guest user can not access to the Account.State picklist definition.'
      );
    }
  }

  @isTest
  public static void testSendEmail() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(guestUser) {
      Test.startTest();
      try{
        SMC_AC_WarrantyRegistration.sendEmail(false, false, true, 'contactName', 'fake@fake.com');
        System.assert(true);
      }
      catch(Exception e){
        System.assert(false);
      }
      Test.stopTest();
      System.assert(true);
    }
  }

  @isTest
  public static void testSaveRequestGuest() {
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    String countrycode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1;
    String serialNumber = 'AssetSerialNumberTest';
    String purchasedDate = '2020-01-01';
    Date purchasedDateConverted = Date.valueOf(purchasedDate);
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Queue
    Group franceOSL = [
      SELECT Id, Name, Type
      FROM Group
      WHERE
        Type = :STA_UtilsStatic.QUEUE
        AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
    ];
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
    ]
    .Id;
    Account accountQueue = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT + '_GroupQueue',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    accountQueue.SMC_Queue_ID__c = franceOSL.Id;
    accountQueue.OwnerId = userAdmin.Id;
    insert new List<Account>{ accountQueue };

    Test.startTest();
      System.runAs(guestUser) {
        SMC_AC_WarrantyRegistration.ResultInformation result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          STA_UtilsStatic.CONTACT_FIRSTNAME1,
          STA_UtilsStatic.CONTACT_LASTNAME1,
          STA_UtilsStatic.CONTACT_EMAIL1,
          STA_UtilsStatic.CONTACT_MOBILEPHONE1,
          'Mr.',
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          STA_UtilsStatic.CONTACT_MAILINGSTATE1,
          null,
          null,
          STA_UtilsStatic.ACCOUNT_NAME1,
          'USA',
          'AssetSerialNumberTest',
          'productDescription',
          '2020-01-01',
          null,
          null,
          true,
          true
        );
        System.assert(result.isNotInError, 'There is an error during the save');
      }
    Test.stopTest();

    System.runAs(userAdmin) {
      Account checkAccount;
      Contact checkContact;
      Asset checkAsset;
      Case checkCase;
      try {
        checkAccount = [
          SELECT Id
          FROM Account
          WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
        ];
        checkContact = [
          SELECT Id, AccountId
          FROM Contact
          WHERE
            Name = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 +
            ' ' +
            STA_UtilsStatic.CONTACT_LASTNAME1)
        ];
        checkAsset = [
          SELECT Id, LocationId, InstallDate, SMC_Asset_Warranty_End_Date__c
          FROM Asset
          WHERE Name = :serialNumber
        ];
        checkCase = [
          SELECT Id, AccountId, ContactId, AssetId, Status, SMC_Sub_Status__c
          FROM Case
          WHERE Subject = :('WARRANTY REGISTRATION [' + serialNumber + ']')
        ];
      } catch (Exception e) {
        System.assert(false, 'One of record is not retrieved.');
      }

      //Account
      System.assertNotEquals(null, checkAccount);
      //Contact
      System.assertNotEquals(null, checkContact);
      System.assertNotEquals(null, checkContact.AccountId);
      //Asset
      System.assertNotEquals(null, checkAsset);
      System.assertNotEquals(null, checkAsset.LocationId);
      System.assertEquals(purchasedDateConverted, checkAsset.InstallDate);
      System.assertEquals(
        purchasedDateConverted.addYears(1),
        checkAsset.SMC_Asset_Warranty_End_Date__c
      );
      //Case
      System.assertNotEquals(null, checkCase);
      System.assertNotEquals(null, checkCase.AccountId);
      System.assertNotEquals(null, checkCase.ContactId);
      System.assertNotEquals(null, checkCase.AssetId);
      // System.assertEquals('Closed', checkCase.Status);
      // System.assertEquals('Closed', checkCase.SMC_Sub_Status__c);
    }
  }

  @isTest
  public static void testSaveRequestContactDuplicate() {
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    String countrycode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1;
    String serialNumber = 'AssetSerialNumberTest';
    String purchasedDate = '2020-01-01';
    Date purchasedDateConverted = Date.valueOf(purchasedDate);
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Queue
    Group franceOSL = [
      SELECT Id, Name, Type
      FROM Group
      WHERE
        Type = :STA_UtilsStatic.QUEUE
        AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
    ];
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
    ]
    .Id;
    Account accountQueue = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT + '_GroupQueue',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    accountQueue.SMC_Queue_ID__c = franceOSL.Id;
    accountQueue.OwnerId = userAdmin.Id;

    //Account duplicate
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account theAccount = new Account(
      Id = null,
      Name = STA_UtilsStatic.ACCOUNT_NAME1,
      SMC_Account_Subsidiaries__c = null,
      SMC_Category__c = 'U',
      BillingCountryCode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      BillingState = null,
      BillingStreet = null,
      BillingPostalCode = null,
      BillingCity = null,
      RecordTypeId = recordTypeIdAcc,
      AccountSource = STA_UtilsStatic.ACCOUNT_SOURCE_WARRANTY_REGISTRATION,
      SMC_Main_Activity__c = null,
      SMC_Your_Organization__c = null
    );
    insert new List<Account>{ accountQueue, theAccount };

    //Contact duplicate
    Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
    recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdCtc = recordTypesContact.get(
        STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
      )
      .getRecordTypeId();
    Contact theContact = new Contact(
      Id = null,
      RecordTypeId = recordTypeIdCtc,
      FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME1,
      LastName = STA_UtilsStatic.CONTACT_LASTNAME1,
      Email = STA_UtilsStatic.CONTACT_EMAIL1,
      MobilePhone = STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      AccountId = theAccount.Id,
      SMC_Job_title__c = null,
      SMC_Warranty_Reg_Newsletter__c = false
    );

    Test.startTest();
    System.runAs(guestUser) {
        SMC_AC_WarrantyRegistration.ResultInformation result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          STA_UtilsStatic.CONTACT_FIRSTNAME1,
          STA_UtilsStatic.CONTACT_LASTNAME1,
          STA_UtilsStatic.CONTACT_EMAIL1,
          STA_UtilsStatic.CONTACT_MOBILEPHONE1,
          'Mr.',
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          STA_UtilsStatic.CONTACT_MAILINGSTATE1,
          null,
          null,
          STA_UtilsStatic.ACCOUNT_NAME1,
          'USA',
          'AssetSerialNumberTest',
          'productDescription',
          '2020-01-01',
          null,
          null,
          true,
          true
        );
        System.assert(result.isNotInError, 'There is an error during the save');
      }
      Test.stopTest();

    System.runAs(userAdmin) {
      Account checkAccount;
      Contact checkContact;
      Asset checkAsset;
      Case checkCase;
      try {
        checkAccount = [
          SELECT Id
          FROM Account
          WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
        ];
        checkContact = [
          SELECT Id, AccountId
          FROM Contact
          WHERE
            Name = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 +
            ' ' +
            STA_UtilsStatic.CONTACT_LASTNAME1)
        ];
        checkAsset = [
          SELECT Id, LocationId, InstallDate, SMC_Asset_Warranty_End_Date__c
          FROM Asset
          WHERE Name = :serialNumber
        ];
        checkCase = [
          SELECT Id, AccountId, ContactId, AssetId, Status, SMC_Sub_Status__c
          FROM Case
          WHERE Subject = :('WARRANTY REGISTRATION [' + serialNumber + ']')
        ];
      } catch (Exception e) {
        System.assert(false, 'One of record is not retrieved.');
      }

      //Account
      System.assertNotEquals(null, checkAccount);
      //Contact
      System.assertNotEquals(null, checkContact);
      System.assertNotEquals(null, checkContact.AccountId);
      //Asset
      System.assertNotEquals(null, checkAsset);
      System.assertNotEquals(null, checkAsset.LocationId);
      System.assertEquals(purchasedDateConverted, checkAsset.InstallDate);
      System.assertEquals(
        purchasedDateConverted.addYears(1),
        checkAsset.SMC_Asset_Warranty_End_Date__c
      );
      //Case
      System.assertNotEquals(null, checkCase);
      System.assertNotEquals(null, checkCase.AccountId);
      System.assertNotEquals(null, checkCase.ContactId);
      System.assertNotEquals(null, checkCase.AssetId);
      // System.assertEquals('Closed', checkCase.Status);
      // System.assertEquals('Closed', checkCase.SMC_Sub_Status__c);
    }
  }

  @isTest
  public static void testSaveRequestContactAndAssetDuplicate() {
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    String countrycode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1;
    String serialNumber = 'AssetSerialNumberTest';
    // String purchasedDate = '2020-01-01';
    // Date purchasedDateConverted = Date.valueOf(purchasedDate);
    Date purchasedDate = Date.today();    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Queue
    Group franceOSL = [
      SELECT Id, Name, Type
      FROM Group
      WHERE
        Type = :STA_UtilsStatic.QUEUE
        AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
    ];
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
    ]
    .Id;
    Account accountQueue = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT + '_GroupQueue',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    accountQueue.SMC_Queue_ID__c = franceOSL.Id;
    accountQueue.OwnerId = userAdmin.Id;

    //Account duplicate
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account theAccount = new Account(
      Id = null,
      Name = STA_UtilsStatic.ACCOUNT_NAME1,
      SMC_Account_Subsidiaries__c = null,
      SMC_Category__c = 'U',
      BillingCountryCode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      BillingState = null,
      BillingStreet = null,
      BillingPostalCode = null,
      BillingCity = null,
      RecordTypeId = recordTypeIdAcc,
      AccountSource = STA_UtilsStatic.ACCOUNT_SOURCE_WARRANTY_REGISTRATION,
      SMC_Main_Activity__c = null,
      SMC_Your_Organization__c = null
    );
    insert new List<Account>{ accountQueue, theAccount };

    //Contact duplicate
    Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
    recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdCtc = recordTypesContact.get(
        STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
      )
      .getRecordTypeId();
    Contact theContact = new Contact(
      Id = null,
      RecordTypeId = recordTypeIdCtc,
      FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME1,
      LastName = STA_UtilsStatic.CONTACT_LASTNAME1,
      Email = STA_UtilsStatic.CONTACT_EMAIL1,
      MobilePhone = STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      AccountId = theAccount.Id,
      SMC_Job_title__c = null,
      SMC_Warranty_Reg_Newsletter__c = false,
      OwnerId = guestUser.Id
    );

    //Asset duplicate
    Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET
      )
      .getRecordTypeId();
    Asset theAsset = SMC_UTIL_TestUtils.createAsset(
      assetRecordTypeId,
      null,
      theAccount.Id,
      theContact.Id,
      'AssetSerialNumberTest',
      null,
      null,
      'AssetSerialNumberTest'
    );
    theAsset.InstallDate = Date.today();
    theAsset.SMC_Asset_Warranty_End_Date__c = Date.today().addYears(1);
    theAsset.OwnerId = guestUser.Id;
    insert new List<Asset>{ theAsset };

    Test.startTest();
    System.runAs(guestUser) {
        SMC_AC_WarrantyRegistration.ResultInformation result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          STA_UtilsStatic.CONTACT_FIRSTNAME1,
          STA_UtilsStatic.CONTACT_LASTNAME1,
          STA_UtilsStatic.CONTACT_EMAIL1,
          STA_UtilsStatic.CONTACT_MOBILEPHONE1,
          'Mr.',
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          STA_UtilsStatic.CONTACT_MAILINGSTATE1,
          null,
          null,
          STA_UtilsStatic.ACCOUNT_NAME1,
          'USA',
          'AssetSerialNumberTest',
          'productDescription',
          '2021-01-01',
          null,
          null,
          true,
          true
        );
        System.assert(result.isNotInError, 'There is an error during the save');
      }
      Test.stopTest();

    System.runAs(userAdmin) {
      Account checkAccount;
      Contact checkContact;
      Asset checkAsset;
      Case checkCase;
      try {
        checkAccount = [
          SELECT Id
          FROM Account
          WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
        ];
        checkContact = [
          SELECT Id, AccountId
          FROM Contact
          WHERE
            Name = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 +
            ' ' +
            STA_UtilsStatic.CONTACT_LASTNAME1)
        ];
        checkAsset = [
          SELECT Id, LocationId, InstallDate, SMC_Asset_Warranty_End_Date__c
          FROM Asset
          WHERE Name = :serialNumber
        ];
        checkCase = [
          SELECT Id, AccountId, ContactId, AssetId, Status, SMC_Sub_Status__c
          FROM Case
          WHERE Subject = :('WARRANTY REGISTRATION [' + serialNumber + ']')
        ];
      } catch (Exception e) {
        System.assert(false, 'One of record is not retrieved.');
      }

      //Account
      System.assertNotEquals(null, checkAccount);
      //Contact
      System.assertNotEquals(null, checkContact);
      System.assertNotEquals(null, checkContact.AccountId);
      //Asset
      System.assertNotEquals(null, checkAsset);
      System.assertNotEquals(null, checkAsset.LocationId);
      System.assertEquals(purchasedDate, checkAsset.InstallDate);
      System.assertEquals(
        purchasedDate.addYears(1),
        checkAsset.SMC_Asset_Warranty_End_Date__c
      );
      //Case
      System.assertNotEquals(null, checkCase);
      System.assertNotEquals(null, checkCase.AccountId);
      System.assertNotEquals(null, checkCase.ContactId);
      System.assertNotEquals(null, checkCase.AssetId);
      // System.assertEquals('Closed', checkCase.Status);
      // System.assertEquals('Closed', checkCase.SMC_Sub_Status__c);
    }
  }

  @isTest
  public static void testSaveRequestBADAccount() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    SMC_AC_WarrantyRegistration.ResultInformation result;
    System.runAs(guestUser) {
      try {
        Test.startTest();
        result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          '2020-01-01',
          null,
          null,
          null,
          null
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Account insertion error is catched.');
      }
      System.assert(
        !result.isNotInError,
        'Account insertion error is not catched.'
      );
    }
  }

  @isTest
  public static void testSaveRequestBADContact() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    SMC_AC_WarrantyRegistration.ResultInformation result;
    System.runAs(guestUser) {
      try {
        Test.startTest();
        result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          null,
          null,
          null,
          null,
          null,
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          null,
          '',
          '',
          STA_UtilsStatic.ACCOUNT_NAME1,
          'USA',
          'AssetSerialNumberTest',
          'productDescription',
          '2020-01-01',
          null,
          null,
          true,
          true
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Contact insertion error is catched.');
      }
      System.assert(
        !result.isNotInError,
        'Contact insertion error is not catched.'
      );
    }
  }

  /*Faut créer un Account afin de bypasser le try/catch sur Account*/
  // @isTest
  // public static void testSaveRequestBADLocationAndAddress() {
  //   User guestUser = [
  //     SELECT Id
  //     FROM User
  //     WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];
  //   String countrycode = STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1;
  //   String serialNumber = 'AssetSerialNumberTest';
  //   String purchasedDate = '2020-01-01';
  //   Date purchasedDateConverted = Date.valueOf(purchasedDate);
  //   SMC_AC_WarrantyRegistration.ResultInformation result;

  //   //Account init
  //   Id recordTypeId = [
  //       SELECT Id
  //       FROM RecordType
  //       WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
  //       LIMIT 1
  //     ]
  //     .get(0)
  //     .Id;
  //   Account account = SMC_UTIL_TestUtils.createAccount(
  //     recordTypeId,
  //     STA_UtilsStatic.ACCOUNT_NAME1,
  //     STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //     STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
  //   );
  //   account.SMC_Account_External_Id__c = STA_UtilsStatic.TEST + 'ssssss';
  //   insert account;

  //   System.runAs(guestUser) {
  //     try {
  //       Test.startTest();
  //       result = SMC_AC_WarrantyRegistration.saveRequest(
  //         false,
  //         STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //         STA_UtilsStatic.CONTACT_LASTNAME1,
  //         STA_UtilsStatic.CONTACT_EMAIL1,
  //         STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //         'Mr.',
  //         null,
  //         null,
  //         null,
  //         null,
  //         null,
  //         null,
  //         null,
  //         null,
  //         STA_UtilsStatic.ACCOUNT_NAME1,
  //         'USA',
  //         'AssetSerialNumberTest',
  //         'productDescription',
  //         '2020-01-01',
  //         null,
  //         null,
  //         true,
  //         true
  //       );
  //       Test.stopTest();
  //     } catch (Exception e) {
  //       System.debug('Contact insertion error is catched.');
  //     }
  //     System.assert(
  //       !result.isNotInError,
  //       'Contact insertion error is not catched.'
  //     );
  //   }
  // }

  @isTest
  public static void testSaveRequestBADAsset() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    SMC_AC_WarrantyRegistration.ResultInformation result;
    System.runAs(guestUser) {
      try {
        Test.startTest();
        result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          null,
          null,
          STA_UtilsStatic.CONTACT_EMAIL1,
          STA_UtilsStatic.CONTACT_MOBILEPHONE1,
          'Mr.',
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          'fakeState',
          null,
          null,
          null,
          null,
          null,
          null,
          '2020-01-01',
          null,
          null,
          true,
          true
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Contact insertion error is catched.');
      }
      System.assert(
        !result.isNotInError,
        'Contact insertion error is not catched.'
      );
    }
  }

  @isTest
  public static void testSaveRequestBADCase() {
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    SMC_AC_WarrantyRegistration.ResultInformation result;
    System.runAs(guestUser) {
      try {
        Test.startTest();
        result = SMC_AC_WarrantyRegistration.saveRequest(
          false,
          null,
          null,
          STA_UtilsStatic.CONTACT_EMAIL1,
          STA_UtilsStatic.CONTACT_MOBILEPHONE1,
          'Mr.',
          STA_UtilsStatic.ACCOUNT_NAME1,
          STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
          STA_UtilsStatic.CONTACT_MAILINGSTREET1,
          STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
          STA_UtilsStatic.CONTACT_MAILINGCITY1,
          'fakeState',
          null,
          null,
          STA_UtilsStatic.ACCOUNT_NAME1,
          'USA',
          'AssetSerialNumberTest',
          'productDescription',
          '2020-01-01',
          null,
          null,
          true,
          true
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Contact insertion error is catched.');
      }
      System.assert(
        !result.isNotInError,
        'Contact insertion error is not catched.'
      );
    }
  }

  @isTest
  public static void testInsertAccount(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];

    //Set account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertAccount(sendObject);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theAccount, 'Account is not inserted.');
    }
  }

  @isTest
  public static void testInsertAccount_Update(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Set account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertAccount(sendObject);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theAccount, 'Account is not updated.');
    }
  }

  @isTest
  public static void testInsertContact(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Set account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
      null
    );
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.contactIsDuplicate = false;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertContact(sendObject, false, null);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theContact.AccountId, 'Contact is not inserted.');
    }
  }

  @isTest
  public static void testInsertContact_Update(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.OwnerId = soc1.UserId__c;
      insert account;
    Contact contact = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1, //null, 
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, //null, 
      STA_UtilsStatic.CONTACT_MAILINGCITY1, //null, 
      STA_UtilsStatic.CONTACT_MAILINGSTATE1, //null, 
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, //null, 
      STA_UtilsStatic.CONTACT_OTHERCITY1,
      account.Id
    );
    contact.SMC_Job_title__c = null;
    contact.SMC_Sync_With_Address_Account__c = false;
    insert contact;
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.contactIsDuplicate = true;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertContact(sendObject, true, 'CEO');
      Test.stopTest();
      System.assert(returnObject.theContact.SMC_Warranty_Reg_Newsletter__c, 'Contact is not updated (Newletter).');
      System.assertEquals('CEO', returnObject.theContact.SMC_Job_title__c, 'Contact is not updated (JobTitle).');
    }
  }

  @isTest
  public static void testInsertLocationAndAddress(){
    System.debug('albator testInsertLocationAndAddress');
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Account account;
    //USER ADMIN
    System.runas(userAdmin){
      //Get record type id
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.OwnerId = soc1.UserId__c;
      insert account;
      // //Location
      // theLocation = new Schema.Location();
      // theLocation.Name = 'Location for warranty Asset SerialNumber';
      // theLocation.SMC_Service_Territory__c = worldST.Id;
      // theLocation.OwnerId = soc1.UserId__c;
      // theLocation.LocationType = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      // //Address
      // theAddress = new Schema.Address();
      // theAddress.Description = 'Address for Warranty Asset SerialNumber';
      // theAddress.CountryCode = 'US';
      // theAddress.City = STA_UtilsStatic.CONTACT_MAILINGCITY1;
      // theAddress.Street = STA_UtilsStatic.CONTACT_MAILINGSTREET1;
      // theAddress.PostalCode = STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1;
      // theAddress.State = STA_UtilsStatic.CONTACT_MAILINGSTATE1;
      // theAddress.LocationType = 'Site';
      // theAddress.ParentId = theLocation.Id;
    }

    //USER GUEST
    Test.startTest();
      System.runAs(guestUser) {

        // OperatingHours oh;
        // ServiceTerritory worldST;
        Schema.Location theLocation;
        Schema.Address theAddress;

        //Location
        theLocation = new Schema.Location();
        theLocation.Name = 'Location for warranty Asset SerialNumber';
        // theLocation.SMC_Service_Territory__c = worldST.Id;
        theLocation.OwnerId = soc1.UserId__c;
        theLocation.LocationType = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
        //Address
        theAddress = new Schema.Address();
        theAddress.Description = 'Address for Warranty Asset SerialNumber';
        theAddress.CountryCode = 'US';
        theAddress.City = STA_UtilsStatic.CONTACT_MAILINGCITY1;
        theAddress.Street = STA_UtilsStatic.CONTACT_MAILINGSTREET1;
        theAddress.PostalCode = STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1;
        theAddress.State = STA_UtilsStatic.CONTACT_MAILINGSTATE1;
        theAddress.LocationType = 'Site';
        theAddress.ParentId = theLocation.Id;

        SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
        sendObject.assetIsDuplicate = false;
        // sendObject.thServiceTerritory = worldST;
        sendObject.theLocation = theLocation;
        sendObject.theAddress = theAddress;
        sendObject.theAccount = account;
        SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertLocationAndAddress(sendObject);

        System.assertNotEquals(null, returnObject.theLocation.SMC_Address__c, 'Location is not updated with new address.');
      }
    Test.stopTest();
  }

  @isTest
  public static void testInsertAsset(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    
    //Setup
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    OperatingHours oh;
    ServiceTerritory worldST;
    Schema.Location theLocation;
    Schema.Address theAddress;
    Asset theAsset;
    System.runas(userAdmin){
      // //Location
      theLocation = new Schema.Location();
      theLocation.Name =
        'Location for warranty Asset SerialNumber';
      // theLocation.SMC_Service_Territory__c = worldST.Id;
      theLocation.OwnerId = soc1.UserId__c;
      insert theLocation;
      
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAss = recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      theAsset = new Asset(
        Id = null,
        AccountId = account.Id,
        ContactId = contact.Id,
        RecordTypeId = recordTypeIdAss,
        Name = 'SerialNumber',
        SerialNumber = 'SerialNumber',
        Status = 'Active',
        SMC_Warranty_Status__c = 'Not Validated',
        InstallDate = Date.today(),
        PurchaseDate = Date.today(),
        SMC_Shipping_date__c = Date.today(),
        SMC_CommissioningDate__c = Date.today(),
        SMC_Asset_Warranty_End_Date__c = Date.today().addYears(1),
        LocationId = null,
        Product2Id = null,
        SMC_Purchased_from_company__c = 'Company 1',
        SMC_Purchased_from_country__c = 'USA',
        OwnerId = soc1.UserId__c
      );
    }
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.assetIsDuplicate = false;
      sendObject.assetExist = false;
      // sendObject.thServiceTerritory = worldST;
      sendObject.theLocation = theLocation;
      // sendObject.theAddress = theAddress;
      sendObject.theAsset = theAsset;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertAsset(sendObject);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theAsset, 'Asset is not inserted.');
    }
  }

  @isTest
  public static void testInsertAsset_Update(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    
    //Setup
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    OperatingHours oh;
    ServiceTerritory worldST;
    Schema.Location theLocation;
    Schema.Address theAddress;
    Asset theAsset;
    System.runas(userAdmin){
      //Location
      theLocation = new Schema.Location();
      theLocation.Name =
        'Location for warranty Asset SerialNumber';
      // theLocation.SMC_Service_Territory__c = worldST.Id;
      theLocation.OwnerId = soc1.UserId__c;
      insert theLocation;
      
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAss = recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      theAsset = new Asset(
        Id = null,
        AccountId = account.Id,
        ContactId = contact.Id,
        RecordTypeId = recordTypeIdAss,
        Name = 'SerialNumber',
        SerialNumber = 'SerialNumber',
        Status = 'Active',
        SMC_Warranty_Status__c = 'Not Validated',
        InstallDate = Date.today(),
        PurchaseDate = Date.today(),
        SMC_Shipping_date__c = Date.today(),
        SMC_CommissioningDate__c = Date.today(),
        SMC_Asset_Warranty_End_Date__c = Date.today().addYears(1),
        LocationId = null,
        Product2Id = null,
        SMC_Purchased_from_company__c = 'Company 1',
        SMC_Purchased_from_country__c = 'USA',
        OwnerId = soc1.UserId__c
      );
      insert theAsset;
    }
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.assetIsDuplicate = false;
      sendObject.assetExist = true;
      // sendObject.thServiceTerritory = worldST;
      sendObject.theLocation = theLocation;
      sendObject.theAddress = theAddress;
      sendObject.theAsset = theAsset;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = SMC_AC_WarrantyRegistration.insertAsset(sendObject);
      Test.stopTest();
      System.assertEquals('Not Validated', returnObject.theAsset.SMC_Warranty_Status__c, 'Asset is not updated.');
    }
  }

  @isTest
  public static void testInsertCase(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    
    //Setup
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    OperatingHours oh;
    ServiceTerritory worldST;
    Schema.Location theLocation;
    Schema.Address theAddress;
    Asset theAsset;
    System.runas(userAdmin){

      // //Location
      theLocation = new Schema.Location();
      theLocation.Name =
        'Location for warranty Asset SerialNumber';
      // theLocation.SMC_Service_Territory__c = worldST.Id;
      theLocation.OwnerId = soc1.UserId__c;
      insert theLocation;
      
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAss = recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      theAsset = new Asset(
        Id = null,
        AccountId = account.Id,
        ContactId = contact.Id,
        RecordTypeId = recordTypeIdAss,
        Name = 'SerialNumber',
        SerialNumber = 'SerialNumber',
        Status = 'Active',
        SMC_Warranty_Status__c = 'Not Validated',
        InstallDate = Date.today(),
        PurchaseDate = Date.today(),
        SMC_Shipping_date__c = Date.today(),
        SMC_CommissioningDate__c = Date.today(),
        SMC_Asset_Warranty_End_Date__c = Date.today().addYears(1),
        LocationId = null,
        Product2Id = null,
        SMC_Purchased_from_company__c = 'Company 1',
        SMC_Purchased_from_country__c = 'USA',
        OwnerId = soc1.UserId__c
      );
      insert theAsset;
    }

    Case theCase = new Case(
      Id = null,
      AccountId = account.Id,
      ContactId = contact.Id,
      Subject = 'WARRANTY REGISTRATION [SerialNumber]',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = 'Product description',
      SMC_Serial_Number__c = 'SerialNumber',
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [SerialNumber]',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null
    );
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.assetIsDuplicate = false;
      sendObject.assetExist = true;
      // sendObject.thServiceTerritory = worldST;
      sendObject.theLocation = theLocation;
      // sendObject.theAddress = theAddress;
      sendObject.theAsset = theAsset;
      sendObject.theCase = theCase;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      returnObject.theCase = SMC_AC_WarrantyRegistration.insertCase(sendObject, theCase);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theCase.Id, 'Case is not inserted.');
    }
  }

  @isTest
  public static void testInsertCase_Update(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    
    //Setup
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    OperatingHours oh;
    ServiceTerritory worldST;
    Schema.Location theLocation;
    Schema.Address theAddress;
    Asset theAsset;
    System.runas(userAdmin){
      // //Location
      theLocation = new Schema.Location();
      theLocation.Name =
        'Location for warranty Asset SerialNumber';
      // theLocation.SMC_Service_Territory__c = worldST.Id;
      theLocation.OwnerId = soc1.UserId__c;
      insert theLocation;
      
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAss = recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      theAsset = new Asset(
        Id = null,
        AccountId = account.Id,
        ContactId = contact.Id,
        RecordTypeId = recordTypeIdAss,
        Name = 'SerialNumber',
        SerialNumber = 'SerialNumber',
        Status = 'Active',
        SMC_Warranty_Status__c = 'Not Validated',
        InstallDate = Date.today(),
        PurchaseDate = Date.today(),
        SMC_Shipping_date__c = Date.today(),
        SMC_CommissioningDate__c = Date.today(),
        SMC_Asset_Warranty_End_Date__c = Date.today().addYears(1),
        LocationId = null,
        Product2Id = null,
        SMC_Purchased_from_company__c = 'Company 1',
        SMC_Purchased_from_country__c = 'USA',
        OwnerId = soc1.UserId__c
      );
      insert theAsset;
    }

    Case theCase = new Case(
      Id = null,
      AccountId = account.Id,
      ContactId = contact.Id,
      Subject = 'WARRANTY REGISTRATION [SerialNumber]',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = 'Product description',
      SMC_Serial_Number__c = 'SerialNumber',
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [SerialNumber]',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null
    );
    System.runAs(userAdmin){
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      insert theCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    }

    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.theAccount = account;
      sendObject.theContact = contact;
      sendObject.assetIsDuplicate = false;
      sendObject.assetExist = true;
      // sendObject.thServiceTerritory = worldST;
      sendObject.theLocation = theLocation;
      // sendObject.theAddress = theAddress;
      sendObject.theAsset = theAsset;
      sendObject.theCase = theCase;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      returnObject.theCase = SMC_AC_WarrantyRegistration.insertCase(sendObject, theCase);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theCase.Id, 'Case is not updated.');
    }
  }

  @isTest
  public static void testInsertCaseComment_ContactDuplicate(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];

    Case theCase = new Case(
      Id = null,
      Subject = 'WARRANTY REGISTRATION [SerialNumber]',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = 'Product description',
      SMC_Serial_Number__c = 'SerialNumber',
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [SerialNumber]',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null
    );
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(userAdmin){
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      insert theCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    }

    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.assetIsDuplicate = false;
      sendObject.contactIsDuplicate = true;
      sendObject.theCase = theCase;
      SMC_AC_WarrantyRegistration.insertCaseComment(sendObject);
      Test.stopTest();
    }
    CaseComment checkCC = [SELECT Id FROM CaseComment WHERE ParentId = :theCase.Id];
    System.assertNotEquals(null, checkCC, 'CaseComment is not inserted (Contact duplicate).');
  }

  @isTest
  public static void testInsertCaseComment_AssetDuplicate(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];

    Case theCase = new Case(
      Id = null,
      Subject = 'WARRANTY REGISTRATION [SerialNumber]',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = 'Product description',
      SMC_Serial_Number__c = 'SerialNumber',
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [SerialNumber]',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null
    );
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(userAdmin){
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      insert theCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    }

    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.assetIsDuplicate = true;
      sendObject.contactIsDuplicate = false;
      sendObject.theCase = theCase;
      SMC_AC_WarrantyRegistration.insertCaseComment(sendObject);
      Test.stopTest();
    }
    CaseComment checkCC = [SELECT Id FROM CaseComment WHERE ParentId = :theCase.Id];
    System.assertNotEquals(null, checkCC, 'CaseComment is not inserted (Asset duplicate).');
  }

  @isTest
  public static void testUpdateCase(){
    //Guest
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //Admin
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    //Queue
    Group franceOSL = [
      SELECT Id, Name, Type
      FROM Group
      WHERE
        Type = :STA_UtilsStatic.QUEUE
        AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
    ];
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
    ]
    .Id;
    Account accountQueue = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT + '_GroupQueue',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    accountQueue.SMC_Queue_ID__c = franceOSL.Id;
    accountQueue.OwnerId = userAdmin.Id;
    insert new List<Account>{ accountQueue };

    //Technical user
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Get record type id
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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

    Case theCase = new Case(
      Id = null,
      AccountId = account.Id,
      ContactId = contact.Id,
      Subject = 'WARRANTY REGISTRATION [SerialNumber]',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = 'Product description',
      SMC_Serial_Number__c = 'SerialNumber',
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [SerialNumber]',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null,
      OwnerId = accountQueue.SMC_Queue_ID__c
    );
    System.runAs(userAdmin){
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      insert theCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    }
    System.runAs(guestUser) {
      Test.startTest();
      SMC_AC_WarrantyRegistration.WrapperInformation sendObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      sendObject.assetIsDuplicate = false;
      sendObject.theCase = theCase;
      sendObject.soc1Id = soc1.UserId__c;
      SMC_AC_WarrantyRegistration.WrapperInformation returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
      returnObject.theCase = SMC_AC_WarrantyRegistration.updateCase(sendObject, theCase, true);
      Test.stopTest();
      System.assertNotEquals(null, returnObject.theCase.Id, 'Case is not updated.');
    }
  }

  @isTest
  public static void testUploadFile(){
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    // User guestUser = [
    //   SELECT Id
    //   FROM User
    //   WHERE Email = :('wr-' + STA_UtilsStatic.USERNAME_TEST)
    // ];
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    //Set account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.OwnerId = soc1.UserId__c;
    insert account;
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
    SMC_AC_WarrantyRegistration.WrapperInformation returnObject;
    Case newCase;
    Test.startTest();
      System.runAs(adminUser) {
        newCase = new Case(
          Subject = 'Temporary Case',
          OwnerId = UserInfo.getUserId(),
          Origin = 'Customer Community',
          Type = 'SMC_Warranty_Claims',
          Status = 'Open',
          SMC_Sub_Status__c = 'Open'
        );
        PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
        insert newCase;
        PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'PenguinsTooLarge';
        contentVersion.PathOnClient = 'PenguinsTooLarge.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content Too Large');
        insert contentVersion;

        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
    
        returnObject = new SMC_AC_WarrantyRegistration.WrapperInformation();
        returnObject.theCase = newCase;
        returnObject.theContact = contact;
        SMC_AC_WarrantyRegistration.uploadFile(returnObject, contentVersion.ContentDocumentId);
      }
    Test.stopTest();
    ContentDocumentLink theCDL = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :newCase.Id];
    System.assertNotEquals(null, theCDL, 'File is not updated.');
  }

  @isTest
  public static void testCoverage(){
    Case newCase = new Case(
      Subject = 'Temporary Case',
      OwnerId = UserInfo.getUserId(),
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      SMC_Sub_Status__c = 'Open'
    );
    PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    insert newCase;
    PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);

    SMC_AC_WarrantyRegistration.WrapperStaticInfos newWrapper = new SMC_AC_WarrantyRegistration.WrapperStaticInfos();
    newWrapper.caseId = newCase.Id;
  }
}