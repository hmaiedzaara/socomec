public with sharing class TH_LO_LocationTriggerHandler extends TriggerHandler {
    // Maps and list initialized from the Trigger context
    private Map<Id, Schema.Location> oldMap;
    private Map<Id, Schema.Location> newMap;
    private List<Schema.Location> oldList;
    private List<Schema.Location> newList;

    // Constructor
    public TH_LO_LocationTriggerHandler() {
        this.oldMap = (Map<Id, Schema.Location>) Trigger.oldMap;
        this.newMap = (Map<Id, Schema.Location>) Trigger.newMap;
        this.oldList = (List<Schema.Location>) Trigger.Old;
        this.newList = (List<Schema.Location>) Trigger.New;
    }

    public override void beforeUpdate() {
      if (Pad.cantrigger(STA_UtilsStatic.CLASS_LOCATION_MANAGEMENT)) {
        System.debug(LoggingLevel.INFO + '## >>> Location Before Update:START <<< run by ' + UserInfo.getName());
  
        SMC_AP_ManageLocation.renameLocation(this.newMap,this.oldMap);
  
        System.debug(LoggingLevel.INFO, '## >>> Location Before Update:END <<<');
      }
    }

    public override void afterUpdate() {
        if (Pad.cantrigger(STA_UtilsStatic.CLASS_LOCATION_MANAGEMENT) && !System.isFuture()) {
          System.debug(LoggingLevel.INFO,'## >>> Location After Update:START <<< run by ' + UserInfo.getName());
          
          SMC_AP_ManageLocation.getdurationFromCallout(this.newMap,this.oldMap);
          
          System.debug(LoggingLevel.INFO, '## >>> Location After Update:END <<<');
        }
    }
}