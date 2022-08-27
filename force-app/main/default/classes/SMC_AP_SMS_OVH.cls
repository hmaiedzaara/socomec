public class SMC_AP_SMS_OVH {

    @InvocableMethod(label='SMS OVH')
    public static void invokeThisMetho(List<FlowInputs> request) {
        SMC_AP_SMS_OVH_Callout.manageSMSOVHCallout(request[0].message, request[0].phoneNumber);
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
    
        @InvocableVariable
        public String message;
        
        @InvocableVariable
        public String phoneNumber; 
    }
}