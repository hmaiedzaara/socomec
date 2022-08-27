/**
 * @description       : Controller of smc_lwc_case_order_tracking_tab
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   05-10-2021   Vincent RECASENS (Modis)   Initial Version
**/
public without sharing class SMC_AC_Case_Order_Tracking {
    public class WrapperInformation{
        @AuraEnabled
        public String jsonResult { get; set; }
        public WrapperInformation(String jsonResult){
            this.jsonResult = jsonResult;
        }
    }

    /**
    * @description : get case erp code
    * @author Vincent RECASENS (Modis) | 05-11-2021 
    * @param recordId 
    * @return String 
    **/
    @TestVisible
    private static Case getCurrentCase(String recordId){
      Case currentCase;
        try{
          currentCase = [SELECT Id, SMC_ERP_Order_Number__c, SMC_TECH_Order_Origin__c FROM Case WHERE Id = :recordId];
        }
        catch(Exception e){
          System.debug('There is no ERP Code or case is not retrieve : ' + e.getMessage());
        }
        return currentCase;
    }

    /**
    * @description : get case erp code
    * @author Vincent RECASENS (Modis) | 05-11-2021 
    * @param recordId 
    * @return String 
    **/
    @TestVisible
    private static String getCurrentCaseERPCode(String recordId){
      String erpCode = '';
        try{
          erpCode = [SELECT Id, SMC_ERP_Order_Number__c FROM Case WHERE Id = :recordId].SMC_ERP_Order_Number__c;
        }
        catch(Exception e){
          System.debug('There is no ERP Code or case is not retrieve : ' + e.getMessage());
        }
        return erpCode;
    }
    /**
    * @description : do callout to wmis-100
    * @author Vincent RECASENS (Modis) | 05-10-2021 
    * @param orderOrShipment 
    * @param salesOrderNumber 
    * @param calloutInformations 
    **/
    @TestVisible
    private static String makeCallout(
        String salesOrderNumber,
        Case_Callout__mdt calloutInformations
    ) {
        System.debug(
          LoggingLevel.INFO,
          '>>>>>>SMC_AC_Case_Order_Tracking -> Method makeCallout - START'
        );
        //Build the callout*****
        HttpRequest request = new HttpRequest();
        request.setEndpoint(calloutInformations.The_URL__c);
        request.setMethod(STA_UtilsStatic.GET_METHOD);
        request.setHeader(
          STA_UtilsStatic.CONTENT_TYPE,
          STA_UtilsStatic.APPLICATION_JSON
        );
        request.setTimeout(60000);
        String requestQuery =
          STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();
          System.debug(
            LoggingLevel.INFO,
            'Request URL --> ' + request.getEndpoint()
          );
    
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();
        String responseBody = '';
        try {
          response = http.send(request);
          //Error
          if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
            CalloutException calloutException = new CalloutException();
            calloutException.setMessage(
              STA_UtilsStatic.BAD_STATUS_CODE +
              response.getStatusCode() +
              ' -> BODY : ' +
              response.getBody()
            );
            throw calloutException;
          }
          responseBody = response.getBody();
          System.debug(LoggingLevel.INFO, 'Response body : ' + response.getBody());
        } catch (CalloutException calloutException) {
          System.debug(
            LoggingLevel.INFO,
            'Callout error' +
            ' -> CalloutException : ' +
            calloutException
          );
          SMC_UTIL_Methods_Batch.createErrorLog(
            new List<CalloutException>{ calloutException },
            'Callout error',
            STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
            null,
            requestQuery,
            new List<String>{'Sales order number : ' + salesOrderNumber}
          );
        } catch (Exception e) {
          System.debug(LoggingLevel.INFO, 'Exception : ' + e);
          SMC_UTIL_Methods_Batch.createErrorLog(
            new List<Exception>{ e },
            'Unknown error',
            STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
            null,
            requestQuery,
            new List<String>{'Sales order number : ' + salesOrderNumber}
          );
        }
    
        System.debug(
          LoggingLevel.INFO,
          '>>>>>>SMC_AC_Case_Order_Tracking -> Method makeCallout - END'
        );
        return responseBody;
    }

    /**
     * @description : init datatables
     * @author Vincent RECASENS (Modis) | 10/04/2020
     * @param orderOrShipment
     * @param salesOrderNumber
     * @return String
     **/
    @AuraEnabled
    public static String initialisationTab(String recordId, String internalOrexternal) {
        //Get case erp code
        // String erpCode = getCurrentCaseERPCode(recordId);
        Case currentCase = getCurrentCase(recordId);
        /* TEMPORARY */
        // erpCode = '100031';
        // currentCase.SMC_ERP_Order_Number__c = '3ES000036';
        /* TEMPORARY */
        if(currentCase != null && currentCase.SMC_ERP_Order_Number__c != '' && currentCase.SMC_ERP_Order_Number__c != null){
          currentCase.SMC_ERP_Order_Number__c = 
              (currentCase.SMC_ERP_Order_Number__c.split(' ').size() > 1 ? 
                currentCase.SMC_ERP_Order_Number__c.replace(' ', '%20') : 
                currentCase.SMC_ERP_Order_Number__c);
          //Check employee or external
          String cmpIs = internalOrexternal == 'Internal' ? 'employee' : 'external';
          //Callout informations
          Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
              STA_UtilsStatic.ORDERTRACKING
          );
          calloutInformations.The_URL__c += currentCase.SMC_TECH_Order_Origin__c + '/order/' + currentCase.SMC_ERP_Order_Number__c + '/employeeType/' + cmpIs;
          // calloutInformations.The_URL__c = 'https://wmisi.soc-grp.net/SocSalesforceView/shipments.dsp?salesOrder=3ES000036';
          String responseBody = makeCallout(currentCase.SMC_ERP_Order_Number__c, calloutInformations);
          System.debug('Response : ' + responseBody);
          return JSON.serialize(new WrapperInformation(responseBody));
        }
        return '';
    }
}