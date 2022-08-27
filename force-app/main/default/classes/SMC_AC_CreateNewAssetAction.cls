/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_CreateNewAssetAction 
-- - Author : Vincent RECASENS (Modis)
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_CreateNewAssetAction
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 10-APR-2019  VRE     1.0         Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_CreateNewAssetAction {
  /**
   * @description : pass parent asset RecordTypeId to the LC
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param parentId
   * @return Asset
   **/
  @AuraEnabled
  public static Asset getParentInformation(String parentId) {
    Asset parentAsset = [
      SELECT Id, AccountId, LocationId, ContactId, RecordTypeId
      FROM Asset
      WHERE Id = :parentId
    ];

    Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    if (
      parentAsset.RecordTypeId ==
      recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET_GROUP)
        .getRecordTypeId()
    ) {
      //No update on Location!!
      //It is used to pass RecordType information to the LightningComponent
      parentAsset.LocationId = null;
    }

    return parentAsset;
  }
}