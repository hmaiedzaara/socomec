/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_ScoringForm
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_ScoringForm
--
-- Maintenance History:
-- /!\ DISCOUNT = SCORING /!\
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     	Initial Version
-- 26-NOV-2018  Vincent RECASENS  		1.0     	Manage token and upsert Scoring
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_ScoringForm {
  /**
   * @description : get callout information from MDT in according to the org
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Call_Scoring_Domain__mdt
   **/
  public static Call_Scoring_Domain__mdt getHost() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getHost - START'
    );

    // Define organization
    String host;
    host = URL.getSalesforceBaseUrl().getHost();
    Call_Scoring_Domain__mdt[] scoringDomain = [
      SELECT
        Label,
        Organization__c,
        Organization_Community__c,
        Domain__c,
        SecurityToken_Application__c,
        SecurityToken_Secret__c,
        id_PCO__c,
        id_PCS__c,
        id_SERVICES__c,
        id_EE__c
      FROM Call_Scoring_Domain__mdt
    ]; //There are not 200 elements in this custom metadata

    // Get url and security token informations
    Call_Scoring_Domain__mdt callInformations = new Call_Scoring_Domain__mdt();
    for (Call_Scoring_Domain__mdt mdt : scoringDomain) {
      //If host == mdt.Organization__c -> PRODUCTION
      if (
        host == mdt.Organization__c ||
        host == mdt.Organization_Community__c
      ) {
        callInformations = mdt;
      } else if (
        (host.contains(mdt.Organization__c) ||
        host.startsWithIgnoreCase(mdt.Organization__c + '-socomec')) &&
        mdt.Organization__c.length() <= 10
      ) {
        //If host contains 'DEV', 'QA', or 'INT' -> mdt.Organization__c length is lower of 5 char
        callInformations = mdt;
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getHost - END'
    );
    return callInformations;
  }

  /**
   * @description : callout to refresh token
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param callInformations
   * @param recordList
   * @return SMC_DTO_DiscountToken
   **/
  private static SMC_DTO_DiscountToken getTokenRefresh(
    Call_Scoring_Domain__mdt callInformations,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getTokenRefresh - START'
    );

    // Get security token
    Call_Scoring__mdt scoringToken = [
      SELECT DeveloperName, Endpoint_Scoring__c
      FROM Call_Scoring__mdt
      WHERE DeveloperName = :STA_UtilsStatic.TOKEN
    ];
    String tokenEndpoint =
      callInformations.Domain__c + scoringToken.Endpoint_Scoring__c;

    SMC_DTO_DiscountToken token = new SMC_DTO_DiscountToken();
    token = SMC_AP_ScoringCallout.getDiscountToken(
      callInformations,
      tokenEndpoint,
      recordList
    );
    token.callInformations = callInformations;

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getTokenRefresh - END'
    );
    return token;
  }

  /**
   * @description : get scoring from scoring form
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recId
   * @return SMC_DTO_ScoringForm
   **/
  @AuraEnabled
  public static SMC_DTO_ScoringForm getDiscountInformationsFromDiscountForm(
    String recId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformationsFromDiscountForm - START'
    );

    SMC_DTO_ScoringForm dtoScoringForm = getDiscountInformations(
      new Set<Id>{ recId },
      true
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformationsFromDiscountForm - END'
    );
    return dtoScoringForm;
  }

  /**
   * @description : get account informations to upsert scoring
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param accountId
   * @param isInsert
   * @return SMC_DTO_ScoringForm
   **/
  public static SMC_DTO_ScoringForm getDiscountInformations(
    Set<Id> accountId,
    Boolean isInsert
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformations - START'
    );

    List<Account> accounts;
    try {
      accounts = [
        SELECT
          Id,
          Name,
          AccountNumber,
          SMC_Category__c,
          SMC_Business__c,
          SMC_Pricing_Tier__c,
          BillingCountryCode
        FROM Account
        WHERE Id IN :accountId
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR - Account id invalid : ' + e);
      return null;
    }

    Call_Scoring_Domain__mdt callInformations = getHost();

    SMC_DTO_ScoringForm dtoScoringForm = new SMC_DTO_ScoringForm();
    Boolean displayMockOrNot = SMC_AC_Scoring.displayMock();
    if (Test.isRunningTest()) {
      displayMockOrNot = false;
    }
    if (displayMockOrNot == true) {
      dtoScoringForm.token = 'tokenRefresh'; //Fill for MOCK
      if (accounts.size() == 1) {
        dtoScoringForm.account = accounts[0];
      } else {
        dtoScoringForm.account = null;
      }
      dtoScoringForm.accountList = accounts;
      dtoScoringForm.scoringExist = true;
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AC_ScoringForm -> display Mock'
      );
    } else {
      //Error list
      List<String> recordList = new List<String>();
      for (Account oneAccount : accounts) {
        recordList.add(oneAccount.Id);
      }
      dtoScoringForm.discountTokenDto = getTokenRefresh(
        callInformations,
        recordList
      );
      dtoScoringForm.token = dtoScoringForm.discountTokenDto.refreshToken;
      if (accounts.size() == 1) {
        dtoScoringForm.account = accounts[0];
      } else {
        dtoScoringForm.account = null;
      }
      dtoScoringForm.accountList = accounts;
      dtoScoringForm.urlPartial = callInformations.Domain__c;

      //Upsert Discount
      if (!Test.isRunningTest()) {
        ObjectLinkDiscountInfrmationToUpsertDiscount objectLink = upsertDiscount(
          accounts,
          dtoScoringForm,
          isInsert,
          null
        );
        dtoScoringForm.scoringExist = objectLink.scoringExist; //For test = TRUE
        dtoScoringForm.baIds = objectLink.baIds; //For test = TRUE
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformations - END'
    );
    return dtoScoringForm;
  }

  /**
   * @description : upsert scoring information in according to account upsert
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param accounts
   * @param scoringInformations
   * @param isInsert
   * @param listResultForTest
   * @return ObjectLinkDiscountInfrmationToUpsertDiscount
   **/
  public static ObjectLinkDiscountInfrmationToUpsertDiscount upsertDiscount(
    List<Account> accounts,
    SMC_DTO_ScoringForm scoringInformations,
    Boolean isInsert,
    List<SMC_DTO_Scoring_AreScored> listResultForTest
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method upsertDiscount - START'
    );

    if (accounts == null || accounts.size() == 0) {
      System.debug(LoggingLevel.INFO, 'Account is null');
      return null;
    }

    //Error list
    List<String> recordAreScoredList = new List<String>();

    Map<Id, Account> accountIdToAccount = new Map<Id, Account>();
    String body = '[';
    for (Account oneAccount : accounts) {
      body += '{"account":"' + oneAccount.Id + '","country":"' + oneAccount.BillingCountryCode +'"},';
      +accountIdToAccount.put(oneAccount.Id, oneAccount);

      recordAreScoredList.add(oneAccount.Id);
    }
    body = body.substring(0, (body.length() - 1)) + ']';

    // Get all scoring
    Call_Scoring__mdt scoringAreScoredEndpoints = [
      SELECT DeveloperName, Endpoint_Scoring__c
      FROM Call_Scoring__mdt
      WHERE DeveloperName = :STA_UtilsStatic.SCORING_ARE_SCORED
    ];//A dégager 
    String areScoredEndpoint =
      scoringInformations.urlPartial +
      scoringAreScoredEndpoints.Endpoint_Scoring__c; //A degager
    List<SMC_DTO_Scoring_AreScored> listResult = new List<SMC_DTO_Scoring_AreScored>();
    if (Test.isRunningTest()) {
      listResult = listResultForTest;
    } else {
      listResult = SMC_AP_ScoringCallout.areScoredScoring(
        body,
        areScoredEndpoint,
        scoringInformations.token,
        recordAreScoredList
      );//C'est l'appel WS pour savoir s il existe ou si il faut le créer
    }

    List<SMC_DTO_UpsertAccountForScoring> accountToUpdate = new List<SMC_DTO_UpsertAccountForScoring>(); // Y aura peut être un Update (si modif du compte)
    List<SMC_DTO_UpsertAccountForScoring> accountToInsert = new List<SMC_DTO_UpsertAccountForScoring>();
    for (SMC_DTO_Scoring_AreScored oneScoring : listResult) {
      Account account = accountIdToAccount.get(oneScoring.account);
      if (oneScoring.bas.size() == 0 && isInsert) {
        //Call "insert Scoring" -> Upsert POST + determine BaId
        SMC_DTO_Scoring_BAs bas = new SMC_DTO_Scoring_BAs();
        bas.id = STA_UtilsStatic.ONE;
        bas.ba = STA_UtilsStatic.PCO;
        oneScoring.bas.add(bas);
        accountToInsert.add(
          new SMC_DTO_UpsertAccountForScoring(
            account.Id,
            account.AccountNumber,
            account.BillingCountryCode,
            account.SMC_Category__c,
            account.SMC_Business__c,
            account.SMC_Pricing_Tier__c,
            UserInfo.getUserName(),
            oneScoring.bas
          )
        );
      } else if (oneScoring.bas.size() > 0) {
        //Call "getScoringLine"
        accountToUpdate.add(
          new SMC_DTO_UpsertAccountForScoring(
            account.Id,
            account.AccountNumber,
            account.BillingCountryCode,
            account.SMC_Category__c,
            account.SMC_Business__c,
            account.SMC_Pricing_Tier__c,
            UserInfo.getUserName(),
            oneScoring.bas
          )
        );
      } else if (oneScoring.bas.size() == 0 && !isInsert) {
        ObjectLinkDiscountInfrmationToUpsertDiscount objectLink = new ObjectLinkDiscountInfrmationToUpsertDiscount();
        objectLink.scoringExist = false;
        return objectLink;
      }
    }

    // Get UPSERT
    Call_Scoring__mdt scoringUpsertEndpoints = [
      SELECT DeveloperName, Endpoint_Scoring__c
      FROM Call_Scoring__mdt
      WHERE DeveloperName = :STA_UtilsStatic.SCORING_UPSERT
    ];
    String methodEndpoint =
      scoringInformations.urlPartial +
      scoringUpsertEndpoints.Endpoint_Scoring__c;

    SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn = new SMC_AP_ScoringCallout.ScoringWrapper();
    ObjectLinkDiscountInfrmationToUpsertDiscount objectLink = new ObjectLinkDiscountInfrmationToUpsertDiscount();

    //Error list
    List<String> recordInsertList = new List<String>();
    //Insert Scoring
    if (accountToInsert.size() > 0) {
      //Construct body to callout
      String bodyUpsert = '[';
      for (SMC_DTO_UpsertAccountForScoring oneUpsert : accountToInsert) {
        bodyUpsert +=
          '{' +
          '"account":"' +
          oneUpsert.account +
          '",' +
          '"acc":"' +
          oneUpsert.acc +
          '",' +
          '"category":"' +
          oneUpsert.category +
          '",' +
          '"business":"' +
          oneUpsert.business +
          '",' +
          '"tier":"' +
          oneUpsert.tier +
          '",' +
          '"country":"' +
          oneUpsert.country +
          '",' +
          '"user":"' +
          oneUpsert.user +
          '",' +
          '"baIds":[';
        String endBodyUpsert = STA_UtilsStatic.EMPTY_STRING;
        for (SMC_DTO_Scoring_BAs oneBa : oneUpsert.bas) {
          endBodyUpsert += oneBa.id + ',';
          objectLink.baIds.add(oneBa.id);
        }
        bodyUpsert +=
          endBodyUpsert.substring(0, (endBodyUpsert.length() - 1)) + ']},';

        recordInsertList.add(oneUpsert.account);
      }
      bodyUpsert = bodyUpsert.substring(0, (bodyUpsert.length() - 1)) + ']';

      //Callout
      wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
        bodyUpsert,
        STA_UtilsStatic.POST_METHOD,
        methodEndpoint,
        scoringInformations.token,
        recordInsertList
      );
    }

    //Error list
    List<String> recordUpdateList = new List<String>();
    //Update Scoring
    if (accountToUpdate.size() > 0) {
      //Construct body to callout
      String bodyUpsert = '[';
      for (SMC_DTO_UpsertAccountForScoring oneUpsert : accountToUpdate) {
        bodyUpsert +=
          '{' +
          '"account":"' +
          oneUpsert.account +
          '",' +
          '"acc":"' +
          oneUpsert.acc +
          '",' +
          '"category":"' +
          oneUpsert.category +
          '",' +
          '"business":"' +
          oneUpsert.business +
          '",' +
          '"tier":"' +
          oneUpsert.tier +
          '",' +
          '"country":"' +
          oneUpsert.country +
          '",' +
          '"user":"' +
          oneUpsert.user +
          '",' +
          '"baIds":[';
        String endBodyUpsert = STA_UtilsStatic.EMPTY_STRING;
        for (SMC_DTO_Scoring_BAs oneBa : oneUpsert.bas) {
          endBodyUpsert += oneBa.id + ',';
          objectLink.baIds.add(oneBa.id);
        }
        bodyUpsert +=
          endBodyUpsert.substring(0, (endBodyUpsert.length() - 1)) + ']},';

        recordUpdateList.add(oneUpsert.account);
      }
      bodyUpsert = bodyUpsert.substring(0, (bodyUpsert.length() - 1)) + ']';

      //Callout
      wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
        bodyUpsert,
        STA_UtilsStatic.PUT_METHOD,
        methodEndpoint,
        scoringInformations.token,
        recordUpdateList
      );
    }

    if (
      wrapperReturn.response != null &&
      (wrapperReturn.response.getStatusCode() == 200 ||
      wrapperReturn.response.getStatusCode() == 201)
    ) {
      objectLink.scoringExist = true;
    } else {
      objectLink.scoringExist = false;
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method upsertDiscount - END'
    );
    return objectLink;
  }

  public class ObjectLinkDiscountInfrmationToUpsertDiscount {
    public Boolean scoringExist { get; set; }
    public List<String> baIds { get; set; }

    public ObjectLinkDiscountInfrmationToUpsertDiscount() {
      baIds = new List<String>();
    }
  }

  /////////////////////////////////////////////////////// Discount Form V2 ///////////////////////////////////////////////////////

  /**
   * @description : Get List BA Information to display it in a Tab
   * @author Denis PHAM (Modis) | 23/05/2022
   * @return List<SMC_BA_Information__mdt>
   **/
  @AuraEnabled
  public static List<SMC_BA_Information__mdt> getBaInformations()
  {
    return [SELECT MasterLabel, DeveloperName, SMC_BA_ID__c FROM SMC_BA_Information__mdt ORDER BY SMC_BA_ID__c ];
  }

  /**
  * @description : Get scoring from scoring form
  * @author Denis PHAM (Modis) | 23/05/2022
  * @param recId
  * @return SMC_DTO_ScoringForm
  **/
  @AuraEnabled
  public static SMC_DTO_ScoringForm getDiscountInformationsFromDiscountForm_v2(
    String recId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformationsFromDiscountForm_v2 - START'
    );

    SMC_DTO_ScoringForm dtoScoringForm = getDiscountInformations_v2(
      new Set<Id>{ recId },
      true
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformationsFromDiscountForm_v2 - END'
    );
    return dtoScoringForm;
  }

  /**
  * @description : get account informations to get scoring
  * @author Denis PHAM (Modis) | 23/05/2022
  * @param accountId
  * @param isInsert
  * @return SMC_DTO_ScoringForm
  **/
  public static SMC_DTO_ScoringForm getDiscountInformations_v2 (
    Set<Id> accountId,
    Boolean isInsert
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformations_v2 - START'
    );

    List<Account> accounts;
    try {
      accounts = [
        SELECT
          Id,
          Name,
          AccountNumber,
          SMC_Category__c,
          SMC_Business__c,
          SMC_Pricing_Tier__c,
          BillingCountryCode
        FROM Account
        WHERE Id IN :accountId
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR - Account id invalid : ' + e);
      return null;
    }

    Call_Scoring_Domain__mdt callInformations = getHost();

    SMC_DTO_ScoringForm dtoScoringForm = new SMC_DTO_ScoringForm();
    Boolean displayMockOrNot = SMC_AC_Scoring.displayMock();
    if (Test.isRunningTest()) {
      displayMockOrNot = false;
    }
    if (displayMockOrNot == true) {
      dtoScoringForm.token = 'tokenRefresh'; //Fill for MOCK
      if (accounts.size() == 1) {
        dtoScoringForm.account = accounts[0];
      } else {
        dtoScoringForm.account = null;
      }
      dtoScoringForm.accountList = accounts;
      dtoScoringForm.scoringExist = true;
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AC_ScoringForm -> display Mock'
      );
    } else {
      dtoScoringForm.token = UserInfo.getSessionId();
      if (accounts.size() == 1) {
        dtoScoringForm.account = accounts[0];
      } else {
        dtoScoringForm.account = null;
      }
      dtoScoringForm.accountList = accounts;
      dtoScoringForm.urlPartial = callInformations.Domain__c;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ScoringForm -> Method getDiscountInformations_v2 - END'
    );
    return dtoScoringForm;
  }
}