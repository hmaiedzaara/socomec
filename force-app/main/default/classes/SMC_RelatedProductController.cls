public without sharing class SMC_RelatedProductController {

    @AuraEnabled
    public static  List<RelatedProduct> getRelatedProduct ( String idProduct , String effectiveAccountId , String numberOfProduct   ){

        Webstore wb = [ select id , name from WebStore WHERE name = 'eorder'] ; // 'eorder' to be configured somewhere 

        Account acc = [ select id , smc_country__c  from account where id =  :effectiveAccountId   ] ; 

        Integer limitation = Integer.ValueOf ( numberOfProduct ) ; 

        List<RelatedProduct> l_RelatedProduct = new List<RelatedProduct>() ; 

        Set <String>  l_ProductId = new Set <String> () ; 

        List<SMC_RelatedProduct__c> smc_RelatedProducts = [    SELECT  id,
                                                                    Name,
                                                                    SMC_Country__c,
                                                                    SMC_ParentProduct__c,
                                                                    SMC_RelatedProduct__c,
                                                                    SMC_ReplacementDescription__c,
                                                                    SMC_ParentProduct__r.StockKeepingUnit,
                                                                    SMC_ParentProduct__r.Name,
                                                                    SMC_RelatedProduct__r.StockKeepingUnit,
                                                                    SMC_RelatedProduct__r.Name
                                                            FROM    SMC_RelatedProduct__c 
                                                            WHERE   SMC_RelatedProduct__c = :idProduct 
                                                            AND     SMC_StartDate__c < TODAY 
                                                            AND     SMC_EndDate__c   > TODAY 
                                                            AND     SMC_Country__c = :acc.smc_country__c
                                                            AND     RecordType.developerName = 'Replacement_product'
                                                            LIMIT   :Limitation
                                                        ] ; 
                                                        
        for( SMC_RelatedProduct__c rp : smc_RelatedProducts){
            l_ProductId.add ( rp.SMC_ParentProduct__c ) ; 
        }

        Map <String , ConnectApi.ProductDetail > l_productInfo =  SMC_CartUtiles.getProductsInfo (  wb.id , effectiveAccountId , new List<String> (l_ProductId)    ) ; 

        for( SMC_RelatedProduct__c rp : smc_RelatedProducts ){
            l_RelatedProduct.add ( new RelatedProduct ( rp.SMC_ParentProduct__c ,  rp.SMC_ParentProduct__r.Name , rp.SMC_ParentProduct__r.StockKeepingUnit , rp.SMC_ParentProduct__c , rp.SMC_RelatedProduct__c , rp.SMC_ReplacementDescription__c ,l_productInfo.get( rp.SMC_ParentProduct__c ).defaultImage.url , '/eorder/s/product/detail/' + rp.SMC_ParentProduct__c   ) ) ; 
        }
        
        return   l_RelatedProduct; 
                    
    }

    public class RelatedProduct{

        @AuraEnabled
        public String relatedProduct_Id ; 

        @AuraEnabled
        public String relatedProduct_Name ; 

        @AuraEnabled
        public String relatedProduct_SKU ; 

        @AuraEnabled
        public String relatedProduct_ParentProductId ; 

        @AuraEnabled
        public String relatedProduct_RelatedProductId; 

        @AuraEnabled
        public String relatedProduct_Description ; 

        @AuraEnabled
        public String relatedProduct_DefaultImage_URL ; 

        @AuraEnabled
        public String relatedProduct_URL ; 



        public RelatedProduct ( String relatedProduct_Id  ,  String relatedProduct_Name, String relatedProduct_SKU , String relatedProduct_ParentProductId , String relatedProduct_RelatedProductId ,  String relatedProduct_Description, String relatedProduct_DefaultImage_URL , String relatedProduct_URL  ) {

            this.relatedProduct_Id                  = relatedProduct_Id                 ; 
            this.relatedProduct_Name                = relatedProduct_Name               ; 
            this.relatedProduct_SKU                 = relatedProduct_SKU                ;
            this.relatedProduct_ParentProductId     = relatedProduct_ParentProductId    ;
            this.relatedProduct_RelatedProductId    = relatedProduct_RelatedProductId   ; 
            this.relatedProduct_DefaultImage_URL    = relatedProduct_DefaultImage_URL   ;
            this.relatedProduct_Description         = relatedProduct_Description        ;
            this.relatedProduct_URL                 = relatedProduct_URL                ;


        }


    }


}
