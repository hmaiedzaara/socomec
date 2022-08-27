/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 03-22-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   03-16-2021   Vincent RECASENS (Modis)   Initial Version
**/
public with sharing class SMC_AP_ManageProduct2 {

    /**
    * @description : check if product is active
    * @author Vincent RECASENS (Modis) | 04-27-2021 
    * @param newList 
    **/
    public static void checkActiveProduct(List<Product2> newList){
        //Get "ServiceProduct" record type
        Id recordTypeIdServiceProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
            .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
            .getRecordTypeId();
        for(Product2 onePdt : newList){
            //condition 0 : apply to service products
            if(onePdt.RecordTypeId == recordTypeIdServiceProduct &&
            //condition 1 : no end of life and no extend end of life
               (
                onePdt.SMC_Date_EndOfLife__c == null &&
                onePdt.SMC_Date_ExtendedEndOfLife__c == null
               ) ||
            //condition 2 : end of life greater than today
               (
                onePdt.SMC_Date_EndOfLife__c != null && 
                onePdt.SMC_Date_EndOfLife__c > Date.today()
               ) ||
            //condition 3 : extend end of life greater than today
                (
                onePdt.SMC_Date_ExtendedEndOfLife__c != null && 
                onePdt.SMC_Date_ExtendedEndOfLife__c > Date.today()
                )
              ){
                onePdt.IsActive = true; //active product
            }
            else if(onePdt.RecordTypeId == recordTypeIdServiceProduct){
                onePdt.IsActive = false; //desactive product
            }
        }
    }
    
    /**
    * @description : rename ProductCode and Name in according to their configuration (manufacturer, range, model...)
    * @author Vincent RECASENS (Modis) | 07-01-2021 
    * @param newList 
    **/
    public static void renameProductCode_ProductName(List<Product2> newList) {
        Map<String, String> mapManufacturerValue_ManufacturerLabel = new Map<String, String>();
        Schema.DescribeFieldResult fieldResultManufacturer = Product2.SMC_Manufacturer_p__c.getDescribe();
        List<Schema.PicklistEntry> entriesManufacturer = fieldResultManufacturer.getPicklistValues();
        for (Schema.PicklistEntry entry : entriesManufacturer) {
            mapManufacturerValue_ManufacturerLabel.put(entry.getValue(), entry.getLabel());
        }

        Map<String, String> mapModelValue_ModelLabel = new Map<String, String>();
        Schema.DescribeFieldResult fieldResultModel = Product2.SMC_Model_p__c.getDescribe();
        List<Schema.PicklistEntry> entriesModel = fieldResultModel.getPicklistValues();
        for (Schema.PicklistEntry entry : entriesModel) {
            mapModelValue_ModelLabel.put(entry.getValue(), entry.getLabel());
        }
        Id recordTypeIdServiceProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
            .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
            .getRecordTypeId();
        for (Product2 product : newList) {
            if(product.RecordTypeId == recordTypeIdServiceProduct && mapManufacturerValue_ManufacturerLabel.containsKey(product.SMC_Manufacturer_p__c) && product.SMC_Is_Socomec_Product__c == STA_UtilsStatic.NO){
                String manufacturerValue = mapManufacturerValue_ManufacturerLabel.get(product.SMC_Manufacturer_p__c).removeEnd(' (' + product.SMC_Manufacturer_p__c + ')');
                String modelValue = '';
                if (product.SMC_Model_p__c != null) {
                    modelValue = mapModelValue_ModelLabel.get(product.SMC_Model_p__c).removeEnd(' (' + product.SMC_Model_p__c + ')');
                }
                product.ProductCode = product.SMC_Manufacturer_p__c + (product.SMC_Range_p__c == null ?
                    '-' : '-' + product.SMC_Range_p__c) + (product.SMC_Model_p__c == null ?
                    '-' : '-' + product.SMC_Model_p__c) + (product.SMC_Configuration_p__c == null ?
                    '-' : '-' + product.SMC_Configuration_p__c) + (product.SMC_Phase_p__c == null ?
                    '-' : '-' +product.SMC_Phase_p__c) + (product.SMC_Power_p__c == null ?
                    '-' : '-' + product.SMC_Power_p__c) + (product.SMC_Power_Unit_p__c == null ?
                    '-' : '-' + product.SMC_Power_Unit_p__c) + (product.SMC_Type_p__c == null ?
                    '' :'-' + product.SMC_Type_p__c);
                product.Name = manufacturerValue + ' ' + (modelValue == '' ?
                    ' (' : modelValue + ' (' ) + product.SMC_Manufacturer_p__c + (product.SMC_Range_p__c == null ?
                    '' : '-' + product.SMC_Range_p__c) + (product.SMC_Model_p__c == null ?
                    ') ' : '-' + product.SMC_Model_p__c + ')') + (product.SMC_Configuration_p__c == null ?
                    '' : ' ' + product.SMC_Configuration_p__c ) + (product.SMC_Phase_p__c == null ?
                    '' : ' ' + product.SMC_Phase_p__c ) + (product.SMC_Power_p__c == null ?
                    '' :  ' ' + product.SMC_Power_p__c) + (product.SMC_Power_Unit_p__c == null ?
                    '' : ' ' + product.SMC_Power_Unit_p__c ) + (product.SMC_Type_p__c == null ?
                    '' : ' ' + product.SMC_Type_p__c);
            }
        }
    }
    
    /**
    * @description 
    * @author Vincent RECASENS (Modis) | 07-21-2021 
    * @param newMap 
    **/
    // public static void createNewWorkTypesForNewProductWorkItem(Map<Id, Product2> newMap){
    //     system.enqueueJob(new TestQueue(newMap));
    // }
    /**
    * @description 
    * @author Vincent RECASENS (Modis) | 07-21-2021 
    * @param newMap 
    **/
    public static void createNewWorkTypesForNewProductWorkItem(Map<Id, Product2> newMap){
        // System.debug('SMC_AP_ManageProduct2.createNewWorkTypeForNewProductWorkItem START');
        List<String> manufacturer = new List<String>();
        List<String> range = new List<String>();
        List<String> model = new List<String>();
        List<String> phase = new List<String>();
        List<String> power = new List<String>();
        List<String> power_Unit = new List<String>();
        Map<String, Product2> mapGeneralConfig_newWI = new Map<String, Product2>();
        Id recordTypeWorkOrderItemId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_WORK_ITEM_PRODUCT).getRecordTypeId();
        
        Map<Id, WorkType> mapWtToInsert = new Map<Id, WorkType>();
        for (Id oneId : newMap.keySet()) {
            Product2 newProduct = newMap.get(oneId);
            if (newProduct.RecordTypeId == recordTypeWorkOrderItemId) {
                String genralConfig = '';
                if(newProduct.SMC_Manufacturer_p__c != null && newProduct.SMC_Manufacturer_p__c != ''){
                    genralConfig += newProduct.SMC_Manufacturer_p__c;
                    manufacturer.add(newProduct.SMC_Manufacturer_p__c);
                }
                if(newProduct.SMC_Range_p__c != null && newProduct.SMC_Range_p__c != ''){
                    genralConfig += (genralConfig.length() > 0 ? ' ' + newProduct.SMC_Range_p__c : newProduct.SMC_Range_p__c);
                    range.add(newProduct.SMC_Range_p__c);
                }
                if(newProduct.SMC_Model_p__c != null && newProduct.SMC_Model_p__c != ''){
                    genralConfig += (genralConfig.length() > 0 ? ' ' + newProduct.SMC_Model_p__c : newProduct.SMC_Model_p__c);
                    model.add(newProduct.SMC_Model_p__c);
                }
                if(newProduct.SMC_Phase_p__c != null && newProduct.SMC_Phase_p__c != ''){
                    genralConfig += (genralConfig.length() > 0 ? ' ' + newProduct.SMC_Phase_p__c : newProduct.SMC_Phase_p__c);
                    phase.add(newProduct.SMC_Phase_p__c);
                }
                if(newProduct.SMC_Power_p__c != null && newProduct.SMC_Power_p__c != ''){
                    genralConfig += (genralConfig.length() > 0 ? ' ' + newProduct.SMC_Power_p__c : newProduct.SMC_Power_p__c);
                    power.add(newProduct.SMC_Power_p__c);
                }
                if(newProduct.SMC_Power_Unit_p__c != null && newProduct.SMC_Power_Unit_p__c != ''){
                    genralConfig += (genralConfig.length() > 0 ? ' ' + newProduct.SMC_Power_Unit_p__c : newProduct.SMC_Power_Unit_p__c);
                    power_Unit.add(newProduct.SMC_Power_Unit_p__c);
                }
                // System.debug('manufacturer : ' + manufacturer);
                // System.debug('range : ' + range);
                // System.debug('model : ' + model);
                // System.debug('phase : ' + phase);
                // System.debug('power : ' + power);
                // System.debug('power_Unit : ' + power_Unit);
                // System.debug('genralConfig : ' + genralConfig);
                mapGeneralConfig_newWI.put(genralConfig, newProduct);
            }
        }
        // System.debug('mapGeneralConfig_newWI-->' + mapGeneralConfig_newWI);
        if(mapGeneralConfig_newWI.size() > 0){
            // System.debug('in first if');
            //ServiceProduct
            Id recordTypeServiceProductId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
            Map<String, List<Id>> newWorkTypeName_ListServiceProductId = new Map<String, List<Id>>();
            Map<String, WorkType> newWorkTypeName_NewWorkType = new Map<String, WorkType>();
            Set<String> setGenralConfigAlreadyUsed = new Set<String>();
            // System.debug('manufacturer->' + manufacturer);
            // System.debug('range->' +range);
            // System.debug('model->' +model);
            // System.debug('phase->' +phase);
            // System.debug('power->' +power);
            // System.debug('power_Unit->' +power_Unit);
            String additionnalQuery = (manufacturer != null && manufacturer.size() != 0 ? ' AND SMC_Manufacturer_p__c IN :manufacturer' : '') + 
                                      (range != null && range.size() != 0 ? ' AND SMC_Range_p__c IN :range' : '') + 
                                      (model != null && model.size() != 0 ? ' AND SMC_Model_p__c IN :model' : '') + 
                                      (phase != null && phase.size() != 0 ? ' AND SMC_Phase_p__c IN :phase' : '') + 
                                      (power != null && power.size() != 0 ? ' AND SMC_Power_p__c IN :power' : '') + 
                                      (power_Unit != null && power_Unit.size() != 0 ? ' AND SMC_Power_Unit_p__c IN :power_Unit' : '');
            String query = 'SELECT Id, ' +
                           'SMC_Work_Type__c,  ' +
                           'SMC_Manufacturer_p__c,  ' +
                           'SMC_Range_p__c,  ' +
                           'SMC_Model_p__c ,  ' +
                           'SMC_Phase_p__c,  ' +
                           'SMC_Power_p__c,  ' +
                           'SMC_Power_Unit_p__c,  ' +
                           'SMC_Type_p__c ' +
                        'FROM Product2 ' +
                        'WHERE RecordTypeId = \'' + recordTypeServiceProductId + '\'' + additionnalQuery;
            // for (Product2 oneProduct : [
            //                             SELECT Id, 
            //                                 SMC_Work_Type__c, 
            //                                 SMC_Manufacturer_p__c, 
            //                                 SMC_Range_p__c, 
            //                                 SMC_Model_p__c , 
            //                                 SMC_Phase_p__c, 
            //                                 SMC_Power_p__c, 
            //                                 SMC_Power_Unit_p__c, 
            //                                 SMC_Type_p__c
            //                             FROM Product2 
            //                             WHERE RecordTypeId =: recordTypeServiceProductId 
            //                                 AND SMC_Manufacturer_p__c IN :manufacturer 
            //                                 AND SMC_Range_p__c IN :range 
            //                                 AND SMC_Model_p__c IN :model 
            //                                 AND SMC_Phase_p__c IN :phase 
            //                                 AND SMC_Power_p__c IN :power
            //                                 AND SMC_Power_Unit_p__c IN :power_Unit
            //                             ]) {
            // System.debug('additionnalQuery : ' + additionnalQuery);
            // System.debug('query : ' + query);
            for (Product2 oneProduct : Database.query(query)) {
                // System.debug('oneProduct-->' + oneProduct);
                String generalConfig = oneProduct.SMC_Manufacturer_p__c + ' ' + 
                                    oneProduct.SMC_Range_p__c + ' ' +
                                    oneProduct.SMC_Model_p__c + ' ' +
                                    oneProduct.SMC_Phase_p__c + ' ' +
                                    oneProduct.SMC_Power_p__c + ' ' +
                                    oneProduct.SMC_Power_Unit_p__c;
                // System.debug('generalConfig-->' + generalConfig);
                //If ServiceProduct not match with a WorkItem, continue to another iteration
                Product2 newProduct;
                if(mapGeneralConfig_newWI.get(generalConfig) == null){
                    // System.debug('continue');
                    Boolean notFindSP = true;
                    for(String keys : mapGeneralConfig_newWI.keySet()){
                        if(generalConfig.contains(keys)){
                            newProduct = mapGeneralConfig_newWI.get(keys);
                            notFindSP = false;
                            break;
                        }
                    }
                    
                    if(notFindSP){
                        continue;
                    }
                }
                else{
                    newProduct = mapGeneralConfig_newWI.get(generalConfig);
                }

                String newWorkTypeName = (newProduct.SMC_Work_Type_Category__c != null ? newProduct.SMC_Work_Type_Category__c + ' - ' : '') +
                                         (newProduct.SMC_Range_p__c  != null ? newProduct.SMC_Range_p__c + ' ' : '') +
                                         (newProduct.SMC_Model_p__c  != null ? newProduct.SMC_Model_p__c + ' ' : '') +
                                         (newProduct.SMC_Phase_p__c  != null ? newProduct.SMC_Phase_p__c + ' ' : '') +
                                         (newProduct.SMC_Power_p__c  != null ? newProduct.SMC_Power_p__c + ' ' : '') +
                                         (newProduct.SMC_Power_Unit_p__c  != null ? newProduct.SMC_Power_Unit_p__c + ' ' : '') +
                                         (oneProduct.SMC_Type_p__c  != null ? oneProduct.SMC_Type_p__c : '');
                // System.debug('newWorkTypeName-->' + newWorkTypeName);
                if(newWorkTypeName_NewWorkType.get(newWorkTypeName) == null){
                    WorkType newWorkType = new WorkType();
                    newWorkType.Name = newWorkTypeName;
                    newWorkType.DurationType = 'Hours';
                    newWorkType.EstimatedDuration = 1;
                    newWorkType.SMC_Type__c = newProduct.SMC_Work_Type_Category__c;
                    newWorkType.SMC_Active_from__c = Date.today();
                    newWorkType.SMC_Work_Item__c = newProduct.Id;

                    newWorkTypeName_ListServiceProductId.put(newWorkTypeName, new List<Id>{oneProduct.Id});
                    newWorkTypeName_NewWorkType.put(newWorkTypeName, newWorkType);
                    // System.debug('newWorkType-->' + newWorkType);
                }
                else{
                    newWorkTypeName_ListServiceProductId.get(newWorkTypeName).add(oneProduct.Id);
                }
            }
            // System.debug('after for');
            // System.debug('newWorkTypeName_NewWorkType.size()-->' + newWorkTypeName_NewWorkType.size());
            if(newWorkTypeName_NewWorkType.size() > 0){
                insert newWorkTypeName_NewWorkType.values();

                List<SMC_WorkTypeServiceProductAssociation__c> assoToInsert = new List<SMC_WorkTypeServiceProductAssociation__c>();
                for(String wtName : newWorkTypeName_NewWorkType.keySet()){
                    for(Id spId : newWorkTypeName_ListServiceProductId.get(wtName)){
                        SMC_WorkTypeServiceProductAssociation__c newAsso = new SMC_WorkTypeServiceProductAssociation__c();
                        newAsso.SMC_Service_Product__c = spId;
                        newAsso.SMC_Work_Type__c = newWorkTypeName_NewWorkType.get(wtName).Id;
                        assoToInsert.add(newAsso);
                    }
                }
                // System.debug('assoToInsert-->' + assoToInsert);
                if(assoToInsert.size() > 0){
                    insert assoToInsert;
                }
            }
        }
        // System.debug('SMC_AP_ManageProduct2.createNewWorkTypeForNewProductWorkItem END');
    }

    // public class TestQueue implements Queueable {
    //     Map<Id, Product2> newMap;

    //     public TestQueue(Map<Id, Product2> newMap){
    //         this.newMap = newMap;
    //     }

    //     public void execute(QueueableContext context) {
    //         createNewWorkTypesForNewProductWorkItemBis(newMap);
    //     }
    // }
    
        /**
    * @description : update work type if product (work item) is deactivated
    * @author Tanya SIBONI (Modis) | 07-29-2021 
    * @param newMap 
    * @param oldMap 
    **/
    public static void updateWorkTypeIfProductWorkItemDeactivated(Map<Id,Product2> newMap, Map<Id,Product2> oldMap){
        Id recordTypeWorkItemId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_WORK_ITEM_PRODUCT).getRecordTypeId();
        Map<Id, WorkType> mapProduct2WIId_Worktype = new Map<Id, WorkType>();
        Set<Id> workItemId = new Set<Id>();
        for(Id oneId : newMap.keySet()){
            //Check record type
            Product2 newProduct = newMap.get(oneId);
            if (newProduct.RecordTypeId == recordTypeWorkItemId ) {
            	Product2 oldProduct = oldMap.get(oneId);
            	//Get work type id
                if( newProduct.IsActive != oldProduct.IsActive && newProduct.IsActive == false){
                    workItemId.add(oneId);
                }
            }
        }
        List<WorkType> workTypeToUpdate = new List<WorkType>();
        for (WorkType wt : [SELECT Id, Name, SMC_Active_until__c, SMC_Work_Item__c FROM WorkType WHERE SMC_Work_Item__c IN: workItemId]) {
            wt.SMC_Active_until__c = Date.today();
            workTypeToUpdate.add(wt);
        }
        
        //Make update
        if(workTypeToUpdate.size() > 0){
            update workTypeToUpdate;
        }
    }
        /**
    * @description : update work type if product (work order item) is updated
    * @author Vincent RECASENS (Modis) | 03-15-2021 
    * @param newMap 
    * @param oldMap 
    **/
    public static void updateWorkTypeRelatedToWorkOrderItem(Map<Id,Product2> newMap, Map<Id,Product2> oldMap){
        Id recordTypeWorkOrderItemId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_WORKORDER_ITEM_PRODUCT).getRecordTypeId();
        Map<Id, Id> mapWorkTypeId_Product2WOIId = new Map<Id, Id>();
        for(Id oneId : newMap.keySet()){
            //Check record type
            Product2 newProduct = newMap.get(oneId);
            if (newProduct.RecordTypeId == recordTypeWorkOrderItemId) {
            	Product2 oldProduct = oldMap.get(oneId);
            	//Get work type id
                if((newProduct.SMC_Work_Type_duration__c != oldProduct.SMC_Work_Type_duration__c ||
                   newProduct.SMC_Work_Type_Category__c != oldProduct.SMC_Work_Type_Category__c) &&
                   newProduct.SMC_Type_p__c != oldProduct.SMC_Type_p__c){
                    mapWorkTypeId_Product2WOIId.put(newProduct.SMC_Work_Type__c, oneId);
                }
            }
        }
        
        if(mapWorkTypeId_Product2WOIId.size() > 0){
            List<WorkType> workTypeToUpdate = new List<WorkType>();
            for(WorkType oneWo : [SELECT Id, Name, SMC_Work_Item__c, EstimatedDuration, SMC_Type__c FROM WorkType WHERE Id IN :mapWorkTypeId_Product2WOIId.keySet()]){
                Boolean estimatedDurationHasChanged = false;
                Boolean typeHasChanged = false;
                Product2 newProduct = newMap.get(oneWo.SMC_Work_Item__c);
                //Check fields
                if(oneWo.EstimatedDuration != newProduct.SMC_Work_Type_duration__c){
                    oneWo.EstimatedDuration = newProduct.SMC_Work_Type_duration__c;
                    estimatedDurationHasChanged = true;
                }
                if(oneWo.SMC_Type__c != newProduct.SMC_Work_Type_Category__c){
                    oneWo.SMC_Type__c = newProduct.SMC_Work_Type_Category__c;
                    typeHasChanged = true;
                }
                
                //Check if need to update
                if(estimatedDurationHasChanged || typeHasChanged){
                    workTypeToUpdate.add(oneWo);
                }
            }
            
            //Make update
            if(workTypeToUpdate.size() > 0){
                update workTypeToUpdate;
            }
        }
    }

    
    /**
* @description : Queueable class to update product (work order item) after create new work type
* @author Vincent RECASENS (Modis) | 03-15-2021 
**/
  public class UpdateWorkOrderItemWithNewWorkTypeId implements Queueable {
    Map<Id, Id> mapProductWorkOrderItemId_To_WorkTypeId;
    Map<Id, Product2> mapProductToUpdate;

    public UpdateWorkOrderItemWithNewWorkTypeId(Map<Id, Id> mapProductWorkOrderItemId_To_WorkTypeId) {
        this.mapProductWorkOrderItemId_To_WorkTypeId = mapProductWorkOrderItemId_To_WorkTypeId;
        this.mapProductToUpdate = new Map<Id, Product2>([SELECT Id, SMC_Work_Type__c FROM Product2 WHERE Id IN :mapProductWorkOrderItemId_To_WorkTypeId.keySet()]);
    }

      public void execute(QueueableContext context) {
          for(Id oneId : mapProductToUpdate.keySet()){
              mapProductToUpdate.get(oneId).SMC_Work_Type__c = mapProductWorkOrderItemId_To_WorkTypeId.get(oneId);
          }
          update mapProductToUpdate.values();
      }
  }
}