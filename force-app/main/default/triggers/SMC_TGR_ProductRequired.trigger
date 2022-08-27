/**
 * @File Name          : SMC_TGR_ProductRequired.trigger
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 14/05/2020 à 09:27:53
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    13/05/2020   Vincent RECASENS (Modis)     Initial Version
 **/
trigger SMC_TGR_ProductRequired on ProductRequired(after insert, after update) {
  new TH_PR_ProductRequiredTriggerHandler().run();
}