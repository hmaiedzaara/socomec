/**
 * @File Name          : SMC_DTO_GetScoring.cls
 * @Description        :
 * @Author             : Denis PHAM (Modis)
 * @Group              :
 * @Last Modified By   : Denis PHAM (Modis)
 * @Last Modified On   : 07/07/2022 
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0       07/07/202       Denis PHAM (Modis)     Initial Version
 **/

 public with sharing class SMC_DTO_GetScoring {
    @AuraEnabled
    public Integer id { get; set; }

    @AuraEnabled
    public String sfdcAccountId { get; set; }

    @AuraEnabled
    public List<SMC_DTO_Scoring_ScoringLine> scoringLines { get; set; }

    public SMC_DTO_GetScoring() {

    }
}