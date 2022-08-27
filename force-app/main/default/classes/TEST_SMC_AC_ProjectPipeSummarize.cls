/**
 * @File Name          : TEST_AC_ProjectPipeSummarize.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    10/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/

@IsTest
public without sharing class TEST_SMC_AC_ProjectPipeSummarize {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    userStandard.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    insert userStandard;

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
      userStandard.Id
    );
    insert userTerritoryAssociation;

    System.runAs(userStandard) {
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
        userStandard.Id
      );
      genericAccount.isGenericOppAccount__c = true;
      insert genericAccount;
    }
  }

  /**
   * @description : test SMC_AC_ProjectPipeSummarize.getAmountPipe()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void getAmountPipeTest() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(userStandard) {
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity o = new Opportunity();
      o.Name = STA_UtilsStatic.TEST;
      o.CloseDate = Date.today();
      o.OwnerId = UserInfo.getUserID();
      o.StageName = STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED;
      o.RecordTypeId = recordTypeId;
      o.amount = 1.00;
      insert o;
      Decimal amount = SMC_AC_ProjectPipeSummarize.getAmountPipe();
      System.assertEquals(o.Amount, amount, 'The amount does not match.');
    }
  }

  // This method tests the getProjectNumberPipe method
  @IsTest
  public static void getProjectNumberPipeTest() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(userStandard) {
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity o = new Opportunity();
      o.Name = STA_UtilsStatic.TEST;
      o.CloseDate = Date.today();
      o.OwnerId = UserInfo.getUserID();
      o.StageName = STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED;
      o.RecordTypeId = recordTypeId;
      o.amount = 1.00;
      insert o;
      Decimal nbOpp = SMC_AC_ProjectPipeSummarize.getProjectNumberPipe();
      System.assertEquals(
        1,
        nbOpp,
        'The opportunity should not math with filters.'
      );
    }
  }

  /**
   * @description : test SMC_AC_ProjectPipeSummarize.getUserDefaultCurrency()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void getUserDefaultCurrencyTest() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(userStandard) {
      System.assertEquals(
        SMC_AC_ProjectPipeSummarize.getUserDefaultCurrency(),
        UserInfo.getDefaultCurrency(),
        'The user currency not does match.'
      );
    }
  }
}