/**
 * @File Name          : SMC_TGR_QuoteTrigger.trigger
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 12/05/2020 à 09:36:28
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/05/2020   Vincent RECASENS (Modis)     Initial Version
 **/
trigger SMC_TGR_QuoteTrigger on Quote(
  before insert,
  before update,
  after update,
  before delete
) {
  new TH_QUO_QuoteTriggerHandler().run();
}