/**
 * @File Name          : TEST_SMC_AP_DoNothingClass.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2017   Xavier BRANCHE (Modis)       Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AP_DoNothingClass {
  /**
   * @description : test SMC_AP_DoNothingClass.doNothing()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testDoNothing() {
    SMC_AP_DoNothingClass.doNothing();
    System.assert(true, 'The assert function is broken.');
  }
}