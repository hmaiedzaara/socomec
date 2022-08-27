public without sharing class SMC_AC_QuickAction_NewCase {
    /** MAPPING OBJECT --> ADDITIONNAL PREDEFNIED VALUES **/
    // public Map<String, >

    @AuraEnabled
    public static String setDefaultValues(String recordId){
        //From Where? => check object
        SMC_AC_Page_CreateCase.PredefinedFieldsValues returnWrapper;
        if(recordId.startsWith('006')) {
                returnWrapper = fromOpportunity(recordId);
        }
        //Quote
        else if(recordId.startsWith('0Q0')) {
            returnWrapper = fromQuote(recordId);
        }
        //Contact
        else if(recordId.startsWith('003')) {
            returnWrapper = fromContact(recordId);
        }
        //From nowhere
        else {
            //standard case
        }
        return JSON.serialize(returnWrapper);
    }

    private static SMC_Case_RecordType__mdt getKindCaseToSetCaseTypeList(String fromObject){
        return [SELECT Label, 
                       Kind_Case__c, 
                       Img_Path__c,
                       RecordType_According_To_Kind_Case__c,
                       Case_Type_Img_Identifier__c 
                FROM SMC_Case_RecordType__mdt 
                WHERE DeveloperName = :(STA_UtilsStatic.SMC_PREFIX_CASE_QUICK_ACTION + fromObject)];
    }

    private static SMC_AC_Page_CreateCase.PredefinedFieldsValues fromOpportunity(String recordId){
        //Get opportunity
        Opportunity theOpportunitty = [SELECT Id, AccountId FROM Opportunity WHERE Id = :recordId];
        //Get metadata
        SMC_Case_RecordType__mdt caseRecordTypeMdt = getKindCaseToSetCaseTypeList(STA_UtilsStatic.OPPORTUNITY);
        //Set predefined values
        SMC_AC_Page_CreateCase.PredefinedFieldsValues pdv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(caseRecordTypeMdt.Kind_Case__c.split(';')[0]);
        pdv.opportunityId = theOpportunitty.Id;
        pdv.endCustomerId = theOpportunitty.AccountId;
        //Set metadata
        pdv.recordTypeMdt = caseRecordTypeMdt;
        pdv.kindCase = pdv.recordTypeMdt.Kind_Case__c;
        return pdv;
    }

    private static SMC_AC_Page_CreateCase.PredefinedFieldsValues fromQuote(String recordId){
        //Get quote
        Quote theQuote = [SELECT Id, OpportunityId, Opportunity.AccountId FROM Quote WHERE Id = :recordId];
        //Get metadata
        SMC_Case_RecordType__mdt caseRecordTypeMdt = getKindCaseToSetCaseTypeList(STA_UtilsStatic.QUOTE);
        //Set predefined values
        SMC_AC_Page_CreateCase.PredefinedFieldsValues pdv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(caseRecordTypeMdt.Kind_Case__c.split(';')[0]);
        pdv.opportunityId = theQuote.OpportunityId;
        pdv.quoteId = theQuote.Id;
        pdv.endCustomerId = theQuote.Opportunity.AccountId;
        //Set metadata
        pdv.recordTypeMdt = caseRecordTypeMdt;
        pdv.kindCase = pdv.recordTypeMdt.Kind_Case__c;
        return pdv;
    }

    private static SMC_AC_Page_CreateCase.PredefinedFieldsValues fromContact(String recordId){
        //Get quote
        Contact theContact = [SELECT Id, AccountId FROM Contact WHERE Id = :recordId];
        //Get metadata
        SMC_Case_RecordType__mdt caseRecordTypeMdt = getKindCaseToSetCaseTypeList(STA_UtilsStatic.CONTACT);
        //Set predefined values
        SMC_AC_Page_CreateCase.PredefinedFieldsValues pdv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(caseRecordTypeMdt.Kind_Case__c.split(';')[0]);
        pdv.accountId = theContact.AccountId;
        pdv.contactId = theContact.Id;
        //Set metadata
        pdv.recordTypeMdt = caseRecordTypeMdt;
        pdv.kindCase = pdv.recordTypeMdt.Kind_Case__c;
        return pdv;
    }
}