/*
--------------------------------------------------------------------------------------
-- - Name          : TH_SKR_SkillRequirementTriggerHandler
-- - Author        : Vincent RECASENS (VRE - Modis)
-- - Description   : Handler for trigger SkillRequirementTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 24-MAY-2019  VR    1.0     Initial version
-- ??-???-20??  EB    1.1     Manage Skills on WorkOrder
-- 06-APR-2020  VR    1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_SKR_SkillRequirementTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SkillRequirement> oldMap;
  private Map<Id, SkillRequirement> newMap;
  private List<SkillRequirement> oldList;
  private List<SkillRequirement> newList;

  // Constructor
  public TH_SKR_SkillRequirementTriggerHandler() {
    this.oldMap = (Map<Id, SkillRequirement>) Trigger.oldMap;
    this.newMap = (Map<Id, SkillRequirement>) Trigger.newMap;
    this.oldList = (List<SkillRequirement>) Trigger.Old;
    this.newList = (List<SkillRequirement>) Trigger.New;
  }

  /**
  * @description Handle "SkillRequirement After Insert"
  -manage Skils on WorkOrder
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SKILLREQUIREMENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> SkillRequirement After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageSkillRequirement.replySkillRequirementOnWorkOrder(newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> SkillRequirement After Insert:END <<<'
      );
    }
  }
}