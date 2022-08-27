/**
 * @File Name          : SMC_AP_DoNothingClass.cls
 * @Description        :
 * @Author             : Xavier BRANCHE (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09/04/2020 à 09:47:28
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2017   Xavier BRANCHE (Modis)       Initial Version
 **/

public without sharing class SMC_AP_DoNothingClass {
  /**
   * @description : execute for bypass process builder
   * @author Vincent RECASENS (Modis) | 08/04/2020 
   **/
  @InvocableMethod
  public static void doNothing() {
    //do nothing
  }
}