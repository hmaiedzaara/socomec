/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_CommunityFooter
-- - Author : Denis PHAM
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_CommunityFooter
--
-- Maintenance History:
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 25-MAY-2022  Denis PHAM        		1.0     	Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_CommunityFooter {

    //Customers 
    @AuraEnabled
    public static SMC_Community_Footer_Links__mdt getCustomersLink(){
        return [SELECT MasterLabel, DeveloperName, Addresses_Link__c, Legal_Notice_Link__c,	Privacy_Notice_Link__c, Terms_of_Use_Link__c 
                FROM  SMC_Community_Footer_Links__mdt
                WHERE DeveloperName = : STA_UtilsStatic.CUSTOMERS_DEVELOPER_NAME][0];
    }

    //Customer Portal
    @AuraEnabled
    public static SMC_Community_Footer_Links__mdt getCustomerPortalLink(){
        return [SELECT MasterLabel, DeveloperName, Addresses_Link__c, Legal_Notice_Link__c,	Privacy_Notice_Link__c, Terms_of_Use_Link__c 
                FROM  SMC_Community_Footer_Links__mdt
                WHERE DeveloperName = : STA_UtilsStatic.CUSTOMER_PORTAL_DEVELOPER_NAME][0];
    }

    //Online Ordering Portal
    @AuraEnabled
    public static SMC_Community_Footer_Links__mdt getOnlineOrderingPortalLink(){
        return [SELECT MasterLabel, DeveloperName, Addresses_Link__c, Legal_Notice_Link__c,	Privacy_Notice_Link__c, Terms_of_Use_Link__c 
                FROM  SMC_Community_Footer_Links__mdt
                WHERE DeveloperName = : STA_UtilsStatic.ONLINE_ORDERING_PORTAL_DEVELOPER_NAME][0];
    }

    //Supplier Portal
    @AuraEnabled
    public static SMC_Community_Footer_Links__mdt getSupplierPortalLink(){
        return [SELECT MasterLabel, DeveloperName, Addresses_Link__c, Legal_Notice_Link__c,	Privacy_Notice_Link__c, Terms_of_Use_Link__c 
                FROM  SMC_Community_Footer_Links__mdt
                WHERE DeveloperName = : STA_UtilsStatic.SUPPLIER_PORTAL_DEVELOPER_NAME][0];
    }

    //Warranty Registration
    @AuraEnabled
    public static SMC_Community_Footer_Links__mdt getWarrantyRegistrationLink(){
        return [SELECT MasterLabel, DeveloperName, Addresses_Link__c, Legal_Notice_Link__c,	Privacy_Notice_Link__c, Terms_of_Use_Link__c 
                FROM  SMC_Community_Footer_Links__mdt
                WHERE DeveloperName = : STA_UtilsStatic.WARRANTY_REGISTRATION_DEVELOPER_NAME][0];
    }
}