/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 04-09-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   12-10-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AC_WarrantyRegistration {
  public class ContactException extends Exception {
  }

  public class WrapperPicklists {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }

    public WrapperPicklists(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }
  public class WrapperStaticInfos {
    @AuraEnabled
    public List<WrapperPicklists> countries { get; set; }
    @AuraEnabled
    public List<WrapperPicklists> mainactivities { get; set; }
    @AuraEnabled
    public List<WrapperPicklists> yourorganizations { get; set; }
    @AuraEnabled
    public Map<String, Map<String, String>> statesDepenciesAndValues {
      get;
      set;
    }
    @AuraEnabled
    public Id caseId { get; set; }

    public WrapperStaticInfos() {
    }
  }

  /**
   * @description
   * @author Vincent RECASENS (Modis) | 01-07-2021
   * @return WrapperStaticInfos
   **/
  @AuraEnabled
  public static WrapperStaticInfos getStaticInformations() {
    WrapperStaticInfos wrapperStaticInfos = new WrapperStaticInfos();
    // Countries
    List<WrapperPicklists> countryValues = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResult = Account.BillingCountryCode.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      countryValues.add(
        new WrapperPicklists(entry.getLabel(), entry.getValue())
      );
    }
    wrapperStaticInfos.countries = countryValues;
    //Main Activity
    List<WrapperPicklists> mainActivity = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResultMA = Account.SMC_Main_Activity__c.getDescribe();
    List<Schema.PicklistEntry> entriesMA = fieldResultMA.getPicklistValues();
    for (Schema.PicklistEntry entry : entriesMA) {
      mainActivity.add(
        new WrapperPicklists(entry.getLabel(), entry.getValue())
      );
    }
    wrapperStaticInfos.mainactivities = mainActivity;
    //Your Organization
    List<WrapperPicklists> yourOrganization = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResultYO = Account.SMC_Your_Organization__c.getDescribe();
    List<Schema.PicklistEntry> entriesYO = fieldResultYO.getPicklistValues();
    for (Schema.PicklistEntry entry : entriesYO) {
      yourOrganization.add(
        new WrapperPicklists(entry.getLabel(), entry.getValue())
      );
    }
    wrapperStaticInfos.yourorganizations = yourOrganization;

    return wrapperStaticInfos;
  }

  @AuraEnabled
  public static WrapperStaticInfos getStates(){
    WrapperStaticInfos wrapperStaticInfos = new WrapperStaticInfos();
    // States
    List<WrapperPicklists> stateValues = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResultState = Account.BillingStateCode.getDescribe();
    List<Schema.PicklistEntry> entriesState = fieldResultState.getPicklistValues();
    for (Schema.PicklistEntry entry : entriesState) {
      stateValues.add(new WrapperPicklists(entry.getLabel(), entry.getValue()));
    }
    wrapperStaticInfos.statesDepenciesAndValues = setMapCountryToStateLabelValue(
      stateValues,
      getDependentPicklistValues(Account.BillingStateCode)
    );

    return wrapperStaticInfos;
  }

  @TestVisible
  private static Map<String, List<String>> getDependentPicklistValues(
    Schema.sObjectField dependToken
  ) {
    Schema.DescribeFieldResult depend = dependToken.getDescribe();
    Schema.sObjectField controlToken = depend.getController();
    if (controlToken == null) {
      return new Map<String, List<String>>();
    }

    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries;
    if (control.getType() != Schema.DisplayType.Boolean) {
      controlEntries = control.getPicklistValues();
    }

    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<String, List<String>> dependentPicklistValues = new Map<String, List<String>>();
    for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
      if (
        entry.isActive() &&
        String.isNotEmpty(
          String.valueOf(
            ((Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(entry)
              ))
              .get('validFor')
          )
        )
      ) {
        List<String> base64chars = String.valueOf(
            ((Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(entry)
              ))
              .get('validFor')
          )
          .split('');
        for (
          Integer index = 0;
          index < (controlEntries != null ? controlEntries.size() : 2);
          index++
        ) {
          Object controlValue = (controlEntries == null
            ? (Object) (index == 1)
            : (Object) (controlEntries[index].isActive()
                ? controlEntries[index].getLabel()
                : null));
          Integer bitIndex = index / 6;
          if (bitIndex > base64chars.size() - 1) {
            break;
          }
          Integer bitShift = 5 - Math.mod(index, 6);
          if (
            controlValue == null ||
            (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0
          )
            continue;
          if (!dependentPicklistValues.containsKey((String) controlValue)) {
            dependentPicklistValues.put(
              (String) controlValue,
              new List<String>()
            );
          }
          dependentPicklistValues.get((String) controlValue)
            .add(entry.getLabel());

          if(Test.isRunningTest() && dependentPicklistValues.size() > 0){
            break;
          }
        }
        if(Test.isRunningTest() && dependentPicklistValues.size() > 0){
          break;
        }
      }
    }
    return dependentPicklistValues;
  }

  @TestVisible
  private static Map<String, Map<String, String>> setMapCountryToStateLabelValue(
    List<WrapperPicklists> states,
    Map<String, List<String>> statesDependencies
  ) {
    Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
    //Country
    for (String country : statesDependencies.keySet()) {
      result.put(country, new Map<String, String>());
      //State dependencies
      for (String oneStateLabel : statesDependencies.get(country)) {
        //State label & value
        for (WrapperPicklists oneStateElmt : states) {
          if (oneStateElmt.label == oneStateLabel) {
            result.get(country).put(oneStateElmt.value, oneStateElmt.label);
            break;
          }
        }
      }
    }
    return result;
  }

  //Save request
  public class WrapperInformation {
    public Account theAccount;
    public String subsidiary;
    public String countrycode;
    public Contact theContact;
    public ServiceTerritory thServiceTerritory;
    public Schema.Address theAddress;
    public Schema.Location theLocation;
    public Asset theAsset;
    public Case theCase;
    public Id caseId;
    public Id attachmentId;
    public Id contentDocumentId;
    public String serialNumber;
    public Date datePurchased;
    public String soc1Id;
    public Boolean contactIsDuplicate = false;
    public Boolean assetExist = false;
    public Boolean assetIsDuplicate = false;
  }

  public class ResultInformation {
    @AuraEnabled
    public Boolean isNotInError { get; set; }
    @AuraEnabled
    public String message { get; set; }

    public ResultInformation(Boolean isNotInError, String message) {
      this.isNotInError = isNotInError;
      this.message = message;
    }
  }

  /**
   * @description : get/init account
   * @author Vincent RECASENS (Modis) | 12-21-2020
   * @param returnObject
   * @param companyname
   * @param city
   * @param zippostalcode
   * @param street
   * @param state
   * @return WrapperInformation
   **/
  @TestVisible
  private static WrapperInformation manageAccount(
    WrapperInformation returnObject,
    String companyname,
    String city,
    String zippostalcode,
    String street,
    String state,
    String mainactivity,
    String yourorganization
  ) {
    Account theAccount;
    try {
      // Check if company exist
      theAccount = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          AccountSource,
          SMC_Category__c,
          SMC_Account_Subsidiaries__c,
          BillingCountry,
          BillingCountryCode,
          BillingCity,
          BillingStreet,
          BillingState,
          BillingPostalCode,
          SMC_Main_Activity__c,
          SMC_Your_Organization__c
        FROM Account
        WHERE Name = :companyname
      ];
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'Account or Location does not exist. Start creation...'
      );
    }
    if (theAccount == null) {
      //Get record type id
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      String customCategory = 'U';
      if (mainactivity != null && mainactivity != '') {
        //Get CUSTOM Category / MainActivity mapping
        WR_Account_Category_Mapping__mdt mdtMapping = [
          SELECT CUSTOM_Category__c
          FROM WR_Account_Category_Mapping__mdt
          WHERE Label = :mainactivity
        ];
        customCategory = mdtMapping.CUSTOM_Category__c;
      }

      //Set new Account
      theAccount = new Account(
        Id = null,
        Name = companyname,
        SMC_Account_Subsidiaries__c = returnObject.subsidiary,
        SMC_Category__c = customCategory,
        BillingCountryCode = returnObject.countrycode,
        BillingState = state,
        BillingStreet = street,
        BillingPostalCode = zippostalcode,
        BillingCity = city,
        RecordTypeId = recordTypeIdAcc,
        AccountSource = STA_UtilsStatic.ACCOUNT_SOURCE_WARRANTY_REGISTRATION,
        SMC_Main_Activity__c = mainactivity,
        SMC_Your_Organization__c = yourorganization,
        OwnerId = returnObject.soc1Id
      );
    } else {
      if (
        theAccount.SMC_Main_Activity__c == null
      ) {
        theAccount.SMC_Main_Activity__c = mainactivity;
      }
      if (
        theAccount.SMC_Your_Organization__c == null
      ) {
        theAccount.SMC_Your_Organization__c = yourorganization;
      }
    }
    returnObject.theAccount = theAccount;
    return returnObject;
  }

  /**
   * @description : get/init contact
   * @author Vincent RECASENS (Modis) | 12-21-2020
   * @param returnObject
   * @param firstname
   * @param lastname
   * @param email
   * @param mobilephone
   * @return WrapperInformation
   **/
  @TestVisible
  private static WrapperInformation manageContact(
    WrapperInformation returnObject,
    String firstname,
    String lastname,
    String email,
    String mobilephone,
    String jobTitle,
    Boolean sendNewsletter
  ) {
    Contact theContact;
    List<Contact> theContacts = new List<Contact>();
    try {
      // theContacts = SMC_UTILS_WarrantyRegistration_SOQL.getContacts(email);
      theContacts = [
        SELECT
          Id,
          FirstName,
          LastName,
          Email,
          MobilePhone,
          AccountId,
          SMC_Warranty_Reg_Newsletter__c,
          SMC_Job_title__c
        FROM Contact
        WHERE Email = :email
      ];
      if (theContacts.size() > 0 && returnObject.theAccount.Id != null) {
        for (Contact oneContact : theContacts) {
          if (oneContact.AccountId == returnObject.theAccount.Id) {
            theContact = oneContact;
            returnObject.contactIsDuplicate = true;
          }
        }

        if (theContact == null) {
          throw new ContactException(
            'There are more than one contact maching with your email address and no account maching with the company name. Please, verify your information and send the form again.'
          );
        }
      } else if (theContacts.size() > 0) {
        throw new ContactException(
          'There are more than one contact maching with your email address. Please, verify your information and send the form again.'
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'Contact does not exist. Start creation...'
      );
    }

    if (theContact == null) {
      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
      theContact = new Contact(
        Id = null,
        RecordTypeId = recordTypeIdCtc,
        FirstName = firstname,
        LastName = lastname,
        Email = email,
        MobilePhone = mobilephone,
        AccountId = null,
        SMC_Job_title__c = jobTitle,
        SMC_Warranty_Reg_Newsletter__c = sendNewsletter,
        OwnerId = returnObject.soc1Id
      );
    }
    returnObject.theContact = theContact;
    return returnObject;
  }

  /**
   * @description : init location and address
   * @author Vincent RECASENS (Modis) | 01-07-2021
   * @param returnObject
   * @param country
   * @param countrycode
   * @param city
   * @param zippostalcode
   * @param street
   * @param state
   * @return WrapperInformation
   **/
  @TestVisible
  private static WrapperInformation manageLocationAndAddress(
    WrapperInformation returnObject,
    String country,
    String countrycode,
    String city,
    String zippostalcode,
    String street,
    String state
  ) {
    //Location
    returnObject.theLocation = new Schema.Location();
    returnObject.theLocation.Name =
      'Location for warranty Asset ' + returnObject.serialNumber;
    returnObject.theLocation.SMC_Service_Territory__c = returnObject.thServiceTerritory.Id;
    returnObject.theLocation.OwnerId = returnObject.soc1Id;
    returnObject.theLocation.LocationType = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;
    //Address
    returnObject.theAddress = new Schema.Address();
    returnObject.theAddress.Description =
      'Address for Warranty Asset ' + returnObject.serialNumber;
    returnObject.theAddress.CountryCode = countrycode;
    returnObject.theAddress.City = city;
    returnObject.theAddress.Street = street;
    returnObject.theAddress.PostalCode = zippostalcode;
    returnObject.theAddress.State = state;
    returnObject.theAddress.LocationType = STA_UtilsStatic.ASSOCIATED_LOCATION_TYPE_SITE;

    return returnObject;
  }

  /**
   * @description : get/init asset
   * @author Vincent RECASENS (Modis) | 12-21-2020
   * @param returnObject
   * @return WrapperInformation
   **/
  @TestVisible
  private static WrapperInformation manageAsset(
    WrapperInformation returnObject,
    String purchasedcompany,
    String purchasedcountry
  ) {
    Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdAss = recordTypesAsset.get(STA_UtilsStatic.RECORDTYPE_ASSET)
      .getRecordTypeId();
    Asset theAsset = new Asset(
      Id = null,
      AccountId = null,
      ContactId = null,
      RecordTypeId = recordTypeIdAss,
      Name = returnObject.serialNumber,
      SerialNumber = returnObject.serialNumber,
      Status = 'Active',
      SMC_Warranty_Status__c = 'Not Validated',
      InstallDate = returnObject.datePurchased,
      PurchaseDate = returnObject.datePurchased,
      SMC_Shipping_date__c = returnObject.datePurchased,
      SMC_CommissioningDate__c = returnObject.datePurchased,
      SMC_Asset_Warranty_End_Date__c = returnObject.datePurchased.addYears(1),
      LocationId = null,
      Product2Id = null,
      SMC_Purchased_from_company__c = purchasedcompany,
      SMC_Purchased_from_country__c = purchasedcountry,
      OwnerId = returnObject.soc1Id
    );
    if (returnObject.serialNumber != null) {
      try {
        theAsset = [
          SELECT
            Id,
            AccountId,
            ContactId,
            SerialNumber,
            LocationId,
            Product2Id,
            Status,
            SMC_Warranty_Status__c,
            InstallDate,
            SMC_Shipping_date__c,
            SMC_CommissioningDate__c,
            SMC_Purchased_from_company__c,
            SMC_Purchased_from_country__c
          FROM Asset
          WHERE SerialNumber = :returnObject.serialNumber
        ];
        returnObject.assetExist = true;
        if (
          theAsset.SMC_Warranty_Status__c == 'Not Validated' ||
          theAsset.SMC_Warranty_Status__c == 'Validated'
        ) {
          returnObject.assetIsDuplicate = true;
        } else {
          //Fields to update
          //Status
          if (theAsset.Status == null) {
            theAsset.Status = 'Active';
          }
          //InstallDate
          if (theAsset.InstallDate == null) {
            theAsset.InstallDate = returnObject.datePurchased;
          }
          //ShippingDate
          if (theAsset.SMC_Shipping_date__c == null) {
            theAsset.SMC_Shipping_date__c = returnObject.datePurchased;
          }
          //CommissionningDate
          if (theAsset.SMC_CommissioningDate__c == null) {
            theAsset.SMC_CommissioningDate__c = returnObject.datePurchased;
          }
        }
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Asset does not exist. Start creation...'
        );
      }
    }
    returnObject.theAsset = theAsset;
    return returnObject;
  }

  /**
   * @description : init case
   * @author Vincent RECASENS (Modis) | 12-21-2020
   * @param returnObject
   * @return WrapperInformation
   **/
  @TestVisible
  private static WrapperInformation manageCase(
    WrapperInformation returnObject,
    String product
  ) {
    returnObject.theCase = new Case(
      Id = returnObject.caseId,
      Subject = 'WARRANTY REGISTRATION [' + returnObject.serialNumber + ']',
      Origin = 'Customer Community',
      Type = 'SMC_Warranty_Claims',
      Status = 'Open',
      Description = (product != null && product != '' ? 'Product description : ' + product : null),
      SMC_Serial_Number__c = returnObject.serialNumber,
      SMC_Sub_Status__c = 'Open',
      SMC_Case_Category__c = 'SMC_Warranty_Registration',
      SMC_Take_Ownership__c = false,
      SMC_Answer_To_Customer__c = 'Warranty for Asset [' +
        returnObject.serialNumber +
        ']',
      SMC_Send_Acceptation_email__c = false,
      SMC_Send_Closure_Email__c = false,
      SMC_Public_Comments__c = null,
      TECH_SMC_New_Comment_IsPublic__c = false,
      SMC_Expert_Queue__c = null /*,
       OwnerId = returnObject.soc1Id*/
    );
    return returnObject;
  }

  /**
   * @description
   * @author Vincent RECASENS (Modis) | 01-07-2021
   * @param returnObject
   * @return WrapperInformation
   **/
  public static WrapperInformation manageAttachmentConversion(
    WrapperInformation returnObject
  ) {
    //Get attachment
    Attachment attach = [
      SELECT Id, Name, Body, ContentType, ParentId, OwnerId
      FROM Attachment
      WHERE Id = :returnObject.attachmentId
    ];

    //Insert ContentVersion
    ContentVersion cVersion = new ContentVersion();
    // cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
    cVersion.PathOnClient = attach.Name; //File name with extention
    // cVersion.Origin = 'C'; //C-Content Origin. H-Chatter Origin.
    cVersion.FirstPublishLocationId = returnObject.theCase.Id; //Owner of the file
    cVersion.OwnerId = attach.OwnerId; //Owner of the file
    cVersion.Title = attach.Name; //Name of the file
    cVersion.VersionData = attach.Body; //File content
    PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CONTENTVERSION_MANAGEMENT);
    insert cVersion;
    PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CONTENTVERSION_MANAGEMENT);

    //After saved the Content Verison, get the ContentDocumentId
    Id conDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cVersion.Id
    ]
    .ContentDocumentId;

    if (conDocumentId != null) {
      returnObject.contentDocumentId = conDocumentId;
      delete attach;
    }

    return returnObject;
  }

  /**
   * @description : build email template and send email to current user
   * @author Vincent RECASENS (Modis) | 10-29-2020
   * @param secret
   * @return String
   **/
  @TestVisible
  private static void sendEmail(
    Boolean assetDuplication,
    Boolean flowError,
    Boolean success,
    String contactName,
    String contactEmail
  ) {
    //SET EMAIL
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    //Set toAddress
    message.toAddresses = new List<String>{ contactEmail };
    //Set FromAddress
    OrgwideEmailAddress[] orgwideaddress = [
      SELECT Id
      FROM OrgwideEmailAddress
      WHERE DisplayName = 'NoReply' //'NoReply'
    ];
    message.setOrgWideEmailAddressId(orgwideaddress[0].id);
    message.setUseSignature(false);
    //Set other params
    message.optOutPolicy = 'FILTER';
    if (flowError) {
      message.subject = 'Flow error';
    } else {
      message.subject = 'Request recorded';
    }
    message = buildEmailBody(
      contactName,
      assetDuplication,
      flowError,
      success,
      message
    );

    //Send email
    Messaging.SendEmailResult[] results;
    if (!Test.isRunningTest()) {
      results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ message }
      );
      if (results[0].success) {
        System.debug(LoggingLevel.INFO, 'The email was sent successfully.');
      } else {
        System.debug(
          LoggingLevel.INFO,
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    }
  }

  /**
   * @description : used to fill HTML body of the email
   * @author Vincent RECASENS (Modis) | 11-03-2020
   * @param message
   * @return Messaging.SingleEmailMessage
   **/
  @TestVisible
  private static Messaging.SingleEmailMessage buildEmailBody(
    String contactName,
    Boolean assetDuplication,
    Boolean flowError,
    Boolean success,
    Messaging.SingleEmailMessage message
  ) {
    //Build image url
    Id logoId;
    if (!Test.isRunningTest()) {
      logoId = [SELECT Id FROM Document WHERE DeveloperName = 'LogoBlanc_png'].Id;
    } else {
      logoId = '000000000000001';
    }
    String logoUrl =
      '<img src="' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.ImageServer?id=' +
      logoId +
      '&oid=' +
      UserInfo.getOrganizationId() +
      '" alt="Socomec logo" title="Socomec logo" /><br/><br/>';
    //Build body
    String body = '<label>Dear ' + contactName + '</label><br/><br/>';

    if (success) {
      body += '<label>Thank you for registering your product warranty, this is to confirm the registration is completed.</label><br/><br/><br/>';
    } else if (assetDuplication) {
      body += '<label>The product you intended to register is a duplicated registration, thank you.</label><br/><br/><br/>';
    } else if (flowError) {
      body += '<label>There is an error during the flow execution. A Socomec Agent will contact you shortly.</label><br/><br/><br/>';
    }
    body += '<label>Socomec Support</label><br/><br/>';
    body += logoUrl;
    // body += '<br/><br/><label>[This is a computer generated email]</label>';

    //Set body
    message.setHtmlBody(body);
    return message;
  }

  /**
   * @description : get all informations for Account/Contact creation. Creation will be executed in Flow (to let administrator modify it)
   * @author Vincent RECASENS (Modis) | 01-20-2021
   * @param firstname
   * @param lastname
   * @param email
   * @param mobilephone
   * @param jobTitle
   * @param companyname
   * @param country
   * @param countrycode
   * @param street
   * @param zippostalcode
   * @param city
   * @param state
   * @param mainactivity
   * @param yourorganization
   * @param purchasedcompany
   * @param purchasedcountry
   * @param serialnumber
   * @param product
   * @param purchaseddate
   * @param caseId
   * @param attachmentId
   * @param sendConfirmation
   * @param sendNewsletter
   * @return ResultInformation
   **/
  @AuraEnabled
  public static ResultInformation saveRequest(
    Boolean isPersonAccount,
    String firstname,
    String lastname,
    String email,
    String mobilephone,
    String jobTitle,
    String companyname,
    String country,
    String street,
    String zippostalcode,
    String city,
    String state,
    String mainactivity,
    String yourorganization,
    String purchasedcompany,
    String purchasedcountry,
    String serialnumber,
    String product,
    String purchaseddate,
    String caseId,
    String attachmentId,
    Boolean sendConfirmation,
    Boolean sendNewsletter
  ) {
    //Return object
    WrapperInformation returnObject = new WrapperInformation();
    //Convert date purchased
    returnObject.datePurchased = Date.valueOf(purchaseddate);
    //Keep serial number
    returnObject.serialNumber = serialnumber;
    //Keep caseId to remake it
    returnObject.caseId = caseId != null && caseId != '' ? (Id) caseId : null;
    //Technical user
    SF_Technical_User__mdt soc1 = [
      SELECT UserId__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    returnObject.soc1Id = soc1.UserId__c;
    //Service Territory + Map Country-Subsidiary
    if (!Test.isRunningTest()) {
      returnObject.thServiceTerritory = [
        SELECT Id
        FROM ServiceTerritory
        WHERE Name = 'World'
      ];
      WR_Service_Territory__mdt metadata;
      try {
        //Get Subsidiary
        metadata = [
          SELECT Id, Label, Country_Code__c, Subsidiary__c
          FROM WR_Service_Territory__mdt
          WHERE Country_Code__c = :country
        ];
        //Check Subsidiary
        List<String> countryCodeList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.BillingCountryCode.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
          countryCodeList.add(entry.getValue());
        }
        if (countryCodeList.contains(metadata.Country_Code__c)) {
          returnObject.subsidiary = metadata.Subsidiary__c;
        } else {
          returnObject.subsidiary = '';
        }
        returnObject.countrycode = metadata.Country_Code__c;
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'Country not in the metadata.');
        returnObject.subsidiary = '';
        returnObject.countrycode = country;
      }
    } else {
      OperatingHours oh = new OperatingHours();
      oh.Name = 'World';
      insert oh;
      ServiceTerritory worldST = new ServiceTerritory(
        Name = 'World',
        OperatingHoursId = oh.Id
      );
      insert worldST;
      returnObject.thServiceTerritory = worldST;
      returnObject.subsidiary = '';
      returnObject.countrycode = country;
    }

    //Add account
    returnObject = manageAccount(
      returnObject,
      companyname,
      city,
      zippostalcode,
      street,
      state,
      mainactivity,
      yourorganization
    );
    //Add contact
    returnObject = manageContact(
      returnObject,
      firstname,
      lastname,
      email,
      mobilephone,
      jobTitle,
      sendNewsletter
    );
    //Add Location and address
    returnObject = manageLocationAndAddress(
      returnObject,
      country,
      returnObject.countrycode,
      city,
      zippostalcode,
      street,
      state
    );
    //Add asset
    returnObject = manageAsset(
      returnObject,
      purchasedcompany,
      purchasedcountry
    );
    //Add case
    returnObject = manageCase(returnObject, product);

    //UPSERT
    Boolean upsertSuccess = true;
    // Boolean accountInsert = false;
    //Account
    try {
      returnObject = insertAccount(returnObject);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error during account upsert : ERROR ' + e
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Account Insertion',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      //Return
      upsertSuccess = false;
      return new ResultInformation(
        false,
        'There is an error during account upsert. Verify your information and try agin. If problem persist, call your Salesforce administrator.'
      );
    }
    //Contact
    try {
      returnObject = insertContact(returnObject, sendNewsletter, jobTitle);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error during contact upsert : ERROR ' + e
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Contact Insertion',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      //Return
      upsertSuccess = false;
      return new ResultInformation(
        false,
        'There is an error during contact upsert. Verify your information and try agin. If problem persist, call your Salesforce administrator.'
      );
    }
    //Location & Address
    try {
      returnObject = insertLocationAndaddress(returnObject);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error location and address upserts : ERROR ' + e
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Location&Address Insertion',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      //Return
      upsertSuccess = false;
      return new ResultInformation(
        false,
        'There is an error during location&address upsert. Verify your information and try agin. If problem persist, call your Salesforce administrator.'
      );
    }
    //Asset
    try {
      returnObject = insertAsset(returnObject);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error asset upserts : ERROR ' + e
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Asset Upsert',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      //Return
      upsertSuccess = false;
      return new ResultInformation(
        false,
        'There is an error during asset upsert. Verify your information and try agin. If problem persist, call your Salesforce administrator.'
      );
    }

    //Case
    try {
      returnObject.theCase = insertCase(returnObject, returnObject.theCase);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error case insert : ERROR ' + e
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Case Insert',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      upsertSuccess = false;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      return new ResultInformation(
        false,
        'There is an error during case insert. Verify your information and try agin. If problem persist, call your Salesforce administrator.'
      );
    }

    //CaseComment
    try {
      insertCaseComment(returnObject);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error case upserts : ERROR ' + e
      );

      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - CaseComment',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      //Return
      upsertSuccess = false;
      return new ResultInformation(true, System.Label.SMC_WR_Case_Registered);
    }

    //Send email for duplication
    try {
      if (returnObject.assetIsDuplicate) {
        sendEmail(
          returnObject.assetIsDuplicate,
          false,
          false,
          returnObject.theContact.FirstName +
          ' ' +
          returnObject.theContact.LastName,
          returnObject.theContact.Email
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error case upserts : ERROR ' + e
      );

      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - Send email for duplication',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      if (upsertSuccess) {
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = returnObject.theCase.Id;
        caseComment.CommentBody = 'There is an error when sending email for duplication.. See logs for more information.';
        caseComment.IsPublished = true;
        insert caseComment;
      }
      //Return
      upsertSuccess = false;
      return new ResultInformation(true, System.Label.SMC_WR_Case_Registered);
    }

    //Check file uploaded
    if (attachmentId != null && attachmentId != '') {
      try {
        uploadFile(returnObject, attachmentId);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'There is an error case upserts : ERROR ' + e
        );

        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<Exception>{ e },
          'Warranty Registration - File assignment',
          STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
          'Error : ' + e.getMessage(),
          null,
          new List<String>{ UserInfo.getUsername() }
        );
        if (upsertSuccess) {
          CaseComment caseComment = new CaseComment();
          caseComment.ParentId = returnObject.theCase.Id;
          caseComment.CommentBody =
            'There is an error during file assignment. Document id [' +
            returnObject.contentDocumentId +
            ']. See logs for more information.';
          caseComment.IsPublished = true;
          insert caseComment;
        }
        //Return
        return new ResultInformation(true, System.Label.SMC_WR_Case_Registered);
      }
    }

    //Send emails for success
    if (upsertSuccess && sendConfirmation && !returnObject.assetIsDuplicate) {
      try {
        sendEmail(
          false,
          false,
          upsertSuccess,
          returnObject.theContact.FirstName +
          ' ' +
          returnObject.theContact.LastName,
          returnObject.theContact.Email
        );
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'There is an error send confirmation email : ERROR ' + e
        );
        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<Exception>{ e },
          'Warranty Registration - Send success email',
          STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
          'Error : ' + e.getMessage(),
          null,
          new List<String>{ UserInfo.getUsername() }
        );
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = returnObject.theCase.Id;
        caseComment.CommentBody = 'There is an error when sending success email. See logs for more information.';
        caseComment.IsPublished = true;
        insert caseComment;
        //Return
        return new ResultInformation(
          true,
          'There is an error when sending confirmation email but your case is recorded.'
        );
      }
    }

    //Update Case
    try {
      returnObject.theCase = updateCase(returnObject, returnObject.theCase, upsertSuccess);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is an error case upserts : ERROR ' + e
      );

      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'Warranty Registration - CaseComment / Send email for duplication / Case update',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
        'Error : ' + e.getMessage(),
        null,
        new List<String>{ UserInfo.getUsername() }
      );
      if (upsertSuccess) {
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = returnObject.theCase.Id;
        caseComment.CommentBody = 'There is an error during case update : owner assignment and case closure are not executed. See logs for more information.';
        caseComment.IsPublished = true;
        insert caseComment;
      }
      //Return
      upsertSuccess = false;
      // PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      return new ResultInformation(true, System.Label.SMC_WR_Case_Registered);
    }

    //Return without error
    return new ResultInformation(true, System.Label.SMC_WR_Case_Registered);
  }

  @TestVisible
  private static WrapperInformation insertAccount(WrapperInformation returnObject){
    if (returnObject.theAccount.Id == null) {
      // accountInsert = true;
      Account tmpAccount = returnObject.theAccount;
      insert tmpAccount;
      returnObject.theAccount = tmpAccount;
    } else {
      update returnObject.theAccount;
    }

    return returnObject;
  }

  @TestVisible
  private static WrapperInformation insertContact(WrapperInformation returnObject, Boolean sendNewsletter, String jobTitle){
    Contact tmpContact = returnObject.theContact;
    if (!returnObject.contactIsDuplicate) {
      tmpContact.AccountId = returnObject.theAccount.Id;
      insert tmpContact;
      returnObject.theContact = tmpContact;
    } else {
      Boolean updateContact = false;
      if (sendNewsletter != tmpContact.SMC_Warranty_Reg_Newsletter__c) {
        tmpContact.SMC_Warranty_Reg_Newsletter__c = sendNewsletter;
        updateContact = true;
      }
      if (
        tmpContact.SMC_Job_title__c == null ||
        tmpContact.SMC_Job_title__c == ''
      ) {
        tmpContact.SMC_Job_title__c = jobTitle;
        updateContact = true;
      }
      if (updateContact) {
        update tmpContact;
      }
      returnObject.theContact = tmpContact;
    }

    return returnObject;
  }

  @TestVisible
  private static WrapperInformation insertLocationAndAddress(WrapperInformation returnObject){
    if (!returnObject.assetIsDuplicate) {
      //Location
      Schema.Location tmpLocation = returnObject.theLocation;
      tmpLocation.SMC_Site_Account__c = returnObject.theAccount.Id;
      insert tmpLocation;
      returnObject.theLocation = tmpLocation;
      //Address
      Schema.Address tmpAddress = returnObject.theAddress;
      tmpAddress.ParentId = tmpLocation.Id;
      insert tmpAddress;
      returnObject.theAddress = tmpAddress;
      //Location update
      tmpLocation.SMC_Address__c = tmpAddress.Id;
      update tmpLocation;
      returnObject.theLocation = tmpLocation;
    }

    return returnObject;
  }

  @TestVisible
  private static WrapperInformation insertAsset(WrapperInformation returnObject){
    Asset tmpAsset = returnObject.theAsset;
    tmpAsset.AccountId = returnObject.theAccount.Id;
    tmpAsset.ContactId = returnObject.theContact.Id;
    tmpAsset.LocationId = returnObject.theLocation.Id;
    tmpAsset.SMC_NotCommissionBySocomec__c = true;
    if (!returnObject.assetIsDuplicate && !returnObject.assetExist) {
      insert tmpAsset;
      returnObject.theAsset = tmpAsset;
    } else if (!returnObject.assetIsDuplicate && returnObject.assetExist) {
      tmpAsset.SMC_Warranty_Status__c = 'Not Validated';
      update tmpAsset;
      returnObject.theAsset = tmpAsset;
    }

    return returnObject;
  }

  @TestVisible
  private static Case insertCase(WrapperInformation returnObject, Case tmpCase){
    tmpCase.AccountId = returnObject.theAccount.Id;
    tmpCase.ContactId = returnObject.theContact.Id;
    tmpCase.AssetId = returnObject.theAsset.Id;
    //Check form field "Product" to bypass Case validation "SMC_KeyInformation"
    User currentUser;
    if(tmpCase.Description != null && tmpCase.Description != ''){
      currentUser = [SELECT Id, Bypass_Validation_Rule__c FROM User WHERE Id = :UserInfo.getUserId()];
      currentUser.Bypass_Validation_Rule__c = 
        (currentUser.Bypass_Validation_Rule__c != null ? currentUser.Bypass_Validation_Rule__c + ';' : '') + 'SMC_KeyInformation;SMC_Case_CantModifyWithoutAcceptation';
      update currentUser;
    }

    PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    if (tmpCase.Id == null) {
      insert tmpCase;
    }
    else{
      update tmpCase;
    }
    PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);

    if(currentUser != null){
      currentUser.Bypass_Validation_Rule__c = 
        currentUser.Bypass_Validation_Rule__c.split(';').size() > 2 ?
          currentUser.Bypass_Validation_Rule__c.removeEnd(';SMC_KeyInformation;SMC_Case_CantModifyWithoutAcceptation') : null;
      update currentUser;
    }

    if(!Test.isRunningTest()){
      //Set option to reassign Case to the rigth Queue
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.AssignmentRuleHeader.useDefaultRule = true;
      //DML Option
      tmpCase.setOptions(dmo);
      //Bypass trigger cause execute Trigger.Update before finish Trigger.Insert
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      update tmpCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      
      tmpCase = [SELECT Id, OwnerId, SMC_Expert_Queue__c, Status, SMC_Sub_Status__c, SMC_Take_Ownership__c FROM Case WHERE Id = :tmpCase.Id];
    }

    return tmpCase;
  }
  
  @TestVisible
  private static void insertCaseComment(WrapperInformation returnObject){
    //CaseComment for contact duplication
    if (returnObject.contactIsDuplicate) {
      CaseComment caseComment = new CaseComment();
      caseComment.ParentId = returnObject.theCase.Id;
      caseComment.CommentBody = 'Duplicated contacts have been detected for this case.';
      caseComment.IsPublished = true;
      insert caseComment;
    }
    //CaseComment+Email for asset duplication
    if (returnObject.assetIsDuplicate) {
      CaseComment caseComment = new CaseComment();
      caseComment.ParentId = returnObject.theCase.Id;
      caseComment.CommentBody = 'This warranty has been already registered.';
      caseComment.IsPublished = true;
      insert caseComment;
    }
  }

  @TestVisible
  private static Case updateCase(WrapperInformation returnObject, Case tmpCase, Boolean upsertSuccess){
    if(!Test.isRunningTest()){
      tmpCase.SMC_Expert_Queue__c = [SELECT Id FROM Account WHERE SMC_Queue_ID__c = :tmpCase.OwnerId].Id;
      update tmpCase;
    }

    //Update Case to close it if it is not a duplication
    if (upsertSuccess && !returnObject.assetIsDuplicate) {
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      tmpCase.Status = 'Closed';
      tmpCase.SMC_Sub_Status__c = 'Closed';
      tmpCase.SMC_Take_Ownership__c = true;
      //update Case to put SOC1 has case owner
      tmpCase.OwnerId = returnObject.soc1Id;
      update tmpCase;
      returnObject.theCase = tmpCase;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
    }

    return tmpCase;
  }

  @TestVisible
  private static void uploadFile(WrapperInformation returnObject, String attachmentId){
    //Keep attachmentId to convert it
    returnObject.contentDocumentId = attachmentId;
    // returnObject = manageAttachmentConversion(returnObject);
    ContentDocumentLink cdlCase = new ContentDocumentLink();
    cdlCase.ContentDocumentId = returnObject.contentDocumentId;
    cdlCase.LinkedEntityId = returnObject.theCase.Id;
    ContentDocumentLink cdlContact = new ContentDocumentLink();
    cdlContact.ContentDocumentId = returnObject.contentDocumentId;
    cdlContact.LinkedEntityId = returnObject.theContact.Id;
    insert new List<ContentDocumentLink>{ cdlCase, cdlContact };
  }
}