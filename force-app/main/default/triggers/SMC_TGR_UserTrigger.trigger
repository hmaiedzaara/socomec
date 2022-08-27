/**
 * @File Name          : SMC_TGR_UserTrigger.trigger
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 21/04/2020 à 16:30:44
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    21/04/2020   Vincent RECASENS (Modis)     Initial Version
 **/
trigger SMC_TGR_UserTrigger on User(before insert, after insert, before update) {
  new TH_US_UserTriggerHandler().run();
}