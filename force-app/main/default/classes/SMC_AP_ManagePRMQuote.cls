public with sharing class SMC_AP_ManagePRMQuote {

    public static void duplicateLinkQuoteToPRMQuote(Map<Id, SMC_PRM_Quote__c> newMap){
        //Get quotes id
        Map<Id, Id> mapPRMQuoteId_QuoteId = new Map<Id, Id>();
        for(Id oneId : newMap.keySet()){
            mapPRMQuoteId_QuoteId.put(oneId, newMap.get(oneId).Quote__c);
        }

        //Get file link to quote
        Map<Id, List<ContentDocumentLink>> mapQuoteId_Cdl = new Map<Id, List<ContentDocumentLink>>();
        try{
            List<ContentDocumentLink> cdlList = [SELECT LinkedEntityId, 
                                                        ContentDocumentId, 
                                                        Visibility 
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId IN :mapPRMQuoteId_QuoteId.values()];
            for(ContentDocumentLink oneCdl : cdlList){
                if(mapQuoteId_Cdl.get(oneCdl.LinkedEntityId) == null){
                    mapQuoteId_Cdl.put(oneCdl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                mapQuoteId_Cdl.get(oneCdl.LinkedEntityId).add(oneCdl);
            }
        }
        catch(Exception e){
            Set<Id> quoteIds = new Set<Id>();
            quoteIds.addAll(mapPRMQuoteId_QuoteId.values());
            System.debug('There is no file link to this quote list : ' + quoteIds);
        }

        //If there is no file, get out of the method
        if(mapQuoteId_Cdl.size() == 0){
            return;
        }

        //Set new file link to PRM quote
        List<ContentDocumentLink> newCdls = new List<ContentDocumentLink>();
        for(Id onePrmQuoteId : mapPRMQuoteId_QuoteId.keySet()){
            if(mapQuoteId_Cdl.get(mapPRMQuoteId_QuoteId.get(onePrmQuoteId)) == null){
                continue;
            }

            for(ContentDocumentLink oneCdl : mapQuoteId_Cdl.get(mapPRMQuoteId_QuoteId.get(onePrmQuoteId))){
                ContentDocumentLink newCdl = new ContentDocumentLink();
                newCdl.LinkedEntityId = onePrmQuoteId;
                newCdl.ContentDocumentId = oneCdl.ContentDocumentId;
                newCdl.Visibility = oneCdl.Visibility;
                newCdls.add(newCdl);
            }
        }

        if(newCdls.size() > 0){
            PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
            insert newCdls;
            PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
        }
    }
}