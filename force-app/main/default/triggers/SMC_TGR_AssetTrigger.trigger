/**
 * @File Name          : SMC_TGR_AssetTrigger.trigger
 * @Description        : 
 * @Author             : emmanuel.bernier@modis.com
 * @Group              : 
 * @Last Modified By   : emmanuel.bernier@modis.com
 * @Last Modified On   : 18/06/2020 à 15:40:08
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    18/06/2020   emmanuel.bernier@modis.com     Initial Version
**/
trigger SMC_TGR_AssetTrigger on Asset(
  before insert,
  after insert,
  before update,
  after update,
  before delete
) {
  new TH_ASS_AssetTrigger().run();
}