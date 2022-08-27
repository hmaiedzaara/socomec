/**
 * @File Name          : SMC_DTO_GetScoring_Body.cls
 * @Description        :
 * @Author             : Denis PHAM (Modis)
 * @Group              :
 * @Last Modified By   : Denis PHAM (Modis)
 * @Last Modified On   : 31/05/2022 
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0       31/05/2022      Denis PHAM (Modis)               Initial Version
 **/

 public with sharing class SMC_DTO_GetScoring_Body {
    @AuraEnabled
    public String sfdcAccountId { get; set; }
  
    @AuraEnabled
    public String category { get; set; }
  
    @AuraEnabled
    public String business { get; set; }

    @AuraEnabled
    public String countryCode { get; set; }

    @AuraEnabled
    public String tier { get; set; }
  
    @AuraEnabled
    public String acc { get; set; }

    @AuraEnabled
    public List<Integer> baIds { get; set; }

    public SMC_DTO_GetScoring_Body() {

    }
}