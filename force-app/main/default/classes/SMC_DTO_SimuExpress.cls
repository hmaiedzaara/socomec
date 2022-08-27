/**
 * @File Name          : SMC_DTO_SimuExpress.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/12/2019 à 15:35:27
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/01/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public without sharing class SMC_DTO_SimuExpress {
  @AuraEnabled
  public Boolean isRedirect { get; set; }

  @AuraEnabled
  public List<String> resultList { get; set; }

  @AuraEnabled
  public SMC_DTO_QuotationTool_MissingFields dtoMissingFields { get; set; }

  public SMC_DTO_SimuExpress() {
    this.isRedirect = false;
    this.resultList = null;
    this.dtoMissingFields = null;
  }

  public SMC_DTO_SimuExpress(List<String> resultList) {
    this.isRedirect = true;
    this.resultList = resultList;
  }

  public SMC_DTO_SimuExpress(
    SMC_DTO_QuotationTool_MissingFields dtoMissingFields
  ) {
    this.isRedirect = false;
    this.dtoMissingFields = dtoMissingFields;
  }
}