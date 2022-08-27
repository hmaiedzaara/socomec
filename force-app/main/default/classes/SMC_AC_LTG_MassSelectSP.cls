/**
 * @File Name          : SMC_AC_LTG_MassSelectSP.cls
 * @Description        : Apex ontroler of component to select multiple ServiceProduct
 * @Author             : Emmanuel BERNIER (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-18-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/06/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

public without sharing class SMC_AC_LTG_MassSelectSP {

  public class GTLDefinitionStruct {
    List<SMC_GtlServiceProductAssociation__c> selectedServiceProductList;
    List<Product2> serviceProductList;
    public GTLDefinitionStruct(String searchkey, id gtlLineId) {
      selectedServiceProductList = [
        SELECT id, SMC_Service_Product__r.Name, SMC_Service_Product__c
        FROM SMC_GtlServiceProductAssociation__c
        WHERE SMC_Logistic_Technical_Guide__c = :gtlLineId
        ORDER BY SMC_Service_Product__r.Name ASC
      ];
      serviceProductList = SMC_AC_LTG_MassSelectSP.refreshServiceProductList(
        searchkey,
        1
      );
    }
  }

  /**
   * @description : get service product
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param searchkey
   * @param gtlLineId
   * @return String = serialization(GTLDefinitionStruct)
   **/
  @AuraEnabled
  public static String getServiceProduct(String searchkey, id gtlLineId) {
    GTLDefinitionStruct retVal = new GTLDefinitionStruct(searchkey, gtlLineId);
    System.debug(LoggingLevel.INFO, retVal);
    return JSON.serialize(retVal);
  }

  /**
   * @description : refresh service product list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param searchkey
   * @return String = serialization(List<Product2>)
   **/
  @AuraEnabled
  public static String refreshServiceProduct(String searchkey, Integer factorOffset) {
    return JSON.serialize(
      GTLDefinitionStruct.refreshServiceProductList(searchkey, factorOffset)
    );
  }

  /**
   * @description : insert or delete SMC_GtlServiceProductAssociation__c
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param idList
   * @param gtlLineId
   **/
  @AuraEnabled
  public static void updateAssociation(String idList, id gtlLineId) {
    list<String> strIdList = (list<String>) JSON.deserialize(
      idList,
      list<String>.class
    );
    //Delete all
    List<SMC_GtlServiceProductAssociation__c> removedList = new List<SMC_GtlServiceProductAssociation__c>();
    List<String> removedProductNameList = new List<String>();
    for (SMC_GtlServiceProductAssociation__c oneAsso : [
      SELECT
        Id,
        SMC_Service_Product__r.Name,
        SMC_Logistic_Technical_Guide__r.Name
      FROM SMC_GtlServiceProductAssociation__c
      WHERE
        SMC_Service_Product__c NOT IN :strIdList
        AND SMC_Logistic_Technical_Guide__c = :gtlLineId
    ]) {
      removedList.add(oneAsso);
      removedProductNameList.add(oneAsso.SMC_Service_Product__r.Name);
    }
    if (removedList != null && removedList.size() > 0) {
      delete removedList;
    }

    //Get new asso
    List<String> addedProductNameList = new List<String>();
    List<String> addedProductIdList = new List<String>();
    Map<Id, SMC_GtlServiceProductAssociation__c> gtlAssociationMap = new Map<Id, SMC_GtlServiceProductAssociation__c>();
    for (SMC_GtlServiceProductAssociation__c asso : [
      SELECT Id, SMC_Service_Product__c, SMC_Service_Product__r.Name
      FROM SMC_GtlServiceProductAssociation__c
      WHERE SMC_Logistic_Technical_Guide__c = :gtlLineId
    ]) {
      gtlAssociationMap.put(asso.SMC_Service_Product__c, asso);
    }
    List<SMC_GtlServiceProductAssociation__c> newAssoList = new List<SMC_GtlServiceProductAssociation__c>();
    for (String idServiceProduct : strIdList) {
      if (gtlAssociationMap.get(idServiceProduct) == null) {
        newAssoList.add(
          new SMC_GtlServiceProductAssociation__c(
            SMC_Service_Product__c = idServiceProduct,
            SMC_Logistic_Technical_Guide__c = gtlLineId
          )
        );
        addedProductIdList.add(idServiceProduct);
      }
    }
    //Insert new
    insert newAssoList;

    if (addedProductIdList.size() > 0) {
      for (Product2 onePdt : [
        SELECT Name
        FROM Product2
        WHERE Id IN :addedProductIdList
      ]) {
        addedProductNameList.add(onePdt.Name);
      }
    }

    //Update historic
    if (addedProductNameList.size() > 0 || removedProductNameList.size() > 0) {
      manageHistoric(gtlLineId, addedProductNameList, removedProductNameList);
    }
  }

  /**
   * @description : refresh service product list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param searchkey
   * @return List<Product2>
   **/
  // @TestVisible
  // private static List<Product2> refreshServiceProductList(String searchkey) {
  //   List<Product2> serviceProductList = new List<Product2>();
  //   if (searchkey.length() > 0) {
  //     List<List<SObject>> searchList = [
  //       FIND :searchkey
  //       IN NAME FIELDS
  //       RETURNING
  //         Product2(
  //           id,
  //           Name
  //           WHERE recordtype.developername = 'SMC_Service_Product')
  //       LIMIT 1000
  //     ];
  //     for (SObject obj : searchList[0]) {
  //       serviceProductList.add(
  //         new Product2(id = (Id) obj.get('Id'), Name = (String) obj.get('Name'))
  //       );
  //     }
  //   } else {
  //     serviceProductList = [
  //       SELECT Id, Name
  //       FROM product2
  //       WHERE recordtype.developername = 'SMC_Service_Product'
  //       LIMIT 1000
  //     ];
  //   }
  //   return serviceProductList;
  // }

  /**
   * @description : refresh service product list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param searchkey
   * @return List<Product2>
   **/
  @TestVisible
  private static List<Product2> refreshServiceProductList(String searchkey, Integer factorOffset) {
    List<Product2> serviceProductList = new List<Product2>();
    Integer queryLimit = 100;
    Integer offset = factorOffset*queryLimit;
    if (searchkey != null && searchkey.length() > 0) {
      searchkey = '\'' + searchkey + '\'';
      List<List<SObject>> searchList = [
        FIND :searchkey
        IN NAME FIELDS
        RETURNING
          Product2(
            Id,
            Name
          WHERE recordtype.developername = 'SMC_Service_Product' 
          ORDER BY CreatedDate
          LIMIT :queryLimit 
          OFFSET :offset
          )
      ];
      for (SObject obj : searchList[0]) {
        serviceProductList.add(
          new Product2(Id = (Id) obj.get('Id'), Name = (String) obj.get('Name'))
        );
      }
    } else {
      serviceProductList = [
        SELECT Id, Name
        FROM product2
        WHERE recordtype.developername = 'SMC_Service_Product' 
        ORDER BY CreatedDate
        LIMIT :queryLimit
        OFFSET :offset
      ];
    }
    return serviceProductList;
  }

  @AuraEnabled
  public static List<String> getInformationsList(String recordId) {
    //Search historic
    String strTmp = [
      SELECT SMC_Historic_Service_Product__c
      FROM SMC_GTL__c
      WHERE Id = :recordId
    ]
    .SMC_Historic_Service_Product__c;
    List<String> returnList = new List<String>();
    if(strTmp == null){
      return returnList;
    }

    //Sort historic
    String[] tmpTabOld = strTmp.split(';');
    for (Integer i = 0; i < tmpTabOld.size(); ++i) {
      if (
        tmpTabOld[i] != null &&
        (tmpTabOld[i].startsWith('Add') || tmpTabOld[i].startsWith('Remove'))
      ) {
        returnList.add(tmpTabOld[i]);
      } else {
        if (tmpTabOld[i] != null && tmpTabOld[i] != '') {
          if (returnList.size() > 0) {
            returnList.add(
              '------------------------------------------------------------'
            );
          } //modification separator
          returnList.add(tmpTabOld[i]);
        }
      }
    }
    return returnList;
  }

  private static void manageHistoric(
    String gtlLineId,
    List<String> addedProductNameList,
    List<String> removedProductNameList
  ) {
    SMC_GTL__c gtlLine = [
      SELECT Id, SMC_Historic_Service_Product__c
      FROM SMC_GTL__c
      WHERE Id = :gtlLineId
    ];
    String oldHistoric = (gtlLine.SMC_Historic_Service_Product__c != null
      ? gtlLine.SMC_Historic_Service_Product__c
      : '');
    String newUpdate =
      ';' +
      Datetime.now().format() +
      ' - ' +
      UserInfo.getName() +
      ' :;';
    Boolean hasModification = false;
    //Set added service product
    if (addedProductNameList != null && addedProductNameList.size() > 0) {
      for (String onePdtName : addedProductNameList) {
        newUpdate += System.Label.SMC_Added + ' ' + onePdtName + ';';
        hasModification = true;
      }
    }
    //Set removed service product
    if (removedProductNameList != null && removedProductNameList.size() > 0) {
      for (String onePdtName : removedProductNameList) {
        newUpdate += System.Label.SMC_Removed + ' ' + onePdtName + ';';
        hasModification = true;
      }
    }

    //Set historic
    if (hasModification) {
      //Update historic
      gtlLine.SMC_Historic_Service_Product__c = newUpdate + oldHistoric;
      update gtlLine;
    }
  }
}