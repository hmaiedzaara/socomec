public without sharing class SMC_AP_ManageQuote_AsyncAFDML {
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public Id quoteid;
    }
    
    /*** GENERER PDF + ENVOIE EMAIL ***/
    @InvocableMethod(label='Training certification email & PDF')
    public static void sendEmailWithPDF(List<FlowInputs> request){
        System.enqueueJob(new ResetQuoteFields(request));
    }

    public class ResetQuoteFields implements Queueable, Database.AllowsCallouts {
        List<FlowInputs> request;
        public ResetQuoteFields(List<FlowInputs> request) {
            this.request = request;
        }

        public void execute(QueueableContext context){
            //Get quote ids
            Set<Id> setQuoteIds = new Set<Id>();
            for(FlowInputs oneInput : this.request){
                setQuoteIds.add(oneInput.quoteid);
            }

            //Get quote et reset fields
            List<Quote> quoteToReset = new List<Quote>();
            for(Quote oneQuote : [SELECT Id, 
                                         SMC_Send_Reminder__c 
                                  FROM Quote 
                                  WHERE Id IN :setQuoteIds]){
                oneQuote.SMC_Send_Reminder__c = false;
                quoteToReset.add(oneQuote);
            }

            //update quote
            update quoteToReset;
        }
    }
}