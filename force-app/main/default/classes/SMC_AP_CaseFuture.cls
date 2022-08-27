/**
 * @File Name          : SMC_AP_CaseFuture.cls
 * @Description        :
 * @Author             : David SOBZACK (Socomec) / Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09/04/2020 à 09:47:28
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2018   David SOBZACK (Socomec)      Initial Version
 * 1.0    ??/??/2019   Vincent RECASENS (Modis)     Add bulkification
 **/

public without sharing class SMC_AP_CaseFuture {
  /**
   * @description : update case product informations from case serial number
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param caseIds
   * @param isInsert 
   **/
  @Future(callout=true)
  public static void updateCasesProductInfo(Set<Id> caseIds, Boolean isInsert) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method updateCasesProductInfo - START'
    );

    //Bypass method if the input list is empty
    if (caseIds == null || caseIds.size() == 0) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_CaseFuture -> Method updateCasesProductInfo : no update'
      );
      return;
    }

    List<Case> cases = [
      SELECT
        Id,
        SMC_Serial_Number__c,
        /*SMC_Product_Text__c, */
        SMC_Product_Family__c,
        SMC_Product_Power__c,
        SMC_Product_Sub_Family__c,
        SMC_Product_Configuration__c /*,
        OwnerId,
        Owner.SMC_Queue_ID__c,
        SMC_Expert_Queue__c*/
      FROM Case
      WHERE Id IN :caseIds
    ];

    // Build the requestBody
    Set<String> serialNumbers = new Set<String>();
    Map<String, List<Case>> mappingSerialNumberToCase = new Map<String, List<Case>>();
    List<String> recordList = new List<String>();
    for (Case oneCase : cases) {
      serialNumbers.add(oneCase.SMC_Serial_Number__c);
      if (mappingSerialNumberToCase.containsKey(oneCase.SMC_Serial_Number__c)) {
        mappingSerialNumberToCase.get(oneCase.SMC_Serial_Number__c)
          .add(oneCase);
      } else {
        mappingSerialNumberToCase.put(
          oneCase.SMC_Serial_Number__c,
          new List<Case>{ oneCase }
        );
      }
    }
    //Request Body
    String serialNumbersJSON =
      STA_UtilsStatic.OPEN_ACCOLADE +
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_JSON_KEY +
      (String) JSON.serialize(serialNumbers) +
      STA_UtilsStatic.CLOSE_ACCOLADE;

    // Callout WS
    List<SMC_DTO_SN_ProductInfo> snPis = new List<SMC_DTO_SN_ProductInfo>();
    snPis = SMC_AP_CaseCallout.getSNProductInfo(serialNumbersJSON, recordList);

    //Treat WS response
    if (snPis == null || snPis.size() == 0) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_CaseFuture -> Method updateCasesProductInfo - error/empty response from server - END'
      );
      return;
    }
    List<Case> casesToUpdate = new List<Case>();
    for (SMC_DTO_SN_ProductInfo oneSnPi : snPis) {
      for (Case c : mappingSerialNumberToCase.get(oneSnPi.serialNumber)) {
        if (string.isBlank(oneSnPi.productFamily)) {
          c.SMC_Product_Family__c = STA_UtilsStatic.EMPTY_STRING;
        } else {
          c.SMC_Product_Family__c = oneSnPi.productFamily;
        }

        if (string.isBlank(oneSnPi.productModel)) {
          c.SMC_Product_Sub_Family__c = STA_UtilsStatic.EMPTY_STRING;
        } else {
          c.SMC_Product_Sub_Family__c = oneSnPi.productModel;
        }

        if (string.isBlank(oneSnPi.productConfig)) {
          c.SMC_Product_Configuration__c = STA_UtilsStatic.EMPTY_STRING;
        } else {
          c.SMC_Product_Configuration__c = oneSnPi.productConfig;
        }

        if (oneSnPi.rate == null) {
          c.SMC_Product_Power__c = STA_UtilsStatic.EMPTY_STRING;
        } else {
          c.SMC_Product_Power__c = string.valueOf(oneSnPi.rate);
        }

        casesToUpdate.add(c);
      }
    }

    //Reaffect AssignmentRules on insert
    if (isInsert) {
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.AssignmentRuleHeader.useDefaultRule = true;
      for (Case oneCase : casesToUpdate) {
        oneCase.setOptions(dmo);
      }
    }

    //Update
    try {
      update casesToUpdate;
    } catch (DmlException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR <<SMC_AP_ManageCase.updateCasesProductInfo>> : Exception --> ' +
        dmlException
      );
    }

    System.debug( 
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method updateCasesProductInfo - END'
    );
  }

  /**
   * @description : callout to send CIMsa visit to external server
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newCaseIdSet 
   **/
  @Future(callout=true)
  public static void sendCimsaVisit(Set<Id> newCaseIdSet) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method sendCimsaVisit - START'
    );

    //Bypass method if the input list is empty
    if (newCaseIdSet == null || newCaseIdSet.size() != 1) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_CaseFuture -> Method sendCimsaVisit : no visit created - Bad Set<Id> (null or too much element)'
      );
      return;
    }

    Id newCaseId;
    for (Id oneId : newCaseIdSet) {
      newCaseId = oneId;
    }
    User currentUser = [
      SELECT Alias
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    List<Case> theCaseList = [
      SELECT
        Id,
        TECH_SMC_SafeId__c,
        CaseNumber,
        SMC_Serial_Number__c,
        TECH_SMC_CIMSA_Visit_CheckStatus__c,
        SMC_IsVisitCimsaCreationSent__c,
        SMC_CIMSA_Visit_Number__c,
        SMC_CIMSA_Visit_Under__c,
        SMC_CIMSA_Visit_Category__c,
        SMC_CIMSA_Planned_Date__c,
        SMC_CIMSA_Estimated_Work__c,
        SMC_CIMSA_Number_Of_Visit__c
      FROM Case
      WHERE Id = :newCaseId
    ];

    Case theCase;
    if (theCaseList.size() == 0) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_CaseFuture -> Method sendCimsaVisit : no visit created - List empty'
      );
      return;
    } else if (theCaseList.size() != 1) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_CaseFuture -> Method sendCimsaVisit : no visit created - Too much element in the list'
      );
      return;
    } else {
      theCase = theCaseList[0];
    }

    SMC_DTO_CimsaVisit resultCallout;
    if (theCase != null) {
      SMC_DTO_CimsaVisit dtoCimsaVisit;
      dtoCimsaVisit = new SMC_DTO_CimsaVisit();
      dtoCimsaVisit.VISUNDID = theCase.SMC_CIMSA_Visit_Under__c;
      dtoCimsaVisit.VISCATID = theCase.SMC_CIMSA_Visit_Category__c;
      dtoCimsaVisit.VISSN = theCase.SMC_Serial_Number__c;
      dtoCimsaVisit.VISPL = theCase.SMC_CIMSA_Planned_Date__c.format();
      dtoCimsaVisit.VIEWH = String.valueOf(theCase.SMC_CIMSA_Estimated_Work__c);
      dtoCimsaVisit.SFUSER = currentUser.Alias;
      dtoCimsaVisit.SFCASE = theCase.CaseNumber;
      dtoCimsaVisit.SFCASEID = theCase.TECH_SMC_SafeId__c;

      resultCallout = SMC_AP_CaseCallout.createCimsaVisit(
        JSON.serialize(dtoCimsaVisit),
        new List<String>{ 'Case : ' + theCase.Id }
      );

      if (resultCallout.calloutResponse) {
        theCase.SMC_CIMSA_Visit_Number__c = resultCallout.VICODE;
        if (theCase.SMC_CIMSA_Number_Of_Visit__c != null) {
          theCase.SMC_CIMSA_Number_Of_Visit__c += 1;
        } else {
          theCase.SMC_CIMSA_Number_Of_Visit__c = 1;
        }
        theCase.TECH_SMC_CIMSA_Visit_CheckStatus__c = false;
      } else {
        theCase.TECH_SMC_CIMSA_Visit_CheckStatus__c = true;
      }
      theCase.SMC_IsVisitCimsaCreationSent__c = false;
    }

    try {
      update theCase;
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method sendCimsaVisit - END'
    );
  }

  /**
   * @description : reset case fields related to CIMsa
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newCaseIdSet 
   **/
  @Future
  public static void resetCimsaVisitBoolean(Set<Id> newCaseIdSet) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method resetCimsaVisitBoolean - START'
    );

    Id newCaseId;
    for (Id oneId : newCaseIdSet) {
      newCaseId = oneId;
    }
    List<Case> theCaseList = [
      SELECT Id, SMC_IsVisitCimsaCreationSent__c
      FROM Case
      WHERE Id = :newCaseId
    ];
    for (Case oneCase : theCaseList) {
      oneCase.SMC_IsVisitCimsaCreationSent__c = false;
    }
    update theCaseList;

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture -> Method resetCimsaVisitBoolean - END'
    );
  }
}