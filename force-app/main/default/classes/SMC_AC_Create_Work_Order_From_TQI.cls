/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Create_Work_Order_From_TQI
-- - Author : Denis PHAM
-- - Description : This class is the Apex controller of the lightning web component smc_lwc_create_wo_from_tqi
--
-- Maintenance History:
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 21/06/2022   Denis PHAM        		1.0     	Initial Version
---------------------------------------------------------------------------
*/
public without sharing class SMC_AC_Create_Work_Order_From_TQI {
    /**
    * @description : Check if there is Asset on the Service Product
    * @author Denis PHAM (Modis) | 21/06/2022
    * @param recId
    * @param underContract
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean checkAssets(
        String recId,
        Boolean underContract
    ){
        System.debug(
            LoggingLevel.INFO,
            '>>>>>>SMC_AC_Create_Work_Order_From_TQI -> Method checkAssets - START'
        );

        
        Boolean hasAsset;
        String queryAssetUnderContract = '';

        if(underContract){
            queryAssetUnderContract = 'AND Asset.SMC_Covered_By_Service_Contract_formula__c = true';
        }

        //Construct the query 
        String query =  'SELECT Id FROM ProductServiceCampaignItem WHERE AssetId != null AND SMC_TECH_WOLI_Generated__c = false AND ProductServiceCampaignId =\'' + recId + '\'' + queryAssetUnderContract;

        List<ProductServiceCampaignItem> lItemWithAsset = Database.query(query);

        if(lItemWithAsset.size() > 0){
            hasAsset = true;
        } else{
            hasAsset = false;
        }

        System.debug(
            LoggingLevel.INFO,
            '>>>>>>SMC_AC_Create_Work_Order_From_TQI -> Method checkAssets - END'
        );
        
        return hasAsset;
    }

    /**
    * @description : Generate WO, WOLI, SA and Products Required on the TQI
    * @author Denis PHAM (Modis) | 22/06/2022
    * @param recId
    * @param underContract
    * @param numberSparePartItems
    * @param startDateTQI
    * @param endDateTQI
    * @param duration
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean generateRecords(
        String recId,
        Boolean underContract, 
        Integer numberSparePartItems,
        Date startDateTQI,
        Date endDateTQI,
        Decimal duration
    ){
        System.debug(
            LoggingLevel.INFO,
            '>>>>>>SMC_AC_Create_Work_Order_From_TQI -> Method generateRecords - START'
        );

        Boolean resultProcess;

        //Object To Insert 
        List<WorkOrder> lWoToInsert = new List<WorkOrder>();
        List<WorkOrderLineItem> lWoliToInsert = new List<WorkOrderLineItem>();
        List<ServiceAppointment> lSaToInsert = new List<ServiceAppointment>();
        List<ProductRequired> lProductRequiredToInsert = new List<ProductRequired>();
        Set<Id> sTempSCI = new Set<Id>();
        List<ProductServiceCampaignItem> lPSCItoUpdate = new List<ProductServiceCampaignItem>();

        //Variable used for the treatment of generation of records
        Map<Id, List<Id>> mapRootAssetToAssets = new Map<Id, List<Id>>();
        Map<Id, Id> mapAssetToProduct = new Map<Id, Id>();
        Map<Id, Id> mapProductToWorkType = new Map<Id, Id>();
        Map<Id, Id> mapAssetToAccount = new Map<Id, Id>();
        Map<Id, Id> mapAssetToContact = new Map<Id, Id>();
        Map<Id, Id> mapAssetToLocation = new Map<Id, Id>();
        Map<Id, Id> mapAssetToRootAsset = new Map<Id, Id>();
        Map<Id, Id> mapRootAssetToWO = new Map<Id, Id>();
        Map<Id, Id> mapAssetToPSCI = new Map<Id, Id>();
        Map<Id, ProductServiceCampaignItem> mapIdSPCI = new Map<Id, ProductServiceCampaignItem>();
        Map<Id, List<Date>> mapAssetToDueDate = new Map<Id, List<Date>>();
        Set<Id> setIdProduct = new Set<Id>(); 
        Set<Id> setIdAsset = new Set<Id>();
        Set<Id> setIdWOInserted= new Set<Id>();
        List<SMC_Spare_part_item__c> lSparePartItems = new List<SMC_Spare_part_item__c>();

        if(numberSparePartItems > 0){
            lSparePartItems = [SELECT Id, SMC_Product__c, SMC_Quantity__c FROM SMC_Spare_part_item__c WHERE SMC_Product_Service_Campaign__c = :recId];
        }

        String queryAssetUnderContract = '';
        if(underContract){
            queryAssetUnderContract = 'AND Asset.SMC_Covered_By_Service_Contract_formula__c = true';
        }

        //Construct the query 
        String query =  'SELECT Id, AssetId, Asset.RootAssetId, Asset.Product2Id, Asset.RootAsset.LocationId, Asset.RootAsset.Location.SMC_Site_Account__c, Asset.RootAsset.Location.SMC_Main_Contact__c, SMC_TECH_WOLI_Generated__c FROM ProductServiceCampaignItem WHERE AssetId != null AND SMC_TECH_WOLI_Generated__c = false AND ProductServiceCampaignId =\'' + recId + '\'' + queryAssetUnderContract;

        //Prevent all creation if WOLI are not created
        Savepoint sp = Database.setSavepoint();

        //Loop on product the get Asset to know how many WO and WOLI will be created
        for(ProductServiceCampaignItem psc : Database.query(query))
        {
            if(mapRootAssetToAssets.containsKey(psc.Asset.RootAssetId)) {
                List<Id> lAsset = mapRootAssetToAssets.get(psc.Asset.RootAssetId);
                lAsset.add(psc.AssetId);
                mapRootAssetToAssets.put(psc.Asset.RootAssetId, lAsset);
            } else {
                mapRootAssetToAssets.put(psc.Asset.RootAssetId, new List<Id> { psc.AssetId });
            }

            mapAssetToProduct.put(psc.AssetId, psc.Asset.Product2Id);
            mapAssetToDueDate.put(psc.Asset.RootAssetId, new List<Date> { endDateTQI });
            mapAssetToRootAsset.put(psc.AssetId, psc.Asset.RootAssetId);
            mapAssetToPSCI.put(psc.AssetId, psc.Id);
            mapIdSPCI.put(psc.Id, psc);

            //Info WO from Root Asset
            mapAssetToAccount.put(psc.Asset.RootAssetId, psc.Asset.RootAsset.Location.SMC_Site_Account__c);
            mapAssetToContact.put(psc.Asset.RootAssetId, psc.Asset.RootAsset.Location.SMC_Main_Contact__c );
            mapAssetToLocation.put(psc.Asset.RootAssetId, psc.Asset.RootAsset.LocationId);
        
            setIdProduct.add(psc.Asset.Product2Id);
            setIdAsset.add(psc.AssetId);
            setIdAsset.add(psc.Asset.RootAssetId);

        }

        //Get Work Type from the Product of the Assets linked to the TQI
        for(SMC_WorkTypeServiceProductAssociation__c wtspa : [SELECT Id, SMC_Work_Type__c, SMC_Service_Product__c
                                                              FROM SMC_WorkTypeServiceProductAssociation__c 
                                                              WHERE SMC_Service_Product__c IN :setIdProduct 
                                                              AND Work_Type_Category__c = :STA_UtilsStatic.TQI])
        {            
            mapProductToWorkType.put(wtspa.SMC_Service_Product__c, wtspa.SMC_Work_Type__c);
        }


        //Get All End Date from WOLI where the Type is "Preventive Maintenance".
        for(WorkOrderLineItem woli : [SELECT Id, AssetId, Asset.RootAssetId, WorkOrder.SMC_Due_Date__c
                                      FROM WorkOrderLineItem 
                                      WHERE WorkOrder.SMC_Due_Date__c < :endDateTQI
                                      AND WorkOrder.SMC_Due_Date__c >= TODAY
                                      AND AssetId IN :setIdAsset
                                      AND WorkType.SMC_Type__c = :STA_UtilsStatic.PMV])
        {
            if(mapAssetToDueDate.containsKey(woli.Asset.RootAssetId)) {
                List<Date> lDate = mapAssetToDueDate.get(woli.Asset.RootAssetId);
                lDate.add(Date.newInstance(woli.WorkOrder.SMC_Due_Date__c.year(), woli.WorkOrder.SMC_Due_Date__c.month(), woli.WorkOrder.SMC_Due_Date__c.day()));
                mapAssetToDueDate.put(woli.Asset.RootAssetId, lDate);
            }
        }

        //Creation of Work Order
        for(Id rootAsset : mapRootAssetToAssets.keyset()){
            WorkOrder woToInsert = new WorkOrder();
            woToInsert.Status = STA_UtilsStatic.TO_BE_SCHEDULED;
            woToInsert.Description = Label.SMC_TQI_WO_Automatic_Creation;
            woToInsert.AccountId = mapAssetToAccount.get(rootAsset);
            //Pour le contact y a un filtre pour prendre des contacts liés au compte : Modifier le filter des contacts sur le WO
            woToInsert.SMC_TECH_Contact__c =  mapAssetToContact.get(rootAsset);
            woToInsert.ContactId = mapAssetToContact.get(rootAsset);
            //Sort the list
            mapAssetToDueDate.get(rootAsset).sort();
            woToInsert.SMC_Due_Date__c = mapAssetToDueDate.get(rootAsset)[0];
            woToInsert.LocationId = mapAssetToLocation.get(rootAsset);
            woToInsert.ProductServiceCampaignId = recId;
            woToInsert.SMC_TECH_Asset__c = rootAsset;
            
            lWoToInsert.add(woToInsert);
        }

        if(lWoToInsert != null && lWoToInsert.size() > 0)
        {
            try {
                Database.insert(lWoToInsert, true);
            } catch(Exception  e) {
                resultProcess = false;
                System.debug('The following exception has occurred: ' + e.getMessage());
                String errorMessage = e.getMessage();
                String formattedErrorMessage = errorMessage.substringAfter('_EXCEPTION,');
                formattedErrorMessage = formattedErrorMessage.substring(0, (formattedErrorMessage.length()-4));
                throw new AuraHandledException(formattedErrorMessage);
            }

            for(WorkOrder woInserted : lWoToInsert){
                mapRootAssetToWO.put(woInserted.SMC_TECH_Asset__c, woInserted.Id);
            }
        }

        //Creation of WOLI
        for(List<Id> lAsset : mapRootAssetToAssets.values()){
            for(Id ass : lAsset){
                if(mapProductToWorkType.get(mapAssetToProduct.get(ass)) != null){
                    WorkOrderLineItem woliToInsert = new WorkOrderLineItem();
                    woliToInsert.WorkOrderId = mapRootAssetToWO.get(mapAssetToRootAsset.get(ass));
                    woliToInsert.AssetId = ass;
                    //woliToInsert.ProductServiceCampaignId = recId;
                    woliToInsert.WorkTypeId = mapProductToWorkType.get(mapAssetToProduct.get(ass));
                    woliToInsert.Status	 = STA_UtilsStatic.STR_NEW;
                    woliToInsert.Duration = duration;
                    woliToInsert.SMC_TECH_Product_Service_Campaign_Item__c = mapAssetToPSCI.get(ass);

                    lWoliToInsert.add(woliToInsert);
                    setIdWOInserted.add(mapRootAssetToWO.get(mapAssetToRootAsset.get(ass)));
                }
            }
        }
        
        if(lWoliToInsert != null && lWoliToInsert.size() > 0)
        {
            try {
                Database.insert(lWoliToInsert, true);
            } catch(Exception  e) {
                resultProcess = false;
                Database.rollback(sp);
                System.debug('The following exception has occurred: ' + e.getMessage());
                String errorMessage = e.getMessage();
                String formattedErrorMessage = errorMessage.substringAfter('_EXCEPTION,');
                formattedErrorMessage = formattedErrorMessage.substring(0, (formattedErrorMessage.length()-4));
                throw new AuraHandledException(formattedErrorMessage);
            }
            
            for(WorkOrderLineItem woli : lWoliToInsert)
            {
                sTempSCI.add(woli.SMC_TECH_Product_Service_Campaign_Item__c);
            }
        } else {
            Database.rollback(sp);
        }

        if(sTempSCI != null && sTempSCI.size() > 0 )
        {
            for(Id psci : sTempSCI){
                mapIdSPCI.get(psci).SMC_TECH_WOLI_Generated__c = true;
                lPSCItoUpdate.add(mapIdSPCI.get(psci));
            }
        }


        //Product Required for each WOLI 
        if(numberSparePartItems > 0){
            for(WorkOrderLineItem woli : lWoliToInsert){
                for(SMC_Spare_part_item__c spi : lSparePartItems){

                    ProductRequired productRequiredToInsert = new ProductRequired();
                    productRequiredToInsert.ParentRecordId = woli.Id;
                    productRequiredToInsert.Product2Id = spi.SMC_Product__c;
                    productRequiredToInsert.QuantityRequired = spi.SMC_Quantity__c;

                    lProductRequiredToInsert.add(productRequiredToInsert);
                }
            }

            try {
                Database.insert(lProductRequiredToInsert, true);
            } catch(Exception  e) {
                resultProcess = false;
                System.debug('The following exception has occurred: ' + e.getMessage());
                String errorMessage = e.getMessage();
                String formattedErrorMessage = errorMessage.substringAfter('_EXCEPTION,');
                formattedErrorMessage = formattedErrorMessage.substring(0, (formattedErrorMessage.length()-4));
                throw new AuraHandledException(formattedErrorMessage);
            }
        }
        
        if(lWoToInsert != null && lWoToInsert.size() > 0)
        {
            //Service Appointment
            for(WorkOrder wo : lWoToInsert){
                if(setIdWOInserted.contains(wo.Id)){
                    ServiceAppointment saToInsert = new ServiceAppointment();
                    saToInsert.ParentRecordId = wo.Id; 
                    saToInsert.Status = STA_UtilsStatic.NONE;
                    saToInsert.EarliestStartTime = DateTime.newInstance(startDateTQI.year(), startDateTQI.month(), startDateTQI.day());
                    saToInsert.DueDate = DateTime.newInstance(wo.SMC_Due_Date__c.year(), wo.SMC_Due_Date__c.month(), wo.SMC_Due_Date__c.day());
                    saToInsert.ServiceTerritoryId =  wo.Location.SMC_Service_Territory__c;
                    saToInsert.Duration = wo.Duration;

                    lSaToInsert.add(saToInsert);
                }
            }
        }   

        if(lSaToInsert != null && lSaToInsert.size() > 0)
        {
            try {
                Database.insert(lSaToInsert, true);
            } catch(Exception  e) {
                resultProcess = false;
                System.debug('The following exception has occurred: ' + e.getMessage());
                String errorMessage = e.getMessage();
                String formattedErrorMessage = errorMessage.substringAfter('_EXCEPTION,');
                formattedErrorMessage = formattedErrorMessage.substring(0, (formattedErrorMessage.length()-4));
                throw new AuraHandledException(formattedErrorMessage);
            }
        }

        //Update Product Service line Item
        if(lPSCItoUpdate.size() > 0){
            try {
                Database.update(lPSCItoUpdate, true);
            } catch(Exception  e) {
                resultProcess = false;
                System.debug('The following exception has occurred: ' + e.getMessage());
                String errorMessage = e.getMessage();
                String formattedErrorMessage = errorMessage.substringAfter('_EXCEPTION,');
                formattedErrorMessage = formattedErrorMessage.substring(0, (formattedErrorMessage.length()-4));
                throw new AuraHandledException(formattedErrorMessage);
            }
        }
        
        resultProcess = true;

        System.debug(
            LoggingLevel.INFO,
            '>>>>>>SMC_AC_Create_Work_Order_From_TQI -> Method generateRecords - END'
        );

        return resultProcess;
    }
}