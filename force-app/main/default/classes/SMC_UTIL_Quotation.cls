/*
---------------------------------------------------------------------------
-- - Name : SMC_UTIL_Quotation
-- - Author : Vincent RECASENS
-- - Description : This class is an utils class to check if all fields 
                   are fill to access to discount form
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     -----------------------
-- 12-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_UTIL_Quotation {
  /** GET LISTS OF : 
        -User
        -Quote.SMC_Forecast__c
        -Account.SMC_Category__c
        -Account.SMC_PCO_Price_List__c
        -Contact.SMC_Forecast__c
    **/

  //User
  public static List<User> getUsers() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getUsers - START'
    );

    //Get Permission Set "Quotation Tool" to build a List<User> with only users who have this permission
    // List<PermissionSetAssignment> pasList = [
    //   SELECT
    //     Assignee.Id,
    //     Assignee.Name,
    //     PermissionSet.Id,
    //     PermissionSet.Label,
    //     PermissionSet.Name
    //   FROM PermissionSetAssignment
    //   WHERE PermissionSet.Name = :STA_UtilsStatic.ACCESS_MYSOCOMEC_QUOTATION_TOOL
    // ];
    // List<Id> userIdAssignee = new List<Id>();
    // for (PermissionSetAssignment pas : pasList) {
    //   userIdAssignee.add(pas.Assignee.Id);
    // }

    List<User> standardProfileUsers = [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE
        Id IN (
          SELECT AssigneeId
          FROM PermissionSetAssignment
          WHERE
            PermissionSet.Name = :STA_UtilsStatic.ACCESS_MYSOCOMEC_QUOTATION_TOOL
        )
      ORDER BY LastName
    ];
    List<User> finalUsersList = new List<User>();
    User fakeUser = new User();
    fakeUser.FirstName = STA_UtilsStatic.EMPTY_STRING;
    fakeUser.LastName = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
    finalUsersList.add(fakeUser);

    if (standardProfileUsers != null && standardProfileUsers.size() > 0) {
      for (User u : standardProfileUsers) {
        finalUsersList.add(u);
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getUsers - END'
    );
    return finalUsersList;
  }

  //Quote.SMC_Forecast__c
  public static List<String> getQuoteForecasts() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getQuoteForecasts - START'
    );

    List<String> options = new List<String>();
    Schema.DescribeFieldResult fieldResult = Quote.SMC_Forecast__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      options.add(entry.getValue());
    }

    List<String> tmpOptions = new List<String>();
    if (options != null && options.size() > 0) {
      for (Integer i = 0; i < options.size(); ++i) {
        if (options[i] == STA_UtilsStatic.NO) {
          options.remove(i);
        }
      }
      tmpOptions.add(STA_UtilsStatic.NO);
      for (Integer i = 0; i < options.size(); ++i) {
        tmpOptions.add(options[i]);
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getQuoteForecasts - END'
    );
    return tmpOptions;
  }

  //Account.SMC_Category__c
  public static List<String> getAccountCategory() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getAccountCategory - START'
    );

    List<String> options = new List<String>();
    Schema.DescribeFieldResult fieldResult = Account.SMC_Category__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      options.add(entry.getValue());
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getAccountCategory - END'
    );
    return options;
  }

  //Account.SMC_PCO_Price_List__c
  public static List<String> getAccountPriceList() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getAccountCategory - START'
    );

    List<String> options = new List<String>();
    Schema.DescribeFieldResult fieldResult = Account.SMC_PCO_Price_List__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      options.add(entry.getValue());
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getAccountCategory - END'
    );
    return options;
  }

  //Contact.SMC_PCO_Price_List__c
  public static List<String> getContactSalutation() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getContactSalutation - START'
    );

    List<String> options = new List<String>();
    Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      options.add(entry.getValue());
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : getContactSalutation - END'
    );
    return options;
  }

  /** CHECK VALIDITY FOR QUOTATION ON : 
        -Account
        -Contact
        -Quote
    **/

  //Account
  public static SMC_DTO_QuotationTool_MissingFields checkAccount(
    SMC_DTO_QuotationTool_MissingFields dtoMissingFields,
    Account account
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkAccount - START'
    );
    List<String> accountFields = new List<String>();

    if (account != null) {
      dtoMissingFields.account = account;

      if (account.BillingCountryCode == null) {
        accountFields.add('BillingCountry + ');
      }
      if (account.SMC_Category__c == null) {
        accountFields.add('Category + ');
      }
      if (account.SMC_PCO_Price_List__c == null) {
        accountFields.add('Price List + ');
      }

      if (accountFields.size() > 0) {
        Integer lastIndex = accountFields.size() - 1;
        accountFields[lastIndex] = accountFields[lastIndex]
          .split(STA_UtilsStatic.SPLIT_PLUS)[0];
        dtoMissingFields.accountFieldsMiss = true;
        dtoMissingFields.fieldMiss = true;
      }
    } else {
      dtoMissingFields.nullExist = true;
      accountFields.add('No Account found');
    }

    dtoMissingFields.accountFields = accountFields;
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkAccount - END'
    );
    return dtoMissingFields;
  }

  //Contact
  public static SMC_DTO_QuotationTool_MissingFields checkContact(
    SMC_DTO_QuotationTool_MissingFields dtoMissingFields,
    Contact contact
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkContact - START'
    );
    List<String> contactFields = new List<String>();

    if (contact != null) {
      dtoMissingFields.contact = contact;

      // if(contact.Salutation == null){
      //     contactFields.add('Salutation or Honorary title (it\'s a part of Contact Name) + ');
      // }
      if (contact.Email == null) {
        contactFields.add('Email + ');
      }
      if (contact.Phone == null && contact.MobilePhone == null) {
        contactFields.add('Phone or MobilePhone (at least one of them) + ');
      }

      if (contactFields.size() > 0) {
        Integer lastIndex = contactFields.size() - 1;
        contactFields[lastIndex] = contactFields[lastIndex]
          .split(STA_UtilsStatic.SPLIT_PLUS)[0];
        dtoMissingFields.contactFieldsmiss = true;
        dtoMissingFields.fieldMiss = true;
      }
    } else {
      dtoMissingFields.nullExist = true;
      contactFields.add('No Contact found');
    }

    dtoMissingFields.contactFields = contactFields;
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkContact - END'
    );
    return dtoMissingFields;
  }

  //Quote
  public static SMC_DTO_QuotationTool_MissingFields checkQuote(
    SMC_DTO_QuotationTool_MissingFields dtoMissingFields,
    Quote quote
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkQuote - START'
    );
    List<String> quoteFields = new List<String>();

    if (quote != null) {
      if (quote.Name == null) {
        quoteFields.add('Name + ');
      }
      if (quote.OwnerId == null) {
        quoteFields.add('OwnerId + ');
      }

      if (quoteFields.size() > 0) {
        Integer lastIndex = quoteFields.size() - 1;
        quoteFields[lastIndex] = quoteFields[lastIndex]
          .split(STA_UtilsStatic.SPLIT_PLUS)[0];
        dtoMissingFields.quoteFieldsMiss = true;
        dtoMissingFields.fieldMiss = true;
      }
    } else {
      dtoMissingFields.nullExist = true;
      quoteFields.add('No Quote found');
    }

    dtoMissingFields.quoteFields = quoteFields;
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_UTIL_Quotation : checkQuote - END'
    );
    return dtoMissingFields;
  }
}