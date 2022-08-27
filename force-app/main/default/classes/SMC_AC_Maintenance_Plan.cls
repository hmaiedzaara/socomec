/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 04-08-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   04-06-2021   Vincent RECASENS (Modis)   Initial Version
**/
public without sharing class SMC_AC_Maintenance_Plan {

    @AuraEnabled
    public static Map<String, String> checkInformationsAndLaunchMaintenancePlans(String serviceContractId){
        //Check lines
        // String errorInit = '\nTo initlize a maintenance plan, you need to fill a location with an address on the contract line and the work type link the to service product on the asset need to be "PREVENTIVE_MAINTENANCE" type';
        String errorInit = '';
        Map<Id, Id> mapProduct2Id_LocationId = new Map<Id, Id>();
        Map<Id, String> mapLocationId_LocationName = new Map<Id, String>();
        for(ContractLineItem oneCLI : [SELECT Id, 
                                              LineItemNumber, 
                                              SMC_Asset_Location__c, 
                                              AssetId, 
                                              Asset.Location.Name, 
                                              Asset.Location.SMC_Address__c, 
                                              Asset.Product2Id
                                            //   Asset.Product2.SMC_Work_Type__c, 
                                            //   Asset.Product2.SMC_Work_Type__r.SMC_Type__c
                                       FROM ContractLineItem 
                                       WHERE ServiceContractId = :((Id)serviceContractId)]){
            if(oneCLI.AssetId == null){
                return new Map<String, String>{'error' => STA_UtilsStatic.ERROR_MP_NO_ASSET +  + oneCLI.LineItemNumber};
            }
            else if(oneCLI.SMC_Asset_Location__c == null || oneCLI.SMC_Asset_Location__c == ''){
                return new Map<String, String>{'error' => STA_UtilsStatic.ERROR_MP_NO_LOCATION + oneCLI.LineItemNumber + errorInit};
            }
            else if(oneCLI.Asset.Location.SMC_Address__c == null){
                return new Map<String, String>{'error' => STA_UtilsStatic.ERROR_MP_NO_ADDRESS +  + oneCLI.LineItemNumber + errorInit};
            }
            else if(oneCLI.Asset.Product2Id == null){
                return new Map<String, String>{'error' => STA_UtilsStatic.ERROR_MP_NO_SERVICE_PRODUCT +  + oneCLI.LineItemNumber + errorInit};
            }
            else{
                mapProduct2Id_LocationId.put(oneCLI.Asset.Product2Id, oneCLI.SMC_Asset_Location__c);
                mapLocationId_LocationName.put((Id) oneCLI.SMC_Asset_Location__c, oneCLI.Asset.Location.Name);
            }
        }

        //Check wortk type
        Set<Id> product2OK = new Set<Id>();
        for(SMC_WorkTypeServiceProductAssociation__c oneWtAss : [SELECT Id, SMC_Service_Product__c, SMC_Work_Type__c, SMC_Work_Type__r.SMC_Type__c FROM SMC_WorkTypeServiceProductAssociation__c WHERE SMC_Service_Product__c IN :mapProduct2Id_LocationId.keySet()]){
            // if(oneWtAss.SMC_Service_Product__c == null || oneWtAss.SMC_Work_Type__c == null){
            //     return new Map<String, String>{'error' => 'There is no work type on the asset\'s service product on the line.' + errorInit};
            // }
            // else
            if(oneWtAss.SMC_Work_Type__r.SMC_Type__c == 'PMV'){
                product2OK.add(oneWtAss.SMC_Service_Product__c);
                // return new Map<String, String>{'error' => 'The work type link the to asset\'s service product need to be "PREVENTIVE MAINTENANCE" type.' + errorInit};
            }
            // else{
            // }
        }

        //Manage map
        Map<Id, String> mapLocationId_LocationNameChecker = new Map<Id, String>();
        for(Id oneId : mapProduct2Id_LocationId.keySet()){
            if(product2OK.contains(oneId)){
                mapLocationId_LocationNameChecker.put(mapProduct2Id_LocationId.get(oneId), mapLocationId_LocationName.get(mapProduct2Id_LocationId.get(oneId)));
            }
        }

        //Create maintenance plans
        if(mapLocationId_LocationNameChecker.size() > 0){
            ServiceContract theSC = [SELECT Id, 
                                            Name, 
                                            AccountId,
                                            ContactId, 
                                            StartDate, 
                                            EndDate
                                    FROM ServiceContract 
                                    WHERE Id = :serviceContractId];
            List<MaintenancePlan> maintenancePlanToInsert = new List<MaintenancePlan>();
            for(Id oneLocId : mapLocationId_LocationNameChecker.keySet()){
                MaintenancePlan newMP = new MaintenancePlan();
                newMP.MaintenancePlanTitle = theSC.Name + ' - ' + mapLocationId_LocationNameChecker.get(oneLocId);
                newMP.AccountId = theSC.AccountId;
                newMP.ContactId = theSC.ContactId;
                newMP.DoesAutoGenerateWorkOrders  = true;
                newMP.StartDate = theSC.StartDate;
                newMP.NextSuggestedMaintenanceDate = theSC.StartDate;
                newMP.EndDate = theSC.EndDate;
                newMP.Frequency = 1;
                newMP.FrequencyType = 'Months';
                newMP.GenerationHorizon = 90;
                newMP.GenerationTimeframe = 3;
                newMP.GenerationTimeframeType = 'Months';
                newMP.LocationId = oneLocId;
                newMP.SvcApptGenerationMethod = 'SvcApptPerWorkOrder';
                newMP.ServiceContractId = theSC.Id;
                newMP.WorkOrderGenerationMethod = 'WorkOrderLineItemPerAsset';

                maintenancePlanToInsert.add(newMP);
            }

            if(maintenancePlanToInsert.size() > 0){
                try{
                    insert maintenancePlanToInsert;
                    return new Map<String, String>{'success' => 'Maintenance plan has inserted.'};
                }
                catch(Exception e){
                    System.debug('MaintenancePlan insertion error : ' + e.getMessage());
                    return new Map<String, String>{'error' => 'There is a problem during MaintenancePlan insertion. Please contact your administrator.'};
                }
            }
        }
        return new Map<String, String>{'warning' => STA_UtilsStatic.ERROR_MP_NO_MAINTENANCE_PLAN_TO_INITIALIZE};
    }

    @AuraEnabled
    public static Boolean sendInformationsToFlow(String serviceContractId, List<Integer> monthsSelected){
        try {
            //Transform months list to a signle string
            String monthsOneLineList = '';
            for(Integer oneMonth : monthsSelected){
                monthsOneLineList += oneMonth + ',';
            }
            Map<String, Object> variablesMap = new Map<String, Object>();
            variablesMap.put('ServiceContractId', serviceContractId);
            variablesMap.put('SelectedMonths', monthsOneLineList.removeEnd(','));
            Flow.Interview.SMC_Init_Maintenance_Plans_From_Service_Contract maintenancePlanFlow = new Flow.Interview.SMC_Init_Maintenance_Plans_From_Service_Contract(
              variablesMap
            );
            if (!Test.isRunningTest()) {
                maintenancePlanFlow.start();
            }
        } catch (Exception e) {
            System.debug('Problem in flow SMC_Init_Maintenance_Plans_From_Service_Contract : ' + e.getMessage());
            return false;
        }
        return true;
    }
}