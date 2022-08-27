/**
 * @File Name          : TH_AL_AssociatedLocationTriggerHandler.cls
 * @Description        :
 * @Author             : Emmanuel BERNIER (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		        Modification
 * 1.0    19/02/2019   Emmanuel BERNIER (Modis)   Initial Version
 * 1.0    06/04/2020   Vincent RECASENS (Modis)   Add documentation
 **/

public with sharing class TH_AL_AssociatedLocationTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, AssociatedLocation> oldMap;
  private Map<Id, AssociatedLocation> newMap;
  private List<AssociatedLocation> oldList;
  private List<AssociatedLocation> newList;

  // Constructor
  public TH_AL_AssociatedLocationTriggerHandler() {
    this.oldMap = (Map<Id, AssociatedLocation>) Trigger.oldMap;
    this.newMap = (Map<Id, AssociatedLocation>) Trigger.newMap;
    this.oldList = (List<AssociatedLocation>) Trigger.Old;
    this.newList = (List<AssociatedLocation>) Trigger.New;
  }

  /**
  * @description Handle "AssociatedLocation After Insert"
  -manage AssociatedLocation
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ASSOCIATED_LOCATION_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Associated Location After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageAssociatedLocation.manageAssociatedLocationType(this.newMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> Associated Location After Insert:END <<<'
      );
    }
  }
}