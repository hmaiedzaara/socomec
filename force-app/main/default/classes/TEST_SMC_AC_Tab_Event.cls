/**
 * @File Name          : TEST_SMC_AC_Tab_Event.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 01-20-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    23/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
@IsTest
public class TEST_SMC_AC_Tab_Event {
  /**
   * @description : test SMC_AC_Tab_Event.[getCalendars() / getEventInformations() / saveUpdate()]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest(seeAllData=true)
  public static void testMethods() {
    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    insert user;
    //Get calendar Id
    String calendarName;
    Id calendarId;
    Map<Id, String> mapCalendar = SMC_AC_Tab_Event.getCalendars();
    for (Id oneId : mapCalendar.keySet()) {
      calendarId = oneId;
      calendarName = mapCalendar.get(oneId);
      break;
    }

    GroupMember newMember = new GroupMember();
    newMember.GroupId = [
      SELECT Id
      FROM group
      WHERE Name = :STA_UtilsStatic.GROUP_SCHEDULER
    ]
    .Id;
    newMember.UserOrGroupId = user.Id;
    insert newMember;

    System.runAs(user) {
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_Round_Zone__c = 'AAA';
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      Test.startTest();

      Datetime theDatetime = Datetime.newInstance(
        Datetime.now().year(),
        Datetime.now().month(),
        Datetime.now().day()
      );

      //Event
      Event event1 = SMC_UTIL_TestUtils.createEvent(
        calendarId,
        null,
        contact.Id,
        STA_UtilsStatic.EVENT_SUBJECT1,
        null,
        null,
        theDatetime,
        theDatetime.addHours(1),
        60
      );
      //Event
      Event event2 = SMC_UTIL_TestUtils.createEvent(
        calendarId,
        null,
        contact.Id,
        STA_UtilsStatic.EVENT_SUBJECT2,
        null,
        null,
        theDatetime.addDays(3),
        theDatetime.addDays(3),
        1440
      );
      event2.IsAllDayEvent = true;
      insert new List<Event>{ event1, event2 };
      //Set wrapper for tests
      SMC_AC_Tab_Event.WrapperList wrapperList = new SMC_AC_Tab_Event.WrapperList();
      wrapperList.datas.add(
        new SMC_AC_Tab_Event.WrapperUnit(
          event1.Id,
          STA_UtilsStatic.EVENT_SUBJECT1,
          Datetime.now(),
          contact.Id,
          account.Id,
          event1.SMC_Account_Round_Zone__c,
          event1.SMC_Visit_Follow_up__c
        )
      );
      wrapperList.datas.add(
        new SMC_AC_Tab_Event.WrapperUnit(
          event2.Id,
          STA_UtilsStatic.EVENT_SUBJECT2,
          Datetime.now().addDays(3),
          contact.Id,
          account.Id,
          event2.SMC_Account_Round_Zone__c,
          event2.SMC_Visit_Follow_up__c
        )
      );

      /** TEST "getEventInformations" **/
      String resultJson = SMC_AC_Tab_Event.getEventInformations(
        100,
        0,
        null,
        null,
        null,
        null,
        calendarName
      );
      System.assertNotEquals(
        null,
        resultJson,
        'There is no Event in the test.'
      );
      SMC_AC_Tab_Event.WrapperList selectedRows = (SMC_AC_Tab_Event.WrapperList) JSON.deserialize(
        resultJson,
        SMC_AC_Tab_Event.WrapperList.class
      );

      /** TEST "saveUpdate" **/
      Boolean resultUpdate = SMC_AC_Tab_Event.saveUpdate(
        JSON.serialize(wrapperList.datas),
        Datetime.now().addDays(10),
        null
      );
      System.assert(resultUpdate, 'Event is not updated.');
      //
      Test.stopTest();

      Map<Id, Event> eventUpdated = new Map<Id, Event>(
        [
          SELECT Id, StartDateTime, EndDateTime
          FROM Event
          WHERE Subject = :STA_UtilsStatic.EVENT_SUBJECT1
        ]
      );
      //Check result
      for (SMC_AC_Tab_Event.WrapperUnit oneUnit : selectedRows.datas) {
        if (eventUpdated.get(oneUnit.id) != null) {
          System.assertNotEquals(
            oneUnit.startDate,
            eventUpdated.get(oneUnit.id).StartDateTime,
            'Event is not updated with rigth StartDate.'
          );
        }
      }
    }
  }
}