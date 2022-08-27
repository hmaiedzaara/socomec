/**
 * @File Name          : SMC_DTO_ML_Wrapper_Picklist.cls
 * @Description        : 
 * @Author             : Vincent RECASENS (Modis)
 * @Group              : 
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
**/

public with sharing class SMC_DTO_ML_Wrapper_Picklist {
    
    public with sharing class SMC_DTO_ML_PF_Parent {

        @AuraEnabled
        public SMC_DTO_ML_PF_Children children;
    }

    public with sharing class SMC_DTO_ML_PF_Children {
        
        @AuraEnabled
        public List<SMC_DTO_ML_PF_GrandChildren> grandChildren;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;

    }
    
    public with sharing class SMC_DTO_ML_PF_GrandChildren {

        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
    }
    
    public with sharing class SMC_DTO_ML_Others {

        @AuraEnabled
        public List<SMC_DTO_ML_OthersDetails> objects;
    }
    
    public with sharing class SMC_DTO_ML_OthersDetails {

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}