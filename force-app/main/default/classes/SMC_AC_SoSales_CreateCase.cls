/**
 * @File Name          : SMC_AC_SoSales_CreateCase.cls
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/06/2020 à 11:14:05
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    26/02/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_AC_SoSales_CreateCase {
  /**
   * @description : get case informations for child case creation
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @return Case
   **/
  @AuraEnabled
  public static Case getCase(String recordId) {
    Case theCase = [
      SELECT
        Id,
        Subject,
        AccountId,
        ContactId,
        SMC_Internal_Requestor__c,
        SMC_SOV_Number__c,
        SMC_TECH_Closure_pilot__c,
        SMC_Serial_Number__c,
        ProductId,
        SMC_Quote__c,
        Opportunity__c,
        SMC_End_customer__c
      FROM Case
      WHERE Id = :recordId
    ];

    if (theCase.SMC_Internal_Requestor__c == null) {
      theCase.SMC_Internal_Requestor__c = UserInfo.getUserId();
    }
    return theCase;
  }
}