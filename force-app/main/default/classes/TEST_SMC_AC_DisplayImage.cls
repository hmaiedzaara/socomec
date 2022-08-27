/**
 * @File Name          : TEST_AC_DisplayImage.cls
 * @Description        :
 * @Author             : ?????? | ???/??/2017
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 04/05/2020 à 15:44:00
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2017         ??????                 Initial Version
 **/

@IsTest
public without sharing class TEST_SMC_AC_DisplayImage {
  // This method tests the getIdDocumentFromImageName method
  @IsTest
  public static void getIdDocumentFromImageNameTest() {
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert new List<User>{ userStandard };
    System.runAs(userStandard) {
      String userAlias = [
        SELECT Alias
        FROM User
        WHERE Id = :UserInfo.getUserID()
      ]
      .Alias;
      Document doc1 = new Document();
      doc1.FolderId = UserInfo.getUserID();
      doc1.Name = userAlias + STA_UtilsStatic.UNDERSCORE + STA_UtilsStatic.TEST;
      insert doc1;

      Id idDoc1 = SMC_AC_DisplayImage.getIdDocumentFromImageName(
        STA_UtilsStatic.TEST,
        null,
        true,
        false
      );
      System.assertEquals(doc1.Id, idDoc1, 'Method return wrong Id or NULL.');
    }
  }
}