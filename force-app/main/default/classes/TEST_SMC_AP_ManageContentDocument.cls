/**
 * @File Name          : TEST_SMC_AP_ManageContentDocument.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/10/2018   Vincent RECASENS (Modis)     Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AP_ManageContentDocument {
  /**
   * @description : test SMC_AP_ManageContentDocument.communityUserCantDeleteFiles(null)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCommunityUserCantDeleteFiles() {
    //Missing real test!!
    System.assert(
      !SMC_AP_ManageContentDocument.communityUserCantDeleteFiles(null),
      'Error.'
    );
  }

  /**
   * @description : test SMC_AP_ManageContentDocument.preventDeleteContentDocument()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testDeleteContentDocument() {
    ContentVersion contentVersion = new ContentVersion();
    contentVersion.Title = 'Penguins';
    contentVersion.PathOnClient = 'Penguins.jpg';
    contentVersion.VersionData = Blob.valueOf('Test Content');
    contentVersion.IsMajorVersion = true;
    insert contentVersion;

    ContentDocument oneContentDocument = [
      SELECT Id
      FROM ContentDocument
      LIMIT 1
    ];

    System.assert(
      Database.delete(oneContentDocument).isSuccess(),
      'The file is not deleted. '
    );
  }
}