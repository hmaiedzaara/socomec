/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_UTIL_Quotation
-- - Author : Vincent RECASENS
-- - Description : This class is an utils class to check if all fields 
                   are fill to access to discount form
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     -----------------------
-- 12-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_UTIL_Quotation {
  /**
   * @description : test SMC_UTIL_Quotation.getUser()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testGetUser() {
    //create and insert users
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST + 'ManageAccount',
      STA_UtilsStatic.USER_NICKNAME + 'ManageAccount'
    );
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '1',
      STA_UtilsStatic.EMAIL_TEST + '1',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User user3 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      STA_UtilsStatic.EMAIL_TEST + '2',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    insert new List<User>{ user1, user2, user3 };
    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = ps.Id
      )
    };

    //TEST
    List<User> users = new List<User>();
    users = SMC_UTIL_Quotation.getUsers();
    System.assertNotEquals(0, users.size(), 'The user do not exist.');
  }
  /**
   * @description : test SMC_UTIL_Quotation.getForecast()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testGetForecast() {
    //create and insert users
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST + 'ManageAccount',
      STA_UtilsStatic.USER_NICKNAME + 'ManageAccount'
    );
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '1',
      STA_UtilsStatic.EMAIL_TEST + '1',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User user3 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      STA_UtilsStatic.EMAIL_TEST + '2',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    insert new List<User>{ user1, user2, user3 };
    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = ps.Id
      )
    };

    //TEST
    System.assertNotEquals(
      null,
      SMC_UTIL_Quotation.getQuoteForecasts().size(),
      'The field SMC_Forecast__c no longer exist.'
    );
  }

  /**
   * @description : test SMC_UTIL_Quotation.getAccountCategory()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testGetAccountCategory() {
    //create and insert users
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST + 'ManageAccount',
      STA_UtilsStatic.USER_NICKNAME + 'ManageAccount'
    );
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '1',
      STA_UtilsStatic.EMAIL_TEST + '1',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User user3 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      STA_UtilsStatic.EMAIL_TEST + '2',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    insert new List<User>{ user1, user2, user3 };
    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = ps.Id
      )
    };

    //TEST
    System.assertNotEquals(
      null,
      SMC_UTIL_Quotation.getAccountCategory().size(),
      'Error.'
    );
  }
}