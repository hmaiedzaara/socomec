@isTest
public with sharing class TEST_SMC_AP_SMS_OVH_Callout {
    @isTest
    public static void testSMSOVH(){

        SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
            200,
            'OK',
            '{"invalidReceivers":[],"totalCreditsRemoved":1,"validReceivers":["+3362345679"],"ids":[320764238]}',
            null
        );

        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        System.assertEquals(true, SMC_AP_SMS_OVH_Callout.manageSMSOVHCallout('test message', '+3362345679'));
        
        Test.stopTest();
    }   

    @isTest
    public static void testSMSOVHKO(){

        SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
            401,
            'Unauthorized',
            '{"invalidReceivers":[],"totalCreditsRemoved":0,"validReceivers":["+3362345679"],"ids":[320764238]}',
            null
        );

        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        System.assertEquals(false, SMC_AP_SMS_OVH_Callout.manageSMSOVHCallout('test message', '+3362345679'));
        
        Test.stopTest();
    }   
}