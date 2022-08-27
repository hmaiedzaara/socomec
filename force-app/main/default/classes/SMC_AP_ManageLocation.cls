/*
---------------------------------------------------------------------------
-- - Name : SMC_AP_ManageLocation
-- - Author : Vincent RECASENS
-- - Description : This class manage Location
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 03-APR-2019  VRE  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageLocation {
    /**
* @description : update site account of the location
* @author Vincent RECASENS (Modis) | 08/04/2020
* @param mapLocationIdToAccountId 
**/
    public static void updateSiteAccountFromNewAssociatedLocationSite(
        Map<Id, Id> mapLocationIdToAccountId
    ) {
        List<Schema.Location> locations = new List<Schema.Location>();
        // List<Database.SaveResult> updateLocationResultList = new List<Database.SaveResult>();
        locations = [
            SELECT Id, SMC_Site_Account__c
            FROM Location
            WHERE Id IN :mapLocationIdToAccountId.keySet()
        ];
        for (Schema.Location oneLocation : locations) {
            oneLocation.SMC_Site_Account__c = mapLocationIdToAccountId.get(
                oneLocation.Id
            );
        }
        // updateLocationResultList = Database.update(locations);
        Database.update(locations);
        System.debug(
            LoggingLevel.INFO,
            '## >>> SMC_AP_ManageLocation updateSiteAccount: update location OK <<< ##'
        );
    }
    
    public static void getdurationFromCallout(Map<Id, Schema.Location> newMap, Map<Id, Schema.Location> oldMap) {
        System.debug('-----------START : getdurationFromCallout------------');
        Map<Id, Id> mapIdLocationAddress_IdLocation = new Map<Id, Id>();
        Map<Id, Id> mapIdServiceTerritory_IdLocation = new Map<Id, Id>();
        for(Id oneId : newMap.keySet()){
            if(newMap.get(oneId).SMC_Address__c != null &&
               newMap.get(oneId).SMC_Service_Territory__c != null &&
               (newMap.get(oneId).SMC_Address__c != oldMap.get(oneId).SMC_Address__c ||
                newMap.get(oneId).SMC_Service_Territory__c != oldMap.get(oneId).SMC_Service_Territory__c)){
                    mapIdLocationAddress_IdLocation.put(newMap.get(oneId).SMC_Address__c, oneId);
                    mapIdServiceTerritory_IdLocation.put(newMap.get(oneId).SMC_Service_Territory__c, oneId);
                }
        }
        
        if(mapIdLocationAddress_IdLocation.size() == 0 || mapIdServiceTerritory_IdLocation.size() == 0){
            System.debug('There is no location to update, exit process.');
            return;
        }
        List<Schema.Address> addressLocations = new List<Schema.Address>();
        List<ServiceTerritory> addressServiceTerritory = new List<ServiceTerritory>();
        
        try {
            addressLocations = [SELECT Id, Latitude, Longitude FROM Address WHERE Id IN: mapIdLocationAddress_IdLocation.keySet()];
            addressServiceTerritory = [SELECT Id,  Latitude, Longitude FROM ServiceTerritory WHERE Id IN: mapIdServiceTerritory_IdLocation.keySet()];
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        List<Double> origin = new List<Double>();
        List<Double> destination = new List<Double>();
        
        try {
            for (ServiceTerritory st : addressServiceTerritory) {
                if (st.Latitude == null || st.Longitude == null) {
                    System.debug('ServiceTerritory latitude and longitude in error : ' + st);
                    return;
                }
                Double lat = st.Latitude;
                Double lng = st.Longitude;
                origin.add(lat);
                origin.add(lng);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        try {
            for (Schema.Address address : addressLocations) {
                if (address.Latitude == null || address.Longitude == null) {
                    System.debug('Schema.Address latitude and longitude in error : ' + address);
                    return;
                }
                Double lat = address.Latitude;
                Double lng = address.Longitude;
                destination.add(lat);
                destination.add(lng);
            }
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        System.enqueueJob(new GetdurationFromCallout_Queueable(mapIdLocationAddress_IdLocation, origin, destination));
    }
    
    public class GetdurationFromCallout_Queueable implements Queueable, Database.AllowsCallouts {
        Map<Id, Id> mapIdLocationAddress_IdLocation;
        List<Double> origin;
        List<Double> destination;
        
        
        public GetdurationFromCallout_Queueable(Map<Id, Id> mapIdLocationAddress_IdLocation, List<Double> origin, List<Double> destination) {
            this.mapIdLocationAddress_IdLocation = mapIdLocationAddress_IdLocation;
            this.origin = origin;
            this.destination = destination;  
        }
        
        public void execute(QueueableContext context) {
            System.debug(LoggingLevel.INFO, 'getdurationFromCallout execute START');           
            //Update EstimatedTravelTime in Location
            SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes rep = SMC_AP_ManageServiceAppointment_Callout.manageServiceAppointementCallout(this.origin, this.destination);
            
            System.debug('this origin --> ' + this.origin + '  , this destination--->' + this.destination);          
            List<SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Route> emptyList = new List<SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Route>();
            
            if (rep.routes == emptyList) {
                return;
            }
            
            List<Schema.Location> estimatedTravelTime = [SELECT Id, SMC_EstimatedTravelTime__c FROM Location WHERE Id IN: mapIdLocationAddress_IdLocation.values()];
            
            for (Schema.Location ett : estimatedTravelTime) {
                ett.SMC_EstimatedTravelTime__c = (rep.routes[0].sections[0].summary.duration / 60.0).round(System.RoundingMode.UP);
                System.debug(LoggingLevel.INFO, 'Estimated Travel Time----->'+ ett.SMC_EstimatedTravelTime__c);
            }
            try {
                update estimatedTravelTime;
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'The following exception has occurred: ' + e.getMessage());
            }
            
            System.debug(LoggingLevel.INFO, 'getdurationFromCallout execute END');
        }
    }


    public static void renameLocation(Map<Id, Schema.Location> newMap, Map<Id, Schema.Location> oldMap){
        System.debug('-----------START : renameLocation------------');
        Map<Id,Id> mapLocationIdToUpdate_AddressId = new Map<Id,Id>();
        for(Id oneId : newMap.keySet()){
            if(newMap.get(oneId).LocationType == 'Site' && newMap.get(oneId).SMC_Address__c != null && newMap.get(oneId).SMC_Address__c != oldMap.get(oneId).SMC_Address__c){
                mapLocationIdToUpdate_AddressId.put(oneId, newMap.get(oneId).SMC_Address__c);
            }
        }

        if(mapLocationIdToUpdate_AddressId.size() == 0){
            System.debug(LoggingLevel.INFO, 'There is no location to update, exit process.');
            return;
        }

        List<Schema.Address> addressInfo = new List<Schema.Address>();
        Map<Id, Schema.Location> mapLocationToUpdate = new Map<Id, Schema.Location>();
      
        addressInfo = [SELECT Id, Name, City, Country, Street, PostalCode FROM Address WHERE Id IN: mapLocationIdToUpdate_AddressId.values()];
        mapLocationToUpdate = new Map<Id, Schema.Location>([SELECT Id, Name, SMC_Site_Account__c, SMC_Site_Account__r.Name FROM Location WHERE Id IN: mapLocationIdToUpdate_AddressId.keySet()]);

        // create new Location Name
        Map<Id,String> mapAddressId_LocationNewName = new Map<Id,String>();

        for (Schema.Address oneAddress : addressInfo) {
            if (oneAddress.Country == null || oneAddress.City == null || oneAddress.Street == null || oneAddress.PostalCode == null) {
                System.debug(LoggingLevel.INFO, 'Address Country or City in error : ' + oneAddress);
            }
            String newLocationName = (oneAddress.Street == null ? '' : oneAddress.Street + ', ') + (oneAddress.PostalCode == null ? '' : oneAddress.PostalCode ) + (oneAddress.City == null ? '' : ', ' + oneAddress.City ) + (oneAddress.Country == null ? '' : ' - ' + oneAddress.Country);
            mapAddressId_LocationNewName.put(oneAddress.Id, newLocationName);
        }
        
        Map<Id, String> mapLocationId_LocationNewName = new Map<Id, String>();

        if(mapLocationToUpdate != null && mapLocationToUpdate.size() > 0){
            for (Id oneId : newMap.keySet()) {
                if (mapLocationToUpdate.get(oneId) != null && 
                    (mapLocationToUpdate.get(oneId).SMC_Site_Account__c == null || 
                     mapLocationToUpdate.get(oneId).SMC_Site_Account__r.Name == null)) {
                    System.debug(LoggingLevel.INFO, 'Account name in error : ' + mapLocationToUpdate.get(oneId).SMC_Site_Account__r.Name);
                    continue;
                }
                String locationNewName =  (mapLocationToUpdate.get(oneId).SMC_Site_Account__r.Name == null ? '' : mapLocationToUpdate.get(oneId).SMC_Site_Account__r.Name + ' - ') + mapAddressId_LocationNewName.get(newMap.get(oneId).SMC_Address__c) ;  
                
                mapLocationId_LocationNewName.put(oneId, locationNewName);
            }
        }

        // Check if Location name already exist
        List<Schema.Location> newLocationName1 = [SELECT Id, Name FROM Location WHERE Name IN: mapLocationId_LocationNewName.values()];
        
        for (Id oneId : newMap.keySet()) {
            if (newLocationName1 != null && newLocationName1.size() > 0) {
                newMap.get(oneId).addError('This Location Name already exist.');
            }
            if(mapLocationId_LocationNewName.get(oneId) != null){
                newMap.get(oneId).Name = mapLocationId_LocationNewName.get(oneId).toUpperCase();
            }
        }

        System.debug('-----------END : renameLocation------------');
    }
    
    @AuraEnabled
    public static void invokeFlowCreateLocationAndRelatedAddress(Id locId) {
        System.debug('Flow START ');
        Map<String, Object> mapParam = new Map<String, Object>();
        mapParam.put('recordId', locId);

        Flow.Interview.SMC_Create_Location_and_related_Address createNewLocation = new Flow.Interview.SMC_Create_Location_and_related_Address(mapParam);
        createNewLocation.start();

        System.debug('Flow END');
    }
}