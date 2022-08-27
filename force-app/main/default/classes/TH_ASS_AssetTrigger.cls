/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_ASS_AssetTrigger
-- - Author        : Vincent RECASENS
-- - Description   : Handler for trigger AssetTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version   Remarks
-- -----------  ----  -------   -------------------------------------------------
-- 20-FEB-2019 	VRE   1.0       Initial version
-- 06-APR-2020  VRE   1.0       Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_ASS_AssetTrigger extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Asset> oldMap;
  private Map<Id, Asset> newMap;
  private List<Asset> oldList;
  private List<Asset> newList;

  // Constructor
  public TH_ASS_AssetTrigger() {
    this.oldMap = (Map<Id, Asset>) Trigger.oldMap;
    this.newMap = (Map<Id, Asset>) Trigger.newMap;
    this.oldList = (List<Asset>) Trigger.Old;
    this.newList = (List<Asset>) Trigger.New;
  }

  /**
  * @description Handle "Asset Before Insert"
  -set the warranty date
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ASSET_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Asset before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAsset.fillAssetWarranty(this.newList, null);
      SMC_AP_ManageAsset.fillParentServiceOrganization(this.newList);
      //Set the Account on  Asset Service BOM for the user SOC3
      Id soc3 = SF_Technical_User__mdt.getInstance(STA_UtilsStatic.TECHNICAL_USER_SOC3_ID_FROM_MDT).UserId__c;
      if(UserInfo.getUserId() == soc3)
      {
        SMC_AP_ManageAsset.fillAccountSBOM(this.newList);
      }
      

      System.debug(LoggingLevel.INFO, '## >>> Asset before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Asset After Insert"
  * -create asset's ServiceBOM
  * -Prevent creation of Asset ServiceBOM from SOC3
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_ASSET_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Asset After Insert:START <<< run by ' + UserInfo.getName()
      );

      //Prevent Asset Service BOM creation from the user SOC3
      Id soc3 = SF_Technical_User__mdt.getInstance(STA_UtilsStatic.TECHNICAL_USER_SOC3_ID_FROM_MDT).UserId__c;

      if(UserInfo.getUserId() != soc3)
      {
        SMC_AP_ManageAsset.createAssetRelatedObject(this.newMap, null);
      }
      SMC_AP_ManageAsset.fillParentAssetFieldOnSingleAsset(this.newMap);
      //Set theoretical next date automatically
      if(UserInfo.getUserId() == soc3)
      {
        SMC_AP_ManageAsset.fillDateSBOM(this.newMap);
      }

      System.debug(LoggingLevel.INFO, '## >>> Asset After Insert:END <<<');
    }
  }

  /**
  * @description Handle "Asset Before Update"
  -update asset's ServiceBOM
  -update warranty date
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ASSET_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Asset Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAsset.updateServiceBOM(this.newMap, this.oldmap);
      SMC_AP_ManageAsset.fillAssetWarranty(this.newList, this.oldMap);
      System.debug(LoggingLevel.INFO, '## >>> Asset Before Update:END <<<');
    }
  }

  /**
  * @description Handle "Asset After Update"
  -manage service organisation
  -service product is changed --> manage asset's ServiceBOM (insert/update/delete)
  -Prevent creation of Service BOM from SOC3
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ASSET_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Asset After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAsset.manageParentServiceOrganisation(
        this.newList,
        this.oldmap
      );

      //Prevent Asset Service BOM creation from the user SOC3
      Id soc3 = SF_Technical_User__mdt.getInstance(STA_UtilsStatic.TECHNICAL_USER_SOC3_ID_FROM_MDT).UserId__c;

      if(UserInfo.getUserId() != soc3)
      {
        SMC_AP_ManageAsset.productIsChanged(this.newMap, this.oldmap);
      }

      if(SMC_UTIL_CheckRecursiveTrigger.runOnce()){
        SMC_AP_ManageAsset.checkSBOMDates(this.newMap, this.oldmap);
      }
      
      if (Pad.canTrigger('assetDecommission')) {
        SMC_AP_ManageAsset.manageDecomission(this.newList, this.oldmap);
      }

      System.debug(LoggingLevel.INFO, '## >>> Asset After Update:END <<<');
    }
  }

  /**
   * @description
   * @author emmanuel.bernier@modis.com | 18/06/2020
   * @return void
   **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ASSET_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Asset Before Delete:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageAsset.preventDelete(this.oldList);

      System.debug(LoggingLevel.INFO, '## >>> Asset Before Delete:END <<<');
    }
  }
}