/**
 * @File Name          : SMC_DTO_GetScoring_Error.cls
 * @Description        :
 * @Author             : Denis PHAM (Modis)
 * @Group              :
 * @Last Modified By   : Denis PHAM (Modis)
 * @Last Modified On   : 31/05/2022 
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0       31/05/2022      Denis PHAM (Modis)               Initial Version
 **/

 public with sharing class SMC_DTO_GetScoring_Error {
    @AuraEnabled
    public String code { get; set; }
  
    @AuraEnabled
    public String message { get; set; }
  
    public SMC_DTO_GetScoring_Error() {

    }
}