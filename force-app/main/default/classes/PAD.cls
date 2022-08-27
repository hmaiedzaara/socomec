/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 03-31-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   03-31-2021   Vincent RECASENS (Modis)   Initial Version
**/
public with sharing class PAD {
  private static final Set<String> requiredOnce = new Set<String>{
    'AP123',
    'AP432'
  }; //List of Apex codes that should run only once. Add any code to the list
  private static Set<String> hasRun = new Set<String>(); //List of Apex code that has already been run. Keep this list empty.
  public static final String PAD_BypassTrigger; //List of triggers that can be bypassed
  public static final Boolean PAD_DebugMode { get; set; }
  public static final String userRoleName; //User Role Name
  public static final String userProfileName; //User Profile Name
  public static final String userType; //User Type Name
  public static Set<String> ApexForcedBypass = new Set<String>(); //ex: 'AP123','AP432'//List of Apex codes that need to be bypassed, dynamically and temporaryly managed by Apex Code
  /*
	Usage example. Context : AP05 is not allowing to delete EmailMessage records; when merging cases, we need to remove/create EmailMessage records to the target Case. For this we need to temporary allow deletion, even if the user is not byPassing this rule.
		//Switch during the transaction into AP05 bypass, then revert to the original value
		boolean bCanTriggerAP05=PAD.canTrigger('AP05');
		if(bCanTriggerAP05){ //Remove
			PAD.ApexForcedBypass.add('AP05');
		}
		delete [Select Id from EmailMessage where Id in :mapOldNewParentId.keySet() ];
		if(bCanTriggerAP05){ //restore
			PAD.ApexForcedBypass.remove('AP05');
		}
*/
  public static boolean bypassAll = false; //Can be set by Apex Code to avoid running any logic
  static {
    System.debug(
      LoggingLevel.INFO,
      '## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName()
    );
    User user = [
      SELECT
        UserRole.Name,
        Profile.Name,
        UserPreferencesApexPagesDeveloperMode,
        PAD_BypassTrigger__c,
        TECH_SMC_PAD_Bypass_All_Trigger__c,
        UserType
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    PAD_BypassTrigger = ';' + user.PAD_BypassTrigger__c + ';';
    PAD_DebugMode = user.UserPreferencesApexPagesDeveloperMode;
    userRoleName = user.UserRole.Name;
    userProfileName = user.Profile.Name;
    userType = user.UserType;
    bypassAll = (bypassAll == true ? bypassAll : user.TECH_SMC_PAD_Bypass_All_Trigger__c);
    System.debug(LoggingLevel.INFO, '## >>> PAD constructor : END <<<');
  }
  public static boolean canTrigger(String ApexName) {
    //If no bypass
    if (requiredOnce.contains(ApexName)) {
      //If it should run Once
      if (hasRun.contains(ApexName))
        return false; //Already run, should not run
      hasRun.add(ApexName); //Never run, can run only if not bypassed
    }
    return (PAD_BypassTrigger.indexOf(';' + ApexName + ';') == -1 &&
    !ApexForcedBypass.contains(ApexName) &&
    !bypassAll);
  }
  /**********************
Visual Force part below
***********************/
  public class PAD_log { //One log entry
    public String timer { get; set; }
    public String reason { get; set; }
    public String message { get; set; }
    public String rowCSS { get; set; }
    public PAD_log(String message, String reason) {
      this.timer = DateTime.now().format('HH:mm:ss , SS\'ms\'');
      this.reason = reason;
      this.message = message;
    }
    public PAD_log(String message, String reason, String rowCSS) {
      this.timer = DateTime.now().format('HH:mm:ss , SS\'ms\'');
      this.reason = reason;
      this.message = message;
      this.rowCSS = rowCSS;
    }
  }
  public static Long starter;
  public static List<PAD_log> PAD_logs = new List<PAD_log>();
  public static void startTimer() {
    starter = DateTime.now().getTime();
    log(
      '<img src="/img/icon/custom51_100/stopwatch16.gif" width="16px" height="16px"'
    );
  }
  private static final integer MAX_LOG_SIZE = 1000;
  public static void stopTimer() {
    if (starter != null)
      log(
        '<img src="/img/icon/custom51_100/stopwatch16.gif" width="16px" height="16px" /><i> ' +
        String.ValueOf(DateTime.now().getTime() - starter) +
        ' ms</i>'
      );
  }
  public static void log(String message, String reason, String rowColor) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(message, reason, rowColor));
  }
  public static void log(String message, String reason) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(message, reason));
  }
  public static void log(String message) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(message, ''));
  }
  public static void log(Integer message) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(String.valueOf(message), ''));
  }
  public static void log(Integer message, String reason) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(String.valueOf(message), reason));
  }
  public static void log(Integer message, Integer reason) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(
        new PAD_log(String.valueOf(message), String.valueOf(reason))
      );
  }
  public static void log(String message, Integer reason) {
    if (PAD_logs.size() < MAX_LOG_SIZE)
      PAD_logs.add(new PAD_log(message, String.valueOf(reason)));
  }
  @TestVisible
  private static String myColor(Integer myFrom, Integer myTo) {
    Decimal myPercent = (myFrom + 0.0) / (myTo + 0.0001);
    String ret = 'font-weight:bold;';
    if (myPercent >= 0.8)
      ret += 'background-color:#B22222;color:white;';
    else if (myPercent >= 0.5)
      ret += 'background-color:#FF7F00;color:white;';
    return ret;
  }
  public static void limits() {
    log(
      Limits.getAggregateQueries() +
      ' / ' +
      Limits.getLimitAggregateQueries(),
      'AggregateQueries',
      myColor(Limits.getAggregateQueries(), Limits.getLimitAggregateQueries())
    );
    log(
      Limits.getAsyncCalls() +
      ' / ' +
      Limits.getLimitAsyncCalls(),
      'Async Calls',
      myColor(Limits.getAsyncCalls(), Limits.getLimitAsyncCalls())
    );
    log(
      Limits.getCallouts() +
      ' / ' +
      Limits.getLimitCallouts(),
      'Callouts',
      myColor(Limits.getCallouts(), Limits.getLimitCallouts())
    );
    log(
      Limits.getCpuTime() +
      ' / ' +
      Limits.getLimitCpuTime(),
      'CPU Time',
      myColor(Limits.getCpuTime(), Limits.getLimitCpuTime())
    );
    log(
      Limits.getDMLRows() +
      ' / ' +
      Limits.getLimitDMLRows(),
      'DML Rows',
      myColor(Limits.getDMLRows(), Limits.getLimitDMLRows())
    );
    log(
      Limits.getDMLStatements() +
      ' / ' +
      Limits.getLimitDMLStatements(),
      'DML Statements',
      myColor(Limits.getDMLStatements(), Limits.getLimitDMLStatements())
    );
    log(
      Limits.getEmailInvocations() +
      ' / ' +
      Limits.getLimitEmailInvocations(),
      'Email Invocations',
      myColor(Limits.getEmailInvocations(), Limits.getLimitEmailInvocations())
    );
    log(
      Limits.getFindSimilarCalls() +
      ' / ' +
      Limits.getLimitFindSimilarCalls(),
      'FindSimilarCalls',
      myColor(Limits.getFindSimilarCalls(), Limits.getLimitFindSimilarCalls())
    );
    log(
      Limits.getFutureCalls() +
      ' / ' +
      Limits.getLimitFutureCalls(),
      'Future Calls',
      myColor(Limits.getFutureCalls(), Limits.getLimitFutureCalls())
    );
    log(
      Limits.getHeapSize() +
      ' / ' +
      Limits.getLimitHeapSize(),
      'Heap Size',
      myColor(Limits.getHeapSize(), Limits.getLimitHeapSize())
    );
    log(
      Limits.getMobilePushApexCalls() +
      ' / ' +
      Limits.getLimitMobilePushApexCalls(),
      'MobilePushApexCalls',
      myColor(
        Limits.getMobilePushApexCalls(),
        Limits.getLimitMobilePushApexCalls()
      )
    );
    log(
      Limits.getQueries() +
      ' / ' +
      Limits.getLimitQueries(),
      'Queries',
      myColor(Limits.getQueries(), Limits.getLimitQueries())
    );
    log(
      Limits.getQueryLocatorRows() +
      ' / ' +
      Limits.getLimitQueryLocatorRows(),
      'QueryLocator Rows',
      myColor(Limits.getQueryLocatorRows(), Limits.getLimitQueryLocatorRows())
    );
    log(
      Limits.getQueryRows() +
      ' / ' +
      Limits.getLimitQueryRows(),
      'Query Rows',
      myColor(Limits.getQueryRows(), Limits.getLimitQueryRows())
    );
    log(
      Limits.getQueueableJobs() +
      ' / ' +
      Limits.getLimitQueueableJobs(),
      'Queueable Jobs',
      myColor(Limits.getQueueableJobs(), Limits.getLimitQueueableJobs())
    );
    log(
      Limits.getRunAs() +
      ' / ' +
      Limits.getLimitRunAs(),
      'RunAs',
      myColor(Limits.getRunAs(), Limits.getLimitRunAs())
    );
    log(
      Limits.getSavepointRollbacks() +
      ' / ' +
      Limits.getLimitSavepointRollbacks(),
      'Savepoint Rollbacks',
      myColor(
        Limits.getSavepointRollbacks(),
        Limits.getLimitSavepointRollbacks()
      )
    );
    log(
      Limits.getSavepoints() +
      ' / ' +
      Limits.getLimitSavepoints(),
      'Savepoints',
      myColor(Limits.getSavepoints(), Limits.getLimitSavepoints())
    );
    log(
      Limits.getSoslQueries() +
      ' / ' +
      Limits.getLimitSoslQueries(),
      'Sosl Queries',
      myColor(Limits.getSoslQueries(), Limits.getLimitSoslQueries())
    );
  }
  public List<PAD_log> getPAD_logs() {
    return PAD_logs;
  }
}