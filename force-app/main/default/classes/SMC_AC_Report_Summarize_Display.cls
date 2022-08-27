/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_Report_Summarize_Display
-- - Author : Vincent RECASENS
-- - Description : This class is Apex controller of LWC Pipe Summarize
                   It's an evolution of SMC_AC_PipeSummarize to use report instead of soql
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 24-OCT-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AC_Report_Summarize_Display {
  public class AllInformations {
    @AuraEnabled
    public Decimal element1;
    @AuraEnabled
    public Decimal element2;
    @AuraEnabled
    public String userCurrency;
    @AuraEnabled
    public String error;

    public AllInformations(String error) {
      this.error = error;
    }

    public AllInformations(Decimal element1, Decimal element2) {
      this.element1 = element1;
      this.element2 = element2;
      this.userCurrency = UserInfo.getDefaultCurrency();
    }
  }

  /**
  * @description : run report, get informations and store them in 2 column
  /!\ FOR THE REPORT /!\
  -column 1 : record id for redirection
  -column 2 : record name for row title
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @param reportDeveloperName 
  * @param aggregateColumn1 
  * @param aggregateColumn2 
  * @return AllInformations 
  **/
  @AuraEnabled
  public static AllInformations getInformations(
    String reportDeveloperName,
    Integer aggregateColumn1,
    Integer aggregateColumn2
  ) {
    //Get report
    List<Report> reportList = [
      SELECT Id
      FROM Report
      WHERE DeveloperName = :reportDeveloperName
    ]; //HOMEPAGE_Project_per_Closing_Date_REJ - SMC_Account_project_portfolio_with_acount
    //Get informations
    Decimal element1;
    Decimal element2;
    if (reportList != null && reportList.size() >= 0) {
      //Get report columns
      String reportId = (String) reportList.get(0).get('Id');
      Reports.reportResults results = Reports.ReportManager.runReport(
        reportId,
        true
      );
      Reports.ReportFactWithDetails factDetails1 = (Reports.ReportFactWithDetails) results.getFactMap()
        .get('T!T');
      List<Reports.SummaryValue> oppAggregs = results.getFactMap()
        .get('T!T')
        .getAggregates();

      if (oppAggregs != null && oppAggregs.size() >= aggregateColumn1) {
        //Get aggregated columns
        aggregateColumn1 = (aggregateColumn1 == 1
          ? oppAggregs.size() - 1
          : (aggregateColumn1 > 1 ? aggregateColumn1 - 2 : (null))); // If null --> ERROR
        aggregateColumn2 = (aggregateColumn2 == 1
          ? oppAggregs.size() - 1
          : (aggregateColumn2 > 1 ? aggregateColumn2 - 2 : (null))); // If null --> ERROR
        element1 = (aggregateColumn1 != null
          ? (Decimal) oppAggregs.get(aggregateColumn1).getValue()
          : null);
        element2 = (aggregateColumn2 != null
          ? (Decimal) oppAggregs.get(aggregateColumn2).getValue()
          : null);
      } else {
        System.debug(LoggingLevel.INFO, 'ERROR Column aggregate');
        return new AllInformations('ERROR Column aggregate calculation');
      }
    } else {
      System.debug(LoggingLevel.INFO, 'ERROR Report not found');
      return new AllInformations('ERROR Report not found');
    }

    return new AllInformations(element1, element2);
  }
}