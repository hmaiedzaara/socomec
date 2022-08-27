/*
---------------------------------------------------------------------------
-- - Name : SMC_UTIL_LCDesign_AssetRelatedCase
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the picklist
                   lightning design "Filter" of lightning component 
                   SMC_LC_Asset_RelatedWarrantyCase
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ------------------
-- 13-FEB-2019  VRE     1.0     	Initial Version
---------------------------------------------------------------------------
*/

global with sharing class SMC_UTIL_LCDesign_AssetRelatedCase extends VisualEditor.DynamicPickList {
  /**
   * @description : get default value "None"
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @return VisualEditor.DataRow
   **/
  global override VisualEditor.DataRow getDefaultValue() {
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
      STA_UtilsStatic.NONE,
      STA_UtilsStatic.DEFAULT_PICKLIST_VALUE
    );
    return defaultValue;
  }

  /**
   * @description : get case informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @return VisualEditor.DynamicPickListRows
   **/
  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
    myValues.addRow(
      new VisualEditor.DataRow(
        STA_UtilsStatic.DEFAULT_PICKLIST_VALUE,
        STA_UtilsStatic.DEFAULT_PICKLIST_VALUE
      )
    );

    //Case Type
    myValues.addRow(
      new VisualEditor.DataRow(
        '*****' +
        STA_UtilsStatic.CASE_TYPE +
        '*****',
        STA_UtilsStatic.CASE_TYPE +
        ' = ' +
        STA_UtilsStatic.CASE_TYPE
      )
    );
    Schema.DescribeFieldResult fieldResultType = Case.Type.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResultType.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      myValues.addRow(
        new VisualEditor.DataRow(
          entry.getLabel(),
          STA_UtilsStatic.CASE_TYPE_APINAME +
          ' = \'' +
          entry.getValue() +
          '\''
        )
      );
    }

    //Case Status
    myValues.addRow(
      new VisualEditor.DataRow(
        '*****' +
        STA_UtilsStatic.CASE_STATUS +
        '*****',
        STA_UtilsStatic.CASE_STATUS +
        ' = ' +
        STA_UtilsStatic.CASE_STATUS
      )
    );
    fieldResultType = Case.Status.getDescribe();
    entries = fieldResultType.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      myValues.addRow(
        new VisualEditor.DataRow(
          entry.getLabel(),
          STA_UtilsStatic.CASE_STATUS_APINAME +
          ' = \'' +
          entry.getValue() +
          '\''
        )
      );
    }

    //Case Priority
    myValues.addRow(
      new VisualEditor.DataRow(
        '*****' +
        STA_UtilsStatic.CASE_PRIORITY +
        '*****',
        STA_UtilsStatic.CASE_PRIORITY +
        ' = ' +
        STA_UtilsStatic.CASE_PRIORITY
      )
    );
    fieldResultType = Case.Priority.getDescribe();
    entries = fieldResultType.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      myValues.addRow(
        new VisualEditor.DataRow(
          entry.getLabel(),
          STA_UtilsStatic.CASE_PRIORITY_APINAME +
          ' = \'' +
          entry.getValue() +
          '\''
        )
      );
    }

    //Case Product Family
    myValues.addRow(
      new VisualEditor.DataRow(
        '*****' +
        STA_UtilsStatic.CASE_PRODUCT_FAMILY +
        '*****',
        STA_UtilsStatic.CASE_PRODUCT_FAMILY +
        ' = ' +
        STA_UtilsStatic.CASE_PRODUCT_FAMILY
      )
    );
    fieldResultType = Case.SMC_Product_Family__c.getDescribe();
    entries = fieldResultType.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      myValues.addRow(
        new VisualEditor.DataRow(
          entry.getLabel(),
          STA_UtilsStatic.CASE_PRODUCT_FAMILY_APINAME +
          ' = \'' +
          entry.getValue() +
          '\''
        )
      );
    }

    return myValues;
  }
}