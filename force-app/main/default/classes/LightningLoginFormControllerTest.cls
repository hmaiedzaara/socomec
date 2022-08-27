/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 09-23-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-23-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest(SeeAllData=true)
public without sharing class LightningLoginFormControllerTest {
  @IsTest
  static void testLoginWithInvalidCredentials() {
    System.assertEquals(
      null,
      LightningLoginFormController.login(null, null, null)
    );
  }

  @IsTest
  static void LightningLoginFormControllerInstantiation() {
    LightningLoginFormController controller = new LightningLoginFormController();
    System.assertNotEquals(controller, null);
  }

  @IsTest
  static void testIsUsernamePasswordEnabled() {
    System.assertEquals(
      true,
      LightningLoginFormController.getIsUsernamePasswordEnabled()
    );
  }

  @IsTest
  static void testIsSelfRegistrationEnabled() {
    System.assertEquals(
      false,
      LightningLoginFormController.getIsSelfRegistrationEnabled()
    );
  }

  @IsTest
  static void testGetSelfRegistrationURL() {
    System.assertEquals(
      null,
      LightningLoginFormController.getSelfRegistrationUrl()
    );
  }

  @IsTest
  static void testAuthConfig() {
    Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
    System.assertNotEquals(null, authConfig);
  }

  @IsTest
  static void testGetForgotPasswordUrl() {
    String result = STA_UtilsStatic.EMPTY_STRING;
    result = LightningLoginFormController.getForgotPasswordUrl();
    System.assertEquals(null, result);
  }

  @IsTest
  static void testSetExperienceId() {
    String result = STA_UtilsStatic.EMPTY_STRING;
    result = LightningLoginFormController.setExperienceId(null);
    System.assertEquals(null, result);
  }
}