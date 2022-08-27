/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_FileDownload
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is the Apex controller of the lightning 
                   component SMC_LC_FileDownload
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 03-JUL-2019  VRE    1.0         Initial Version
-- 30-OCT-2019  VRE    1.0         Add authorization to display the DOWNLOAD button
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AC_FileDownload {
  /**
   * @description : check if user is allowed to download the file = display the btn DOWNLOAD or not on LC
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param isPublic
   * @param fileId
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean userIsAuthorized(Boolean isPublic, String fileId) {
    //Si PUBLIC --> tlm le voit
    //Si NOT PUBLIC --> visibility par partage du groupe (comme aujourd'hui)
    if (isPublic) {
      return true;
    }

    //Check if the user can access to the file
    try {
      List<ContentDocument> searchList = [
        SELECT Id
        FROM ContentDocument
        WHERE Id = :fileId
      ];
      System.debug(LoggingLevel.INFO, searchList);
      if (searchList != null && searchList.size() > 0) {
        return true;
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'The user with id \'' +
        UserInfo.getUserId() +
        '\' can\'t access to the file.'
      );
    }

    return false;
  }
}