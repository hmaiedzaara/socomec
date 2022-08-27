/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageAssociatedLocation
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ManageAssociatedLocation
--
-- Maintenance History:
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 03-APR-2019  VRE     1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageAssociatedLocation {
  /**
   * @description : test SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testManageAssociatedLocationTypeTrigger() {
    //Set the User
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
    insert user;

    System.runAs(user) {
      PAD.bypassAll = true;

      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeAccCustomerId = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();

      Account theAccount1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        user.Id,
        user.Id,
        user.Id,
        user.Id,
        user.Id
      );

      Account theAccount2 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME2,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        user.Id,
        user.Id,
        user.Id,
        user.Id,
        user.Id
      );
      insert new List<Account>{ theAccount1, theAccount2 };

      Schema.Location theLocation1 = SMC_UTIL_TestUtils.createLocation(
        STA_UtilsStatic.TEST
      );
      insert new List<Schema.Location>{ theLocation1 };

      PAD.bypassAll = false;

      Test.startTest();
      AssociatedLocation firstAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount1.Id
      );
      firstAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert firstAssociatedLoaction;
      AssociatedLocation firstCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :firstAssociatedLoaction.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE,
        firstCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE).'
      );
      Schema.Location checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount1.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );

      AssociatedLocation secondAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount1.Id
      );
      secondAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert secondAssociatedLoaction;
      AssociatedLocation secondCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :firstAssociatedLoaction.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER,
        secondCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER).'
      );
      checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount1.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );

      AssociatedLocation thirdAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount2.Id
      );
      thirdAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert thirdAssociatedLoaction;
      AssociatedLocation thirdCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :secondCheckAssociatedLocation.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER,
        thirdCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER).'
      );
      checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount2.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );
      Test.stopTest();
    }
  }

  /**
   * @description : test SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testManageAssociatedLocationTypeBypassTrigger() {
    //Set the User
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
    insert user;

    System.runAs(user) {
      PAD.bypassAll = true;

      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeAccCustomerId = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();

      Account theAccount1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        user.Id,
        user.Id,
        user.Id,
        user.Id,
        user.Id
      );

      Account theAccount2 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME2,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        user.Id,
        user.Id,
        user.Id,
        user.Id,
        user.Id
      );
      insert new List<Account>{ theAccount1, theAccount2 };

      Schema.Location theLocation1 = SMC_UTIL_TestUtils.createLocation(
        STA_UtilsStatic.TEST
      );
      insert new List<Schema.Location>{ theLocation1 };

      Test.startTest();
      AssociatedLocation firstAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount1.Id
      );
      firstAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert firstAssociatedLoaction;
      SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType(
        new Map<Id, AssociatedLocation>{
          firstAssociatedLoaction.Id => firstAssociatedLoaction
        }
      );
      AssociatedLocation firstCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :firstAssociatedLoaction.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE,
        firstCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE).'
      );
      Schema.Location checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount1.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );

      AssociatedLocation secondAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount1.Id
      );
      secondAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert secondAssociatedLoaction;
      SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType(
        new Map<Id, AssociatedLocation>{
          secondAssociatedLoaction.Id => secondAssociatedLoaction
        }
      );
      AssociatedLocation secondCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :firstAssociatedLoaction.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER,
        secondCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER).'
      );
      checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount1.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );

      AssociatedLocation thirdAssociatedLoaction = SMC_UTIL_TestUtils.createAssociatedLocation(
        theLocation1.Id,
        theAccount2.Id
      );
      thirdAssociatedLoaction.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
      insert thirdAssociatedLoaction;
      SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType(
        new Map<Id, AssociatedLocation>{
          thirdAssociatedLoaction.Id => thirdAssociatedLoaction
        }
      );
      AssociatedLocation thirdCheckAssociatedLocation = [
        SELECT Type
        FROM AssociatedLocation
        WHERE Id = :secondCheckAssociatedLocation.Id
      ];
      System.assertEquals(
        STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER,
        thirdCheckAssociatedLocation.Type,
        'The AssociatedLocation insertion does not keep the type defined (STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER).'
      );
      checkTheLocation = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation1.Id
      ];
      System.assertEquals(
        theAccount2.Id,
        checkTheLocation.SMC_Site_Account__c,
        'The account location does not match with the account defined.'
      );
      Test.stopTest();

      PAD.bypassAll = false;
    }
  }
}