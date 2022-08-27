/**
 * @File Name          : LCCtrl_GenericLookup.cls
 * @Description        : Lookup component usable in layouts or flows
 * @Author             : Emmanuel BERNIER (Modis)
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/12/2019 à 14:52:00
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

public with sharing class LCCtrl_GenericLookup {
  @AuraEnabled
  public static List<SObject> fetchLookUpValues(
    String searchKeyWord,
    String ObjectName,
    String additionalWhere,
    Boolean isParent
  ) {
    System.debug(LoggingLevel.INFO, 'ObjectName-->' + ObjectName);
    String searchKey = '%' + searchKeyWord + '%';

    // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
    String sQuery = '';
    if (!isParent) {
      if (ObjectName.toLowerCase() != 'case') {
        sQuery =
          'select id, Name from ' +
          String.escapeSingleQuotes(ObjectName) +
          ' where ' +
          (string.isBlank(additionalWhere)
            ? ''
            : String.escapeSingleQuotes(additionalWhere) + ' AND ') +
          ' Name LIKE :searchKey order by createdDate DESC limit 5';
      } else {
        sQuery =
          'select id, CaseNumber from ' +
          String.escapeSingleQuotes(ObjectName) +
          ' where ' +
          (string.isBlank(additionalWhere)
            ? ''
            : String.escapeSingleQuotes(additionalWhere) + ' AND ') +
          ' CaseNumber LIKE :searchKey order by createdDate DESC limit 5';
      }
    } else if (isParent) {
      if (ObjectName.toLowerCase() != 'case') {
        sQuery =
          'select Id, Name from ' +
          String.escapeSingleQuotes(ObjectName) +
          ' where ' +
          (string.isBlank(additionalWhere) ? '' : additionalWhere + ' AND ') +
          ' Name LIKE :searchKey order by createdDate DESC limit 5';
      } else {
        sQuery =
          'select Id, CaseNumber from ' +
          String.escapeSingleQuotes(ObjectName) +
          ' where ' +
          (string.isBlank(additionalWhere) ? '' : additionalWhere + ' AND ') +
          ' CaseNumber LIKE :searchKey order by createdDate DESC limit 5';
      }
    } else {
      return null;
    }
    return Database.query(sQuery);
  }

  @AuraEnabled
  public static SObject fetchDefaultObject(String objectName, String recordId) {
    if (objectName != null && recordId != null) {
      if (objectName.toLowerCase() != 'case') {
        return Database.query(
          'SELECT Id, Name FROM ' +
          String.escapeSingleQuotes(objectName) +
          ' WHERE Id = \'' +
          String.escapeSingleQuotes(recordId) +
          '\''
        );
      } else {
        return Database.query(
          'SELECT Id, CaseNumber FROM ' +
          String.escapeSingleQuotes(objectName) +
          ' WHERE Id = \'' +
          String.escapeSingleQuotes(recordId) +
          '\''
        );
      }
    } else {
      return null;
    }
  }
}