/**
 * @File Name          : TEST_SMC_AC_Edit_Report_To_Field.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    27/02/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@isTest
public with sharing class TEST_SMC_AC_Edit_Report_To_Field {
  /**
   * @description : test SMC_AC_Edit_Report_To_Field.editManagerId()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testEditManagerId() {
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
    User userStandard3 = SMC_UTIL_TestUtils.createUser(
      'standard3-' + STA_UtilsStatic.USERNAME_TEST,
      'standard3-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard3-' + STA_UtilsStatic.USERNAME_TEST,
      'standard3-' + STA_UtilsStatic.USERNAME_TEST
    );
    insert new List<User>{ userStandard1, userStandard2, userStandard3 };

    System.runAs(userStandard1) {
      User standard2 = [
        SELECT Id, ManagerId
        FROM User
        WHERE Id = :userStandard2.Id
      ];
      System.assertEquals(
        null,
        standard2.ManagerId,
        'User standard2 has already a manager.'
      );
      User standard3 = [SELECT Id FROM User WHERE Id = :userStandard3.Id];

      Test.startTest();
      SMC_AC_Edit_Report_To_Field.editManagerId(standard2.Id, standard3.Id);
      Test.stopTest();

      User standard2Check = [
        SELECT Id, ManagerId
        FROM User
        WHERE Id = :userStandard2.Id
      ];
      System.assertEquals(
        standard3.Id,
        standard2Check.ManagerId,
        'Update did not apply.'
      );
    }
  }
}