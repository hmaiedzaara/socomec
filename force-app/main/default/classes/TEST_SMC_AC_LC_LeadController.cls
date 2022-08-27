/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_LC_LeadController 
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_AC_LC_LeadController
--
-- Maintenance History:
--
-- Date         Name      Version     Remarks
-- -----------  ----      -------     ------------------
-- 07-JAN-2019  VRECA     1.0         Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_LC_LeadController {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
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
    user.SMC_Approval_Level__c = 5;
    user.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    insert user;

    Territory2Type theTerritoryType = [SELECT Id FROM Territory2Type LIMIT 1];
    Territory2Model theTerritoryModel = [
      SELECT Id
      FROM Territory2Model
      WHERE ActivatedDate != null
      LIMIT 1
    ];
    Territory2 theTerritory = SMC_UTIL_TestUtils.createTerritory2(
      'Dev' + STA_UtilsStatic.TEST,
      STA_UtilsStatic.TEST,
      theTerritoryModel.Id,
      theTerritoryType.Id
    );
    insert theTerritory;
    UserTerritory2Association userTerritoryAssociation = SMC_UTIL_TestUtils.createUserTerritory2Association(
      theTerritory.Id,
      user.Id
    );
    insert userTerritoryAssociation;

    System.runAs(user) {
      Id recordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME)
        .getRecordTypeId();
      Account genericAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccountInternal,
        'Generic' + STA_UtilsStatic.ACCOUNT_NAME1,
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
        user.Id
      );
      genericAccount.isGenericOppAccount__c = true;
      insert genericAccount;
    }
  }

  /**
   * @description : test SMC_AC_LC_LeadController.getDuplicatesOpportunities()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetDuplicatesOpportunitiesListNotFilled() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_LC_LeadController : testGetDuplicatesOpportunitiesListNotFilled - START'
    );

    User user = [
      SELECT Id, Bypass_All_Processes_Builder__c
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Processes_Builder__c = true;
    update user;
    
    System.runAs(user) {
      Lead theLead = SMC_UTIL_TestUtils.createLead(
        STA_UtilsStatic.EVENTS,
        STA_UtilsStatic.LEAD_COMPANY1,
        STA_UtilsStatic.LEAD_FIRSTNAME1,
        STA_UtilsStatic.LEAD_LASTNAME1,
        STA_UtilsStatic.LEAD_PHONE1,
        STA_UtilsStatic.LEAD_EMAIL1,
        STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
        STA_UtilsStatic.LEAD_POSTALCODE1,
        STA_UtilsStatic.LEAD_CITY1,
        STA_UtilsStatic.LEAD_STATE1,
        STA_UtilsStatic.LEAD_COUNTRY1
      );
      theLead.rvpe_projectlocation__c = STA_UtilsStatic.LEAD_PROJECT_LOCATION1;
      insert theLead;

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity firstOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        '1st Opp ' + STA_UtilsStatic.TEST,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      Opportunity secondOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        '2nd Opp ' + STA_UtilsStatic.TEST,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      secondOpportunity.rvpe_projectlocation__c = STA_UtilsStatic.LEAD_PROJECT_LOCATION1;
      insert new List<Opportunity>{ firstOpportunity };

      List<Opportunity> resultList = new List<Opportunity>();
      resultList = SMC_AC_LC_LeadController.getDuplicatesOpportunities(
        theLead.rvpe_projectlocation__c
      );

      System.assert(
        resultList.size() == 0,
        'There is a duplication. Check opportunities and relaunch test.'
      );
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_LC_LeadController : testGetDuplicatesOpportunitiesListNotFilled - END'
    );
  }

  /**
  * @description : test SMC_AC_LC_LeadController.getOpportunityFieldsLabel()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetOpportunityFieldsLabel() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_LC_LeadController : testGetOpportunityFieldsLabel - START'
    );

    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    System.runAs(user) {
      System.assert(
        SMC_AC_LC_LeadController.getOpportunityFieldsLabel().size() > 0,
        'The method do not return opportunities fields label.'
      );
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_LC_LeadController : testGetOpportunityFieldsLabel - END'
    );
  }
}