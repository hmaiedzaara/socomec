/*
---------------------------------------------------------------------------
-- - Name : SMC_AP_ManageAssociatedLocation
-- - Author : Vincent RECASENS
-- - Description : This class manage Associated Location
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 03-APR-2019  VRE  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageAssociatedLocation {
  /**
   * @description : manage the location in according to its type
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap 
   **/
  public static void manageAssociatedLocationType(
    Map<Id, AssociatedLocation> newMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAssociatedLocation manageAssociatedLocationType: START <<< ##'
    );

    Map<Id, Id> mapLocationIdToAccountId = new Map<Id, Id>();
    Map<Id, Id> mapAccountIdToAssociatedLocationListId = new Map<Id, Id>();
    List<Id> accountIds = new List<Id>();
    for (Id key : newMap.keySet()) {
      // System.debug(LoggingLevel.INFO, 'newMap.get(key) : ' + newMap.get(key));
      if (
        newMap.get(key).Type == STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE
      ) {
        mapAccountIdToAssociatedLocationListId.put(
          newMap.get(key).ParentRecordId,
          key
        );
        mapLocationIdToAccountId.put(
          newMap.get(key).LocationId,
          newMap.get(key).ParentRecordId
        );
      }
    }

    changeAssociatedLocationType(
      newMap,
      /*mapAccountIdToAssociatedLocationListId, */ mapLocationIdToAccountId
    );
    SMC_AP_ManageLocation.updateSiteAccountFromNewAssociatedLocationSite(
      mapLocationIdToAccountId
    );

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAssociatedLocation manageAssociatedLocationType: END <<< ##'
    );
  }

  /**
   * @description : change the associated location type
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap 
   **/
  public static void changeAssociatedLocationType(
    Map<Id, AssociatedLocation> mapAssociatedLocation,
    /*Map<Id, Id> mapAccountIdToAssociatedLocationListId, */ Map<Id, Id> mapLocationIdToAccountId
  ) {
    // System.debug(LoggingLevel.INFO, 'mapAssociatedLocation : ' + mapAssociatedLocation);
    // System.debug(LoggingLevel.INFO, 'mapAccountIdToAssociatedLocationListId : ' + mapAccountIdToAssociatedLocationListId);
    List<AssociatedLocation> associatedLocationToUpdate = new List<AssociatedLocation>();
    for (
      AssociatedLocation associadtedLocation : [
        SELECT Id, LocationId, ParentRecordId, Type
        FROM AssociatedLocation
        WHERE
          Id NOT IN :mapAssociatedLocation.keySet()
          // AND ParentRecordId IN :mapAccountIdToAssociatedLocationListId.keySet()
          AND LocationId IN :mapLocationIdToAccountId.keySet()
          AND Type = :STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE
      ]
    ) {
      associadtedLocation.Type = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_OTHER;
      // System.debug(LoggingLevel.INFO, 'associadtedLocation : ' + associadtedLocation);
      associatedLocationToUpdate.add(associadtedLocation);
    }

    update associatedLocationToUpdate;
  }
}