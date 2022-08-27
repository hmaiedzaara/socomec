/**
 * @File Name          : TH_SERVICEAPPOINTMENT_TriggerHandler.cls
 * @Description        :
 * @Author             : Emmanuel Bernier (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		         Modification
 * 1.0    10/12/2019   Emmanuel Bernier (Modis)     Initial Version
 * 1.0    06/04/2020   Vincent RECASENS (Modis)     Add documentation
 **/

public with sharing class TH_SERVICEAPPOINTMENT_TriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, ServiceAppointment> oldMap;
  private Map<Id, ServiceAppointment> newMap;
  private List<ServiceAppointment> oldList;
  private List<ServiceAppointment> newList;

  // Constructor
  public TH_SERVICEAPPOINTMENT_TriggerHandler() {
    this.oldMap = (Map<Id, ServiceAppointment>) Trigger.oldMap;
    this.newMap = (Map<Id, ServiceAppointment>) Trigger.newMap;
    this.oldList = (List<ServiceAppointment>) Trigger.Old;
    this.newList = (List<ServiceAppointment>) Trigger.New;
  }

  /**
  * @description Handle "ServiceAppointment Before Insert"
  -manage EarliestStartTime field
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SERVICE_APPOINTMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment Before Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageServiceAppointment.checkUniquenessServiceAppointmentOnWorkOrder(
        newList
      );
      SMC_AP_ManageServiceAppointment.fillEarliestStartDateFromParent(newList);
      SMC_AP_ManageServiceAppointment.checkWorkOrderCorrectness(newList);
      SMC_AP_ManageServiceAppointment.checkCommissionningWO(newList);
      SMC_AP_ManageServiceAppointment.setDurationFromAllRelatedWoli(newList);
      SMC_AP_ManageServiceAppointment.checkEstimatedLaborTime(newList);
      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment Before Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "ServiceAppointment After Insert"
  -manage EarliestStartTime field
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SERVICE_APPOINTMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageServiceAppointment.fillFirstStartDateFromParent(newList);
      SMC_AP_ManageServiceAppointment.sendEmailServiceAppointment(
        newList,
        null
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment After Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "ServiceAppointment After Update"
  -manage FirstStartTime field
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SERVICE_APPOINTMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment After Update:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageServiceAppointment.fillFirstStartDateFromParent(newList);
      SMC_AP_ManageServiceAppointment.sendEmailServiceAppointment(
        newList,
        oldMap
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> ServiceAppointment After Update:END <<<'
      );
    }
  }
}