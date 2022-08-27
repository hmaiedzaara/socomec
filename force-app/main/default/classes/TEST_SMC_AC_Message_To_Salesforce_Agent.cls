/**
 * @File Name          : TEST_SMC_AC_Message_To_Salesforce_Agent.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver    Date         Author  Modification
 * 1.0    06/01/2020   VRE     Initial Version
 **/
@Istest
public with sharing class TEST_SMC_AC_Message_To_Salesforce_Agent {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    //Set UserAdmin to receive the email
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
    insert userAdmin;

    System.runAs(userAdmin) {
      //Set an Account to link to the contact
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
      insert accountQueue;

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
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        accountQueue.Id
      );
      contactPartner.RecordTypeId = recordTypeContactPartner.Id;
      insert contactPartner;

      //Set an PartnerUser
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
    }
  }

  /**
   * @description : test SMC_AC_Message_To_Salesforce_Agent.createCommunityMessage()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void createCommunityMessage() {
    User userAdmin = [
      SELECT Id, ContactId
      FROM User
      WHERE LastName = :('admin1-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    User userPartner = [
      SELECT Id, ContactId
      FROM User
      WHERE LastName = :STA_UtilsStatic.CONTACT_LASTNAME1
    ];
    Contact contactPartner;
    System.runAs(userAdmin) {
      contactPartner = [
        SELECT Id
        FROM Contact
        WHERE LastName = :STA_UtilsStatic.CONTACT_LASTNAME1
      ];
    }

    System.runAs(userPartner) {
      //User PartnerUser to send the message
      Test.startTest();
      SMC_AC_Message_To_Salesforce_Agent.createCommunityMessage(
        STA_UtilsStatic.TEST,
        Blob.valueOF(STA_UtilsStatic.TEST)
      );
      Test.stopTest();

      System.assertNotEquals(
        null,
        [
          SELECT Id
          FROM SMC_Community_Message__c
          WHERE Recipient_Contact__c = :contactPartner.Id
        ],
        'The CommunityMessage creation failed.'
      );
    }
  }
}