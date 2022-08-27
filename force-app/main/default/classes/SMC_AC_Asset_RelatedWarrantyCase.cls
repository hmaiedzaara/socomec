/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Asset_RelatedWarrantyCase
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_Asset_RelatedWarrantyCase
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 13-FEB-2019  VRE     1.0     	Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_Asset_RelatedWarrantyCase {
  /**
   * @description : get cases with asset's serial number
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param assetId
   * @param whereClause
   * @return List<Case>
   **/
  @AuraEnabled
  public static List<Case> getRelatedCase(String assetId, String whereClause) {
    Asset srcAsset = [SELECT Id, SerialNumber FROM Asset WHERE Id = :assetId];
    List<Case> returnList = new List<Case>();
    if (srcAsset.SerialNumber != null) {
      String query =
        'SELECT Id, CaseNumber, Subject, Status, SMC_Sub_Status__c, SMC_Requested_Deadline__c ' +
        'FROM Case ' +
        ' WHERE SMC_Serial_Number__c = \'' +
        String.escapeSingleQuotes(srcAsset.SerialNumber) +
        '\'';

      // Format "whereClause" : "[Filter] = \'[Value]\'"
      if (
        whereClause != null &&
        !whereClause.startsWith(STA_UtilsStatic.DEFAULT_PICKLIST_VALUE)
      ) {
        query +=
          String.escapeSingleQuotes(
            STA_UtilsStatic.SPACE +
            STA_UtilsStatic.AND_MAJOR +
            STA_UtilsStatic.SPACE
          ) + whereClause;
      }
      returnList = (List<Case>) Database.query(query);
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_Asset_RelatedCase -> Method getRelatedCase - END (returnList : ' +
      returnList +
      ')'
    );
    return returnList;
  }
}