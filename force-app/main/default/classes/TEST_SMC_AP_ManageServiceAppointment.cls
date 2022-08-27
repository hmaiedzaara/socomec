/**
 * @File Name          : TEST_SMC_AP_ManageServiceAppointment.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 01-21-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/11/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@isTest
public with sharing class TEST_SMC_AP_ManageServiceAppointment {
  @testSetup
  public static void setup() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    userStandard.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userStandard.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_PreventLocationWithoutAddress';
    insert userStandard;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_ADMIN_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userStandard.id,
        PermissionSetId = ps.Id
      )
    };
  }
  /**
   * @description : test SMC_AP_ManageServiceAppointment.fillEarliestStartDateFromParent()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testEarliestStartDateSetting() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType,
        Bypass_Validation_Rule__c
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Workorder wo1 = new Workorder();
      Workorder wo2 = new Workorder();
      insert new List<WorkOrder>{wo1, wo2};
      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo1.id,
        Duration = 4,
        DurationType = 'Hours'
      );
      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        Duration = 4,
        DurationType = 'Hours'
      );
      insert new List<WorkOrderLineItem>{woli1, woli2};

      Test.startTest();
        ServiceAppointment sa1 = new ServiceAppointment(
          parentRecordId = wo1.id,
          earliestStartTime = DateTime.now().addDays(-5),
          Description = '1'
        );
        ServiceAppointment sa2 = new ServiceAppointment(
          parentRecordId = wo2.id,
          earliestStartTime = DateTime.now().addDays(5),
          Description = '2'
        );
        insert new List<ServiceAppointment>{ sa1, sa2 };
      Test.stopTest();

      ServiceAppointment sa1Check = [SELECT Id, earliestStartTime FROM ServiceAppointment WHERE Id = :sa1.Id];
      System.assertEquals(Date.today(), sa1Check.earliestStartTime.date(), 'date is not set to Wo.CreatedDate');
      ServiceAppointment sa2Check = [SELECT Id, earliestStartTime FROM ServiceAppointment WHERE Id = :sa2.Id];
      System.assertEquals(Date.today().addDays(5), sa2Check.earliestStartTime.date(), 'date is not set to Wo.CreatedDate');
    }
  }
  /**
   * @description : test SMC_AP_ManageServiceAppointment.fillFirstStartDateFromParent()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testfillFirstStartDateFromParent() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Workorder wo = new Workorder();
      // Workorder wo2 = new Workorder();
      insert new List<WorkOrder>{wo};//, wo2};
      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        Duration = 4,
        DurationType = 'Hours'
      );
      // WorkOrderLineItem woli2 = new WorkOrderLineItem(
      //   WorkOrderId = wo1.id,
      //   Duration = 3,
      //   DurationType = 'Hours'
      // );
      insert new List<WorkOrderLineItem>{woli1};//, woli2};
      Test.startTest();
        ServiceAppointment sa1 = new ServiceAppointment(
          parentRecordId = wo.id,
          SchedStartTime = DateTime.now().addDays(5),
          SchedEndTime = DateTime.now().addDays(5).addHours(2),
          Description = '1',
          Status = 'Completed'
        );
        ServiceAppointment sa2 = new ServiceAppointment(
          parentRecordId = wo.id,
          SchedStartTime = DateTime.now().addDays(6),
          SchedEndTime = DateTime.now().addDays(6).addHours(2),
          Description = '2'
        );
        insert new List<ServiceAppointment>{ sa1, sa2 };
      Test.stopTest();

      Workorder woTest = [
        SELECT id, SMC_First_pre_planned_Date__c
        FROM Workorder
        WHERE id = :wo.id
        LIMIT 1
      ];
      System.assertEquals(
        DateTime.now().addDays(5).date(),
        woTest.SMC_First_pre_planned_Date__c,
        'first pre planned date not correctly set'
      );
      Workorder woTest2 = [
        SELECT id, SMC_First_pre_planned_Date__c
        FROM Workorder
        WHERE id = :wo.id
        LIMIT 1
      ];
      System.assertNotEquals(
        DateTime.now().addDays(6).date(),
        woTest2.SMC_First_pre_planned_Date__c,
        'first pre planned date not correctly set'
      );
    }
  }

  /**
   * @description : test trigger "Complete Line"
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testSAonCompleteLine() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();

      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProductSparePartNew = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_newsparePart',
        true
      );
      insert theProductSparePartNew;
      WorkType wt = new WorkType(
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Spare_parts_are__c = 'mandatory',
        SMC_Asset_is__c = ''
      );
      insert wt;
      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wt.id
      );
      insert woli;
      ServiceAppointment sa = new ServiceAppointment(
        parentRecordId = wo.id,
        SchedStartTime = DateTime.now().addDays(6),
        SchedEndTime = DateTime.now().addDays(6).addHours(2),
        Description = '2'
      );
      Boolean isError = false;
      try {
        insert sa;
      } catch (Exception e) {
        isError = true;
      }
      System.assert(
        isError,
        'service appointment was inserted without required product'
      );

      ProductRequired reqProd = new ProductRequired(
        ParentRecordId = woli.id,
        QuantityRequired = 1,
        Product2Id = theProductSparePartNew.Id
      );
      reqProd.SMC_Quantity_Consumed__c = 1;
      insert reqProd;
      Boolean isSuccess = true;
      try {
        insert sa;
      } catch (Exception e) {
        isSuccess = false;
      }
      System.assert(
        isSuccess,
        'adding consumed product did not allowed to create the service appointment'
      );
    }
  }

  /**
  * @description : test method "checkUniquenessServiceAppointmentOnWorkOrder"
  * @author Vincent RECASENS (Modis) | 04-15-2021 
  **/
  @isTest
  public static void testCheckUniquenessServiceAppointmentOnWorkOrder() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();

      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProductSparePartNew = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_newsparePart',
        true
      );
      insert theProductSparePartNew;
      WorkType wt = new WorkType(
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Spare_parts_are__c = 'mandatory',
        SMC_Asset_is__c = ''
      );
      insert wt;
      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wt.id
      );
      insert woli;
      ServiceAppointment sa = new ServiceAppointment(
        parentRecordId = wo.id,
        SchedStartTime = DateTime.now().addDays(6),
        SchedEndTime = DateTime.now().addDays(6).addHours(2),
        Description = '2'
      );
      Boolean isError = false;
      try {
        insert sa;
      } catch (Exception e) {
        isError = true;
      }
      System.assert(
        isError,
        'service appointment was inserted without required product'
      );
      Boolean isSuccess = false;
      try {
        ServiceAppointment saBis = new ServiceAppointment(
          parentRecordId = wo.id,
          SchedStartTime = DateTime.now().addDays(6),
          SchedEndTime = DateTime.now().addDays(6).addHours(2),
          Description = '2'
        );
        insert saBis;
      } catch (Exception e) {
        isSuccess = true;
      }
      System.assert(isSuccess, 'The seconde SA is inserted.');
    }
  }

  /**
  * @description : test trigger method "setDurationFromAllRelatedWoli"
  * @author Vincent RECASENS (Modis) | 04-15-2021 
  **/
  @isTest
  public static void testSetDurationFromAllRelatedWoli(){
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS,
        SMC_Spare_parts_are__c = 'Not Allowed'
      );
      insert wt;
      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wt.id
      );
      woli1.DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS;
      woli1.Duration = 1.0;
      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wt.id
      );
      woli2.DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS;
      woli2.Duration = 2.0;
      woli2.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      WorkOrderLineItem woli3 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wt.id
      );
      woli3.DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS;
      woli3.Duration = 3.0;
      insert new list<WorkOrderLineItem>{woli1, woli2, woli3};

      ServiceAppointment theSa = new ServiceAppointment(
        parentRecordId = wo.id,
        SchedStartTime = DateTime.now().addDays(6),
        SchedEndTime = DateTime.now().addDays(6).addHours(2),
        Description = '2'
      );

      Test.startTest();
        insert theSa;
      Test.stopTest();

      ServiceAppointment checkServiceAppointment = [SELECT Id, DurationType, Duration FROM ServiceAppointment WHERE Id = :theSa.Id];
      System.assertEquals(STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS , checkServiceAppointment.DurationType);
      System.assertEquals(4.0 , checkServiceAppointment.Duration);
    }
  }

    /**
  * @description : test method "checkEstimatedLaborTime"
  * @author Tanya SIBONI (Modis) | 09-20-2021
  **/
  @isTest
  public static void testcheckEstimatedLaborTime() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();

      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProductSparePartNew = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_newsparePart',
        true
      );
      insert theProductSparePartNew;
      WorkType wt = new WorkType(
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Spare_parts_are__c = 'mandatory',
        SMC_Asset_is__c = ''
      );
      insert wt;
      WorkOrder wo = new WorkOrder();
      insert wo;
      
      ServiceAppointment sa = new ServiceAppointment(
        parentRecordId = wo.id,
        SchedStartTime = DateTime.now().addDays(6),
        SchedEndTime = DateTime.now().addDays(6).addHours(2),
        Description = '2'
      );
      Boolean isError = false;
      try {
        insert sa;
      } catch (Exception e) {
        isError = true;
      }
      System.assert(
        isError,
        STA_UtilsStatic.SERVICE_APPOINTMENT_ESTIMATED_LABOR_TIME_NULL
      );

    }
  }
}