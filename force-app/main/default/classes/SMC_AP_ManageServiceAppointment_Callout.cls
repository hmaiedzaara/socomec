public with sharing class SMC_AP_ManageServiceAppointment_Callout {
    public static SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes manageServiceAppointementCallout(List<Double> origin, List<Double> destination) {

        SMC_MaintenancePlan__mdt ApiKey = [SELECT APIkey_HERE__c FROM SMC_MaintenancePlan__mdt];

        // String originText =  '52.5308,13.3847';
        // String destinationText =  '52.5323,13.3789';
        String originText = origin[0] + ',' + origin[1];
        String destinationText = destination[0] + ',' + destination[1];

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('callout:SMC_MaintenancePlan/routes?transportMode=car&origin='+originText+'&destination='+destinationText+'&return=summary&apiKey='+ApiKey.APIkey_HERE__c);
        System.debug('https://router.hereapi.com/v8/routes?transportMode=car&origin='+originText+'&destination='+destinationText+'&return=summary&apiKey='+ApiKey.APIkey_HERE__c);
        httpRequest.setMethod('GET');

        String strResponse = null;
        SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes routes = new SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes();

        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(HttpRequest);
            if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 204){
                strResponse = httpResponse.getBody();
                System.debug('Retreive routes string---> '+ strResponse);
                strResponse = strResponse.replaceAll('"time":', '"timeDA":');
                System.debug('Retreive routes string after replace time ---> '+ strResponse);
                routes = (SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes)JSON.deserialize(strResponse, SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes.class);
                System.debug('Retreive routes---> '+ routes);                
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (Exception ex) {
            System.debug('error ---->' +ex);            
        }

        return routes;
    }
}