/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 02-11-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   02-11-2021   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public class TEST_Recaptcha {
  @isTest
  public static void testInsertRecord() {
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      JSON.serialize(new Map<String, Object>{ 'success' => true }),
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    System.assertEquals(
      'Success - v2',
      Recaptcha.insertRecord(null, 'recaptchaResponse')
    );

    Test.stopTest();
  }

  @isTest
  public static void testInsertRecordWithScore() {
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      JSON.serialize(
        new Map<String, Object>{
          'success' => true,
          'score' => 0.5,
          'action' => 'actionTestScore'
        }
      ),
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    System.assertEquals(
      'Success - v3',
      Recaptcha.insertRecord(null, 'recaptchaResponse')
    );

    Test.stopTest();
  }
}