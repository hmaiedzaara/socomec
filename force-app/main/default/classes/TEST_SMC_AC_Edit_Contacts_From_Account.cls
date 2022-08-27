/**
 * @File Name          : TEST_SMC_AC_Edit_Contacts_From_Account.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10-01-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    08/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Edit_Contacts_From_Account {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    //Account
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAcc = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAcc,
      STA_UtilsStatic.TEST,
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
      STA_UtilsStatic.CONTACT_EMAIL1,
      null,
      null,
      null,
      null,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    contactPartner.RecordTypeId = recordTypeContactPartner.Id;
    insert contactPartner;

    // Partner user
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
    userPartner.ContactId = contactPartner.Id;
    userPartner.IsActive = true;
    insert userPartner;

    //Contacts
    Contact contact2 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME2,
      STA_UtilsStatic.CONTACT_LASTNAME2,
      STA_UtilsStatic.CONTACT_PHONE2,
      STA_UtilsStatic.CONTACT_MOBILEPHONE2,
      STA_UtilsStatic.CONTACT_EMAIL2,
      null,
      null,
      null,
      null,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    Contact contact3 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME3,
      STA_UtilsStatic.CONTACT_LASTNAME3,
      STA_UtilsStatic.CONTACT_PHONE3,
      STA_UtilsStatic.CONTACT_MOBILEPHONE3,
      STA_UtilsStatic.CONTACT_EMAIL3,
      null,
      null,
      null,
      null,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    Contact contact4 = SMC_UTIL_TestUtils.createContact(
      'Contact Firstname 4',
      'Contact Lastname 4',
      '0101010101',
      '0606060606',
      'contact4@fake.com',
      null,
      null,
      null,
      null,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    insert new List<Contact>{ contact2, contact3, contact4 };

    //Set IOT contacts
    account.SMC_IOT_Main_Contact__c = contactPartner.Id;
    account.SMC_IOT_Administrative_Contact__c = contact2.Id;
    account.SMC_IOT_Technical_Contact__c = contact3.Id;
    update account;
  }

  /**
   * @description : test SMC_AC_Edit_Contacts_From_Account.getContacts()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetContacts() {
    User userPartner = [
      SELECT Id, SMC_Account_Id__c
      FROM User
      WHERE Email = :STA_UtilsStatic.CONTACT_EMAIL1
    ];

    Account theAccount = [
      SELECT
        Id,
        Name,
        SMC_IOT_Main_Contact__c,
        SMC_IOT_Administrative_Contact__c,
        SMC_IOT_Technical_Contact__c
      FROM Account
      WHERE Id = :userPartner.SMC_Account_Id__c
    ];

    System.runAs(userPartner) {
      String jsonResult = SMC_AC_Edit_Contacts_From_Account.getContacts();
      SMC_AC_Edit_Contacts_From_Account.AllContacts result = (SMC_AC_Edit_Contacts_From_Account.AllContacts) JSON.deserialize(
        jsonResult,
        SMC_AC_Edit_Contacts_From_Account.AllContacts.class
      );

      System.assertEquals(
        theAccount.Id,
        result.accountId,
        'The account is not the same. Check it (compare on Id)'
      );
      System.assertEquals(
        theAccount.Name,
        result.accountName,
        'The account is not the same. Check it (compare on Name)'
      );
      System.assertEquals(
        theAccount.SMC_IOT_Main_Contact__c,
        result.iotMainContactId,
        'The account is not the same. Check it (compare on SMC_IOT_Main_Contact__c)'
      );
      System.assertEquals(
        theAccount.SMC_IOT_Administrative_Contact__c,
        result.iotAdministrativeContactId,
        'The account is not the same. Check it (compare on SMC_IOT_Administrative_Contact__c)'
      );
      System.assertEquals(
        theAccount.SMC_IOT_Technical_Contact__c,
        result.iotTechnicalContactId,
        'The account is not the same. Check it (compare on SMC_IOT_Technical_Contact__c)'
      );
      System.assertEquals(
        4,
        result.mapContacts.size(),
        'The number of contact is more or less than 4 (Owner and 3 IOT - all differents)'
      );
    }
  }

  /**
   * @description : test SMC_AC_Edit_Contacts_From_Account.saveContacts()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSaveContacts() {
    User userPartner = [
      SELECT Id, SMC_Account_Id__c, ContactId
      FROM User
      WHERE Email = :STA_UtilsStatic.CONTACT_EMAIL1
    ];

    Account theAccount = [
      SELECT
        Id,
        Name,
        SMC_IOT_Main_Contact__c,
        SMC_IOT_Administrative_Contact__c,
        SMC_IOT_Technical_Contact__c
      FROM Account
      WHERE Id = :userPartner.SMC_Account_Id__c
    ];

    List<SMC_AC_Edit_Contacts_From_Account.MapContact> mapContacts = new List<SMC_AC_Edit_Contacts_From_Account.MapContact>();
    Contact newIotContact;
    for (Contact oneContact : [
      SELECT Id, Name
      FROM Contact
      WHERE AccountId = :theAccount.Id
    ]) {
      mapContacts.add(
        new SMC_AC_Edit_Contacts_From_Account.MapContact(
          oneContact.Name,
          oneContact.Id
        )
      );
      if (oneContact.Name == ('Contact Firstname 4 Contact Lastname 4')) {
        newIotContact = oneContact;
      }
    }

    Boolean result;
    System.runAs(userPartner) {
      result = SMC_AC_Edit_Contacts_From_Account.saveContacts(
        theAccount.Id,
        theAccount.Name,
        newIotContact.Id,
        newIotContact.Id,
        newIotContact.Id,
        JSON.serialize(mapContacts)
      );
    }

    // List<Case> caseResultList = new List<Case>();
    // caseResultList = [
    //   SELECT
    //     Id,
    //     Subject,
    //     Description,
    //     Type,
    //     SMC_Case_Category__c,
    //     AccountId,
    //     ContactId
    //   FROM Case
    //   WHERE AccountId = :theAccount.Id
    // ];

    Account checkedAccount = [SELECT Id, SMC_IOT_Main_Contact__c, SMC_IOT_Administrative_Contact__c, SMC_IOT_Technical_Contact__c FROM Account WHERE Id = :theAccount.Id];

    System.assert(result, 'Modification is not saved. Check the update.');
    System.assertEquals(newIotContact.Id, checkedAccount.SMC_IOT_Main_Contact__c, '(Administrator) Modification is not saved. Check the update.');
    System.assertEquals(newIotContact.Id, checkedAccount.SMC_IOT_Administrative_Contact__c, '(Main) Modification is not saved. Check the update.');
    System.assertEquals(newIotContact.Id, checkedAccount.SMC_IOT_Technical_Contact__c, '(Technical) Modification is not saved. Check the update.');
    // System.assertEquals(1, caseResultList.size(), 'The case is not created.');
    // System.assertEquals(
    //   ('Request modification IOT contacts - ' + theAccount.Name),
    //   caseResultList[0].Subject,
    //   'The case is not created with rigth parameters.'
    // );
    // System.assertNotEquals(null, caseResultList[0].Description);
    // System.assertEquals(
    //   STA_UtilsStatic.CASE_TYPE_CUSTOMER_CLAIM,
    //   caseResultList[0].Type,
    //   'The case is not created with rigth parameters.'
    // );
    // System.assertEquals(
    //   STA_UtilsStatic.CASE_CATEGORY_OTHER,
    //   caseResultList[0].SMC_Case_Category__c,
    //   'The case is not created with rigth parameters.'
    // );
    // System.assertEquals(
    //   userPartner.ContactId,
    //   caseResultList[0].ContactId,
    //   'The case is not created with rigth parameters.'
    // );
  }
}