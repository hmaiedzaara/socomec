/**
 * @File Name          : TEST_SMC_AC_Modify_Company_Informations.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 12-01-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    08/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Modify_Company_Informations {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @testSetup
  public static void setup() {
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST
    );
    userAdmin.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id;
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_PreventLocationWithoutAddress';
    insert userAdmin;
    System.runAs(userAdmin) {
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        'Account ' + STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      //Set an Contact for PartnerUser
      RecordType recordTypeContactPartner = [
        SELECT Id, Name
        FROM RecordType
        WHERE DeveloperName = :STA_UtilsStatic.PARTNER_CONTACT_RECORDTYPE_NAME
      ];
      Contact contactPartner = SMC_UTIL_TestUtils.createContact(
        null,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'partner-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contactPartner.RecordTypeId = recordTypeContactPartner.Id;
      insert contactPartner;

      account.SMC_IOT_Administrative_Contact__c = contactPartner.Id;
      update account;

      // Partner user
      Profile profilePartner = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
      ];
      User userPartner = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.CONTACT_LASTNAME1,
        'partner-' + STA_UtilsStatic.CONTACT_EMAIL1,
        profilePartner.Id,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.USER_NICKNAME + '_Partner'
      );
      userPartner.ContactId = contactPartner.Id;
      userPartner.IsActive = true;
      insert userPartner;
    }
  }

  /**
   * @description : test SMC_AC_Modify_Company_Informations.getAccountName()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetAccountName() {
    User userPartner = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('partner-' + STA_UtilsStatic.CONTACT_EMAIL1)
    ];

    System.runAs(userPartner) {
      System.assertEquals(
        'Account ' + STA_UtilsStatic.TEST,
        SMC_AC_Modify_Company_Informations.getAccountName(),
        'Partner user is not link with his account.'
      );
    }
  }

  /**
   * @description : test SMC_AC_Modify_Company_Informations.checkContactAdministrator()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCheckContactAdministrator() {
    User userPartner = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('partner-' + STA_UtilsStatic.CONTACT_EMAIL1)
    ];

    System.runAs(userPartner) {
      System.assert(
        SMC_AC_Modify_Company_Informations.checkContactAdministrator(),
        'This partner is not the IOT administration of the account.'
      );
    }
  }

  /**
   * @description : test SMC_AC_Modify_Company_Informations.checkContactAdministrator()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateCase() {
    User userPartner = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType,
        SMC_Account_Id__c,
        ContactId
      FROM User
      WHERE Email = :('partner-' + STA_UtilsStatic.CONTACT_EMAIL1)
    ];

    System.runAs(userPartner) {
      String caseSubject = 'Test Modify Information';
      Blob caseDescription = Blob.valueOf('test description');
      Test.startTest();
      SMC_AC_Modify_Company_Informations.createCase(
        caseSubject,
        caseDescription
      );
      Test.stopTest();

      Case checker = [
        SELECT Id, AccountId, ContactId, Subject, Description, Type, Origin
        FROM Case
        WHERE Subject = :caseSubject
      ];
      System.assertEquals(userPartner.SMC_Account_Id__c, checker.AccountId);
      System.assertEquals(userPartner.ContactId, userPartner.ContactId);
      System.assertEquals(caseSubject, checker.Subject);
      System.assertEquals(caseDescription.toString(), checker.Description);
      System.assertEquals('SMC_Customer_Claim', checker.Type);
      System.assertEquals('IOT Customer Portal', checker.Origin);
    }
  }
}