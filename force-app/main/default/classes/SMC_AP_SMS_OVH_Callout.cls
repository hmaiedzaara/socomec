public with sharing class SMC_AP_SMS_OVH_Callout {
    public static Boolean  manageSMSOVHCallout(String message, String phoneNumber) {

        SMC_SMS_OVH__mdt sms_ovh_mdt = [SELECT Sender__c, URL_SMS_OVH__c, Application_Key__c, Application_Secret__c, Consumer_Key__c, Service_Name__c  FROM SMC_SMS_OVH__mdt  WHERE DeveloperName = :'SMC_SMS_OVH_dev'];

        String AK = sms_ovh_mdt.Application_Key__c;
        String AppS = sms_ovh_mdt.Application_Secret__c;
        String CK = sms_ovh_mdt.Consumer_Key__c;
        
        String ServiceName = sms_ovh_mdt.Service_Name__c;
        String sender = sms_ovh_mdt.Sender__c;
        String url = sms_ovh_mdt.URL_SMS_OVH__c;

        String METHOD = STA_UtilsStatic.POST_METHOD;
        String QUERY = url+'/'+ServiceName+'/jobs';
        String BODY = '{ "charset": "UTF-8", "receivers": [ "' + phoneNumber + '" ], "message": "' + message + '", "priority": "high", "sender": "' + sender + '", "senderForResponse": false, "noStopClause": true}';
        String TSTAMP = (System.now().getTime())/1000 + '';
        String signature = '$1$' + EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(AppS + '+' + CK + '+' + METHOD + '+' + QUERY + '+' + BODY + '+' + TSTAMP)));

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(QUERY);
        request.setMethod(METHOD);
        request.setBody(BODY);
        request.setHeader(STA_UtilsStatic.CONTENT_TYPE, STA_UtilsStatic.APPLICATION_JSON);
        request.setHeader('X-Ovh-Application', AK);
        request.setHeader('X-Ovh-Consumer' , CK);
        request.setHeader('X-Ovh-Signature', signature);
        request.setHeader('X-Ovh-Timestamp', TSTAMP);

        HttpResponse response = new HTTPResponse();

        try {
            response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                    response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug('Response Body--> ' + response.getBody()); 
                return true;
            }
        } catch (CalloutException calloutException) {
            System.debug(
              LoggingLevel.INFO,
              STA_UtilsStatic.BAD_STATUS_CODE +
              response.getStatusCode() +
              ' -> CalloutException : ' +
              calloutException
            );
            SMC_UTIL_Methods_Batch.createErrorLog(
              new List<CalloutException>{ calloutException },
              STA_UtilsStatic.ERROR_SMS_OVH,
              STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
              BODY,
              QUERY,
              new List<String>{phoneNumber}
            );
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, 'Exception : ' + e);
            SMC_UTIL_Methods_Batch.createErrorLog(
              new List<Exception>{ e },
              STA_UtilsStatic.ERROR_SMS_OVH, 
              STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
              BODY,
              QUERY,
              new List<String>{phoneNumber}
            );
        }
        return false;
    }
}