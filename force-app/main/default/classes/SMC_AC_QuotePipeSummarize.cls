/**
 * @File Name          : SMC_AC_QuotePipeSummarize.cls
 * @Description        : Copy and adaptation of the controller AC_ProjectPipeSummarize
 * @Author             : Guillaume BONNET (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 16:05:25
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/04/2018   Guillaume BONNET (Modis)     Initial Version
 * 1.1    20/04/2018   Guillaume BONNET (Modis)     Changing recordType
 **/

public without sharing class SMC_AC_QuotePipeSummarize {
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
   * @description : get quote amount
   * @author Vincent RECASENS (Modis) | ??/??/201?
   * @return Decimal
   **/
  @AuraEnabled
  public static Decimal getAmountPipe() {
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_QuotePipeSummarize getAmountPipe():START <<< ##'
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
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_QuotePipeSummarize getAmountPipe():END <<< ##'
    );
    return amntSum;
  }

  /**
   * @description : get number of opportunity Project
   * @author Vincent RECASENS (Modis) | ??/??/201?
   * @return Decimal
   **/
  @AuraEnabled
  public static Decimal getQuoteNumberPipe() {
    System.debug(
      LoggingLevel.Info,
      '## >>> SMC_AC_QuotePipeSummarize getQuoteNumberPipe():START <<< ##'
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
      '## >>> SMC_AC_QuotePipeSummarize getQuoteNumberPipe():END <<< ##'
    );
    return (Decimal) [
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

  /**
   * @description : get Quote Project and QuickQuotation RecordTypeId
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Set<Id>
   **/
  public static Set<Id> goodSetRecordTypeIdQuote() {
    List<String> recordTypeDevNames = new List<String>{
      STA_UTilsStatic.RECORDTYPE_QUOTE_PROJECT,
      STA_UTilsStatic.RECORDTYPE_QUICK_QUOTE
    };
    Map<Id, RecordType> recordTypesIdMap = new Map<Id, RecordType>(
      [
        SELECT Id
        FROM RecordType
        WHERE
          DeveloperName IN :recordTypeDevNames
          AND SobjectType = :STA_UTilsStatic.QUOTE
      ]
    );
    return recordTypesIdMap.keySet();
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