/**
 * @File Name          : SMC_AC_ProjectPipeSummarize.cls
 * @Description        :
 * @Author             : David SOBZACK (Socomec)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 16:05:38
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/04/2018    David SOBZACK (Socomec)     Initial Version
 **/
public without sharing class SMC_AC_ProjectPipeSummarize {
  /**
   * @description : get all user sub-role id
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param roleIds
   * @return List<ID>
   **/
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
   * @description : get opportunity amount
   * @author Vincent RECASENS (Modis) | ??/??/201?
   * @return Decimal
   **/
  @AuraEnabled
  public static Decimal getAmountPipe() {
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_ProjectPipeSummarize getAmountPipe():START <<< ##'
    );
    Decimal amntSum = 0;
    List<User> subordinateUsers = [
      SELECT Id
      FROM User
      WHERE
        UserRoleId IN :getAllSubRoleIds(
          new List<Id>{ UserInfo.getUserRoleId() }
        )
    ];

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
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_ProjectPipeSummarize getAmountPipe():END <<< ##'
    );
    return amntSum;
  }

  /**
   * @description : get number of opportunity Project
   * @author Vincent RECASENS (Modis) | ??/??/201?
   * @return Decimal
   **/
  @AuraEnabled
  public static Decimal getProjectNumberPipe() {
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_ProjectPipeSummarize getProjectNumberPipe():START <<< ##'
    );
    List<User> subordinateUsers = [
      SELECT Id
      FROM User
      WHERE
        UserRoleId IN :getAllSubRoleIds(
          new List<Id>{ UserInfo.getUserRoleId() }
        )
    ];

    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_ProjectPipeSummarize getProjectNumberPipe():END <<< ##'
    );
    return (Decimal) [
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
  }

  /**
   * @description : get user currency
   * @author Vincent RECASENS (Modis) | ??/??/201?
   * @return String
   **/
  @AuraEnabled
  public static String getUserDefaultCurrency() {
    return UserInfo.getDefaultCurrency();
  }
}