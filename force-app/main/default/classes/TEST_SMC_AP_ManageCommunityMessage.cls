/**
 * @File Name          : TEST_SMC_AP_ManageCommunityMessage.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-11-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/02/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AP_ManageCommunityMessage {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    // userStandard.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME].Id; //Support
    userStandard.Bypass_All_Processes_Builder__c = true;
    userStandard.Bypass_All_Validation_Rules__c = true;
    userStandard.Bypass_All_Workflow_Rules__c = true;
    userStandard.Bypass_All_Flow_Trigger__c = true;
    userStandard.IsActive = true;
    userStandard.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    insert userStandard;

    Contact contact;
    System.runAs(userStandard) {
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.AccountNumber = 'ACC-{000001}';
      //   account.IsCustomerPortal = true;
      insert account;

      RecordType recordTypeContactPartner = [
        SELECT Id, Name
        FROM RecordType
        WHERE DeveloperName = :STA_UtilsStatic.PARTNER_CONTACT_RECORDTYPE_NAME
      ];
      contact = SMC_UTIL_TestUtils.createContact(
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
        account.Id
      );
      contact.Email = 'emailtest@fake.com';
      contact.RecordTypeId = recordTypeContactPartner.Id;
      insert new List<Contact>{ contact };
    }

    Profile profilePartner = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
    ];

    User userPartner = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      profilePartner.Id,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.USER_NICKNAME + '_Partner'
    );
    userPartner.ContactId = contact.Id;
    userPartner.IsActive = true;
    insert userPartner;
  }

  /**
   * @description : test SMC_AP_ManageCommunityMessage.fillURLCustomersCompmunityFieldFromCommunity()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFillURLCustomersCompmunityFieldFromOther() {
    User stanadrdUser = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      Account account = [
        SELECT Id
        FROM Account
        WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
      ];
      Contact contact = [
        SELECT Id
        FROM Contact
        WHERE FirstName = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test')
      ];

      Test.startTest();
      SMC_Community_Message__c messageFromCommunity = SMC_UTIL_TestUtils.createCommunityMessage(
        STA_UtilsStatic.OTHER,
        STA_UtilsStatic.TEST + STA_UtilsStatic.COMMUNITY,
        STA_UtilsStatic.TEST,
        contact.Id
      );
      messageFromCommunity.Account__c = account.Id;
      insert new List<SMC_Community_Message__c>{ messageFromCommunity };

      SMC_Community_Message__c checkMessageFromCommunity = [
        SELECT Id, Record_link_message__c
        FROM SMC_Community_Message__c
        WHERE Id = :messageFromCommunity.Id
      ];
      String salesforceUrl =
        Url.getOrgDomainUrl().toExternalForm() +
        '/' +
        ((String) account.Id).substring(0, 15);
      System.assert(
        checkMessageFromCommunity.Record_link_message__c.contains(
          salesforceUrl
        ),
        'The url construction is break. Check it.'
      );
      Test.stopTest();
    }
  }

  /**
   * @description : test SMC_AP_ManageCommunityMessage.fillURLCustomersCompmunityFieldFromCommunity()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFillURLCustomersCompmunityFieldFromMySpaceCommunity() {
    User stanadrdUser = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      Account account = [
        SELECT Id
        FROM Account
        WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
      ];
      Contact contact = [
        SELECT Id
        FROM Contact
        WHERE FirstName = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test')
      ];

      Test.startTest();
      SMC_Community_Message__c messageFromCommunity = SMC_UTIL_TestUtils.createCommunityMessage(
        STA_UtilsStatic.COMMUNITY,
        STA_UtilsStatic.TEST + STA_UtilsStatic.COMMUNITY,
        STA_UtilsStatic.TEST,
        contact.Id
      );
      messageFromCommunity.Account__c = account.Id;
      insert new List<SMC_Community_Message__c>{ messageFromCommunity };

      SMC_Community_Message__c checkMessageFromCommunity = [
        SELECT Id, Record_link_message__c
        FROM SMC_Community_Message__c
        WHERE Id = :messageFromCommunity.Id
      ];
      String salesforceUrl =
        Url.getOrgDomainUrl().toExternalForm() +
        '/' +
        ((String) account.Id).substring(0, 15);
      System.assert(
        checkMessageFromCommunity.Record_link_message__c.contains(
          salesforceUrl
        ),
        'The url construction is break. Check it.'
      );
      Test.stopTest();
    }
  }

  /**
   * @description : test SMC_AP_ManageCommunityMessage.fillURLCustomersCompmunityFieldFromCommunity()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFillURLCustomersCompmunityFieldFromSF() {
    User stanadrdUser = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      Account account = [
        SELECT Id
        FROM Account
        WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
      ];
      Contact contact = [
        SELECT Id
        FROM Contact
        WHERE FirstName = :(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test')
      ];

      Test.startTest();
      SMC_Community_Message__c messageFromCommunity = SMC_UTIL_TestUtils.createCommunityMessage(
        STA_UtilsStatic.SALESFORCE,
        STA_UtilsStatic.TEST + STA_UtilsStatic.COMMUNITY,
        STA_UtilsStatic.TEST,
        contact.Id
      );
      messageFromCommunity.Account__c = null;
      messageFromCommunity.Partner_Fund_Request__c = null;
      insert new List<SMC_Community_Message__c>{ messageFromCommunity };

      SMC_Community_Message__c checkMessageFromCommunity = [
        SELECT Id, Record_link_message__c
        FROM SMC_Community_Message__c
        WHERE Id = :messageFromCommunity.Id
      ];
      String salesforceUrl =
        Url.getOrgDomainUrl().toExternalForm() +
        '/' +
        STA_UtilsStatic.CUSTOMERS_MIN;
      salesforceUrl = salesforceUrl.replace('salesforce', 'site');
      System.assert(
        checkMessageFromCommunity.Record_link_message__c.contains(
          salesforceUrl
        ),
        'The url construction is break. Check it.'
      );
      Test.stopTest();
    }
  }
}