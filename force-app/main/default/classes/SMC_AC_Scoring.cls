/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Scoring
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_Scoring
--
-- Maintenance History:
-- /!\ DISCOUNT = SCORING /!\
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		  1.0      	  Initial Version
-- 23-MAY-2022  Denis PHAM              2.0         GetTheScoring v2
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_Scoring {
  /**
   * @description : get account's scoring
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param accountSerialize
   * @param token
   * @param baIds
   * @return List<SMC_DTO_Scoring>
   **/
  @AuraEnabled(cacheable=false)
  public static List<SMC_DTO_Scoring> getTheScoring(
    String accountSerialize,
    String token,
    List<String> baIds
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method getTheScoring - START'
    );

    Account account = (Account) JSON.deserialize(
      accountSerialize,
      Account.class
    );

    Boolean displayMockOrNot = SMC_AC_Scoring.displayMock();
    if (Test.isRunningTest()) {
      displayMockOrNot = false;
    }

    SMC_DTO_Scoring scoring = new SMC_DTO_Scoring();
    if (displayMockOrNot == true) {
      scoring = (SMC_DTO_Scoring) JSON.deserialize(
        SMC_UTIL_ScoringMockJSONs.GET_ALL_SCORING_MOCK,
        (SMC_DTO_Scoring.class)
      );
    } else {
      // Get url
      Call_Scoring_Domain__mdt callInformations = SMC_AC_ScoringForm.getHost();
      Call_Scoring__mdt scoringGetAllEndpoints = [
        SELECT DeveloperName, Endpoint_Scoring__c
        FROM Call_Scoring__mdt
        WHERE DeveloperName = :STA_UtilsStatic.SCORING_GET_ALL
      ];
      String getEndpoint =
        callInformations.Domain__c + scoringGetAllEndpoints.Endpoint_Scoring__c;

      String body = '[{"account":"' + account.Id + '","baIds":[';
      for (String str : baIds) {
        body += str + ',';
      }
      body = body.substring(0, body.length() - 1) + ']}]';
      List<SMC_DTO_GetAllScoring> getAllScoring = SMC_AP_ScoringCallout.getAllScoring(
        body,
        getEndpoint,
        token,
        new List<String>{ 'AccountId : ' + account.Id }
      );
      /* NEW without filter on BA v */
      for (SMC_DTO_GetAllScoring oneGA : getAllScoring) {
        for(SMC_DTO_Scoring oneSC : oneGA.scorings){
          scoring.scoringLines.addAll(oneSC.scoringLines);
        }
      }
      /* NEW  without filter on BA ^ */
      /* OLD :
      scoring = getAllScoring[0].scorings[0];
      */
    }

    //Sort lines
    scoring.scoringLines.sort();

    SMC_DTO_Scoring scoringShow = new SMC_DTO_Scoring();
    scoringShow = (SMC_DTO_Scoring) JSON.deserialize(
      JSON.serialize(scoring),
      SMC_DTO_Scoring.class
    );

    //Check if the user can see 'Max Suggested' column
    Id profileId = UserInfo.getProfileId();
    Profile userProfile = [
      SELECT Id, Description, Name
      FROM Profile
      WHERE ID = :profileId
    ];

    scoring.userSeeMaxSuggested = false;
    scoringShow.userSeeMaxSuggested = false;

    List<SMC_DTO_Scoring> listScoring = new List<SMC_DTO_Scoring>();
    listScoring.add(scoring);
    listScoring.add(scoringShow);

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method getTheScoring - END'
    );
    return listScoring;
  }

  /**
   * @description : save account scoring
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param scoring
   * @param token
   * @param recordId
   * @return Boolean
   **/
  @AuraEnabled(cacheable=false)
  public static Boolean saveTheScoring(
    String scoring,
    String token,
    String recordId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method saveTheScoring - START'
    );

    Boolean displayMockOrNot = SMC_AC_Scoring.displayMock();
    if (Test.isRunningTest()) {
      displayMockOrNot = false;
    }
    if (displayMockOrNot == true) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AC_Scoring -> Method saveTheScoring - END with MOCK'
      );
      return true;
    }

    String username = UserInfo.getUserName();
    List<SMC_DTO_TheScoringLine> theScoringLines = new List<SMC_DTO_TheScoringLine>();
    SMC_DTO_Scoring realScoring = (SMC_DTO_Scoring) JSON.deserialize(
      scoring,
      (SMC_DTO_Scoring.class)
    );

    for (Integer j = 0; j < realScoring.scoringLines.size(); ++j) {
      if (realScoring.scoringLines[j].isModified == true) {
        theScoringLines.add(
          new SMC_DTO_TheScoringLine(realScoring.scoringLines[j], username)
        );
      }
    }

    /** TEPORAIRE : 20/01/2020 --> Faut mettre un message ou un truc pour signaler que le scoring n'a pas changé **/
    if (theScoringLines.size() == 0) {
      return true;
    }
    /** TEPORAIRE : 20/01/2020 **/

    //Needed to build the JSON as the server ask
    String body = '[';
    for (SMC_DTO_TheScoringLine oneLine : theScoringLines) {
      body +=
        '{"scoringLineId":"' +
        oneLine.scoringLineId +
        '",' +
        '"discount":' +
        oneLine.discount +
        ',' +
        '"maxSuggested":' +
        oneLine.maxSuggested +
        ',';
      body += '"user":"' + oneLine.user + '"},';
    }
    body = body.substring(0, body.length() - 1) + ']';

    // Get url
    Call_Scoring_Domain__mdt callInformations = SMC_AC_ScoringForm.getHost();
    Call_Scoring__mdt scoringGetAllEndpoints = [
      SELECT DeveloperName, Endpoint_Scoring__c
      FROM Call_Scoring__mdt
      WHERE DeveloperName = :STA_UtilsStatic.SCORING_SAVE
    ];
    String saveEndpoint =
      callInformations.Domain__c + scoringGetAllEndpoints.Endpoint_Scoring__c;

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method saveTheScoring - END'
    );
    return SMC_AP_ScoringCallout.saveScoring(
      body,
      saveEndpoint,
      token,
      new List<String>{ 'AccountId : ' + recordId }
    );
  }

  /**
   * @description : display mock against real callout
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Boolean
   **/
  public static Boolean displayMock() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method displayMock - START'
    );

    Call_Scoring__mdt scoringURL = [
      SELECT Label, Call_Mock__c
      FROM Call_Scoring__mdt
      WHERE Label = :STA_UtilsStatic.SCORING_MOCK
    ];

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method displayMock - END'
    );
    return scoringURL.Call_Mock__c;
  }

  /**
   * @description : get account's scoring
   * @author Denis PHAM (Modis) | 24/05/2022
   * @param accountSerialize
   * @param token
   * @param baIds
   * @return List<SMC_DTO_Scoring>
   **/
  @AuraEnabled(cacheable=false)
  public static List<SMC_DTO_Scoring> getTheScoring_v2(
    String accountSerialize,
    String token,
    String baIds
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method getTheScoring_v2 - START'
    );

    Account account = (Account) JSON.deserialize(
      accountSerialize,
      Account.class
    );

    Boolean displayMockOrNot = SMC_AC_Scoring.displayMock();
    if (Test.isRunningTest()) {
      displayMockOrNot = false;
    }

    SMC_DTO_Scoring scoring = new SMC_DTO_Scoring();
    if (displayMockOrNot == true) {
      scoring = (SMC_DTO_Scoring) JSON.deserialize(
        SMC_UTIL_ScoringMockJSONs.GET_SCORING_MOCK,
        (SMC_DTO_Scoring.class)
      );
    } else {
      // Get url
      Call_Scoring_Domain__mdt callInformations = SMC_AC_ScoringForm.getHost();
      
      //Méthode GET dans Custom Metadata
      Call_Scoring__mdt scoringGetEndpoints = [
        SELECT DeveloperName, Endpoint_Scoring__c
        FROM Call_Scoring__mdt
        WHERE DeveloperName = :STA_UtilsStatic.GET_METHOD
      ];
      String getEndpoint =
        callInformations.Domain__c + scoringGetEndpoints.Endpoint_Scoring__c;

      List<Integer> lBaIds = new List<Integer>();
      lBaIds.add(Integer.valueOf(baIds));

      SMC_DTO_GetScoring_Body dtoBody = new SMC_DTO_GetScoring_Body();
      dtoBody.sfdcAccountId =  account.Id;
      dtoBody.category =  account.SMC_Category__c;
      dtoBody.business =  account.SMC_Business__c;
      dtoBody.countryCode =  account.BillingCountryCode;
      dtoBody.tier =  account.SMC_Pricing_Tier__c;
      dtoBody.acc =  account.AccountNumber;
      dtoBody.baIds =  lBaIds;

      String body = JSON.serialize(dtoBody);

      SMC_DTO_GetScoring getAllScoring = SMC_AP_ScoringCallout.getScoring_v2(
        body,
        getEndpoint,
        token,
        new List<String>{ 'AccountId : ' + account.Id }
      );

      if(getAllScoring.scoringLines != null){
          scoring.scoringLines.addAll(getAllScoring.scoringLines);
      }
      
    }

    //Sort lines
    scoring.scoringLines.sort();

    SMC_DTO_Scoring scoringShow = new SMC_DTO_Scoring();
    scoringShow = (SMC_DTO_Scoring) JSON.deserialize(
      JSON.serialize(scoring),
      SMC_DTO_Scoring.class
    );

    //Check if the user can see 'Max Suggested' column
    Id profileId = UserInfo.getProfileId();
    Profile userProfile = [
      SELECT Id, Description, Name
      FROM Profile
      WHERE ID = :profileId
    ];

    scoring.userSeeMaxSuggested = false;
    scoringShow.userSeeMaxSuggested = false;

    List<SMC_DTO_Scoring> listScoring = new List<SMC_DTO_Scoring>();
    listScoring.add(scoring);
    listScoring.add(scoringShow);

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Scoring -> Method getTheScoring_v2 - END'
    );
    return listScoring;
  }

}