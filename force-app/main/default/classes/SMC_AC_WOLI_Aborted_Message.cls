/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-07-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-10-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public class SMC_AC_WOLI_Aborted_Message {
  /**
   * @description : get WOLI informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param recordId
   * @return List<String>
   **/
  @AuraEnabled
  public static List<String> getWoliInfos(String recordId) {
    WorkOrder theWorkOrder = [
      SELECT SMC_Work_Order_Line_Items_aborted__c
      FROM WorkOrder
      WHERE Id = :recordId
    ];
    if (
      theWorkOrder != null &&
      theWorkOrder.SMC_Work_Order_Line_Items_aborted__c != null
    ) {
      return theWorkOrder.SMC_Work_Order_Line_Items_aborted__c.split(';');
    }
    return null;
  }
}