/**
 * @File Name          : SMC_AC_Modify_Company_Informations.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 12-01-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    26/05/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public with sharing class SMC_AC_Modify_Company_Informations {
  /**
   * @description : get account name from current user
   * @author Vincent RECASENS (Modis) | 27/05/2020
   * @return String
   **/
  @AuraEnabled
  public static String getAccountName() {
    String result;
    try {
      result = [
        SELECT Name
        FROM Account
        WHERE
          Id = :[
            SELECT SMC_Account_Id__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
          ]
          .SMC_Account_Id__c
      ]
      .Name;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'User has no account linked --> ERROR : ' + e
      );
    }

    return result;
  }

  /**
   * @description : check if current user is ContactAdministrator of the account
   * @author Vincent RECASENS (Modis) | 11-30-2020
   **/
  @AuraEnabled
  public static Boolean checkContactAdministrator() {
    try {
      User currentUser = [
        SELECT ContactId, SMC_Account_Id__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
      Account theAccount = [
        SELECT SMC_IOT_Administrative_Contact__c
        FROM Account
        WHERE Id = :currentUser.SMC_Account_Id__c
      ];
      return (currentUser.ContactId != null &&
      currentUser.ContactId == theAccount.SMC_IOT_Administrative_Contact__c);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'User is not the administrative contact : ' + e
      );
    }

    return false;
  }

  /**
   * @description : create case for account information modification
   * @author Vincent RECASENS (Modis) | 11-30-2020
   **/
  @AuraEnabled
  public static void createCase(String subject, Blob description) {
    //Get contact informations
    User currentUser = [
      SELECT ContactId, SMC_Account_Id__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    insert new Case(
      Subject = subject,
      Description = description.toString(),
      AccountId = currentUser.SMC_Account_Id__c,
      ContactId = currentUser.ContactId,
      Type = 'SMC_Customer_Claim',
      Origin = 'IOT Customer Portal'
    );
  }
}