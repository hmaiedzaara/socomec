/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Related_Lookup_Picklist
-- - Author : Denis PHAM
-- - Description : This class test the Apex class SMC_AC_Related_Lookup_Picklist
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 13-JUL-2022  Denis PHAM        		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_Related_Lookup_Picklist {
    @isTest
    static void test_SMC_AC_Related_Lookup_Picklist_DefaultValue() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Contact';
        SMC_AC_Related_Lookup_Picklist  sarlp = new SMC_AC_Related_Lookup_Picklist(context);
        Test.startTest();
        VisualEditor.DataRow defaultValue = sarlp.getDefaultValue();
        Test.stopTest();
        System.assertEquals('Use This Contact',defaultValue.getLabel());
    }

    @isTest
    static void testPicklistValues() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Contact';
        SMC_AC_Related_Lookup_Picklist sarlp = new SMC_AC_Related_Lookup_Picklist(context);
        Test.startTest();
        VisualEditor.DynamicPickListRows picklistValues = sarlp.getValues();
        Test.stopTest();
        System.assert(picklistValues.size() > 0, 'No parent picklist values found for Contact');
    }
}