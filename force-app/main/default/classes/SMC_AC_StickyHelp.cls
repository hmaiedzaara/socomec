public class SMC_AC_StickyHelp {
    
    public class StickyWrapper{
        public String masterLabel;
        public String url;
        
        public StickyWrapper(String masterLabel, String url){
            this.masterLabel = masterLabel;
            this.url = url;
        }
    }
    
    @AuraEnabled
    public static String getStickyInfos(){
        List<StickyWrapper> result = new List<StickyWrapper>();
        for(Sticky_Help__mdt oneStickyInfo : [SELECT Id, MasterLabel, URL__c FROM Sticky_Help__mdt]){
            result.add(new StickyWrapper(oneStickyInfo.MasterLabel, oneStickyInfo.URL__c));
        }
        return JSON.serialize(result);
    }

}