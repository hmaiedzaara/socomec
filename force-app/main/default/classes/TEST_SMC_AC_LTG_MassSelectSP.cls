/**
 * @File Name          : TEST_SMC_AC_LTG_MassSelectSP.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-18-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/06/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AC_LTG_MassSelectSP {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @TestSetup
  static void makeData() {
    List<product2> prodList = new List<product2>();
    Id recTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
      .getRecordTypeId();
    for (Integer i = 0; i < 100; i++) {
      prodList.add(
        SMC_UTIL_TestUtils.createProductFSL(recTypeId, 'prod ' + i, true)
      );
    }
    insert prodList;
    Product2 spare = SMC_UTIL_TestUtils.createProductFSL(
      Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId(),
      'spare',
      true
    );
    insert spare;
    System.debug(LoggingLevel.INFO, 'spare id ' + spare.id);
    insert SMC_UTIL_TestUtils.createGTL(
      spare.id,
      'spareCode',
      STA_UtilsStatic.GTL_ACTIVE
    );
  }
  /**
   * @description : test SMC_AC_LTG_MassSelectSP.[getServiceProduct() / refreshServiceProduct() / updateAssociation()]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  static void testGetProduct() {
    SMC_GTL__c gtl = [SELECT id FROM SMC_GTL__c LIMIT 1];
    list<Id> fixedSearchResults = new List<Id>();
    list<product2> prodList = [
      SELECT id, name
      FROM product2
      WHERE
        recordtypeid = :Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
          .getRecordTypeId()
      LIMIT 4
    ];
    for (product2 prod : prodList) {
      fixedSearchResults.add(prod.id);
    }
    Test.setFixedSearchResults(fixedSearchResults);
    test.startTest();
    SMC_AC_LTG_MassSelectSP.getServiceProduct('', gtl.id);
    SMC_AC_LTG_MassSelectSP.refreshServiceProduct('prod', 1);
    test.stopTest();
    SMC_AC_LTG_MassSelectSP.updateAssociation(
      '["' +
      prodlist[0].id +
      '","' +
      prodList[1].id +
      '","' +
      prodList[2].id +
      '"]',
      gtl.id
    );
    System.assertEquals(
      3,
      [SELECT id FROM SMC_GtlServiceProductAssociation__c].size(),
      'There is no SMC_GtlServiceProductAssociation__c, Product2 or SMC_GTL__c.'
    );
    SMC_AC_LTG_MassSelectSP.updateAssociation(
      '["' +
      prodlist[3].id +
      '","' +
      prodList[2].id +
      '"]',
      gtl.id
    );
    System.assertEquals(
      2,
      [SELECT id FROM SMC_GtlServiceProductAssociation__c].size(),
      'There is no SMC_GtlServiceProductAssociation__c, Product2 or SMC_GTL__c.'
    );
  }
}