/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_PipeSummarize
-- - Author : Vincent RECASENS
-- - Description : This class is Apex controller of LWC Pipe Summarize
                   It's a concatenation of AC_ProjectPipeSummarize and AC_QuotePipeSummarize
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 04-OCT-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AC_PipeSummarize {
  public class AllInformations {
    @AuraEnabled
    public Boolean haveQuotationToolPermission = false;
    @AuraEnabled
    public Decimal amountPipe;
    @AuraEnabled
    public Decimal elementPipe;
    @AuraEnabled
    public String userCurrency;

    public AllInformations(
      Boolean haveQuotationToolPermission,
      Decimal amountPipe,
      Decimal elementPipe
    ) {
      this.haveQuotationToolPermission = haveQuotationToolPermission;
      this.amountPipe = amountPipe;
      this.elementPipe = elementPipe;
      this.userCurrency = UserInfo.getDefaultCurrency();
    }
  }

  /**
  * @description : get all user sub-role id
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @param roleIds 
  * @return List<ID> 
  **/
  @TestVisible
  private static List<ID> getAllSubRoleIds(List<ID> roleIds) {
    List<ID> currentRoleIds = new List<ID>();

    // get all of the roles underneath the passed roles
    for (UserRole userRole : [
      SELECT Id
      FROM UserRole
      WHERE ParentRoleId IN :roleIds AND ParentRoleID != null
    ]) {
      currentRoleIds.add(userRole.Id);
    }

    // go fetch some more rolls!
    if (currentRoleIds.size() > 0) {
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    }

    return currentRoleIds;
  }

  /**
  * @description : get Quote Project and QuickQuotation RecordTypeId
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @return Set<Id> 
  **/
  @TestVisible
  private static Set<Id> goodSetRecordTypeIdQuote() {
    List<String> recordTypeDevNames = new List<String>{
      STA_UTilsStatic.RECORDTYPE_QUOTE_PROJECT,
      STA_UTilsStatic.RECORDTYPE_QUICK_QUOTE
    };
    return new Map<Id, RecordType>(
        [
          SELECT Id
          FROM RecordType
          WHERE
            DeveloperName IN :recordTypeDevNames
            AND SobjectType = :STA_UTilsStatic.QUOTE
        ]
      )
      .keySet();
  }

  /**
  * @description : check user permission and get Amount and number  of opportunity Project or (opportunity Project and quote followed)
  * @author Vincent RECASENS (Modis) | 10/04/2020 
  * @param elementSelectedForPipe 
  * @return AllInformations 
  **/
  @AuraEnabled
  public static AllInformations getInformations(String elementSelectedForPipe) {
    System.debug(
      LoggingLevel.INFO,
      'SMC_AC_PipeSummarize.getInformations : START'
    );
    Boolean haveQuotationToolPermission = false;
    List<PermissionSetAssignment> pasList = [
      SELECT Assignee.Id, PermissionSet.Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE Assignee.Id = :UserInfo.getUserId()
    ];
    for (PermissionSetAssignment onePas : pasList) {
      if (
        onePas.PermissionSet.Name == STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
      ) {
        haveQuotationToolPermission = true;
      }
    }

    List<User> subordinateUsers = [
      SELECT Id
      FROM User
      WHERE
        UserRoleId IN :getAllSubRoleIds(
          new List<Id>{ UserInfo.getUserRoleId() }
        )
    ];

    //Tmp variables
    Decimal amntSum = 0;
    Decimal nbsPipe = 0;

    if (elementSelectedForPipe != STA_UtilsStatic.QUOTE_FOLLOWED) {
      //Amount pipe Project
      for (Opportunity opp : [
        SELECT convertCurrency(Amount) amntConverted
        FROM Opportunity
        WHERE
          SMC_Is_In_Rolling_Year__c = true
          AND IsClosed = false
          AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
          AND Amount > 0
          AND (OwnerId = :UserInfo.getUserID()
          OR OwnerId IN :subordinateUsers)
      ]) {
        amntSum += (Decimal) opp.get(STA_UtilsStatic.AMOUNT_CONVERTED);
      }

      //Number of pipe Project
      nbsPipe += (Decimal) [
          SELECT COUNT(Id) projectNbs
          FROM Opportunity
          WHERE
            SMC_Is_In_Rolling_Year__c = true
            AND IsClosed = false
            AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
            AND (OwnerId = :UserInfo.getUserID()
            OR OwnerId IN :subordinateUsers)
        ][0]
        .get(STA_UtilsStatic.PRJECT_NBS);

      if (
        elementSelectedForPipe == STA_UtilsStatic.QUOTE_PIPE &
        haveQuotationToolPermission
      ) {
        //Amount pipe Project + Quote followed
        for (Quote qte : [
          SELECT convertCurrency(GrandTotal) amntConverted
          FROM Quote
          WHERE
            SMC_Is_In_Rolling_Year__c = true
            AND (OwnerId = :UserInfo.getUserID()
            OR OwnerId IN :subordinateUsers)
            AND RecordTypeId IN :goodSetRecordTypeIdQuote()
        ]) {
          amntSum += (Decimal) qte.get(STA_UtilsStatic.AMOUNT_CONVERTED);
        }

        //Number of pipe Project + Quote followed
        nbsPipe += (Decimal) [
            SELECT COUNT(Id) quoteNbs
            FROM Quote
            WHERE
              SMC_Is_In_Rolling_Year__c = true
              AND (OwnerId = :UserInfo.getUserID()
              OR OwnerId IN :subordinateUsers)
              AND RecordTypeId IN :goodSetRecordTypeIdQuote()
          ][0]
          .get(STA_UtilsStatic.QUOTE_NBS);
      }
    } else if (
      elementSelectedForPipe == STA_UtilsStatic.QUOTE_FOLLOWED &&
      haveQuotationToolPermission
    ) {
      //Amount pipe Project + Quote followed
      for (Quote qte : [
        SELECT convertCurrency(GrandTotal) amntConverted
        FROM Quote
        WHERE
          SMC_Is_In_Rolling_Year__c = true
          AND SMC_Followed__c = true
          AND (OwnerId = :UserInfo.getUserID()
          OR OwnerId IN :subordinateUsers)
          AND RecordTypeId IN :goodSetRecordTypeIdQuote()
      ]) {
        amntSum += (Decimal) qte.get(STA_UtilsStatic.AMOUNT_CONVERTED);
      }

      //Number of pipe Project + Quote followed
      nbsPipe += (Decimal) [
          SELECT COUNT(Id) quoteNbs
          FROM Quote
          WHERE
            SMC_Is_In_Rolling_Year__c = true
            AND (OwnerId = :UserInfo.getUserID()
            OR OwnerId IN :subordinateUsers)
            AND RecordTypeId IN :goodSetRecordTypeIdQuote()
        ][0]
        .get(STA_UtilsStatic.QUOTE_NBS);
    }

    System.debug(
      LoggingLevel.INFO,
      'SMC_AC_PipeSummarize.getInformations : END'
    );
    return new AllInformations(haveQuotationToolPermission, amntSum, nbsPipe);
  }
}