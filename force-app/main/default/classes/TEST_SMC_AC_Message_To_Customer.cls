/**
 * @File Name          : TEST_SMC_AC_Message_To_Customer.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    20/01/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Message_To_Customer {
  /**
   * @description : test SMC_AC_Message_To_Customer.getContactsFromAccount()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetContact() {
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
    insert account;
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
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
    Contact contact2 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME2 + 'test',
      STA_UtilsStatic.CONTACT_LASTNAME2 + 'test',
      STA_UtilsStatic.CONTACT_PHONE2,
      STA_UtilsStatic.CONTACT_MOBILEPHONE2,
      'test-' + STA_UtilsStatic.CONTACT_EMAIL2,
      STA_UtilsStatic.CONTACT_MAILINGSTREET2,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
      STA_UtilsStatic.CONTACT_MAILINGCITY2,
      STA_UtilsStatic.CONTACT_MAILINGSTATE2,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    insert new List<Contact>{ contact1, contact2 };

    System.assertNotEquals(
      null,
      SMC_AC_Message_To_Customer.getContactsFromAccount(account.Id),
      'The account has no contact or contact is not parent to the account.'
    );
  }

  /**
   * @description : test SMC_AC_Message_To_Customer.createCommunityMessage()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testMessageCreation() {
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
    insert account;
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
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
    contact1.Email = 'emailtest@fake.com';
    insert new List<Contact>{ contact1 };

    System.assert(
      SMC_AC_Message_To_Customer.createCommunityMessage(
        'Title',
        Blob.valueOf('Body'),
        String.valueOf(contact1.Id),
        account.Id,
        null,
        new Map<Id, String>{ contact1.Id => contact1.Email }
      ),
      'The CommunityMessage creation failed.'
    );
  }
}