/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageEmailMessage
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ManageEmailMessage
--
-- Maintenance History:
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 03-APR-2019  VRE     1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageLocation {
  /**
   * @description : test SMC_AP_ManageEmailMessage.updateSiteAccountFromNewAssociatedLocationSite() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateSiteAccountFromNewAssociatedLocationSite() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };

    System.runAs(userStandard) {
      Id recordTypeAccCustomerId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
        ]
        .get(0)
        .Id;
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        null,
        null,
        null,
        null,
        null
      );
      Account account2 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME2,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        null,
        null,
        null,
        null,
        null
      );
      insert new List<Account>{ account1, account2 };

      Schema.Location theLocation = SMC_UTIL_TestUtils.createLocation(
        STA_UtilsStatic.TEST
      );
      theLocation.SMC_Site_Account__c = account1.Id;
      insert theLocation;

      Test.startTest();
      Schema.Location theLocationCheckBefore = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation.Id
      ];
      System.assertEquals(
        account1.Id,
        theLocationCheckBefore.SMC_Site_Account__c,
        'The AssociatedLocation is not link to the rigth account.'
      );

      SMC_AP_ManageLocation.updateSiteAccountFromNewAssociatedLocationSite(
        new Map<Id, Id>{ theLocation.Id => account2.Id }
      );

      Schema.Location theLocationCheckAfter = [
        SELECT Id, SMC_Site_Account__c
        FROM Location
        WHERE Id = :theLocation.Id
      ];
      System.assertEquals(
        account2.Id,
        theLocationCheckAfter.SMC_Site_Account__c,
        'The AssociatedLocation is not link to the rigth account.'
      );
      Test.stopTest();
    }
  }

  @isTest
  public static void testGetDurationFromCallout() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };

    System.runAs(userStandard) {
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      insert oh1;

      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      terr1.Latitude = 52.51375;
      terr1.Longitude = 13.42462;
      insert terr1;

      Id recordTypeAccCustomerId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
        ]
        .get(0)
        .Id;

      //Account
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        null,
        null,
        null,
        null,
        null
      );
      insert account1;
      
      //Location
      Schema.Location Location1 = SMC_UTIL_TestUtils.createLocation(STA_UtilsStatic.TEST);
      Location1.SMC_Site_Account__c = account1.Id;
      Location1.SMC_Service_Territory__c = terr1.Id;
      insert Location1;

      //map
      Map<Id, Schema.Location> oldMap = new Map<Id, Schema.Location>();
      oldMap.put(Location1.Id, Location1);

      //Address
      Schema.Address address = new Schema.Address();
      address.ParentId = Location1.Id;
      address.Latitude = 52.5233;
      address.Longitude = 13.428;
      insert address;

      Map<Id, Schema.Location> newMap = new Map<Id, Schema.Location>();

      Location1.SMC_Address__c = address.Id;
      update Location1;
      
      newMap.put(Location1.Id, Location1);

      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
      mock.setStaticResource(STA_UtilsStatic.MOCK_MAINTENANCE_PLAN);
      mock.setStatusCode(200);
      mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
      mock.setHeader(
        STA_UtilsStatic.CONTENT_TYPE,
        STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
      );
  
      // Set the mock callout mode
      Test.setMock(HttpCalloutMock.class, mock);

      Test.startTest();
      SMC_AP_ManageLocation.getDurationFromCallout(newMap,oldMap);
      
      Test.stopTest();

      Location1 = [SELECT Id, SMC_EstimatedTravelTime__c FROM Location WHERE Id =: Location1.Id];

      System.assertEquals(6, Location1.SMC_EstimatedTravelTime__c);
    }
  }

  @isTest
  public static void testGetDurationFromCalloutFAIL() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };

    System.runAs(userStandard) {
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      insert oh1;

      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      terr1.Latitude = 52.51375;
      terr1.Longitude = 13.42462;
      insert terr1;

      Id recordTypeAccCustomerId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
      ].get(0).Id;

      //Account
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        null,
        null,
        null,
        null,
        null
      );
      insert account1;
      
      //Location
      Schema.Location Location1 = SMC_UTIL_TestUtils.createLocation(STA_UtilsStatic.TEST);
      Location1.SMC_Site_Account__c = account1.Id;
      Location1.SMC_Service_Territory__c = terr1.Id;
      insert Location1;

      //map
      Map<Id, Schema.Location> oldMap = new Map<Id, Schema.Location>();
      oldMap.put(Location1.Id, Location1);

      //Address
      Schema.Address address = new Schema.Address();
      address.ParentId = Location1.Id;
      address.Latitude = null;
      address.Longitude = 13.428;
      try {
        insert address;
      } catch (Exception e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      

      Map<Id, Schema.Location> newMap = new Map<Id, Schema.Location>();

      Location1.SMC_Address__c = address.Id;
      update Location1;
      
      newMap.put(Location1.Id, Location1);

      Test.startTest();
      SMC_AP_ManageLocation.getDurationFromCallout(newMap,oldMap);
      
      Test.stopTest();

      Location1 = [SELECT Id, SMC_EstimatedTravelTime__c FROM Location WHERE Id =: Location1.Id];

      System.assertEquals(null, Location1.SMC_EstimatedTravelTime__c);
    }
  }

  @isTest
  public static void testRenameLocation() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };

    System.runAs(userStandard) {
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      insert oh1;

      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      terr1.Latitude = 52.51375;
      terr1.Longitude = 13.42462;
      insert terr1;

        /*
      Id recordTypeAccCustomerId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
      ].get(0).Id;
      */
        
      Id recordTypeAccCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();

      //Account
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        null,
        null,
        null,
        null,
        null
      );
      insert account1;
      
      //Location
      Schema.Location Location1 = SMC_UTIL_TestUtils.createLocation(STA_UtilsStatic.TEST);
      Location1.SMC_Site_Account__c = account1.Id;
      Location1.SMC_Service_Territory__c = terr1.Id;
      Location1.LocationType = 'Site';

      insert Location1;

      //map
      /*
      Map<Id, Schema.Location> oldMap = new Map<Id, Schema.Location>();
      oldMap.put(Location1.Id, Location1);
      */

      //Address
      Schema.Address address = new Schema.Address();
      address.ParentId = Location1.Id;
      address.City = STA_UtilsStatic.ACCOUNT_BILLINGCITY3;
      address.Country = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY3;
      address.PostalCode = STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE3;
      address.Street = STA_UtilsStatic.ACCOUNT_BILLINGSTREET3;
      insert address;

      Location1.SMC_Address__c = address.Id;
            
      Test.startTest();
      System.debug('--------update Location------------');
      update Location1;
      Test.stopTest();

      String locationName = [SELECT Id, Name FROM Location WHERE Id =: Location1.Id].Name; 
      String expectedName = STA_UtilsStatic.ACCOUNT_NAME1 + ' - ' + STA_UtilsStatic.ACCOUNT_BILLINGSTREET3 + ', ' + STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE3 + ', ' + STA_UtilsStatic.ACCOUNT_BILLINGCITY3 + ' - ' + STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY3;
      expectedName = expectedName.toUpperCase();

      System.assertEquals(expectedName, locationName);
    }
  }

  @isTest
  public static void testRenameLocationFAIL() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };

    System.runAs(userStandard) {
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      insert oh1;

      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      terr1.Latitude = 52.51375;
      terr1.Longitude = 13.42462;
      insert terr1;

        /*
      Id recordTypeAccCustomerId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
      ].get(0).Id;
      */
        
      Id recordTypeAccCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();

      //Account
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        null,
        null,
        null,
        null,
        null
      );
      insert account1;
      
      //Location
      Schema.Location Location1 = SMC_UTIL_TestUtils.createLocation(STA_UtilsStatic.TEST);
      Location1.SMC_Site_Account__c = account1.Id;
      Location1.SMC_Service_Territory__c = terr1.Id;
      Location1.LocationType = 'Site';
      insert Location1;

      Schema.Location Location2 = SMC_UTIL_TestUtils.createLocation(STA_UtilsStatic.TEST);
      Location2.SMC_Site_Account__c = account1.Id;
      Location2.SMC_Service_Territory__c = terr1.Id;
      Location2.LocationType = 'Site';
      insert Location2;
      //map
      /*
      Map<Id, Schema.Location> oldMap = new Map<Id, Schema.Location>();
      oldMap.put(Location1.Id, Location1);
      */

      //Address
      Schema.Address address = new Schema.Address();
      address.ParentId = Location1.Id;
      address.City = STA_UtilsStatic.ACCOUNT_BILLINGSTREET1;
      address.Country = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY3;
      address.PostalCode = STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE3;
      address.Street = STA_UtilsStatic.ACCOUNT_BILLINGSTREET3;
      insert address;
      

      Location1.SMC_Address__c = address.Id;
      update Location1;

      
      Test.startTest();
      try {
        Location2.SMC_Address__c = address.Id;
        update Location2;
        System.debug('An exception should have been thrown by the trigger but was not.');
      } catch(Exception e) {
        Boolean expectedExceptionThrown = e.getMessage().contains('This Location Name already exist.') ? true : false;
        System.AssertEquals(true, expectedExceptionThrown);
      } 
      
      Test.stopTest();

      // String locationName = [SELECT Id, Name FROM Location WHERE Id =: Location2.Id].Name; 
      // String expectedName = STA_UtilsStatic.ACCOUNT_NAME1 + ' - ' + STA_UtilsStatic.ACCOUNT_BILLINGSTREET3 + ', ' + STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE3 + ' - ' + STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY3;
      // System.debug('TEST loc name---->'+ locationName);
      // System.assertEquals(expectedName, locationName);
    }
  }
}