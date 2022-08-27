/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_CreateAssetRelatedObject_GTL
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_CreateAssetRelatedObject_GTL
--
-- Maintenance History:
--
-- Date 		Name 	Version 	Remarks
-- ----------- 	---- 	------- 	------------------
-- 18-FEB-2019 	VREC	1.0			Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_CreateAssetRelatedObject_GTL {
  public class ResultWrapper {
    public Boolean isSuccess;
    public Boolean errorOccur;
    public Boolean emptyList;
    public Set<Asset> badRecordTypeAsset;
    public Set<Asset> rigthRecordTypeAsset;
    public Set<Asset> badAsset;
    public Set<Asset> rigthAsset;

    public ResultWrapper() {
      this.isSuccess = false;
      this.emptyList = false;
      this.errorOccur = false;
      this.badRecordTypeAsset = new Set<Asset>();
      this.rigthRecordTypeAsset = new Set<Asset>();
      this.badAsset = new Set<Asset>();
      this.rigthAsset = new Set<Asset>();
    }
  }

  /**
   * @description : retrieve GTL from asset Id
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param assetId
   * @return String = serialization(new Map<Id, Asset>)
   **/
  @AuraEnabled
  public static String getGTLfromAssetId(String assetId) {
    ResultWrapper result = SMC_AP_ManageAsset.createAssetRelatedObject(
      new Map<Id, Asset>{
        assetId => [
          SELECT
            Id,
            Name,
            AccountId,
            ContactId,
            RecordTypeId,
            Product2Id,
            SMC_Parent_service_organisation__c,
            InstallDate,
            SMC_CommissioningDate__c,
            SMC_Manufacturing_date__c,
            SMC_Shipping_date__c,
            CreatedDate
          FROM Asset
          WHERE Id = :assetId
        ]
      },
      null
    );
    return JSON.serialize(result);
  }
}