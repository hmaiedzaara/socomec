/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_FileDownload
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class test the Apex class SMC_AC_FileDownload
-- 
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 10-JUL-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_FileDownload {
  
  /**
  * @description : test setup
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @testSetup
  public static void setup() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard1 = SMC_UTIL_TestUtils.createUser(
      'standard1-' + STA_UtilsStatic.USERNAME_TEST,
      'standard1-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard1-' + STA_UtilsStatic.USERNAME_TEST,
      'standard1-' + STA_UtilsStatic.USERNAME_TEST
    );
    User userStandard2 = SMC_UTIL_TestUtils.createUser(
      'standard2-' + STA_UtilsStatic.USERNAME_TEST,
      'standard2-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard2-' + STA_UtilsStatic.USERNAME_TEST,
      'standard2-' + STA_UtilsStatic.USERNAME_TEST
    );
    insert new List<User>{ userStandard1, userStandard2 };

    // Group newGroup = new Group();
    // newGroup.Name = 'Group test';
    // insert newGroup;

    // GroupMember newGroupMember = new GroupMember();
    // newGroupMember.GroupId = newGroup.Id;
    // newGroupMember.UserOrGroupId = userStandard1.Id;
    // insert new List<GroupMember>{newGroupMember};

    PAD.bypassAll = true;
    // Account acc = new Account(Name=STA_UtilsStatic.TEST);
    // insert acc;

    ContentVersion contentVersion = new ContentVersion();
    contentVersion.Title = 'Penguins';
    contentVersion.PathOnClient = 'Penguins.jpg';
    contentVersion.VersionData = Blob.valueOf('Test Content');
    contentVersion.IsMajorVersion = true;
    contentVersion.SharingOption = 'A';
    contentVersion.SharingPrivacy = STA_UtilsStatic.PRIVATE_ON_RECORD;
    // contentVersion.FirstPublishLocationId = acc.Id;
    insert contentVersion;

    // ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
    // ContentDocument oneContentDocument = [SELECT Id, SharingPrivacy, SharingOption FROM ContentDocument WHERE Id = :insertedContentVersion.ContentDocumentId];
    // List<ContentDocumentLink> theContentDocumentLink = new List<ContentDocumentLink>();
    // for(ContentDocumentLink oneCdl : [SELECT Id, ShareType, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :insertedContentVersion.ContentDocumentId]){
    //     System.debug(LoggingLevel.INFO, oneCdl);
    //     if(oneCdl.LinkedEntityId == acc.Id){
    //         oneCdl.Visibility = STA_UtilsStatic.INTERNAL_USERS;
    //         theContentDocumentLink.add(oneCdl);
    //     }
    // }
    // if(theContentDocumentLink.size() > 0){
    //     update theContentDocumentLink;
    // }

    // ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
    // newContentDocumentLink.ContentDocumentId = oneContentDocument.Id;
    // newContentDocumentLink.LinkedEntityId = userStandard1.Id;
    // newContentDocumentLink.ShareType = STA_UtilsStatic.VIEWER_PERMISSION;
    // newContentDocumentLink.Visibility = STA_UtilsStatic.SHARED;
    // insert newContentDocumentLink;

    PAD.bypassAll = false;
  }

  /**
  * @description : test SMC_AC_FileDownload.userIsAuthorized(true, Id)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testIsPublic() {
    User user2 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard2-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    ContentDocument oneContentDocument = [
      SELECT Id
      FROM ContentDocument
      LIMIT 1
    ];

    System.runAs(user2) {
      System.assert(
        SMC_AC_FileDownload.userIsAuthorized(true, oneContentDocument.Id),
        'The user has not the permission.'
      );
    }
  }

  /**
  * @description : test SMC_AC_FileDownload.userIsAuthorized(false, Id)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testUserIsAuthorized() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    ContentDocument oneContentDocument = [
      SELECT Id
      FROM ContentDocument
      LIMIT 1
    ];

    System.runAs(user1) {
      System.assert(
        SMC_AC_FileDownload.userIsAuthorized(false, oneContentDocument.Id),
        'Check the user who has inserted the file in the setup test method.'
      );
    }
  }

  //Function not implemented yet
  // @isTest
  // public static void testUserIsNotAuthorized(){
  //     User user2 = [SELECT Id FROM User WHERE Email = :('standard2-' + STA_UtilsStatic.USERNAME_TEST)];
  //     ContentDocument oneContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

  //     System.runAs(user2){
  //         System.assert(!SMC_AC_FileDownload.userIsAuthorized(false, oneContentDocument.Id));
  //     }
  // }
}