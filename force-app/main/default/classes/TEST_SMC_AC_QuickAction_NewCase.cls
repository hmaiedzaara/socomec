/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_QuickAction_NewCase
-- - Author : Denis PHAM
-- - Description : This class is the Apex test of the Apex 
                   class SMC_AC_QuickAction_NewCase
--
-- Maintenance History:
--
-- Date 			Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 10-APR-2022 		DPHA	1.0			Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_QuickAction_NewCase {

    /**
    * @description : Test Setup
    * @author : Denis PHAM (Modis) | 22-04-2022
    **/
    @TestSetup
    public static void setup(){
        //Create an User
        Profile profile = [
                            SELECT Id
                            FROM Profile
                            WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
                        ];
    
        User user = SMC_UTIL_TestUtils.createUser(
            STA_UtilsStatic.TEST_DIESE,
            STA_UtilsStatic.EMAIL_TEST,
            profile.Id,
            STA_UtilsStatic.USERNAME_TEST,
            STA_UtilsStatic.USER_NICKNAME
        );
        insert user; 

        //Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();

        Account acc = SMC_UTIL_TestUtils.createAccount(
            accRecordTypeId,
            STA_UtilsStatic.TEST + '_Standard',
            STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
            STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
        );
        insert acc;

        //Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      
        Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
            oppRecordTypeId,
            STA_UtilsStatic.TEST,
            STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
        );
        insert opp;

        //Quote
        Id quoteRecordType = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
        .getRecordTypeId();

        Quote quote = SMC_UTIL_TestUtils.createQuote(
            opp.Id,
            STA_UtilsStatic.QUOTE_NAME1,
            acc.Id
        );
        quote.RecordTypeId = quoteRecordType;
        insert quote;

        //Contact 
        Contact contact = SMC_UTIL_TestUtils.createContact(
            STA_UtilsStatic.CONTACT_FIRSTNAME1,
            STA_UtilsStatic.CONTACT_LASTNAME1,
            STA_UtilsStatic.CONTACT_PHONE1,
            STA_UtilsStatic.CONTACT_MOBILEPHONE1,
            STA_UtilsStatic.CONTACT_EMAIL1,
            STA_UtilsStatic.CONTACT_MAILINGSTREET1,
            STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
            STA_UtilsStatic.CONTACT_MAILINGCITY1,
            STA_UtilsStatic.CONTACT_MAILINGSTATE1,
            STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
            STA_UtilsStatic.CONTACT_OTHERCITY1,
            acc.Id
        );
        insert contact;
    }

    /**
    * @description : Test SMC_AC_QuickAction_NewCase.setDefaultValues(Opportunity)
    * @author : Denis PHAM (Modis) | 20-04-2022
    **/
    @isTest
    public static void testSetDefaultValueOpp() {

        User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        System.runAs(user) {

            Test.startTest();
            String returnWrapper = SMC_AC_QuickAction_NewCase.setDefaultValues(opp.Id);
            Test.stopTest();

            SMC_AC_Page_CreateCase.PredefinedFieldsValues dtoResult = (SMC_AC_Page_CreateCase.PredefinedFieldsValues) JSON.deserialize(
                returnWrapper,
                SMC_AC_Page_CreateCase.PredefinedFieldsValues.class
            );

            System.assertEquals(opp.Id, dtoResult.opportunityId);
        }
    }

    /**
    * @description : Test SMC_AC_QuickAction_NewCase.setDefaultValues(Quote)
    * @author : Denis PHAM (Modis) | 20-04-2022
    **/
    @isTest
    public static void testSetDefaultValueQuote() {

        User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
        Quote quote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];

        System.runAs(user) {

            Test.startTest();
            String returnWrapper = SMC_AC_QuickAction_NewCase.setDefaultValues(quote.Id);
            Test.stopTest();

            SMC_AC_Page_CreateCase.PredefinedFieldsValues dtoResult = (SMC_AC_Page_CreateCase.PredefinedFieldsValues) JSON.deserialize(
                returnWrapper,
                SMC_AC_Page_CreateCase.PredefinedFieldsValues.class
            );

            System.assertEquals(quote.OpportunityId, dtoResult.opportunityId);
            System.assertEquals(quote.Id, dtoResult.quoteId);

        }
    }

    /**
    * @description : Test SMC_AC_QuickAction_NewCase.setDefaultValues(Contact)
    * @author : Denis PHAM (Modis) | 20-04-2022
    **/
    @isTest
    public static void testSetDefaultValueContact() {

        User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        System.runAs(user) {

            Test.startTest();
            String returnWrapper = SMC_AC_QuickAction_NewCase.setDefaultValues(contact.Id);
            Test.stopTest();

            SMC_AC_Page_CreateCase.PredefinedFieldsValues dtoResult = (SMC_AC_Page_CreateCase.PredefinedFieldsValues) JSON.deserialize(
                returnWrapper,
                SMC_AC_Page_CreateCase.PredefinedFieldsValues.class
            );

            System.assertEquals(contact.AccountId, dtoResult.accountId);
            System.assertEquals(contact.Id, dtoResult.contactId);

        }
    }

    /**
    * @description : Test SMC_AC_QuickAction_NewCase.setDefaultValues(Account)
    * @author : Denis PHAM (Modis) | 20-04-2022
    **/
    @isTest
    public static void testSetDefaultValueStandardCase() {

        User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        System.runAs(user) {

            Test.startTest();
                String returnWrapper = SMC_AC_QuickAction_NewCase.setDefaultValues(acc.Id);
            Test.stopTest();

            SMC_AC_Page_CreateCase.PredefinedFieldsValues dtoResult = (SMC_AC_Page_CreateCase.PredefinedFieldsValues) JSON.deserialize(
                returnWrapper,
                SMC_AC_Page_CreateCase.PredefinedFieldsValues.class
            );

            System.assertEquals(null, dtoResult);
        }
    }

}