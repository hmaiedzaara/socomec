/**
 * @File Name          : SMC_AC_Validate_WOL.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-08-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    10/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_AC_Validate_WOL {
  /**
   * @description : check if WorkOrderLineItem is valide
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param workOrderLineItemId
   * @return String
   **/
  @AuraEnabled
  public static String validatedWOL(Id workOrderLineItemId) {
    //check if already validated
    WorkOrderLineItem woliToValidate = [
      SELECT Id, SMC_Is_Valide__c
      FROM WorkOrderLineItem
      WHERE Id = :workOrderLineItemId
    ];
    if (woliToValidate.SMC_Is_Valide__c) {
      return 'already validated';
    }

    //Check EOL and SparePart
    // Map<String, Boolean> mapWOLValidation = SMC_AP_ManageWorkOrder.isLinkedAssetsEOL(
    //   workOrderLineItemId
    // );

    if (!SMC_AP_ManageWorkOrder.isLinkedAssetsEOL(workOrderLineItemId)) {
      woliToValidate.SMC_Is_Valide__c = true;
      try {
        update woliToValidate;
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'There is an error during the update of the work order line item ' +
          workOrderLineItemId
        );
        return 'error';
      }
    } else {
      return 'not validated';
    }

    return 'validated';
  }
}