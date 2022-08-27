/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Files_From_Related_Object
-- - Author : Denis PHAM
-- - Description : This class test the Apex class SMC_AC_Files_From_Related_Object
--
-- Maintenance History:
--
-- Date          Name                    Version     Remarks
-- -----------   ----                    -------     ------------------
--  13-JUL-2022  Denis PHAM    		     1.0     	 Initial Version
---------------------------------------------------------------------------
*/
@IsTest
public with sharing class TEST_SMC_AC_Files_From_Related_Object {

    @TestSetup
    static void setup(){
      //Set the User
      Profile profile = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
      ];
      User user1 = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.TEST_DIESE + '1',
        STA_UtilsStatic.EMAIL_TEST + '1',
        profile.Id,
        STA_UtilsStatic.USERNAME_TEST,
        STA_UtilsStatic.USER_NICKNAME
      );
      user1.Bypass_All_Processes_Builder__c = true;
      user1.Bypass_All_Validation_Rules__c = true;
      user1.Bypass_All_Workflow_Rules__c = true;
      insert user1;

      System.runAs(user1){

        PAD.bypassAll = true;

        //Object 1 : Account
        Id recordTypeIdAccount = [
            SELECT Id
            FROM RecordType
            WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        ].Id;

        Account oneAccount = SMC_UTIL_TestUtils.createAccount(
            recordTypeIdAccount,
            STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
            STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
            STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
        );
        insert oneAccount;

        //Related Object  : Contact 
        Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
            '',
            oneAccount.Id
        );
        insert oneContact;

        //Files sur Object 1 : Account
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test';
        contentVersion.PathOnClient = 'Test.txt';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.FirstPublishLocationId = oneAccount.Id;
        contentVersion.OwnerId = user1.Id;
        insert contentVersion;

        PAD.bypassAll = false;
      }
    }

    @IsTest
    public static void testGetData() {

        User user1 = [SELECT Id FROM User WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

        System.runAs(user1)
        {
            Contact con = [SELECT Id from Contact LIMIT 1];
            String communityName = STA_UtilsStatic.CUSTOMERS_MIN;

            Test.startTest();
                List<SMC_AC_Files_From_Related_Object.WrapperClass> lResult = SMC_AC_Files_From_Related_Object.getData(con.Id, 'AccountId', communityName);
            Test.stopTest();

            System.assertEquals(1, lResult.size());
        }
    }


    @IsTest
    public static void testTitle() {

        User user1 = [SELECT Id FROM User WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

        System.runAs(user1)
        {
            Contact con = [SELECT Id from Contact LIMIT 1];
    
            Test.startTest();
                String title = SMC_AC_Files_From_Related_Object.getTitle(con.Id, 'AccountId');
            Test.stopTest();

            System.assertNotEquals(null, title);
        }
    }

    @IsTest
    public static void testFileSizeToString() {

        User user1 = [SELECT Id FROM User WHERE Email = :(STA_UtilsStatic.EMAIL_TEST + '1')];

        System.runAs(user1)
        {

            Test.startTest();
                String bytes = SMC_AC_Files_From_Related_Object.fileSizeToString(1000);
                String kBytes = SMC_AC_Files_From_Related_Object.fileSizeToString(2000);
                String mBytes = SMC_AC_Files_From_Related_Object.fileSizeToString(2000000);
                String gBytes = SMC_AC_Files_From_Related_Object.fileSizeToString(2000000000);
            Test.stopTest();

            System.assertEquals('1000 Bytes', bytes);
            System.assertEquals('1.95 KB', kBytes);
            System.assertEquals('1.91 MB', mBytes);
            System.assertEquals('1.86 GB', gBytes);
        }
    }


}