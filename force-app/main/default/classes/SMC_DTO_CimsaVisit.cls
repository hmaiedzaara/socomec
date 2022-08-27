/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_CimsaVisit
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is the DTO to call the WebService "Create CIMSA Visit"
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 13-MAR-2019  VRE     1.0     	Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_CimsaVisit {
  public String PS { get; set; }
  public String VISUNDID { get; set; }
  public String VISCATID { get; set; }
  public String VISSN { get; set; }
  public String VISPL { get; set; }
  public String VIEWH { get; set; }
  public String SFUSER { get; set; }
  public String USRID { get; set; }
  public String REQID { get; set; }
  public String SFCASE { get; set; }
  public String SFCASEID { get; set; }
  public String VICODE { get; set; }
  public Boolean calloutResponse { get; set; }

  public SMC_DTO_CimsaVisit() {
    this.calloutResponse = false;
  }
}