/**
 * @File Name          : SMC_DTO_DiscountToken.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:53:02
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_DiscountToken {
  public String refreshToken { get; set; }
  public Call_Scoring_Domain__mdt callInformations { get; set; }

  public SMC_DTO_DiscountToken() {
    this.refreshToken = '';
  }
}