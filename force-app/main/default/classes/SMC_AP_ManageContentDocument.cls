/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageContentDocument
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage ContentDocument             
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 12-OCT-2018  (VR)    1.0         Initial version 
---------------------------------------------------------------------
*/
public with sharing class SMC_AP_ManageContentDocument {
  /**
   * @description : prevent partner to delete a file
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @return Boolean
   **/
  public static Boolean communityUserCantDeleteFiles(
    List<ContentDocument> newList
  ) {
    if (newList != null) {
      Profile partnerCommunityUser = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
      ];

      for (ContentDocument oneContentDocument : newList) {
        if (UserInfo.getProfileId() == partnerCommunityUser.Id) {
          // if(!Test.isRunningTest()){
          oneContentDocument.addError(
            String.escapeSingleQuotes(System.Label.SMC_CantDeleteFile),
            true
          );
          // }
          return false;
        }
      }
    } else {
      System.debug(LoggingLevel.INFO, STA_UtilsStatic.ERROR_PARAM_LIST_NULL);
      return false;
    }

    return true;
  }
}