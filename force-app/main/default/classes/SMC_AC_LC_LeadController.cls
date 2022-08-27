/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_LC_LeadController
-- - Author : David SOBCZACK (DOS)
-- - Description : Check if duplicate Opportunity exist
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 07-JAN-2019  DOS    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AC_LC_LeadController {
  /**
  * @description : get list of duplicate opportunities
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @param projectLocation 
  * @return List<Opportunity> 
  **/
  @AuraEnabled
  public static List<Opportunity> getDuplicatesOpportunities(
    String projectLocation
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_LeadController -> Method getDuplicatesOpportunities - START orderNumber ' +
      projectLocation
    );

    //ProjectName + ProjectLocation
    List<List<SObject>> searchList = [
      FIND :projectLocation
      IN ALL FIELDS
      RETURNING Opportunity(Id, Name WHERE isClosed = false)
    ];

    List<Opportunity> duplicatesOpportunities = new List<Opportunity>();
    duplicatesOpportunities = ((List<Opportunity>) searchList[0]);

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_LC_LeadController -> Method getDuplicatesOpportunities - END'
    );
    return duplicatesOpportunities;
  }
  
  /**
  * @description : get all opportunity fields label
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @return Map<String, String> 
  **/
  @AuraEnabled
  public static Map<String, String> getOpportunityFieldsLabel() {
    Map<String, String> oppFieldsLabel = new Map<String, String>();

    String objectApiName = STA_UtilsStatic.OPPORTUNITY;
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType leadSchema = schemaMap.get(objectApiName);
    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe()
      .fields.getMap();
    for (String fieldName : fieldMap.keySet()) {
      oppFieldsLabel.put(
        fieldName,
        fieldMap.get(fieldName).getDescribe().getLabel()
      );
    }

    return oppFieldsLabel;
  }
}