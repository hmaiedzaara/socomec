/**
 * @File Name          : TEST_SMC_AC_Reporting.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-24-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    26/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Reporting {

  /**
   * @description : test SMC_AC_Reporting.getTotalRecords(IOT Demo - Cases)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest(SeeAllData=true)
  public static void testGetTotalRecords() {
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST
    );
    insert userAdmin;
    System.runAs(userAdmin) {
      SMC_AC_Reporting.AllInformations result = (SMC_AC_Reporting.AllInformations) 
                                                  JSON.deserialize(SMC_AC_Reporting.getTotalRecords('IOT Demo - Cases'), 
                                                                   SMC_AC_Reporting.AllInformations.class);
      System.assertEquals(
        0,
        result.totalRecords,
        'The test user has datas in his report.'
      );
    }
    // }
  }

  /**
   * @description : test SMC_AC_Reporting.getColumns(IOT Demo - Contracts)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest(SeeAllData=true)
  public static void testGetColumns() {

    System.assertEquals(
      null,
      SMC_AC_Reporting.getColumns('IOT Demo - Contracts', 5, 10),
      'The test user has datas in his report.'
    );
  }
}