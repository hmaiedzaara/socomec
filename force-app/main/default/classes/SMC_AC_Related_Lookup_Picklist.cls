/**
 * @description       :
 * @author            : Denis PHAM (Modis)
 * @group             : Modis
 * @last modified on  : 08-JUL-2022
 * @last modified by  : Denis PHAM (Modis)
 * Modifications Log
 * Ver   Date          Author                   Modification
 * 1.0   11-JUL-2022   Denis PHAM (Modis)       Initial Version
 **/

 global with sharing class SMC_AC_Related_Lookup_Picklist extends  VisualEditor.DynamicPickList {

    VisualEditor.DesignTimePageContext context;

    global SMC_AC_Related_Lookup_Picklist(VisualEditor.DesignTimePageContext context) {
        this.context = context;
        //entityName : API Name de l'objet 
        //pageType : HomePage, AppPage, or RecordPage
    }

    global override VisualEditor.DataRow getDefaultValue() {
        String objectLabel = ((SObject) (Type.forName('Schema.' + String.valueOf(this.context.entityName)).newInstance())).getSObjectType().getDescribe().getLabel();
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
        'Use This ' + objectLabel, this.context.entityName);
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(getDefaultValue());
        
        Schema.DescribeSObjectResult describeSobjects = ((SObject) (Type.forName('Schema.' + this.context.entityName).newInstance())).getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> myFields = describeSobjects.fields.getMap();
        for (String field : myFields.keySet()) {
            Schema.DescribeFieldResult currentField = myFields.get(field).getDescribe();
            if (currentField.getType() == Schema.DisplayType.Reference && currentField.isAccessible()) 
            {
                myValues.addRow(new VisualEditor.DataRow(currentField.getLabel(), field));
            }
        }
        return myValues;
    }
}