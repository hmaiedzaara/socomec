/*
----------------------------------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageUser
-- - Author        : Vincent RECASENS (VR) - Modis
-- - Description   : Test class Apex SMC_AP_ManageUser
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 22-NOV-2018  VR    	1.0         Initial version
----------------------------------------------------------------------------------------------
*/
@isTest
public without sharing class TEST_SMC_AP_ManageUser {
  /**
   * @description : test SMC_AP_ManageUser.flagContactIfPartner()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testMethods() {
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
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id;
    insert userAdmin;

    System.runAs(userAdmin) {
      PAD.bypassAll = true;
      //Partner
      Id recordTypeIdPartner = [
          SELECT Id
          FROM RecordType
          WHERE
            DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
          LIMIT 1
        ]
        .get(0)
        .Id;
      Account accountPartner = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdPartner,
        STA_UtilsStatic.TEST + '_Partner',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      //Standard
      Id recordTypeIdStandard = [
          SELECT Id
          FROM RecordType
          WHERE
            DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
          LIMIT 1
        ]
        .get(0)
        .Id;
      Account accountStandard = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdStandard,
        STA_UtilsStatic.TEST + '_Standard',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert new List<Account>{ accountPartner, accountStandard };

      //Partner
      Contact partnerContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + '_Partner',
        STA_UtilsStatic.CONTACT_LASTNAME1 + '_Partner',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1 + '.partner',
        null,
        null,
        null,
        null,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        '',
        accountPartner.Id
      );
      Contact partnerContact2 = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + '_Partnerbis',
        STA_UtilsStatic.CONTACT_LASTNAME1 + '_Partnerbis',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1 + '.partnerbis',
        null,
        null,
        null,
        null,
        'GB',
        '',
        accountPartner.Id
      );
      //Standard
      Contact standardContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + '_Standard',
        STA_UtilsStatic.CONTACT_LASTNAME1 + '_Standard',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1 + '.standard',
        null,
        null,
        null,
        null,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        '',
        accountStandard.Id
      );
      insert new List<Contact>{
        partnerContact,
        partnerContact2,
        standardContact
      };
      PAD.bypassAll = false;

      Test.startTest();

      //Group
      Group grp = new Group();
      grp.name = 'SMC_Partners_' + STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
      grp.Type = 'Regular';
      Group grp2 = new Group();
      grp2.name = 'SMC_Partners_' + 'UK';
      grp2.Type = 'Regular';
      insert new List<Group>{ grp, grp2 };

      //Partner
      Profile profilePartner = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
      ];
      User userPartner = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.USER_NICKNAME + '_Partner',
        STA_UtilsStatic.USERNAME_TEST + '.partner',
        profilePartner.Id,
        STA_UtilsStatic.USERNAME_TEST + '_Partner',
        STA_UtilsStatic.USER_NICKNAME + '_Partner'
      );
      userPartner.ContactId = partnerContact.Id;
      userPartner.CountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
      User userPartner2 = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.USER_NICKNAME + '_Partnerbis',
        STA_UtilsStatic.USERNAME_TEST + '.partnerbis',
        profilePartner.Id,
        STA_UtilsStatic.USERNAME_TEST + '_Partnerbis',
        STA_UtilsStatic.USER_NICKNAME + '_Partnerbis'
      );
      userPartner2.ContactId = partnerContact2.Id;
      userPartner2.CountryCode = 'GB';
      insert new List<User>{ userPartner, userPartner2 };

      Test.stopTest();

      //Check Link CONtact
      Contact checkPartnerContact = [
        SELECT Id, SMC_Is_Partner_Contact__c
        FROM Contact
        WHERE Id = :partnerContact.Id
      ];
      Contact checkStandardContact = [
        SELECT Id, SMC_Is_Partner_Contact__c
        FROM Contact
        WHERE Id = :standardContact.Id
      ];
      System.assert(
        checkPartnerContact.SMC_Is_Partner_Contact__c,
        'The contact is not linked to the user. Check setup.'
      );
      System.assert(
        !checkStandardContact.SMC_Is_Partner_Contact__c,
        'The contact is linked to the user. Check setup.'
      );

      //Check Link PublicGroup
      System.assertNotEquals(
        null,
        [
          SELECT Id
          FROM GroupMember
          WHERE GroupId = :grp.Id AND UserOrGroupId = :userPartner.Id
        ],
        'The user is not in the public group.'
      );

      //Check Link PublicGroup 2
      System.assertNotEquals(
        null,
        [
          SELECT Id
          FROM GroupMember
          WHERE GroupId = :grp2.Id AND UserOrGroupId = :userPartner2.Id
        ],
        'The user is not in the public group.'
      );
    }
  }

  public static void testSetBypassFlows(){
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
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id;
    insert userAdmin;

    System.runAs(userAdmin){
      User checkBF = [SELECT Id, BypassFlow_TXT__c FROM User WHERE Id = :userAdmin.Id];
      System.assertEquals(null, userAdmin.BypassFlow_TXT__c);

      Test.startTest();
        userAdmin.Bypass_Process_Builder__c = 'SMC_Account_On_Update_Create;SMC_Case_On_Create';
        update userAdmin;
      Test.stopTest();

      User checkAF = [SELECT Id, BypassFlow_TXT__c FROM User WHERE Id = :userAdmin.Id];
      System.assertEquals('SMC_Account_On_Update_Create;SMC_Case_On_Create', userAdmin.BypassFlow_TXT__c);

    }
  }
}