/**
 * @File Name          : SMC_AC_Edit_Report_To_Field.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-08-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    27/02/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public without sharing class SMC_AC_Edit_Report_To_Field {
  /**
   * @description : allow user to change ManagerId for him and other users
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @param newManagerId
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean editManagerId(String recordId, String newManagerId) {
    if (newManagerId != null) {
      User theUser = [SELECT Id, ManagerId FROM User WHERE Id = :recordId];
      theUser.ManagerId = newManagerId;
      return Database.update(theUser).isSuccess();
    } else {
      return false;
    }
  }
}