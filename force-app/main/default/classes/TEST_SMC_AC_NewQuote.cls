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
@isTest
public class TEST_SMC_AC_NewQuote {
  @isTest
  public static void testGetInformationsOK() {
    System.debug('>>>>>> TEST_SMC_AC_NewQuote - testGetInformations : START');
    Id profileAdminId;
    Id profilePartnerId;
    List<String> listProfileName = new List<String>{STA_UtilsStatic.PROFILE_SMC_ADMIN, 
                                                    STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY};
    for(Profile oneProfile : [SELECT Id, Name FROM Profile WHERE Name IN :listProfileName]){
      if(oneProfile.Name == STA_UtilsStatic.PROFILE_SMC_ADMIN){
        profileAdminId = oneProfile.Id;
      }
      if(oneProfile.Name == STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY){
        profilePartnerId = oneProfile.Id;
      }
    }
    User userAdmin1 = SMC_UTIL_TestUtils.createUser(
      'admin1-' + STA_UtilsStatic.USER_NICKNAME,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdminId,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      'admin1-' + STA_UtilsStatic.USER_NICKNAME
    );
    userAdmin1.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME].Id; //CEO
    userAdmin1.Bypass_All_Processes_Builder__c = true;
    insert userAdmin1;

    //recordType Account
    Id recordTypeAccCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();

    User user1;
    Opportunity opportunity1;
    Account account1;

    System.runAs(userAdmin1) {
      PAD.bypassAll = true; //Need to bypass trigger on Account

      //Account
      account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1 + 'PartnerAcc',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        userAdmin1.Id,
        userAdmin1.Id,
        userAdmin1.Id,
        userAdmin1.Id,
        userAdmin1.Id
      );
      account1.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account1.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
      insert account1;

      //Set Contacts
      RecordType recordTypeContactPartner = [
        SELECT Id, Name
        FROM RecordType
        WHERE DeveloperName = :STA_UtilsStatic.PARTNER_CONTACT_RECORDTYPE_NAME
      ];
      Contact contactPartner = SMC_UTIL_TestUtils.createContact(
        null,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        account1.Id
      );
      contactPartner.RecordTypeId = recordTypeContactPartner.Id;
      insert contactPartner;

