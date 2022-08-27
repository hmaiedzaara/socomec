/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 04-08-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   04-08-2021   Vincent RECASENS (Modis)   Initial Version
**/
@Istest
public class TEST_SMC_AC_UploadFile {
    
    // @isTest
    // public static void testSaveChunckWithoutFileId(){
    //     //Account
    //     Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    //     recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    //     Id recordTypeIdAcc = recordTypesAccount.get(
    //         STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
    //     )
    //         .getRecordTypeId();
    //     Account account = SMC_UTIL_TestUtils.createAccount(
    //         recordTypeIdAcc,
    //         STA_UtilsStatic.TEST,
    //         STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
    //         STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    //     );
    //     insert account;
    //     SMC_AC_UploadFile.WrapperResult result = SMC_AC_UploadFile.saveChunk(null, 'Test Upload File', 'body file', 'text/plain', '');
    //     System.assertNotEquals(null, result.attchId);
    // }
    
    // @isTest
    // public static void testSaveChunckWithFileId(){
    //     //Account
    //     Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    //     recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    //     Id recordTypeIdAcc = recordTypesAccount.get(
    //         STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
    //     )
    //         .getRecordTypeId();
    //     Account account = SMC_UTIL_TestUtils.createAccount(
    //         recordTypeIdAcc,
    //         STA_UtilsStatic.TEST,
    //         STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
    //         STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    //     );
    //     insert account;
        
    //     Attachment oAttachment = new Attachment();
    //     oAttachment.parentId = account.Id;
    //     oAttachment.Body = EncodingUtil.base64Decode('body file');
    //     oAttachment.Name = 'Test Upload File';
    //     oAttachment.ContentType = 'text/plain';
    //     insert oAttachment;
        
    //     SMC_AC_UploadFile.WrapperResult result = SMC_AC_UploadFile.saveChunk(account.Id, 'Test Upload File', 'body file', 'text/plain', oAttachment.Id);
    //     System.assertEquals(null, result.attchId);
    // }

    @isTest
    public static void testGetDocumentId_OK(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        insert contentVersion;

        String result;
        Test.startTest();
            result = SMC_AC_UploadFile.getContentDocumentId(contentVersion.Id);
        Test.stopTest();
        ContentVersion checker = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        System.assertEquals(checker.ContentDocumentId, result);
    }

    @isTest
    public static void testGetDocumentId_BAD(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'PenguinsTooLarge';
        contentVersion.PathOnClient = 'PenguinsTooLarge.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content Too Large');
        insert contentVersion;

        String result;
        Test.startTest();
            result = SMC_AC_UploadFile.getContentDocumentId(contentVersion.Id);
        Test.stopTest();

        System.assertEquals(System.Label.SMC_Too_Large, result);
    }
    
}