/**
 * @File Name          : SMC_DTO_GetInformationsForToken.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:53:17
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_GetInformationsForToken {
  public String application { get; set; }
  public String secret { get; set; }
  public SMC_DTO_SDFCUser sfdcUser { get; set; }

  public SMC_DTO_GetInformationsForToken() {
    this.sfdcUser = new SMC_DTO_SDFCUser();
  }
}