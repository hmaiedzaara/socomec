/**
 * @File Name          : TEST_SMC_AP_ManageGTL.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-18-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    19/02/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@istest
public without sharing class TEST_SMC_AP_ManageGTL {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @TestSetup
  static void makeData() {
    Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
      .getRecordTypeId();
    Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
      .getRecordTypeId();

    Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
      productRecordTypeId,
      STA_UtilsStatic.TEST,
      true
    );
    Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
      idSpareRecordTypeId,
      'spare1',
      true
    );
    spare1.ProductCode = 'SP-0001';
    Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
      idSpareRecordTypeId,
      'spare2',
      true
    );
    insert new List<Product2>{ theProduct, spare1, spare2 };
  }

  /*
    @IsTest
    static void testDoublon(){
        product2 spare1 = [select id from product2 where name='spare1' limit 1];
        product2 spare2 = [select id from product2 where name='spare2' limit 1];
        try {
            SMC_GTL__c gltLine= new SMC_GTL__c(SMC_Spare_Part__c=spare1.id,SMC_Start_Date__c=date.today());
            insert gltLine;
            update gltLine;
            insert new SMC_GTL__c(SMC_Spare_Part__c=spare1.id,SMC_Start_Date__c=date.today().addDays(-6),SMC_ValidityDate__c=date.today().addDays(-2));
            insert new SMC_GTL__c(SMC_Spare_Part__c=spare2.id,SMC_Start_Date__c=date.today());
            insert new SMC_GTL__c(SMC_Spare_Part__c=spare2.id,SMC_Start_Date__c=date.today().addDays(-6),SMC_ValidityDate__c=date.today().addDays(-2));
            insert new SMC_GTL__c(SMC_Spare_Part__c=spare2.id,SMC_Start_Date__c=date.today());
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e);
        }
        system.assertEquals(4, [select id from SMC_GTL__c].size());

    }
    */

  /**
   * @description : test SMC_AP_ManageGTL.duplicateKey() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  static void testDoublon() {
    product2 spare1 = [SELECT id FROM product2 WHERE name = 'spare1' LIMIT 1];
    product2 spare2 = [SELECT id FROM product2 WHERE name = 'spare2' LIMIT 1];

    try {
      insert new SMC_GTL__c(
        SMC_Spare_Part__c = spare1.id,
        SMC_Start_Date__c = date.today(),
        SMC_Status_GTL__c = STA_UtilsStatic.GTL_ACTIVE
      );
      insert new SMC_GTL__c(
        SMC_Spare_Part__c = spare2.id,
        SMC_Start_Date__c = date.today(),
        SMC_Comment__c = 'One Comment',
        SMC_Status_GTL__c = STA_UtilsStatic.GTL_ACTIVE
      );
      insert new SMC_GTL__c(
        SMC_Spare_Part__c = spare2.id,
        SMC_Start_Date__c = date.today(),
        SMC_Comment__c = 'One Comment',
        SMC_Status_GTL__c = STA_UtilsStatic.GTL_ACTIVE
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, e);
    }

    System.assertEquals(
      2,
      [SELECT id FROM SMC_GTL__c].size(),
      'GTL are not inserted.'
    );
  }

  /**
   * @description : test SMC_AP_ManageGTL.invalidateGtlLine()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInvalidateGtlLine() {
    Product2 theProduct = [
      SELECT Id
      FROM Product2
      WHERE Name = :STA_UtilsStatic.TEST
    ];
    Product2 spare1 = [
      SELECT Id, ProductCode
      FROM Product2
      WHERE Name = 'spare1'
    ];
    Product2 spare2 = [SELECT Id FROM Product2 WHERE Name = 'spare2'];

    SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
      spare1.Id,
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.GTL_ACTIVE
    );
    insert theGtl;

    SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
      theProduct.Id,
      theGtl.Id
    );
    insert theGTLAssociation;

    Test.startTest();
    //Check Association for the future obsolete GTL line
    List<SMC_GtlServiceProductAssociation__c> checkAssociations = [
      SELECT Id
      FROM SMC_GtlServiceProductAssociation__c
      WHERE SMC_Logistic_Technical_Guide__c = :theGTL.Id
    ];
    System.assertEquals(1, checkAssociations.size(), 'GTL is not inserted.');
    theGTL = [
      SELECT
        Id,
        SMC_ValidityDate__c,
        SMC_Spare_Part_Code__c,
        SMC_New_Spare_Part__c,
        SMC_Old_Spare_Part__c
      FROM SMC_GTL__c
      WHERE SMC_Spare_Part__c = :spare1.Id
    ];
    theGtl.SMC_Status_GTL__c = STA_UtilsStatic.GTL_OBSOLETE;
    theGtl.SMC_New_Spare_Part__c = spare2.Id;
    update theGtl;

    SMC_GTL__c checkDuplicateGTL = [
      SELECT
        Id,
        SMC_Start_Date__c,
        SMC_ValidityDate__c,
        SMC_New_Spare_Part__c,
        SMC_Old_Spare_Part__c,
        SMC_Status_GTL__c
      FROM SMC_GTL__c
      WHERE SMC_Spare_Part__c = :spare2.Id
    ];
    System.assertEquals(
      null,
      checkDuplicateGTL.SMC_New_Spare_Part__c,
      'GTL has a NewSparePart filled.'
    );
    System.assertEquals(
      theGtl.SMC_Spare_Part_Code__c,
      checkDuplicateGTL.SMC_Old_Spare_Part__c,
      'Duplication failed.'
    );
    System.assertEquals(
      STA_UtilsStatic.GTL_OBSOLETE,
      theGtl.SMC_Status_GTL__c,
      'Duplication failed.'
    );
    System.assertEquals(
      STA_UtilsStatic.GTL_NOT_YET_ACTIVE,
      checkDuplicateGTL.SMC_Status_GTL__c,
      'Duplication failed.'
    );
    System.assertEquals(
      theGtl.SMC_ValidityDate__c,
      checkDuplicateGTL.SMC_Start_Date__c,
      'Duplication failed.'
    );

    List<SMC_GtlServiceProductAssociation__c> checkDuplicateAssociations = [
      SELECT Id
      FROM SMC_GtlServiceProductAssociation__c
      WHERE SMC_Logistic_Technical_Guide__c = :checkDuplicateGTL.Id
    ];
    System.assertEquals(
      1,
      checkDuplicateAssociations.size(),
      'Duplication failed.'
    );
    Test.stopTest();
  }
  /**
   * @description : test SMC_AP_ManageGTL.duplicateKey() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  static void testManageGTLComment() {
    product2 spare1 = [SELECT id FROM product2 WHERE name = 'spare1' LIMIT 1];
    SMC_GTL__c theGtl = new SMC_GTL__c(
      SMC_Spare_Part__c = spare1.id,
      SMC_Start_Date__c = date.today(),
      SMC_Status_GTL__c = STA_UtilsStatic.GTL_ACTIVE,
      SMC_Comment__c = 'Test'
    );
    insert theGtl;

    theGtl.SMC_Comment__c = 'Comment is changed';
    update theGtl;

    System.assertEquals(
      'Comment is changed',
      [SELECT Id, SMC_Comment__c FROM SMC_GTL__c WHERE Id = :theGtl.Id]
      .SMC_Comment__c,
      'GTL comment is not updated.'
    );
    System.assertEquals(
      1,
      [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :theGtl.Id]
        .size(),
      'Note is not created.'
    );
  }
}