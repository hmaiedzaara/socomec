/*
---------------------------------------------------------------------
-- - Name          : WS_ResponseHandlerV1
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Response for webservice callback    
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 20-Nov-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

global with sharing class WS_ResponseHandlerV1 {
  //List of custom attributes that we want to check the status of the org
  public Boolean isSuccess { get; set; }
  public String Status { get; set; }
  public List<sObject> Data { get; set; }
  public String Message { get; set; }
  public String ErrorCode { get; set; }

  // Constructor
  public WS_ResponseHandlerV1(Boolean isSuccess) {
    this.isSuccess = isSuccess;
  }
}