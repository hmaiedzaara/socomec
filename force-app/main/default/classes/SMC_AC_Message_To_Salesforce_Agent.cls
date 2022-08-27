/**
 * @File Name          : SMC_AC_Message_To_Salesforce_Agent.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-08-2020
 * @Modification Log   :
 * Ver    Date         Author  Modification
 * 1.0    06/01/2020   VRE     Initial Version
 **/

public with sharing class SMC_AC_Message_To_Salesforce_Agent {
  /**
   * @description : insert new CommunityMessage from Other and PB send the email
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param title
   * @param body
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean createCommunityMessage(String title, Blob body) {
    System.debug(LoggingLevel.INFO, 'createCommunityMessage START');
    try {
      //Find the ContactId
      User theUser = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];

      SMC_Community_Message__c oneMessage = new SMC_Community_Message__c();
      oneMessage.SMC_Send_From__c = STA_UtilsStatic.OTHER;
      oneMessage.Title__c = title;
      oneMessage.Message__c = body.toString();
      oneMessage.Recipient_Contact__c = theUser.ContactId;
      return Database.insert(oneMessage).isSuccess();
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
      return false;
    }
  }
}