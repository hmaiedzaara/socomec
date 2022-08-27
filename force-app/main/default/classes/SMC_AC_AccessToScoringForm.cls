/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_AccessToScoringForm
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_AccessToScoringForm
--
-- Maintenance History:
--
-- Date 		Name 				Version 	Remarks
-- ----------- 	---- 				------- 	------------------
-- 26-DEC-2017 	Vincent RECASENS	1.0			Initial Version
-- 12-JAN-2018 	Vincent RECASENS	2.0			Add Custom Metadata Types
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_AccessToScoringForm {
  /**
  * @description : check account informations
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  * @param recId 
  * @return String 
  **/
  @AuraEnabled
  public static String getTheAccount(String recId) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_AccessToScoringForm : getTheAccount - START'
    );

    Account account;
    try {
      account = [
        SELECT
          Id,
          Name,
          BillingCountryCode,
          SMC_Category__c,
          SMC_Business__c,
          SMC_PCO_Price_List__c
        FROM Account
        WHERE Id = :recId
      ];
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_AccessToScoringForm : ERROR --> Account id invalid / ' +
        e
      );
    }

    //END METHOD
    //There is only one value in this MDT
    Access_to_Scoring_form__mdt[] mdtUrl = [
      SELECT Url_Access__c, Error_Access__c
      FROM Access_to_Scoring_form__mdt
    ];

    //Check if the redirection is available for this Account
    if (account != null) {
      if (
        account.BillingCountryCode != null &&
        account.SMC_Category__c != null &&
        account.SMC_PCO_Price_List__c != null
      ) {
        System.debug(
          LoggingLevel.INFO,
          '>>>>>> SMC_AC_AccessToScoringForm : getTheAccount (with redirection)- END'
        );
        return mdtUrl[0].Url_Access__c + recId;
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_AccessToScoringForm : getTheAccount (missing fields) - END'
    );
    return mdtUrl[0].Error_Access__c;
  }
}