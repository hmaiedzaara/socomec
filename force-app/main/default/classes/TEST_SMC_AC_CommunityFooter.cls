/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_CommunityFooter
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

@isTest
public with sharing class TEST_SMC_AC_CommunityFooter {

    /**
    * @description : Test get Metadata
    * @author Vincent RECASENS (Modis) | 07-10-2020
    **/
    @isTest
    public static void testGetMetadata() {
        Test.startTest();

        List<SMC_Community_Footer_Links__mdt> lCommunityFooterLinks = new List<SMC_Community_Footer_Links__mdt>();

        SMC_Community_Footer_Links__mdt customers = SMC_AC_CommunityFooter.getCustomersLink();
        lCommunityFooterLinks.add(customers);
        SMC_Community_Footer_Links__mdt customerPortal = SMC_AC_CommunityFooter.getCustomerPortalLink();
        lCommunityFooterLinks.add(customerPortal);
        SMC_Community_Footer_Links__mdt onlineOrderingPortal = SMC_AC_CommunityFooter.getOnlineOrderingPortalLink();
        lCommunityFooterLinks.add(onlineOrderingPortal);
        SMC_Community_Footer_Links__mdt supplierPortal = SMC_AC_CommunityFooter.getSupplierPortalLink();
        lCommunityFooterLinks.add(supplierPortal);
        SMC_Community_Footer_Links__mdt warrantyRegistration = SMC_AC_CommunityFooter.getWarrantyRegistrationLink();
        lCommunityFooterLinks.add(warrantyRegistration);

        Integer nbCommunityFooterLinks = [SELECT Id FROM SMC_Community_Footer_Links__mdt].size();

        System.assertEquals(lCommunityFooterLinks.size(),nbCommunityFooterLinks);

        Test.stopTest();
    }
}