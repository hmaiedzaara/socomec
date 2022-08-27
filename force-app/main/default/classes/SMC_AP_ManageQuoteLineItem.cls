/*
--------------------------------------------------------------------------------------
-- - Name          : SMC_AP_ManageQuoteLineItem
-- - Author        : DOS
-- - Description   : Manage Quote Line Item               
-- Maintenance History:
--
-- Date         Name                Version  Remarks
-- -----------  ----                -------  -----------------------------------------
-- 11-OCT-19    David SOBCZAK    	1.0     Initial version
--------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageQuoteLineItem {
  /**
  * @description : prevent delete by user interface
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param qlis 
  * @return Boolean 
  **/
  public static Boolean preventDeleteByUI(List<QuoteLineItem> qlis) {
    for (QuoteLineItem qli : qlis) {
      // Prevent Delete if operation don't provide through rest WS (eg : Quotation Tool use Rest WS)
      if (RestContext.request == null) {
        qli.addError(
          String.escapeSingleQuotes(System.Label.SMC_PreventDeleteQLI),
          true
        );
        return false;
      }
    }
    return true;
  }
}