      user1 = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.USER_NICKNAME,
        STA_UtilsStatic.USERNAME_TEST,
        profilePartnerId,
        STA_UtilsStatic.USERNAME_TEST,
        STA_UtilsStatic.USER_NICKNAME
      );
      user1.ContactId = contactPartner.Id;
      insert user1;

      PermissionSet ps = [
        SELECT ID
        FROM PermissionSet
        WHERE Name = :STA_UtilsStatic.ACCESS_MYSOCOMEC_QUOTE
      ];
      insert new List<PermissionSetAssignment>{
        new PermissionSetAssignment(
          AssigneeId = user1.id,
          PermissionSetId = ps.Id
        )
      };
      // PAD.bypassAll = true; //Need to bypass trigger on Account

      //Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      opportunity1 = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.OPPORTUNITY_NAME1,
        STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION
      );
      opportunity1.AccountId = account1.Id;
      insert opportunity1;

      //Team Memebers
      OpportunityTeamMember teamMemeber1 = new OpportunityTeamMember();
      teamMemeber1.OpportunityId = opportunity1.Id;
      teamMemeber1.UserId = user1.Id;
      insert teamMemeber1;

      Quote quote = SMC_UTIL_TestUtils.createQuote(
        opportunity1.Id,
        STA_UtilsStatic.QUOTE_NAME1,
        account1.Id
      );
      quote.OpportunityId = opportunity1.Id;
      quote.SMC_Account__c = account1.Id;
      insert quote;

      opportunity1.SyncedQuoteId = quote.Id;
      update opportunity1;

      SMC_Opportunity_Actors__c oppActor = SMC_UTIL_TestUtils.createOpportunityActors(opportunity1.Id, 
                                                                                      account1.Id, 
                                                                                      contactPartner.Id, 
                                                                                      true);
      insert oppActor;

      PAD.bypassAll = false;
    }

    System.runAs(user1) {
      //Get Users
      List<User> users = SMC_UTIL_Quotation.getUsers();

      Test.startTest();
      // System.assert(dtoMissingField1.fieldMiss == false);

      //Get Account and Contact
      List<Account> accounts1 = new List<Account>();
      Account accountDefault = new Account();
      accountDefault.Name = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
      accounts1.add(accountDefault);
      accounts1.add(account1);

      List<Contact> contacts1 = new List<Contact>();
      Contact contactDefault = new Contact();
      contactDefault.FirstName = STA_UtilsStatic.EMPTY_STRING;
      contactDefault.LastName = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
      contacts1.add(contactDefault);

      //Result Expected
      SMC_DTO_NewQuoteForProject dtoExpected1 = new SMC_DTO_NewQuoteForProject(
        opportunity1,
        accounts1,
        contacts1,
        null,
        true,
        users
      );

      //Check method
      SMC_DTO_NewQuoteForProject dtoActual1 = SMC_AC_NewQuote.getInformations(
        opportunity1.Id
      );
      Test.stopTest();

      //Check with opportunity1
      System.assert(dtoExpected1.opportunity.Id == dtoActual1.opportunity.Id);
      // System.assert(dtoExpected1.accounts[1].Id == dtoActual1.accounts[1].Id);
      // System.assert(
      //   dtoExpected1.contacts[0].Name == dtoActual1.contacts[0].Name
      // );
    }
  }

  @isTest
  public static void testGetInformationsBAD() {
    //Check without permission Quotation Tool
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME2,
      STA_UtilsStatic.USERNAME_TEST2,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    insert user2;

    System.runAs(user2) {
      PAD.bypassAll = true;

      Account account2 = new Account(); //Miss Category to have a warning message
      account2.Name = STA_UtilsStatic.ACCOUNT_NAME2;
      account2.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
      insert account2;

      Contact contact2 = new Contact(); //Miss (Phone & MobilePhone) to have a warning message
      contact2.FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME2;
      contact2.LastName = STA_UtilsStatic.CONTACT_LASTNAME2;
      contact2.AccountId = account2.Id;
      contact2.Salutation = STA_UtilsStatic.CONTACT_SALUTATION;
      contact2.Email = STA_UtilsStatic.CONTACT_EMAIL2;
      insert contact2;

      // PAD.ApexForcedBypass.add(
      //   STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT
      // );
      Opportunity opportunity2 = new Opportunity();
      opportunity2.Name = STA_UtilsStatic.OPPORTUNITY_NAME2;
      opportunity2.StageName = STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION;
      opportunity2.CloseDate = Date.today();
      opportunity2.AccountId = account2.Id;
      opportunity2.SMC_Primary_Contact__c = contact2.Id;
      insert opportunity2;
      // PAD.ApexForcedBypass.remove(
      //   STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT
      // );

      OpportunityTeamMember teamMemeber2 = new OpportunityTeamMember();
      teamMemeber2.OpportunityId = opportunity2.Id;
      teamMemeber2.UserId = user2.Id;
      insert teamMemeber2;

      PAD.bypassAll = false;

      Test.startTest();
      SMC_DTO_NewQuoteForProject dtoActual2 = SMC_AC_NewQuote.getInformations(
        opportunity2.Id
      );
      Test.stopTest();

      System.assertEquals(null, dtoActual2);
    }

    System.debug('>>>>>> TEST_SMC_AC_NewQuote - testGetInformations : END');
  }

  @isTest
  public static void testSaveNewQuote() {
    System.debug('>>>>>> TEST_SMC_AC_NewQuote - testSaveNewQuote : START');

    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user1.Bypass_All_Processes_Builder__c = true;
    insert user1;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.ACCESS_MYSOCOMEC_QUOTE
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user1.id,
        PermissionSetId = ps.Id
      )
    };

    System.runAs(user1) {
      PAD.bypassAll = true; //Need to bypass trigger on Account

      Id recordTypeAccCustomerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();

      //Account
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id
      );
      account1.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account1.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
      account1.OwnerId = user1.Id;
      insert account1;

      //Contact
      Contact contact1 = SMC_UTIL_TestUtils.createContact(
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
        account1.Id
      );
      insert contact1;

      //Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opportunity1 = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.OPPORTUNITY_NAME1,
        STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION
      );
      opportunity1.AccountId = account1.Id;
      opportunity1.SMC_Primary_Contact__c = contact1.Id;
      opportunity1.OwnerId = user1.Id;
      insert opportunity1;

      //Team Memebers
      OpportunityTeamMember teamMemeber1 = new OpportunityTeamMember();
      teamMemeber1.OpportunityId = opportunity1.Id;
      teamMemeber1.UserId = user1.Id;
      insert teamMemeber1;

      PAD.bypassAll = false; //Need to bypass trigger on Account

      Test.startTest();
      // PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT);
      //Test if it's not synchronize
      Quote quote = new Quote();
      quote.Name = STA_UtilsStatic.QUOTE_NAME1;
      String quoteIdExpected = SMC_AC_NewQuote.saveNewQuote(
        opportunity1.Id,
        quote,
        account1.Id,
        contact1.Id,
        user1.Id,
        user1.Id,
        false
      );

      //Test if it's synchronize
      Quote quoteForFail = new Quote();
      quoteForFail.Name = STA_UtilsStatic.QUOTE_NAME2;
      SMC_AC_NewQuote.saveNewQuote(
        opportunity1.Id,
        quoteForFail,
        account1.Id,
        contact1.Id,
        user1.Id,
        user1.Id,
        true
      );
      opportunity1 = [
        SELECT Id, Name, SyncedQuoteId
        FROM Opportunity
        WHERE Name = :STA_UtilsStatic.OPPORTUNITY_NAME1
      ]; //It's mandatory cause the method update the opportunity;
      // PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT);
      Test.stopTest();

      System.assert(quote.Id == quoteIdExpected);
      System.assert(opportunity1.SyncedQuoteId == quoteForFail.Id);
    }

    System.debug('>>>>>> TEST_SMC_AC_NewQuote - testSaveNewQuote : END');
  }
}