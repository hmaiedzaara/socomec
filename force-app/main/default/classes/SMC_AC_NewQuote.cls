/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 09-28-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-01-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public class SMC_AC_NewQuote {
  @AuraEnabled
  public static SMC_DTO_NewQuoteForProject getInformations(String recId) {
    System.debug('>>>>>> SMC_AC_NewQuote : getInformations - START');

    List<PermissionSetAssignment> pasList = new List<PermissionSetAssignment>();
    Boolean hasPermissionSet = false;
    Opportunity opportunity;
    List<Quote> quoteList = new List<Quote>();
    Boolean hasSyncQuote = false;

    try {
      //Get PermissionSet
      hasPermissionSet =
        [
          SELECT Assignee.Id, PermissionSet.Id, PermissionSet.Name
          FROM PermissionSetAssignment
          WHERE
            Assignee.Id = :UserInfo.getUserId()
            AND PermissionSet.Name = :STA_UtilsStatic.ACCESS_MYSOCOMEC_QUOTE
        ]
        .size() > 0;

      //Check if a Quote Master exist
      opportunity = [
        SELECT Id, Name, AccountId, SMC_Primary_Contact__c
        FROM Opportunity
        WHERE Id = :recId
      ];
      quoteList = [
        SELECT Id, OpportunityId, IsSyncing
        FROM Quote
        WHERE OpportunityId = :opportunity.Id AND IsSyncing = true
      ];
    } catch (Exception e) {
      System.debug('ERROR : Check Permissions and Quote Master -> ' + e);
      System.debug('pasList : ' + pasList);
      System.debug('opportunity : ' + opportunity);
      System.debug('quoteList : ' + quoteList);
    }

    if (quoteList.size() > 0) {
      hasSyncQuote = true;
    }

    //Permission set OK
    // if (pasList.size() > 0) {
    if (hasPermissionSet) {
      //Check if current user is partner user
      User currentUser = [
        SELECT Id, FirstName, LastName, ContactId, Contact.AccountId
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
      //Get Opportunity Actors - Accounts & Contacts
      List<SMC_Opportunity_Actors__c> oppActors = [
        SELECT Id, SMC_Account_Linked__c, Contact__c
        FROM SMC_Opportunity_Actors__c
        WHERE SMC_Opportunity_Actors__c = :opportunity.Id
      ];
      List<String> accountList = new List<String>();
      for (SMC_Opportunity_Actors__c oppActor : oppActors) {
        accountList.add(oppActor.SMC_Account_Linked__c);
      }

      //Return all informations
      System.debug('>>>>>> SMC_AC_NewQuote : getInformations - END');
      return new SMC_DTO_NewQuoteForProject(
        true,
        opportunity,
        new List<Account>(
          [
            SELECT
              Id,
              Name,
              BillingCountryCode,
              SMC_Category__c,
              SMC_PCO_Price_List__c
            FROM Account
            WHERE Id = :currentUser.Contact.AccountId
          ]
        ),
        new List<Contact>(
          [
            SELECT
              Id,
              FirstName,
              LastName,
              Name,
              Salutation,
              Email,
              Phone,
              MobilePhone,
              AccountId
            FROM Contact
            WHERE Id = :currentUser.ContactId
          ]
        ),
        null,
        hasSyncQuote,
        new List<User>{ currentUser }
      );
    } else {
      //User hasn't permission
      System.debug(
        '>>>>>> SMC_AC_NewQuote : getInformations - END (without permission)'
      );
      return null;
    }
  }

  @AuraEnabled
  public static String saveNewQuote(
    String recId,
    Quote quote,
    String accountId,
    String contactId,
    String ownerId,
    String reminderPilot,
    Boolean isSync
  ) {
    System.debug('>>>>>> SMC_AC_NewQuote : saveNewQuote - START');

    Opportunity opportunity;
    try {
      opportunity = [
        SELECT Id, Name, AccountId, CloseDate, Probability, SyncedQuoteId
        FROM Opportunity
        WHERE Id = :recId
      ];

      quote.SMC_Account__c = accountId;
      quote.OpportunityId = opportunity.Id;
      quote.OwnerId = UserInfo.getUserId();
      quote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
        .getRecordTypeId();
      quote.SMC_Closing_Date__c = opportunity.CloseDate;
      quote.Status = STA_UtilsStatic.QUOTE_DRAFT;
      quote.SMC_Probability__c = opportunity.Probability;
      if (contactId != STA_UtilsStatic.DEFAULT_PICKLIST_VALUE) {
        quote.ContactId = contactId;
      }
      if (reminderPilot != STA_UtilsStatic.DEFAULT_PICKLIST_VALUE) {
        quote.SMC_Reminder_Pilot__c = reminderPilot;
      }
      insert quote;
    } catch (Exception e) {
      System.debug('ERROR IN saveNewQuote : ' + e);
    }

    if (isSync == true) {
      opportunity.SyncedQuoteId = quote.Id;
      update opportunity;
    }

    System.debug('>>>>>> SMC_AC_NewQuote : saveNewQuote - END');
    return String.valueOf(quote.Id);
  }
}