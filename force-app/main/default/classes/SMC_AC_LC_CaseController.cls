/**
 * @File Name          : SMC_AC_LC_CaseController.cls
 * @Description        :
 * @Author             : David SOBZACK (Socomec)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 14:49:18
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2018   David SOBZACK (Socomec)      Initial Version
 **/

public without sharing class SMC_AC_LC_CaseController {
  /**
   * @description : get html details from case serial number
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param serialNumber
   * @param recordId
   * @return String = html page
   **/
  @AuraEnabled
  public static String getInstalledProductInfosHTML(
    String serialNumber,
    String recordId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getInstalledProductInfosHTML - START sn' +
      serialNumber
    );

    String installedProductInfosHTML = '';
    //TODO - To detele to Winter 20'
    // installedProductInfosHTML = SMC_AP_CaseCallout.getInstalledProductInfosHTML(serialNumber, new List<String>{'CaseId : ' + recordId});

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getInstalledProductInfosHTML - END'
    );
    return installedProductInfosHTML;
  }

  /**
   * @description : get sales order informations
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param orderNumber
   * @param recordId
   * @return List<SMC_DTO_SalesOrderDetails>
   **/
  @AuraEnabled
  public static List<SMC_DTO_SalesOrderDetails> getSalesOrderInfos(
    String orderNumber,
    String recordId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getSalesOrderInfos - START orderNumber' +
      orderNumber
    );

    List<SMC_DTO_SalesOrderDetails> orderNumberDetails = new List<SMC_DTO_SalesOrderDetails>();
    orderNumberDetails = SMC_AP_CaseCallout.getSalesOrderInfos(
      orderNumber,
      new List<String>{ 'CaseId : ' + recordId }
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getSalesOrderInfos - END'
    );
    return orderNumberDetails;
  }

  /**
   * @description : get the related warranty case based on a case id
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param sourceCaseId
   * @return List<Case>
   **/
  @AuraEnabled
  public static List<Case> getRelatedWarrantyCase(String sourceCaseId) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getRelatedWarrantyCase - START (sourceCaseId : ' +
      sourceCaseId +
      ')'
    );

    Case srcCase = [
      SELECT Id, Subject, Type, SMC_Serial_Number__c
      FROM Case
      WHERE Id = :sourceCaseId
    ];

    List<Case> returnList = new List<Case>();
    if (srcCase.SMC_Serial_Number__c != null) {
      returnList = [
        SELECT
          Id,
          CaseNumber,
          Subject,
          Status,
          SMC_Sub_Status__c,
          SMC_Requested_Deadline__c
        FROM Case
        WHERE
          SMC_Serial_Number__c = :srcCase.SMC_Serial_Number__c
          AND Id != :sourceCaseId
          AND Type = :STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS
      ];
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_CaseController -> Method getRelatedWarrantyCase - END (returnList : ' +
      returnList +
      ')'
    );
    return returnList;
  }
}