@isTest
public with sharing class TEST_SMC_AP_ManageSA_Callout {
    @isTest
    public static void testmanageServiceAppointementCallout() {
        //TEST
        List<Double> origin = new List<Double>();
        Double originLat = 52.5308;
        Double originLng = 13.3847;
        origin.add(originLat);
        origin.add(originLng);

        List<Double> destination = new List<Double>();
        Double destinationLat = 52.5323;
        Double destinationLng = 13.3789;
        destination.add(destinationLat);
        destination.add(destinationLng);
        

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource(STA_UtilsStatic.MOCK_MAINTENANCE_PLAN);
        mock.setStatusCode(200);
        mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
        mock.setHeader(
          STA_UtilsStatic.CONTENT_TYPE,
          STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
        );
    
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
    
        Test.startTest();
        SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes rep = SMC_AP_ManageServiceAppointment_Callout.manageServiceAppointementCallout(origin,destination);
        Test.stopTest();
    
        System.assertNotEquals(
          null,
          rep,
          'Mock is wrong. Check it and relaunch test.'
        );
    }

    @isTest
    public static void testmanageServiceAppointementCalloutFAIL() {
        //TEST
        List<Double> origin = new List<Double>();
        Double originLat = 52.5308;
        Double originLng = 13.3847;
        origin.add(originLat);
        origin.add(originLng);

        List<Double> destination = new List<Double>();
        Double destinationLat = 52.5323;
        Double destinationLng = 13.3789;
        destination.add(destinationLat);
        destination.add(destinationLng);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
        mock.setStatusCode(500);
        mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
        mock.setHeader(
          STA_UtilsStatic.CONTENT_TYPE,
          STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
        );

    
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
    
        Test.startTest();
        SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Routes rep = SMC_AP_ManageServiceAppointment_Callout.manageServiceAppointementCallout(origin,destination);
        Test.stopTest();

        List<SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Route> emptyList = new List<SMC_DTO_MaintenancePlan.SMC_DTO_MaintenancePlan_Route>();
    
        System.assertEquals(
            emptyList,
            rep.routes,
            'Mock is wrong. Check it and relaunch test.'
        );
    }

}