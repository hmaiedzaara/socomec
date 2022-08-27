@IsTest
public class TEST_SMC_AP_ManagePRMQuote {

    @isTest
    public static void testDuplicateLinkQuoteToPRMQuote(){
        //Setup
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        ];
        User user = SMC_UTIL_TestUtils.createUser(
            STA_UtilsStatic.USER_NICKNAME,
            STA_UtilsStatic.USERNAME_TEST,
            profile.Id,
            STA_UtilsStatic.USERNAME_TEST,
            STA_UtilsStatic.USER_NICKNAME
        );
        insert user;

        System.runAs(user) {

            PAD.bypassAll = true;

            //Account
            Id recordTypeIdAccount = [
              SELECT Id
              FROM RecordType
              WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
            ]
            .Id;
            Account oneAccount = SMC_UTIL_TestUtils.createAccount(
              recordTypeIdAccount,
              STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
              STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
              STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
            );
            insert oneAccount;

            //Opportunity
            Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                                    .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                                    .getRecordTypeId();
            Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                                    STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                                    STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
            insert opp;
            //Quote
            Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                            STA_UtilsStatic.TEST + 'Share File', 
                                                            oneAccount.Id);
            insert oneQuote;

            PAD.bypassAll = false;
            
            //File
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Penguins1';
            contentVersion.PathOnClient = 'Penguins1.jpg';
            contentVersion.VersionData = Blob.valueOf('Test Content');
            contentVersion.IsMajorVersion = true;
            contentVersion.FirstPublishLocationId = oneQuote.Id;
            insert contentVersion;


            Test.startTest();
                //PRM Quote
                SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
                insert prmQuote;
            Test.stopTest();

            ContentVersion contentVersionChecker = [SELECT Id, 
                                                            Title, 
                                                            ContentDocumentId, 
                                                            SMC_Is_Visible_By_Partner__c, 
                                                            SharingPrivacy
                                                    FROM ContentVersion
                                                    WHERE Id = :contentVersion.Id];

            System.assertEquals(1, [SELECT Id 
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId = :contentVersionChecker.ContentDocumentId AND 
                                            LinkedEntityId = :prmQuote.Id].size());
        }
    }

}