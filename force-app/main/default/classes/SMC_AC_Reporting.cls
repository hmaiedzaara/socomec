/**
 * @File Name          : SMC_AC_Reporting.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    19/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_AC_Reporting {
  public class AllInformations {
    @AuraEnabled
    public Decimal totalRecords;
    @AuraEnabled
    public String recordId;
    @AuraEnabled
    public Map<Integer, ReportRowDetail> mapReportRows;
    @AuraEnabled
    public String error;

    public AllInformations() {
    }

    public AllInformations(String error) {
      this.error = error;
    }

    public AllInformations(Decimal totalRecords) {
      this.totalRecords = totalRecords;
    }

    public AllInformations(Map<Integer, ReportRowDetail> mapReportRows) {
      this.mapReportRows = mapReportRows;
    }
  }

  public class ReportRowDetail {
    @AuraEnabled
    public List<String> columns1;
    @AuraEnabled
    public List<String> columns2;
    @AuraEnabled
    public String recordName; //Second column on report
    @AuraEnabled
    public String recordId; //First column on report
    @AuraEnabled
    public String urlToRecord; //Used to redirection

    public ReportRowDetail() {
    }

    public ReportRowDetail(
      List<String> columns1,
      List<String> columns2,
      String recordName,
      String recordId
    ) {
      this.columns1 = columns1;
      this.columns2 = columns2;
      this.recordName = recordName;
      this.recordId = recordId;
    }
  }

  /**
   * @description : run report and get aggregated column 1 = Total Record
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param reportName
   * @return String
   **/
  @AuraEnabled
  public static String getTotalRecords(String reportName) {
    //Get report
    List<Report> reportList = [
      SELECT Id, Name
      FROM Report
      WHERE Name = :reportName
    ]; //IOT Demo - Cases
    //Get informations
    Decimal totalRecords;
    if (reportList != null && reportList.size() >= 0) {
      //Get report columns
      String reportId = (String) reportList.get(0).get('Id');
      Reports.ReportResults results;
      try {
        results = Reports.ReportManager.runReport(reportId, true);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'There is no data in the report. ERROR : ' + e.getMessage()
        );
      }

      if (results != null) {
        // Get the fact map from the report results
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap()
        .get('T!T');
        if (factDetails == null) {
          return null;
        }

        List<Reports.SummaryValue> oppAggregs = results.getFactMap()
          .get('T!T')
          .getAggregates();

        //Get aggregated columns = Total Records
        totalRecords = oppAggregs != null
          ? (Decimal) oppAggregs.get(0).getValue()
          : null;
      } else {
        return null;
      }
    } else {
      System.debug(LoggingLevel.INFO, 'ERROR Report not found');
      return JSON.serialize(new AllInformations('ERROR Report not found'));
    }
    return JSON.serialize(new AllInformations(totalRecords));
  }

  /**
   * @description : get columnand datas from report
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param reportName
   * @param nbOfColumns
   * @param nbOfRecords
   * @return String
   **/
  @AuraEnabled
  public static String getColumns(
    String reportName,
    Integer nbOfColumns,
    Integer nbOfRecords
  ) {
    //Get report
    List<Report> reportList = [
      SELECT Id, Name
      FROM Report
      WHERE Name = :reportName
    ]; //IOT Demo - Contracts

    //Return value
    Map<Integer, ReportRowDetail> mapReportRows;
    //Get informations
    if (reportList != null && reportList.size() >= 0) {
      //Get report columns
      String reportId = (String) reportList.get(0).get('Id');
      Reports.ReportResults results;
      try {
        results = Reports.ReportManager.runReport(reportId, true);
      } catch (Exception e) {
        System.debug(
          'There is no data in the report. ERROR : ' + e.getMessage()
        );
      }

      if (results != null) {
        // Get the fact map from the report results
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap()
          .get('0!T');
        if (factDetails == null) {
          return null;
        }

        // Map<String, Reports.DetailColumn> mapDetailColumn = results.getReportExtendedMetadata()
        //   .getDetailColumnInfo();

        Integer idxNbOfRecord = 0;
        mapReportRows = new Map<Integer, ReportRowDetail>();
        for (Reports.ReportDetailRow oneRow : factDetails.getRows()) {
          List<String> tmpDataCellValue1 = new List<String>();
          List<String> tmpDataCellValue2 = new List<String>();
          String theRecordId;
          String theRecordName;
          Integer sizeCloumn = nbOfColumns <= oneRow.getDataCells().size()
            ? Math.round(nbOfColumns / 2)
            : Math.round(oneRow.getDataCells().size() / 2);
          for (Integer i = 0; i < oneRow.getDataCells().size(); ++i) {
            if (i == 0) {
              theRecordId = oneRow.getDataCells()[0].getLabel();
            } else if (i == 1) {
              theRecordName = oneRow.getDataCells()[1].getLabel();
            } else {
              if (i < (sizeCloumn + 1)) {
                tmpDataCellValue1.add(oneRow.getDataCells()[i].getLabel());
              } else {
                tmpDataCellValue2.add(oneRow.getDataCells()[i].getLabel());
              }
            }
          }
          ReportRowDetail reportRowDetail = new ReportRowDetail(
            tmpDataCellValue1,
            tmpDataCellValue2,
            theRecordName,
            theRecordId
          );
          mapReportRows.put(idxNbOfRecord, reportRowDetail);
          ++idxNbOfRecord;
        }
      }

      return JSON.serialize(new AllInformations(mapReportRows));
    }

    return null;
  }
}