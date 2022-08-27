/**
 * @File Name          : SMC_AC_Tab_Event.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-19-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    22/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public without sharing class SMC_AC_Tab_Event {
  public class WrapperColumnUnit {
    @TestVisible
    String label;
    @TestVisible
    String fieldName;
    @TestVisible
    String type;
    @TestVisible
    WrapeprColumnTypeAttribute typeAttributes;
    @TestVisible
    Boolean sortable;

    public WrapperColumnUnit(
      String label,
      String fieldName,
      String type,
      Boolean sortable
    ) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
      this.sortable = sortable;
    }

    public WrapperColumnUnit(
      String label,
      String fieldName,
      String type,
      WrapeprColumnTypeAttribute typeAttributes,
      Boolean sortable
    ) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
      this.typeAttributes = typeAttributes;
      this.sortable = sortable;
    }
  }

  //Used to format hyperlink for Name/Subject field
  public class WrapeprColumnTypeAttribute {
    @TestVisible
    WrapeprColumnTypeAttributeLabelObject label;
    @TestVisible
    String target;

    public WrapeprColumnTypeAttribute(String fieldName) {
      this.label = new WrapeprColumnTypeAttributeLabelObject(fieldName);
      this.target = '_blank';
    }
  }
  //Used to format hyperlink for Name/Subject field
  public class WrapeprColumnTypeAttributeLabelObject {
    @TestVisible
    String fieldName;

    public WrapeprColumnTypeAttributeLabelObject(String fieldName) {
      this.fieldName = fieldName;
    }
  }

  public class WrapperUnit {
    //Tech fields
    @TestVisible
    Id id;
    //Fields displayed
    @TestVisible
    String subject;
    @TestVisible
    String subjectUrl;
    @TestVisible
    Datetime startDate;
    @TestVisible
    Id whatId;
    @TestVisible
    String whatName { get; set; }
    @TestVisible
    Id whoId;
    @TestVisible
    String whoName { get; set; }
    @TestVisible
    String roundZone;
    @TestVisible
    String postalCode { get; set; }
    @TestVisible
    String city { get; set; }
    @TestVisible
    String visitFollowUp;

    public WrapperUnit() {
    }

    public WrapperUnit(
      //Tech fields
      Id id,
      //Fields displayed
      String subject,
      Datetime startDate,
      Id whoId,
      Id whatId,
      String roundZone,
      String visitFollowUp
    ) {
      this.id = id;
      this.subject = subject;
      this.subjectUrl = '/lightning/r/Event/' + id + '/view';
      this.startDate = startDate;
      this.whoId = whoId;
      this.whatId = whatId;
      this.roundZone = roundZone;
      this.visitFollowUp = visitFollowUp;
    }
  }

  public class WrapperList {
    @TestVisible
    List<WrapperUnit> datas;
    @TestVisible
    List<WrapperColumnUnit> columns;

    public WrapperList() {
      this.datas = new List<WrapperUnit>();
      this.columns = new List<WrapperColumnUnit>();
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Subject,
          'subjectUrl',
          'url',
          new WrapeprColumnTypeAttribute('subject'),
          true
        )
      );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Start_Date,
          'startDate',
          'date',
          true
        )
      );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Related_To,
          'whatName',
          'text',
          true
        )
      );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Contact_Name,
          'whoName',
          'text',
          true
        )
      );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Round_Zone,
          'roundZone',
          'text',
          true
        )
      );
      // this.columns.add(
      //   new WrapperColumnUnit(
      //     System.Label.SMC_Address,
      //     'location',
      //     'string',
      //     false
      //   )
      // );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Postal_Code,
          'postalCode',
          'text',
          true
        )
      );
      this.columns.add(
        new WrapperColumnUnit(System.Label.SMC_City, 'city', 'text', true)
      );
      this.columns.add(
        new WrapperColumnUnit(
          System.Label.SMC_Visite_Follow_Up,
          'visiteFollowUp',
          'text',
          false
        )
      );
    }
  }

  /**
   * @description : get List<CalendarName>
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @return Map<Id, String>
   **/
  @AuraEnabled
  public static Map<Id, String> getCalendars() {
    Map<String, Id> mapNamesIds = new Map<String, Id>();
    List<String> keyToSort = new List<String>();
    for (Calendar oneCalendar : [
      SELECT Id, Name
      FROM Calendar
      WHERE Name LIKE :(STA_UtilsStatic.SCHEDULE_MEETING_CALENDAR_NAME + '%')
    ]) {
      keyToSort.add(oneCalendar.Name);
      mapNamesIds.put(oneCalendar.Name, oneCalendar.Id);
    }
    keyToSort.sort();

    Map<Id, String> mapIdNames = new Map<Id, String>();
    for (String oneKey : keyToSort) {
      mapIdNames.put(mapNamesIds.get(oneKey), oneKey);
    }
    return mapIdNames;
  }

  /**
   * @description : get events informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param offsetSize
   * @param offset
   * @param queryContactName
   * @param selectedCalendar
   * @return String
   **/
  @AuraEnabled(cacheable=false)
  public static String getEventInformations(
    Integer offsetSize,
    Integer offset,
    String queryAccountName,
    String queryContactName,
    String queryStartDate,
    String queryEndDate,
    String selectedCalendar
  ) {
    //Get event
    WrapperList resultList = new WrapperList();
    Set<Id> whatAccountIds = new Set<Id>();
    Set<Id> whoContactIds = new Set<Id>();
    Set<Id> whoLeadIds = new Set<Id>();

    /* SET QUERY TERMS */
    // Account term
    queryAccountName = ((queryAccountName != null &&
      queryAccountName != '')
      ? (' AND What.Name LIKE \'%' + queryAccountName + '%\'')
      : '');
    // Contact term
    queryContactName = ((queryContactName != null &&
      queryContactName != '')
      ? (' AND Who.Name LIKE \'%' + queryContactName + '%\'')
      : '');
    // Dates
    Date startdateQuery;
    Date enddateQuery;
    Datetime startdatetimeQuery;
    Datetime enddatetimeQuery;
    if (queryStartDate != null) {
      startdateQuery = Date.valueOf(queryStartDate + ' 00:00:00');
      startdatetimeQuery = DateTime.newInstance(
        startdateQuery.year(),
        startdateQuery.month(),
        startdateQuery.day()
      );
    }
    if (queryEndDate != null) {
      enddateQuery = Date.valueOf(queryEndDate + ' 00:00:00');
      enddatetimeQuery = DateTime.newInstance(
        enddateQuery.year(),
        enddateQuery.month(),
        enddateQuery.day() + 1
      );
    }

    /* SET QUERY DATE */
    String queryDate = '';
    if (startdateQuery != null && enddatetimeQuery != null) {
      queryDate = ' AND StartDateTime >= :startdateQuery AND EndDateTime <= :enddatetimeQuery';
    } else if (startdateQuery != null && enddatetimeQuery == null) {
      queryDate = ' AND StartDateTime >= :startdateQuery';
    } else if (startdateQuery == null && enddatetimeQuery != null) {
      queryDate = ' AND EndDateTime <= :enddatetimeQuery';
    }
    /* SET QUERY */
    String query =
      'SELECT Id, Subject, StartDateTime, WhatId, WhoId, SMC_Account_Round_Zone__c, SMC_Visit_Follow_up__c FROM Event WHERE SMC_Calendar__c = \'' +
      selectedCalendar +
      '\'' +
      queryAccountName +
      queryContactName +
      queryDate +
      ' LIMIT :offsetSize OFFSET :offset';

    /* EXECUTE QUERY */
    try {
      for (Event oneEvent : (List<Event>) Database.query(query)) {
        resultList.datas.add(
          new WrapperUnit(
            oneEvent.Id,
            oneEvent.Subject,
            oneEvent.StartDateTime,
            oneEvent.WhoId,
            oneEvent.WhatId,
            oneEvent.SMC_Account_Round_Zone__c,
            oneEvent.SMC_Visit_Follow_up__c
          )
        );
        //What Id
        if (
          oneEvent.WhatId != null &&
          oneEvent.WhatId.getSObjectType() == Schema.Account.SObjectType
        ) {
          whatAccountIds.add(oneEvent.WhatId);
        }
        //Who Id - Contact
        if (
          oneEvent.WhoId != null &&
          oneEvent.WhoId.getSObjectType() == Schema.Contact.SObjectType
        ) {
          whoContactIds.add(oneEvent.WhoId);
        } else if (
          oneEvent.WhoId != null &&
          oneEvent.WhoId.getSObjectType() == Schema.Lead.SObjectType
        ) {
          //Who Id - Lead
          whoLeadIds.add(oneEvent.WhoId);
        }
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
    }

    //Get AccountName = RelatedToName
    if (whatAccountIds.size() > 0) {
      resultList = getAccountName(whatAccountIds, resultList);
    }
    //Get WhoName / PostalCode / City
    if (whoContactIds.size() > 0) {
      resultList = getContactInformations(whoContactIds, resultList);
    }
    //Get WhoName / PostalCode / City
    if (whoLeadIds.size() > 0) {
      resultList = getLeadInformations(whoLeadIds, resultList);
    }

    return JSON.serialize(resultList);
  }

  /**
   * @description : get WhatName from Account
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param whatIds
   * @param resultList
   * @return WrapperList
   **/
  @TestVisible
  private static WrapperList getAccountName(
    Set<Id> whatIds,
    WrapperList resultList
  ) {
    //Get Account name
    Map<Id, String> eventIdToAccountName = new Map<Id, String>();
    for (Account oneAccount : [
      SELECT Id, Name
      FROM Account
      WHERE Id IN :whatIds
    ]) {
      eventIdToAccountName.put(oneAccount.Id, oneAccount.Name);
    }

    //Set datas
    for (WrapperUnit oneWrapperUnit : resultList.datas) {
      if (eventIdToAccountName.get(oneWrapperUnit.whatId) != null) {
        oneWrapperUnit.whatName = eventIdToAccountName.get(
          oneWrapperUnit.whatId
        );
      }
    }
    return resultList;
  }

  /**
   * @description : get WhoName from contact
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param whoContactIds
   * @param resultList
   * @return WrapperList
   **/
  @TestVisible
  private static WrapperList getContactInformations(
    Set<Id> whoContactIds,
    WrapperList resultList
  ) {
    //Get Contact infos
    Map<Id, Contact> eventIdToContact = new Map<Id, Contact>();
    for (Contact oneContact : [
      SELECT Id, Name, MailingPostalCode, MailingCity
      FROM Contact
      WHERE Id IN :whoContactIds
    ]) {
      eventIdToContact.put(oneContact.Id, oneContact);
    }
    //Set datas
    for (WrapperUnit oneWrapperUnit : resultList.datas) {
      if (eventIdToContact.get(oneWrapperUnit.whoId) != null) {
        oneWrapperUnit.whoName = eventIdToContact.get(oneWrapperUnit.whoId)
          .Name;
        oneWrapperUnit.postalCode = eventIdToContact.get(oneWrapperUnit.whoId)
          .MailingPostalCode;
        oneWrapperUnit.city = eventIdToContact.get(oneWrapperUnit.whoId)
          .MailingCity;
      }
    }
    return resultList;
  }

  /**
   * @description : get WhoName from lead
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param whoLeadIds
   * @param resultList
   * @return WrapperList
   **/
  @TestVisible
  private static WrapperList getLeadInformations(
    Set<Id> whoLeadIds,
    WrapperList resultList
  ) {
    //Get Lead infos
    Map<Id, Lead> eventIdToLead = new Map<Id, Lead>();
    for (Lead oneLead : [
      SELECT Id, Name, PostalCode, City
      FROM Lead
      WHERE Id IN :whoLeadIds
    ]) {
      eventIdToLead.put(oneLead.Id, oneLead);
    }
    //Set datas
    for (WrapperUnit oneWrapperUnit : resultList.datas) {
      if (eventIdToLead.get(oneWrapperUnit.whoId) != null) {
        oneWrapperUnit.whoName = eventIdToLead.get(oneWrapperUnit.whoId).Name;
        oneWrapperUnit.postalCode = eventIdToLead.get(oneWrapperUnit.whoId)
          .PostalCode;
        oneWrapperUnit.city = eventIdToLead.get(oneWrapperUnit.whoId).City;
      }
    }
    return resultList;
  }

  /**
   * @description : save start date modification
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param jsonSelectedRows
   * @param dateSelected
   * @param queryContactName
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean saveUpdate(
    String jsonSelectedRows,
    Datetime dateSelected,
    String queryContactName
  ) {
    //JSON to Object
    List<WrapperUnit> selectedRows = (List<WrapperUnit>) JSON.deserialize(
      jsonSelectedRows,
      List<WrapperUnit>.class
    );
    //Get Ids
    List<Id> eventIdsList = new List<Id>();
    for (WrapperUnit oneUnit : selectedRows) {
      eventIdsList.add(oneUnit.Id);
    }
    //Get events
    List<Event> eventToUpdate = new List<Event>();
    List<Event> queryEvents = (List<Event>) Database.query(
      'SELECT Id, IsAllDayEvent, StartDateTime, EndDateTime, DurationInMinutes FROM Event WHERE Id IN :eventIdsList' +
      ((queryContactName == '' ||
        queryContactName == null)
        ? ''
        : (' AND Who.Name LIKE \'%' +
          String.escapeSingleQuotes(queryContactName) +
          '%\''))
    );
    //Set events
    try {
      for (Event oneEvent : queryEvents) {
        oneEvent.StartDateTime = dateSelected;
        if (oneEvent.IsAllDayEvent == null || !oneEvent.IsAllDayEvent) {
          oneEvent.EndDateTime = oneEvent.StartDateTime.addMinutes(
            oneEvent.DurationInMinutes
          );
        } else {
          oneEvent.EndDateTime = oneEvent.StartDateTime;
        }
        eventToUpdate.add(oneEvent);
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
    }
    //Update events
    try {
      update eventToUpdate;
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
      return false;
    }
    System.debug(LoggingLevel.INFO, 'Save END OK');
    return true;
  }
}