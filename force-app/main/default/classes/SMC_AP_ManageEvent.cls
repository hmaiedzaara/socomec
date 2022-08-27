/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageEvent
-- - Author        : David SOBCZAK (DOS) / Vincent RECASENS (VRE)
-- - Description   : Manage Event               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 20-NOV-2019  VRE    1.3     Fill new Contact field on Event
-- 18-SEP-2019  VRE    1.2     Exclude event without WhoId for Location/Desc populate
-- 06-JUI-2018  VRE    1.2     Add Accompanied by management
-- 23-Aug-2017  DOS    1.1     Add Accompanied by management
-- 31-Mai-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public without sharing class SMC_AP_ManageEvent {
  public static Map<Id, EventRelation> eventRelationOnUpdate { get; set; }
  public static Map<Id, EventRelation> eventParentIdToEventRelation {
    get;
    set;
  }
  public static Map<Id, Event> eventRelentionEventIdToEventParent { get; set; }

  /**
   * @description : prevent link Event with account type : GroupConsolidated
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param eventsToCheck
   **/
  // DPHA - Removed after the deletion of the RT RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED_DEVNAME on the Account
  // public static void isParentAccountGroupConsolidated(
  //   List<Event> eventsToCheck
  // ) {
  //   List<Id> relatedAccountId = new List<Id>();
  //   for (Event elem : eventsToCheck) {
  //     relatedAccountId.add(elem.WhatId);
  //   }

  //   Map<ID, Account> relatedAccount = new Map<ID, Account>(
  //     [SELECT Id, RecordTypeId FROM Account WHERE Id IN :relatedAccountId]
  //   );

  //   Id groupConsolidatedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  //     .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED_DEVNAME)
  //     .getRecordTypeId();

  //   for (Event elem : eventsToCheck) {
  //     if (
  //       relatedAccount.get(elem.WhatId) != null &&
  //       relatedAccount.get(elem.WhatId).RecordTypeId ==
  //       groupConsolidatedRecordTypeId
  //     ) {
  //       elem.addError(
  //         String.escapeSingleQuotes(
  //           System.Label.SMC_GroupConsolidatedCantBeLinkToEvent
  //         ),
  //         true
  //       );
  //     }
  //   }
  // }

  /**
  * @description : populate Event Location with Contact's or Lead's address
  /!\ we use @future method because there is a bug concerning lightning and whoId field
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param p_ids   
  **/
  // @future
  // public static void populateEvntLocationWithRelatedAddress_Future(Set<Id> p_ids) {
  //   List<Event> p_events = new List<Event>(
  //     [
  //       SELECT Id, WhoId, Location
  //       FROM Event
  //       WHERE Id IN :p_ids AND WhoId != null
  //     ]
  //   );
  //   // Get list ids of event's main contact /lead
  //   List<Id> lContactIds = new List<Id>();
  //   List<Id> lLeadIds = new List<Id>();
  //   for (Event e : p_events) {
  //     // DOS - condition obsolete car ajoute dans la query 18/09/2019
  //     if (e.WhoId != null) {
  //       if (e.WhoId.getSObjectType() == Contact.sObjectType) {
  //         lContactIds.add(e.WhoId);
  //       } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
  //         lLeadIds.add(e.WhoId);
  //       }
  //     }
  //   }

  //   // Get main contact of events
  //   Map<ID, Contact> mContacts = getContactFromListWhoId(lContactIds);

  //   // Get main lead of events
  //   Map<ID, Lead> mLeads = getLeadFromListWhoId(lLeadIds);

  //   List<Event> evntsToUpdate = new List<Event>();
  //   // Iterate on all events
  //   for (Event e : p_events) {
  //     if (e.WhoId != null && e.Location == null) {
  //       String relatedAddress = STA_UtilsStatic.EMPTY_STRING;
  //       // If related name of event is Contact, get concatenate contact mailing address
  //       if (e.WhoId.getSObjectType() == Contact.sObjectType) {
  //         if (mContacts.containsKey(e.WhoId)) {
  //           relatedAddress = getAddressPlainText(mContacts.get(e.WhoId));
  //         }
  //       } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
  //         // If related name of event is Lead, get concatenate lead address
  //         if (mLeads.containsKey(e.WhoId)) {
  //           relatedAddress = getAddressPlainText(mLeads.get(e.WhoId));
  //         }
  //       }
  //       // We change event.location by related address only if address is not empty
  //       if (!String.isBlank(relatedAddress)) {
  //         // If mailing address is longer than maxlength of event's location use a substring
  //         if (
  //           relatedAddress.length() > SObjectType.Event.Fields.Location.Length
  //         ) {
  //           relatedAddress = relatedAddress.substring(
  //             0,
  //             SObjectType.Event.Fields.Location.Length
  //           );
  //         }
  //         // Update event location
  //         e.location = relatedAddress;
  //         evntsToUpdate.add(e);
  //       }
  //     }
  //   }

  //   // Bulk update event
  //   if (evntsToUpdate.size() > 0) {
  //     update evntsToUpdate;
  //   }
  // }

  /**
  * @description : populate Event Location with Contact's or Lead's address
  /!\ we use @future method because there is a bug concerning lightning and whoId field
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param p_ids   
  **/
  public static void populateEvntLocationWithRelatedAddress(
    List<Event> p_events
  ) {
    // Get list ids of event's main contact /lead
    List<Id> lContactIds = new List<Id>();
    List<Id> lLeadIds = new List<Id>();
    for (Event e : p_events) {
      // DOS - condition obsolete car ajoute dans la query 18/09/2019
      if (e.WhoId != null) {
        if (e.WhoId.getSObjectType() == Contact.sObjectType) {
          lContactIds.add(e.WhoId);
        } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
          lLeadIds.add(e.WhoId);
        }
      }
    }

    // Get main contact of events
    Map<ID, Contact> mContacts = getContactFromListWhoId(lContactIds);

    // Get main lead of events
    Map<ID, Lead> mLeads = getLeadFromListWhoId(lLeadIds);

    // Iterate on all events
    for (Event e : p_events) {
      if (e.WhoId != null && (e.Location == null || e.Location == '')) {
        String relatedAddress = STA_UtilsStatic.EMPTY_STRING;
        // If related name of event is Contact, get concatenate contact mailing address
        if (e.WhoId.getSObjectType() == Contact.sObjectType) {
          if (mContacts.containsKey(e.WhoId)) {
            relatedAddress = getAddressPlainText(mContacts.get(e.WhoId));
          }
        } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
          // If related name of event is Lead, get concatenate lead address
          if (mLeads.containsKey(e.WhoId)) {
            relatedAddress = getAddressPlainText(mLeads.get(e.WhoId));
          }
        }

        // We change event.location by related address only if address is not empty
        if (!String.isBlank(relatedAddress)) {
          // If mailing address is longer than maxlength of event's location use a substring
          if (
            relatedAddress.length() > SObjectType.Event.Fields.Location.Length
          ) {
            relatedAddress = relatedAddress.substring(
              0,
              SObjectType.Event.Fields.Location.Length
            );
          }
          // Update event location
          e.location = relatedAddress;
        }
      }
    }
  }

  /**
   * @description : get opportunity.account informations from Event.WhaId
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param whatIds
   * @return Map<Id, Contact>
   **/
  @TestVisible
  private static Map<Id, Opportunity> getAccountFromListOppId(List<Id> whaIds) {
    // Get main contact of events
    return new Map<ID, Opportunity>(
      [
        SELECT Id, Account.Name, Account.Phone
        FROM Opportunity
        WHERE Id IN :whaIds
      ]
    );
  }

  /**
   * @description : get contact from Event.WhoId
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param whoIds
   * @return Map<Id, Contact>
   **/
  @TestVisible
  private static Map<Id, Contact> getContactFromListWhoId(List<Id> whoIds) {
    // Get main contact of events
    return new Map<ID, Contact>(
      [
        SELECT
          Id,
          Name,
          MailingStreet,
          MailingPostalCode,
          MailingCity,
          MailingState,
          MailingCountry,
          OtherStreet,
          OtherPostalCode,
          OtherCity,
          OtherState,
          OtherCountry,
          Phone,
          MobilePhone,
          Account.Name,
          Account.Phone
        FROM Contact
        WHERE Id IN :whoIds
      ]
    );
  }

  /**
   * @description : get lead from Event.WhoId
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param whoIds
   * @return Map<Id, Lead>
   **/
  @TestVisible
  private static Map<Id, Lead> getLeadFromListWhoId(List<Id> whoIds) {
    return new Map<ID, Lead>(
      [
        SELECT
          Id,
          Name,
          Street,
          PostalCode,
          City,
          State,
          Country,
          Company,
          Phone
        FROM Lead
        WHERE Id IN :whoIds
      ]
    );
  }
  //

  @TestVisible
  private static Map<Id, Account> getAccountFromListWhatId(List<Id> whatIds) {
    return new Map<ID, Account>(
      [SELECT Id, Name FROM Account WHERE Id IN :whatIds]
    );
  }

  @TestVisible
  private static Map<Id, Account> getAccountFromListAccountId(
    List<Id> accountIds
  ) {
    return new Map<ID, Account>(
      [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
    );
  }

  /**
  * @description : populate Event Description with information concerning objects related
  /!\ we use @future method because there is a bug concerning lightning and whoId field (https://developer.salesforce.com/forums/?id=906F000000091zgIAA)
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param p_ids   
  **/
  // @future
  // public static void populateEvntDescription_Future(Set<Id> p_ids) {
  //   List<Event> p_events = new List<Event>(
  //     [
  //       SELECT Id, Owner.Name, WhoId, EventWhoIds, Description
  //       FROM Event
  //       WHERE Id IN :p_ids AND WhoId != null
  //     ]
  //   );
  //   List<EventRelation> eventRelations = new List<EventRelation>(
  //     [
  //       SELECT Id, EventId, RelationId
  //       FROM EventRelation
  //       WHERE EventId IN :p_ids
  //     ]
  //   );
  //   // eventRelations = [SELECT Id, EventId, RelationId FROM EventRelation WHERE EventId IN :p_ids];
  //   // Get list ids of event's contacts /lead
  //   List<Id> lContactIds = new List<Id>();
  //   List<Id> lLeadIds = new List<Id>();
  //   for (Event e : p_events) {
  //     // DOS - Workaround (use List<Id> instead directly EventWhoIds) concerning EventWhoIds which not working in Test Class context
  //     List<Id> lEventWhoIds = getEventWhoIds(e);
  //     if (!lEventWhoIds.isEmpty()) {
  //       if (lEventWhoIds.get(0).getSObjectType() == Contact.sObjectType) {
  //         lContactIds.addAll(lEventWhoIds);
  //       } else if (lEventWhoIds.get(0).getSObjectType() == Lead.sObjectType) {
  //         lLeadIds.addAll(lEventWhoIds);
  //       }
  //     }
  //   }

  //   // Get event's contacts
  //   Map<ID, Contact> mContacts = getContactFromListWhoId(lContactIds);

  //   // Get event's leads
  //   Map<ID, Lead> mLeads = getLeadFromListWhoId(lLeadIds);

  //   List<Event> evntsToUpdate = new List<Event>();

  //   // Iterate on all events
  //   for (Event e : p_events) {
  //     String DescriptionMainContact = STA_UtilsStatic.EMPTY_STRING;
  //     String DescriptionOthersContact = STA_UtilsStatic.EMPTY_STRING;
  //     // DOS - Add Pilot Information
  //     String DescriptionPilot = STA_UtilsStatic.EMPTY_STRING;
  //     // DOS - Workaround (use List<Id> instead directly EventWhoIds) concerning EventWhoIds which not working in Test Class context
  //     List<Id> lEventWhoIds = getEventWhoIds(e);

  //     // If whoIds is not empty we iterate on every related object in order to catch information concerning contacts / lead
  //     if (!lEventWhoIds.isEmpty()) {
  //       for (Id i : lEventWhoIds) {
  //         // If it's the main whoId we store his information with his company
  //         if (i == e.WhoId) {
  //           // If related name of event is Contact, get Company information of the contact + Contact information
  //           if (i.getSObjectType() == Contact.sObjectType) {
  //             if (mContacts.containsKey(i)) {
  //               DescriptionMainContact =
  //                 DescriptionMainContact +
  //                 SObjectType.Account.getLabel() +
  //                 ' : ' +
  //                 getAccountInformationFromContact(mContacts.get(i)) +
  //                 '\n';
  //               DescriptionMainContact =
  //                 DescriptionMainContact +
  //                 SObjectType.Contact.getLabel() +
  //                 ' : ' +
  //                 getContactInformation(mContacts.get(i)) +
  //                 '\n';
  //             }
  //           } else if (i.getSObjectType() == Lead.sObjectType) {
  //             // If related name of event is Lead, get lead information
  //             if (mLeads.containsKey(i)) {
  //               DescriptionMainContact =
  //                 DescriptionMainContact +
  //                 SObjectType.Contact.getLabel() +
  //                 ' : ' +
  //                 getLeadInformation(mLeads.get(i)) +
  //                 '\n';
  //             }
  //           }
  //         } else {
  //           // Else it's others contact
  //           if (i.getSObjectType() == Contact.sObjectType) {
  //             if (mContacts.containsKey(i)) {
  //               DescriptionOthersContact =
  //                 DescriptionOthersContact +
  //                 getContactInformation(mContacts.get(i)) +
  //                 '\n';
  //             }
  //           }
  //         }
  //       }
  //     }

  //     EventRelation theEventRelation;
  //     for (EventRelation oneEventRelation : eventRelations) {
  //       if (e.Id == oneEventRelation.EventId) {
  //         theEventRelation = oneEventRelation;
  //       }
  //     }

  //     // DOS - Add pilot information
  //     if (theEventRelation != null) {
  //       DescriptionPilot = e.Owner.Name;
  //     }

  //     // If we have retrieve
  //     if (
  //       !String.isBlank(DescriptionMainContact) ||
  //       !String.isBlank(DescriptionOthersContact) ||
  //       !String.isBlank(DescriptionPilot)
  //     ) {
  //       // Concatenate all values cocerning descriptions
  //       String Description = STA_UtilsStatic.EMPTY_STRING;
  //       if (e.Description != null) {
  //         Description = e.Description;
  //       }
  //       if (!String.isBlank(Description)) {
  //         Description = Description + '\n-----\n';
  //       }
  //       if (!String.isBlank(DescriptionMainContact)) {
  //         Description = Description + DescriptionMainContact;
  //       }
  //       if (!String.isBlank(DescriptionOthersContact)) {
  //         Description =
  //           Description +
  //           SObjectType.Contact.getLabelPlural() +
  //           ' : \n' +
  //           DescriptionOthersContact;
  //       }
  //       if (!String.isBlank(DescriptionPilot)) {
  //         Description =
  //           Description +
  //           Schema.Event.fields.OwnerId.getDescribe().getLabel() +
  //           ' : ' +
  //           DescriptionPilot;
  //       }

  //       // If Description is longer than maxlength of event's description use a substring
  //       if (
  //         Description.length() > SObjectType.Event.Fields.Description.Length
  //       ) {
  //         Description = Description.substring(
  //           0,
  //           SObjectType.Event.Fields.Description.Length
  //         );
  //       }
  //       // Update event description and add it inside list of event's update
  //       e.Description = Description;
  //       evntsToUpdate.add(e);
  //     }
  //   }
  //   update evntsToUpdate;
  // }

  /**
  * @description : populate Event Description with information concerning objects related
  /!\ we use @future method because there is a bug concerning lightning and whoId field (https://developer.salesforce.com/forums/?id=906F000000091zgIAA)
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param p_ids   
  **/
  public static void populateEvntDescription(List<event> p_events) {
    Set<Id> ids = new Set<Id>();
    for (Event onevenet : p_events) {
      ids.add(onevenet.Id);
    }
    List<EventRelation> eventRelations = new List<EventRelation>(
      [SELECT Id, EventId, RelationId FROM EventRelation WHERE EventId IN :ids]
    );
    // eventRelations = [SELECT Id, EventId, RelationId FROM EventRelation WHERE EventId IN :p_ids];
    // Get list ids of event's contacts /lead
    List<Id> lContactIds = new List<Id>();
    List<Id> lLeadIds = new List<Id>();
    for (Event e : p_events) {
      // DOS - Workaround (use List<Id> instead directly EventWhoIds) concerning EventWhoIds which not working in Test Class context
      List<Id> lEventWhoIds = getEventWhoIds(e);
      if (!lEventWhoIds.isEmpty()) {
        if (lEventWhoIds.get(0).getSObjectType() == Contact.sObjectType) {
          lContactIds.addAll(lEventWhoIds);
        } else if (lEventWhoIds.get(0).getSObjectType() == Lead.sObjectType) {
          lLeadIds.addAll(lEventWhoIds);
        }
      }
    }

    // Get event's contacts
    Map<ID, Contact> mContacts = getContactFromListWhoId(lContactIds);

    // Get event's leads
    Map<ID, Lead> mLeads = getLeadFromListWhoId(lLeadIds);

    List<Event> evntsToUpdate = new List<Event>();

    // Iterate on all events
    for (Event e : p_events) {
      String DescriptionMainContact = STA_UtilsStatic.EMPTY_STRING;
      String DescriptionOthersContact = STA_UtilsStatic.EMPTY_STRING;
      // DOS - Add Pilot Information
      String DescriptionPilot = STA_UtilsStatic.EMPTY_STRING;
      // DOS - Workaround (use List<Id> instead directly EventWhoIds) concerning EventWhoIds which not working in Test Class context
      List<Id> lEventWhoIds = getEventWhoIds(e);

      // If whoIds is not empty we iterate on every related object in order to catch information concerning contacts / lead
      if (!lEventWhoIds.isEmpty()) {
        for (Id i : lEventWhoIds) {
          // If it's the main whoId we store his information with his company
          if (i == e.WhoId) {
            // If related name of event is Contact, get Company information of the contact + Contact information
            if (i.getSObjectType() == Contact.sObjectType) {
              if (mContacts.containsKey(i)) {
                DescriptionMainContact =
                  DescriptionMainContact +
                  SObjectType.Account.getLabel() +
                  ' : ' +
                  getAccountInformationFromContact(mContacts.get(i)) +
                  '\n';
                DescriptionMainContact =
                  DescriptionMainContact +
                  SObjectType.Contact.getLabel() +
                  ' : ' +
                  getContactInformation(mContacts.get(i)) +
                  '\n';
              }
            } else if (i.getSObjectType() == Lead.sObjectType) {
              // If related name of event is Lead, get lead information
              if (mLeads.containsKey(i)) {
                DescriptionMainContact =
                  DescriptionMainContact +
                  SObjectType.Contact.getLabel() +
                  ' : ' +
                  getLeadInformation(mLeads.get(i)) +
                  '\n';
              }
            }
          } else {
            // Else it's others contact
            if (i.getSObjectType() == Contact.sObjectType) {
              if (mContacts.containsKey(i)) {
                DescriptionOthersContact =
                  DescriptionOthersContact +
                  getContactInformation(mContacts.get(i)) +
                  '\n';
              }
            }
          }
        }
      }

      EventRelation theEventRelation;
      for (EventRelation oneEventRelation : eventRelations) {
        if (e.Id == oneEventRelation.EventId) {
          theEventRelation = oneEventRelation;
        }
      }

      // DOS - Add pilot information
      if (theEventRelation != null) {
        DescriptionPilot = e.Owner.Name;
      }

      // If we have retrieve
      if (
        !String.isBlank(DescriptionMainContact) ||
        !String.isBlank(DescriptionOthersContact) ||
        !String.isBlank(DescriptionPilot)
      ) {
        // Concatenate all values cocerning descriptions
        String Description = STA_UtilsStatic.EMPTY_STRING;
        if (e.Description != null) {
          Description = e.Description;
        }
        if (!String.isBlank(Description)) {
          Description = Description + '\n-----\n';
        }
        if (!String.isBlank(DescriptionMainContact)) {
          Description = Description + DescriptionMainContact;
        }
        if (!String.isBlank(DescriptionOthersContact)) {
          Description =
            Description +
            SObjectType.Contact.getLabelPlural() +
            ' : \n' +
            DescriptionOthersContact;
        }
        if (!String.isBlank(DescriptionPilot)) {
          Description =
            Description +
            Schema.Event.fields.OwnerId.getDescribe().getLabel() +
            ' : ' +
            DescriptionPilot;
        }

        // If Description is longer than maxlength of event's description use a substring
        if (
          Description.length() > SObjectType.Event.Fields.Description.Length
        ) {
          Description = Description.substring(
            0,
            SObjectType.Event.Fields.Description.Length
          );
        }
        // Update event description and add it inside list of event's update
        e.Description = Description;
        evntsToUpdate.add(e);
      }
    }
  }

  /**
   * @description : notify pilot on event insert or delete
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @param isInsertion
   **/
  public static void managePilotNotificationInsertOrDelete(
    Map<Id, Event> p_events,
    Boolean isInsertion
  ) {
    // Container for notif operation
    // Because triggerUserEmail not working with lightning https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Database_EmailHeader.htm
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );

    for (Event oneEvent : p_events.values()) {
      if (oneEvent.CreatedById != oneEvent.OwnerId) {
        batchInputs.add(
          getEventChatterNotif(
            (isInsertion
              ? STA_UtilsStatic.EVENT_NOTIF_REQUEST
              : STA_UtilsStatic.EVENT_NOTIF_CANCELLED),
            oneEvent,
            oneEvent.OwnerId,
            (isInsertion ? true : false),
            mapEventSummaryInformtion
          )
        );
      }
    }

    // Send chatter only if no test (ConnectApi dont support test without seealldata)
    if (
      !Test.isRunningTest() &&
      UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
    ) {
      ConnectApi.ChatterFeeds.postFeedElementBatch(
        Network.getNetworkId(),
        batchInputs
      );
    }
  }

  /**
   * @description : notify pilot on event update
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @param oldMap
   **/
  public static void managePilotNotificationUpdate(
    Map<Id, Event> p_events,
    Map<Id, Event> oldMap
  ) {
    // Container for notif operation
    // Because triggerUserEmail not working with lightning https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Database_EmailHeader.htm
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );

    List<String> recordIdsForLog = new List<String>();
    for (Event oneEvent : p_events.values()) {
      Event oldEvent = oldMap.get(oneEvent.Id);
      //Register for log
      recordIdsForLog.add(oneEvent.Id);
      //Process
      if (
        oneEvent.LastModifiedById != oneEvent.OwnerId &&
        ((oneEvent.LastModifiedDate.getTime() -
        oneEvent.CreatedDate.getTime()) > 3000) &&
        (oneEvent.Subject != oldEvent.Subject ||
        oneEvent.AccountId != oldEvent.AccountId ||
        oneEvent.WhoId != oldEvent.WhoId ||
        oneEvent.Location != oldEvent.Location ||
        oneEvent.StartDateTime != oldEvent.StartDateTime ||
        oneEvent.EndDateTime != oldEvent.EndDateTime)
      ) {
        batchInputs.add(
          getEventChatterNotif(
            STA_UtilsStatic.EVENT_NOTIF_UPDATE,
            oneEvent,
            oneEvent.OwnerId,
            true,
            mapEventSummaryInformtion
          )
        );
      }
    }

    // Send chatter only if no test (ConnectApi dont support test without seealldata)
    try {
      if (
        !Test.isRunningTest() &&
        UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
      ) {
        ConnectApi.ChatterFeeds.postFeedElementBatch(
          Network.getNetworkId(),
          batchInputs
        );
      }
    } catch (Exception e) {
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Event - Pilot Notification On Update',
        null,
        'The query is not a query, but it is the StackTrace of the Exception.',
        e.getStackTraceString(),
        recordIdsForLog
      );
    }
  }

  /**
   * @description : if the field "Accompanied By" is filling we put user like an invitee
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   **/
  public static void manageAccompaniedByInviteeOnInsert(
    Map<Id, Event> p_events
  ) {
    // Container for notif operation
    // Because triggerUserEmail not working with lightning https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Database_EmailHeader.htm
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );
    /* *
     * If is a parent event we send update child event by eventrelation and notify users
     * else if it's a child event we send notification inform accompnied person that it's forbidden to edit child event
     * and we recreate the child event with parent value
     * */
    for (EventRelation oneEventRelation : [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId IN :p_events.keySet()
    ]) {
      Event theEvent = p_events.get(oneEventRelation.EventId);
      if (!theEvent.IsChild) {
        batchInputs.add(
          getEventChatterNotif(
            STA_UtilsStatic.EVENT_NOTIF_REQUEST,
            theEvent,
            oneEventRelation.RelationId,
            true,
            mapEventSummaryInformtion
          )
        );
      }
    }

    // Send chatter only if no test (ConnectApi dont support test without seealldata)
    if (
      !Test.isRunningTest() &&
      UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
    ) {
      ConnectApi.ChatterFeeds.postFeedElementBatch(
        Network.getNetworkId(),
        batchInputs
      );
    }
  }

  /**
   * @description : if the field "Accompanied By" is updated we put new user like an invitee and remove the previous
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @param p_old_events
   **/
  public static void manageAccompaniedByInviteeOnUpdate(
    Map<Id, Event> p_events,
    Map<Id, Event> p_old_events
  ) {
    // Container for dml operation
    Map<String, EventRelation> evntRelationMap = getEventRelationMap(
      p_events.values()
    );
    // Container for notif operation
    // Because triggerUserEmail not working with lightning https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Database_EmailHeader.htm
    Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    // FIX SFDC4OUTLOOK - Need to keep information from parent event when child event is update from outlook
    Map<String, Event> p_parent_events = getParentEvents(p_events.values());
    Map<String, EventRelation> evntRelationParentMap = getEventRelationMap(
      p_parent_events.values()
    );
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );

    /* *
     * Iterate on all events
     * If is a parent event we send update child event by eventrelation and notify users
     * else if it's a child event we send notification inform accompnied person that it's forbidden to edit child event
     * and we recreate the child event with parent value
     * */
    eventRelentionEventIdToEventParent = new Map<Id, Event>();
    for (Event newEvent : p_events.values()) {
      // Parent event case
      if (newEvent.isChild) {
        Event parentEvent = p_parent_events.get(
          newEvent.SMC_Activity_CRM_ID__c
        );
        EventRelation eventRelationParent = eventParentIdToEventRelation.get(
          parentEvent.Id
        );
        eventRelentionEventIdToEventParent.put(
          eventRelationParent.EventId,
          parentEvent
        );
        if (
          parentEvent != null &&
          evntRelationParentMap != null &&
          evntRelationParentMap.containsKey(
            String.valueOf(parentEvent.Id) +
            String.valueOf(eventRelationParent.RelationId)
          )
        ) {
          System.debug(
            LoggingLevel.WARN,
            '## >>> SMC_AP_ManageEvent - Child Event Update Problem ##'
          );
          System.debug(
            LoggingLevel.WARN,
            '## >>> SMC_AP_ManageEvent - Parent Event ' +
            JSON.serializePretty(parentEvent) +
            ' ##'
          );
          System.debug(
            LoggingLevel.WARN,
            '## >>> SMC_AP_ManageEvent - Child Event ' +
            JSON.serializePretty(newEvent) +
            ' ##'
          );
          if (
            parentEvent.Subject != newEvent.Subject ||
            parentEvent.StartDateTime != newEvent.StartDateTime ||
            parentEvent.EndDateTime != newEvent.EndDateTime ||
            parentEvent.Location != newEvent.Location ||
            (parentEvent.Description != null &&
            parentEvent.Description.replace(
              '\r',
              STA_UtilsStatic.EMPTY_STRING
            ) != newEvent.Description) ||
            (parentEvent.Description == null &&
            parentEvent.Description != newEvent.Description)
          ) {
            mails.add(
              getEventEmailNotif(
                STA_UtilsStatic.EVENT_CHILD_NOT_UPDATED_TITLE,
                parentEvent,
                newEvent.OwnerId,
                STA_UtilsStatic.EVENT_CHILD_NOT_UPDATED_CONTENT,
                mapEventSummaryInformtion
              )
            );
          }
        }
      }
    }
    // Send chatter only if no test (ConnectApi dont support test without seealldata)
    if (
      !Test.isRunningTest() &&
      UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
    ) {
      ConnectApi.ChatterFeeds.postFeedElementBatch(
        Network.getNetworkId(),
        batchInputs
      );
    }
    Messaging.sendEmail(mails);
  }

  /**
   * @description : manage event relation after event update
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   **/
  public static void checkEventRelationAfterUpdate(Map<Id, Event> p_events) {
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );

    Map<Id, EventRelation> eventRelationAll = new Map<Id, EventRelation>();
    Map<Id, EventRelation> eventRelationUpdated = new Map<Id, EventRelation>();
    Map<Id, EventRelation> eventRelationNew = new Map<Id, EventRelation>();
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    for (EventRelation actualEventRelation : [
      SELECT Id, EventId, Event.CreatedDate, RelationId, CreatedDate
      FROM EventRelation
      WHERE EventId IN :p_events.keySet()
    ]) {
      Event parentEvent;
      if (eventRelentionEventIdToEventParent.size() > 0) {
        parentEvent = eventRelentionEventIdToEventParent.get(
          actualEventRelation.EventId
        );
      } else {
        parentEvent = p_events.get(actualEventRelation.EventId);
      }
      if (
        actualEventRelation.CreatedDate == actualEventRelation.Event.CreatedDate
      ) {
        eventRelationUpdated.put(actualEventRelation.Id, actualEventRelation);
        batchInputs.add(
          getEventChatterNotif(
            STA_UtilsStatic.EVENT_NOTIF_UPDATE,
            parentEvent,
            actualEventRelation.RelationId,
            true,
            mapEventSummaryInformtion
          )
        );
      } else {
        eventRelationNew.put(actualEventRelation.Id, actualEventRelation);
        batchInputs.add(
          getEventChatterNotif(
            STA_UtilsStatic.EVENT_NOTIF_REQUEST,
            parentEvent,
            actualEventRelation.RelationId,
            true,
            mapEventSummaryInformtion
          )
        );
      }
      eventRelationAll.put(actualEventRelation.Id, actualEventRelation);
    }

    for (EventRelation actualEventRelation : eventRelationOnUpdate.values()) {
      Event parentEvent;
      if (eventRelentionEventIdToEventParent.size() > 0) {
        parentEvent = eventRelentionEventIdToEventParent.get(
          actualEventRelation.EventId
        );
      } else {
        parentEvent = p_events.get(actualEventRelation.EventId);
      }
      if (!eventRelationAll.keySet().contains(actualEventRelation.Id)) {
        batchInputs.add(
          getEventChatterNotif(
            STA_UtilsStatic.EVENT_NOTIF_CANCELLED,
            parentEvent,
            actualEventRelation.RelationId,
            false,
            mapEventSummaryInformtion
          )
        );
      }
    }

    if (
      !Test.isRunningTest() &&
      UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
    ) {
      ConnectApi.ChatterFeeds.postFeedElementBatch(
        Network.getNetworkId(),
        batchInputs
      );
    }

    fixEventsWhenEventChildIsUpdate(
      eventRelentionEventIdToEventParent.keySet()
    );
  }

  /**
   * @description : manage event when event child is updated
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param parentEventIdsToFix
   **/
  @Future
  public static void fixEventsWhenEventChildIsUpdate(
    Set<Id> parentEventIdsToFix
  ) {
    update [SELECT Id FROM Event WHERE Id IN :parentEventIdsToFix];
  }

  //If the field "Accompanied By" is filling we put user like an invitee
  public static void manageAccompaniedByInviteeOnDelete(
    Map<Id, Event> p_events
  ) {
    // Container for dml operation
    // Container for notif operation
    // Because triggerUserEmail not working with lightning https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Database_EmailHeader.htm
    Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

    // FIX SFDC4OUTLOOK - Need to keep information from parent event when child event is update from outlook
    Map<String, Event> p_parent_events = getParentEvents(p_events.values());
    Map<String, EventRelation> evntRelationParentMap;
    if (p_parent_events.size() > 0) {
      evntRelationParentMap = getEventRelationMap(p_parent_events.values());
    } else {
      evntRelationParentMap = getEventRelationMap(p_events.values());
    }
    //Get information for mail/post summary information
    Map<Id, EventSummaryInformations> mapEventSummaryInformtion = getInformationsForEventsSummary(
      p_events
    );

    /* *
     * Iterate on all events
     * If is a parent event we send cancelled notification to the accompanied by user
     * else if it's a child event we send notification inform accompnied person that it's forbidden to edit child event
     * and we recreate the child event with parent value
     * */
    Map<Id, Event> mapParentEvents = new Map<Id, Event>();
    for (Event newEvent : p_events.values()) {
      if (!newEvent.isChild) {
        try {
          EventRelation eventRelationParent = eventParentIdToEventRelation.get(
            newEvent.Id
          );
          if (eventRelationParent.RelationId != null) {
            batchInputs.add(
              getEventChatterNotif(
                STA_UtilsStatic.EVENT_NOTIF_CANCELLED,
                newEvent,
                eventRelationParent.RelationId,
                false,
                mapEventSummaryInformtion
              )
            );
          }
        } catch (Exception e) {
          System.debug(
            LoggingLevel.INFO,
            'There is an issue with the synchronization between Outlook and Salesforce, vut it is manage in this try-catch block.'
          );
          System.debug(
            LoggingLevel.INFO,
            'Outlook win every synchronization, so if you want to declined an invitation to an event, please do this via Outlook.'
          );
          System.debug(LoggingLevel.INFO, 'Error message : ' + e);
        }
      } else {
        Event parentEvent = p_parent_events.get(
          newEvent.SMC_Activity_CRM_ID__c
        );
        EventRelation eventRelationParent = eventParentIdToEventRelation.get(
          parentEvent.Id
        );
        System.debug(
          LoggingLevel.WARN,
          '## >>> SMC_AP_ManageEvent - Child Event Update Problem ##'
        );
        System.debug(
          LoggingLevel.WARN,
          '## >>> SMC_AP_ManageEvent - Parent Event ' +
          JSON.serializePretty(parentEvent) +
          ' ##'
        );
        System.debug(
          LoggingLevel.WARN,
          '## >>> SMC_AP_ManageEvent - Child Event ' +
          JSON.serializePretty(newEvent) +
          ' ##'
        );
        mails.add(
          getEventEmailNotif(
            STA_UtilsStatic.EVENT_NOTIF_DECLINED_TITLE,
            parentEvent,
            parentEvent.OwnerId,
            UserInfo.getUserName() +
            STA_UtilsStatic.EVENT_NOTIF_DECLINED_BY +
            newEvent.Subject,
            mapEventSummaryInformtion
          )
        );
      }
    }
    // Bulk dml eventRelation
    // Send chatter only if no test (ConnectApi dont support test without seealldata)
    if (
      !Test.isRunningTest() &&
      UserInfo.getUserType() != STA_UtilsStatic.AUTOMATED_PROCESS
    ) {
      ConnectApi.ChatterFeeds.postFeedElementBatch(
        Network.getNetworkId(),
        batchInputs
      );
    }
    Messaging.sendEmail(mails);
  }

  /**
   * @description : get lead address in plain text format
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param l
   * @return String
   **/
  @TestVisible
  private static String getAddressPlainText(Lead l) {
    String addressPlainText =
      (l.Street != null ? l.Street + ' ' : STA_UtilsStatic.EMPTY_STRING) +
      (l.PostalCode != null
        ? l.PostalCode + ' '
        : STA_UtilsStatic.EMPTY_STRING) +
      (l.City != null ? l.City + ' ' : STA_UtilsStatic.EMPTY_STRING) +
      (l.State != null ? l.State + ' ' : STA_UtilsStatic.EMPTY_STRING) +
      (l.Country != null ? l.Country : STA_UtilsStatic.EMPTY_STRING);
    if (!String.isBlank(addressPlainText)) {
      addressPlainText = addressPlainText.trim();
      // If mailing address is longer than maxlength of event's location use a substring
      if (
        addressPlainText.length() > SObjectType.Event.Fields.Location.Length
      ) {
        addressPlainText = addressPlainText.substring(
          0,
          SObjectType.Event.Fields.Location.Length
        );
      }
    }
    return getAddressPlainTextFormatToEventLocation(addressPlainText);
  }

  /**
   * @description : get contact address in plain text format
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param c
   * @return String
   **/
  @TestVisible
  private static String getAddressPlainText(Contact c) {
    String addressPlainText = STA_UtilsStatic.EMPTY_STRING;
    // else we take the mailing address
    if (c.MailingStreet != null || c.MailingCity != null) {
      addressPlainText =
        (c.MailingStreet != null
          ? c.MailingStreet + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.MailingPostalCode != null
          ? c.MailingPostalCode + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.MailingCity != null
          ? c.MailingCity + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.MailingState != null
          ? c.MailingState + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.MailingCountry != null
          ? c.MailingCountry
          : STA_UtilsStatic.EMPTY_STRING);
    } else {
      // If other address is filled we take this
      addressPlainText =
        (c.OtherStreet != null
          ? c.OtherStreet + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.OtherPostalCode != null
          ? c.OtherPostalCode + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.OtherCity != null
          ? c.OtherCity + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.OtherState != null
          ? c.OtherState + ' '
          : STA_UtilsStatic.EMPTY_STRING) +
        (c.OtherCountry != null
          ? c.OtherCountry
          : STA_UtilsStatic.EMPTY_STRING);
    }
    return getAddressPlainTextFormatToEventLocation(addressPlainText);
  }

  /**
   * @description : get address plain text with the format adapted to event location field
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param a
   * @return String
   **/
  @TestVisible
  private static String getAddressPlainTextFormatToEventLocation(String a) {
    if (!String.isBlank(a)) {
      a = a.trim();
      // If mailing address is longer than maxlength of event's location use a substring
      if (a.length() > SObjectType.Event.Fields.Location.Length) {
        a = a.substring(0, SObjectType.Event.Fields.Location.Length);
      }
    }
    return a;
  }

  /**
   * @description : get account information from a contact
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param c
   * @return String
   **/
  @TestVisible
  private static String getAccountInformationFromContact(Contact c) {
    String accountInformation =
      (c.Account.Name != null
        ? c.Account.Name + ' - '
        : STA_UtilsStatic.EMPTY_STRING) +
      (c.Account.Phone != null
        ? c.Account.Phone
        : STA_UtilsStatic.EMPTY_STRING);
    return accountInformation;
  }

  /**
   * @description : get contact information
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param c
   * @return String
   **/
  @TestVisible
  private static String getContactInformation(Contact c) {
    String contactInformation =
      (c.Name != null ? c.Name + ' - ' : STA_UtilsStatic.EMPTY_STRING) +
      (c.MobilePhone != null
        ? c.MobilePhone + ' '
        : STA_UtilsStatic.EMPTY_STRING) +
      (c.Phone != null ? '/ ' + c.Phone : STA_UtilsStatic.EMPTY_STRING);
    return contactInformation;
  }

  /**
   * @description : get lead information
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param l
   * @return String
   **/
  @TestVisible
  private static String getLeadInformation(Lead l) {
    String leadInformation =
      (l.Company != null ? l.Company + ' - ' : STA_UtilsStatic.EMPTY_STRING) +
      (l.Name != null ? l.Name + ' ' : STA_UtilsStatic.EMPTY_STRING) +
      (l.Phone != null ? '(' + l.Phone + ')' : STA_UtilsStatic.EMPTY_STRING);
    return leadInformation;
  }

  /**
   * @description : get list of WhoIds taking consideration bug with eventWhoIds fields in test class
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param e
   * @return List<Id>
   **/
  @TestVisible
  private static List<Id> getEventWhoIds(Event e) {
    // DOS - Workaround (use List<Id> instead directly EventWhoIds) concerning EventWhoIds which not working in Test Class context
    List<Id> lEventWhoIds = new List<Id>();
    if (!e.EventWhoIds.isEmpty()) {
      lEventWhoIds.addAll(e.EventWhoIds);
    } else if (e.WhoId != null) {
      lEventWhoIds.add(e.WhoId);
    }
    // DOS - Workaround end
    return lEventWhoIds;
  }

  /**
   * @description : return content of chatter notif when there is
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param title
   * @param e
   * @param userId
   * @param isLinkedToEvent
   * @param eventsSummaryInformations
   * @return ConnectApi.BatchInput
   **/
  @TestVisible
  private static ConnectApi.BatchInput getEventChatterNotif(
    String title,
    Event e,
    Id userId,
    boolean isLinkedToEvent,
    Map<Id, EventSummaryInformations> eventsSummaryInformations
  ) {
    // We use ConnectApi instead of dml operation because for it's mandatory to use @mention
    // Initiate var mandatory to send chatter post by ConnectApi
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

    // Link the post to a context (event or user)
    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    if (isLinkedToEvent) {
      feedItemInput.subjectId = e.Id;
    } else {
      feedItemInput.subjectId = userId;
    }

    // Generate post content
    // Add @mention to the user
    mentionSegmentInput.id = userId;
    messageBodyInput.messageSegments.add(mentionSegmentInput);
    // Add text after the mention
    textSegmentInput.text =
      STA_UtilsStatic.LINE_BREAK +
      title +
      getEventSummary(e, eventsSummaryInformations);
    messageBodyInput.messageSegments.add(textSegmentInput);
    feedItemInput.body = messageBodyInput;

    return new ConnectApi.BatchInput(feedItemInput);
  }

  /**
   * @description : create email message which use to notify accompanied
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param title
   * @param e
   * @param userId
   * @param text
   * @param eventsSummaryInformations
   * @return Messaging.SingleEmailMessage
   **/
  @TestVisible
  private static Messaging.SingleEmailMessage getEventEmailNotif(
    String title,
    Event e,
    Id userId,
    String text,
    Map<Id, EventSummaryInformations> eventsSummaryInformations
  ) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    // Assign user to which you are sending the email.
    mail.setTargetObjectId(userId);
    // Email is assigned to user so it can't be save like an activity
    mail.setSaveAsActivity(false);
    // Specify the address used when the recipients reply to the email.
    mail.setReplyTo(STA_UtilsStatic.NOREPLY_EMAIL);
    // Specify the name used as the display name.
    mail.setSenderDisplayName(STA_UtilsStatic.NOREPLY_EMAIL_NAME);
    // Set to True if you want to BCC yourself on the email.
    mail.setBccSender(false);
    // Optionally append the salesforce.com email signature to the email.
    // The email address of the user executing the Apex Code will be used.
    mail.setUseSignature(false);
    // Specify the subject line for your email address.
    mail.setSubject(title);
    // Specify the text content of the email.
    mail.setPlainTextBody(
      getEventSummary(e, eventsSummaryInformations) +
      STA_UtilsStatic.LINE_BREAK +
      STA_UtilsStatic.LINE_BREAK +
      text
    );
    return mail;
  }

  /**
   * @description : get all informations from account and contact/lead for event summary
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @return Map<Id, EventSummaryInformations>
   **/
  @TestVisible
  private static Map<Id, EventSummaryInformations> getInformationsForEventsSummary(
    Map<Id, Event> p_events
  ) {
    //Get Account and Contact/Lead infos
    List<Id> lAccountIds = new List<Id>();
    List<Id> lOppIds = new List<Id>();
    List<Id> lContactIds = new List<Id>();
    List<Id> lLeadIds = new List<Id>();
    for (Event e : p_events.values()) {
      if (
        e.AccountId != null &&
        (e.WhatId == null ||
        e.WhatId.getSObjectType() != Opportunity.sObjectType)
      ) {
        lAccountIds.add(e.AccountId);
      } else if (
        e.WhatId != null &&
        e.WhatId.getSObjectType() == Opportunity.sObjectType
      ) {
        lOppIds.add(e.WhatId);
      }
      // if (e.AccountId != null) {
      //   lAccountIds.add(e.AccountId);
      // }
      if (e.WhoId != null) {
        if (e.WhoId.getSObjectType() == Contact.sObjectType) {
          lContactIds.add(e.WhoId);
        } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
          lLeadIds.add(e.WhoId);
        }
      }
    }

    Map<ID, Account> mAccounts = new Map<Id, Account>();
    if (lAccountIds != null && lAccountIds.size() > 0) {
      mAccounts = getAccountFromListAccountId(lAccountIds);
    }
    // Temp
    // Map<ID, Opportunity> mOpps;
    // if (lOppIds.size() > 0) {
    //   mOpps = getAccountFromListOppId(lOppIds);
    // }
    // Temp
    Map<ID, Contact> mContacts = getContactFromListWhoId(lContactIds);
    Map<ID, Lead> mLeads = getLeadFromListWhoId(lLeadIds);

    Map<Id, String> mapEventIdToTxtLocation = new Map<Id, String>();
    Map<Id, EventSummaryInformations> mapEventIdToInformationsSummary = new Map<Id, EventSummaryInformations>();
    for (Event e : p_events.values()) {
      mapEventIdToInformationsSummary.put(e.Id, new EventSummaryInformations());
      //Account Name
      if (lOppIds.size() > 0) {
        mapEventIdToInformationsSummary.get(e.Id)
          .accountName = getAccountInformationFromContact(
          mContacts.get(e.WhoId)
        );
      } else if (mAccounts != null && mAccounts.containsKey(e.AccountId)) {
        mapEventIdToInformationsSummary.get(e.Id).accountName = mAccounts.get(
            e.AccountId
          )
          .Name;
      }
      // else if (mOpps != null && mOpps.containsKey(e.WhatId)) {
      //   mapEventIdToInformationsSummary.get(e.Id).accountName = mOpps.get(
      //       e.WhatId
      //     )
      //     .Account.Name;
      // }

      //WhoName
      if (e.WhoId != null) {
        if (mContacts.containsKey(e.WhoId)) {
          mapEventIdToInformationsSummary.get(e.Id).whoName = mContacts.get(
              e.WhoId
            )
            .Name;
          //Location
          if (e.Location == null) {
            mapEventIdToInformationsSummary.get(e.Id)
              .eventLocation = getAddressPlainText(mContacts.get(e.WhoId));
          }
        } else if (mLeads.containsKey(e.WhoId)) {
          mapEventIdToInformationsSummary.get(e.Id).whoName = mLeads.get(
              e.WhoId
            )
            .Name;
          //Location
          if (e.Location == null) {
            mapEventIdToInformationsSummary.get(e.Id)
              .eventLocation = getAddressPlainText(mLeads.get(e.WhoId));
          }
        }
      }
    }
    return mapEventIdToInformationsSummary;
  }

  /**
   * @description : build event summary
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param e
   * @param eventsSummaryInformations
   * @return String
   **/
  @TestVisible
  private static String getEventSummary(
    Event e,
    Map<Id, EventSummaryInformations> eventsSummaryInformations
  ) {
    if (
      eventsSummaryInformations == null ||
      eventsSummaryInformations.get(e.Id) == null
    ) {
      System.debug(
        LoggingLevel.INFO,
        'getEventSummary : "eventsSummaryInformations" is null.'
      );
      return getEventSummary(e);
    }

    //Subject
    String eventSummary =
      STA_UtilsStatic.LINE_BREAK +
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.SUBJECT)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.Subject) +
      STA_UtilsStatic.LINE_BREAK;

    //Account
    if (eventsSummaryInformations.get(e.Id).accountName != null) {
      String relatedToIdLabel =
        STA_UtilsStatic.ACCOUNT +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE;
      eventSummary +=
        STA_UtilsStatic.ACCOUNT +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        String.valueOf(eventsSummaryInformations.get(e.Id).accountName) +
        STA_UtilsStatic.LINE_BREAK;
    }

    //Contact/Lead
    if (e.WhoId != null) {
      String contactNameLabel = Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.WHO_ID)
        .getDescribe()
        .getLabel();
      eventSummary +=
        contactNameLabel.substring(0, contactNameLabel.length() - 5) +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        String.valueOf(eventsSummaryInformations.get(e.Id).whoName) +
        STA_UtilsStatic.LINE_BREAK;
    }

    //Location
    if (e.Location != null) {
      eventSummary =
        eventSummary +
        Schema.getGlobalDescribe()
          .get(STA_UtilsStatic.EVENT)
          .getDescribe()
          .fields.getMap()
          .get(STA_UtilsStatic.LOCATION)
          .getDescribe()
          .getLabel() +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        String.valueOf(e.Location) +
        STA_UtilsStatic.LINE_BREAK;
    } else if (
      e.WhoId != null &&
      eventsSummaryInformations.get(e.Id).eventLocation != null
    ) {
      //Location from WhoId if no Location filled
      eventSummary =
        eventSummary +
        Schema.getGlobalDescribe()
          .get(STA_UtilsStatic.EVENT)
          .getDescribe()
          .fields.getMap()
          .get(STA_UtilsStatic.LOCATION)
          .getDescribe()
          .getLabel() +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        String.valueOf(eventsSummaryInformations.get(e.Id).eventLocation) +
        STA_UtilsStatic.LINE_BREAK;
    }

    eventSummary +=
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.START_DATETIME)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.StartDateTime) +
      STA_UtilsStatic.LINE_BREAK +
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.END_DATETIME)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.EndDateTime);

    return eventSummary;
  }

  /**
   * @description : build event summary (old version). Used if some informations on contact/lead is not present
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param e
   * @return String
   **/
  @TestVisible
  private static String getEventSummary(Event e) {
    String eventSummary =
      STA_UtilsStatic.LINE_BREAK +
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.SUBJECT)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.Subject) +
      STA_UtilsStatic.LINE_BREAK;

    // DOS -> (Workaround) on creation the location autofill by contact address is asynchrone because there is a problem with lightning and whoid field
    // cf. function populateEvntLocationWithRelatedAddress
    if (e.Location != null) {
      eventSummary =
        eventSummary +
        STA_UtilsStatic.LINE_BREAK +
        Schema.getGlobalDescribe()
          .get(STA_UtilsStatic.EVENT)
          .getDescribe()
          .fields.getMap()
          .get(STA_UtilsStatic.LOCATION)
          .getDescribe()
          .getLabel() +
        STA_UtilsStatic.COLON +
        STA_UtilsStatic.SPACE +
        String.valueOf(e.Location);
    }

    eventSummary +=
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.START_DATETIME)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.StartDateTime) +
      STA_UtilsStatic.LINE_BREAK +
      Schema.getGlobalDescribe()
        .get(STA_UtilsStatic.EVENT)
        .getDescribe()
        .fields.getMap()
        .get(STA_UtilsStatic.END_DATETIME)
        .getDescribe()
        .getLabel() +
      STA_UtilsStatic.COLON +
      STA_UtilsStatic.SPACE +
      String.valueOf(e.EndDateTime);

    return eventSummary;
  }

  /**
   * @description : get EventRelation from an event list
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @return Map<String, EventRelation>
   **/
  @TestVisible
  private static Map<String, EventRelation> getEventRelationMap(
    List<Event> p_events
  ) {
    Map<String, EventRelation> eventRelationMap = new Map<String, EventRelation>();
    eventRelationOnUpdate = new Map<Id, EventRelation>();
    eventParentIdToEventRelation = new Map<Id, EventRelation>();
    // The map key must be concatenation between eventId and userId in order to allow to find directely the relation from an event
    for (EventRelation eventRelation : [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId IN :p_events
    ]) {
      eventRelationMap.put(
        String.valueOf(eventRelation.EventId) +
        String.valueOf(eventRelation.RelationId),
        eventRelation
      );
      eventRelationOnUpdate.put(eventRelation.Id, eventRelation);
      eventParentIdToEventRelation.put(eventRelation.EventId, eventRelation);
    }
    return eventRelationMap;
  }

  /**
   * @description : generate a new eventRelation record
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_eventId
   * @param p_relationId
   * @return EventRelation
   **/
  @TestVisible
  private static EventRelation getNewEventRelation(
    Id p_eventId,
    Id p_relationId
  ) {
    EventRelation er = new EventRelation();
    er.EventId = p_eventId;
    er.RelationId = p_relationId;
    return er;
  }

  /**
   * @description : get all parents event related to child events existing in param event list
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_events
   * @return Map<String, Event>
   **/
  @TestVisible
  private static Map<String, Event> getParentEvents(List<Event> p_events) {
    // Get Activity_CRM_Id from child event
    List<String> activityChildCrmIds = new List<string>();
    for (Event e : p_events) {
      if (e.isChild && e.SMC_Activity_CRM_ID__c != null) {
        activityChildCrmIds.add(e.SMC_Activity_CRM_ID__c);
      }
    }
    // Get parent event in a map with CRM_id for key because it's the only link between child and parent
    // HOTFIX-DOS 31/03/2020 add temporary limit to solve sync outlook problem
    Map<String, Event> parentEvents = new Map<String, Event>();
    for (Event parentEvent : [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild,
        OwnerId
      FROM Event
      WHERE isChild = false AND SMC_Activity_CRM_ID__c IN :activityChildCrmIds
    ]) {
      if (!parentEvents.containsKey(parentEvent.SMC_Activity_CRM_ID__c)) {
        parentEvents.put(parentEvent.SMC_Activity_CRM_ID__c, parentEvent);
      }
    }
    return parentEvents;
  }

  /**
   * @description : fill SMC_ContactId__c whit Event.WhoId
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void fillContactFieldWithWhoId(
    List<Event> newList,
    Map<Id, Event> oldMap
  ) {
    //Insert
    if (oldMap == null) {
      for (Event oneEvent : newList) {
        if (
          oneEvent.WhoId != null &&
          oneEvent.WhoId.getSobjectType() == Schema.Contact.SObjectType
        ) {
          oneEvent.SMC_ContactId__c = oneEvent.WhoId;
        }
      }
    } else {
      //Update
      for (Event oneEvent : newList) {
        if (
          oneEvent.WhoId != null &&
          oneEvent.WhoId != oldMap.get(oneEvent.Id).WhoId &&
          oneEvent.WhoId.getSobjectType() == Schema.Contact.SObjectType
        ) {
          oneEvent.SMC_ContactId__c = oneEvent.WhoId;
        } else if (
          oneEvent.WhoId != null &&
          oneEvent.WhoId != oldMap.get(oneEvent.Id).WhoId &&
          oneEvent.WhoId.getSobjectType() != Schema.Contact.SObjectType
        ) {
          oneEvent.SMC_ContactId__c = null;
        }
      }
    }
  }

  public class EventSummaryInformations {
    String accountName { get; set; }
    String whoName { get; set; }
    String eventLocation { get; set; }

    public EventSummaryInformations() {
    }
  }
}