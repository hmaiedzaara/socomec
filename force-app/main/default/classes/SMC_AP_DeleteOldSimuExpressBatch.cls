/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_DeleteOldSimuExpressBatch
-- - Author        : Guillaume BONNET
-- - Description   : A batch so that the simuEpress older than 8 day are deleted.
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  SMC_AP_DeleteOldSimuExpressBatch     1.0      Initial version 
---------------------------------------------------------------------
*/
global without sharing class SMC_AP_DeleteOldSimuExpressBatch extends SMC_AP_BatchesAbstractTemplate {
  global SMC_AP_DeleteOldSimuExpressBatch() {
    super();
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > constructor: after super()'
    );

    Id simuExpressRecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = :STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
      LIMIT 1
    ]
    .Id;
    query =
      'Select Id, LastModifiedDate, OpportunityId, Opportunity.RecordTypeId, Opportunity.SyncedQuoteId from Quote where RecordTypeId = \'' +
      simuExpressRecordTypeId +
      '\' AND LastModifiedDate <= ' +
      Datetime.now().addDays(-7).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

    // Launch check master quote
    query = checkQuotes(query);
    System.debug(LoggingLevel.INFO, 'query : ' + query);
  }

  global SMC_AP_DeleteOldSimuExpressBatch(String overrideQuery) {
    //If you want to used the "checkQuotes" method to set the overrideQuery, you need to run the method before call this constructor
    super(overrideQuery);
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > constructor: after super(overrideQuery)'
    );

    Id simuExpressRecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = :STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
      LIMIT 1
    ]
    .Id;
    query =
      'Select Id, LastModifiedDate, OpportunityId, Opportunity.RecordTypeId, Opportunity.SyncedQuoteId from Quote where RecordTypeId = \'' +
      simuExpressRecordTypeId +
      '\' AND LastModifiedDate <= ' +
      Datetime.now().addDays(-7).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

    //Launch check master quote
    query = checkQuotes(query);
    System.debug(LoggingLevel.INFO, 'query : ' + query);
  }

  // Allow the batch to be executed with a call to this method
  public static void run(String overrideQuery) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > run'
    );
    Database.executeBatch(
      new SMC_AP_DeleteOldSimuExpressBatch(overrideQuery),
      200
    );
    // 2nd argument[Integer] Number of records to be passed into the execute method for batch processing.
  }

  // Allow the Batch to be Schedulable
  global override void execute(SchedulableContext sc) {
    Database.executeBatch(new SMC_AP_DeleteOldSimuExpressBatch(null), 200);
  }

  global override void bypassTriggers() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > bypassTriggers'
    );
    PAD.bypassAll = true;
  }

  global override void processObjects(List<sObject> objects) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > processObjects'
    );
    toBeDeletedList.addAll(objects);
  }

  //Check if quotes to delete are master quote on the opportunity
  @testVisible
  public String checkQuotes(String query) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_DeleteOldSimuExpressBatch > checkQuotes'
    );
    List<Quote> quoteToCheck;
    quoteToCheck = (List<Quote>) Database.query(query);
    Set<Id> opportunityToDelete = new Set<Id>();
    Id simuExpressOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS_OPPORTUNITY)
      .getRecordTypeId();
    for (Quote oneQuote : quoteToCheck) {
      //Check if the opportunity is still a SimuExpress or not
      if (
        oneQuote.Opportunity.RecordTypeId ==
        simuExpressOpportunityRecordTypeId &&
        oneQuote.Id == oneQuote.Opportunity.SyncedQuoteId
      ) {
        opportunityToDelete.add(oneQuote.OpportunityId);
      }
    }

    if (opportunityToDelete.size() > 0) {
      query = 'SELECT Id FROM Opportunity WHERE Id IN (';
      for (Id oneId : opportunityToDelete) {
        query += '\'' + oneId + '\',';
      }
      query = query.substring(0, query.length() - 1) + ')';
    }
    return query;
  }
}