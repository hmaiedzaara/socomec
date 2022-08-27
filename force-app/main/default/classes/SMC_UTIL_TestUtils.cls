/*
---------------------------------------------------------------------
-- - Name          : SMC_UTIL_TestUtils
-- - Author        : Xavier BRANCHE (XBR)
-- - Description   : helping methodes for test classes               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 11-Dec-2017  DOS    1.3     Add class to manage Quote WS Test
-- 25-Aug-2017  DOS    1.2     Add class to manage AccountActors Trigger Test
-- 23-Aug-2017  DOS    1.1     Add class to manage Event Trigger Test
-- 31-Mai-2017  XBR    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public without sharing class SMC_UTIL_TestUtils {
  //create testUser
  public static User createTestUser(String strProfile) {
    Profile profile = [SELECT Id FROM Profile WHERE Name = :strProfile];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Duplicate_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    return user;
  }

  // create a new user
  public static User createUser(
    String lastName,
    String email,
    Id profileId,
    String username,
    String communityNickname
  ) {
    User user = new User();
    user.LastName = lastName;
    user.Email = email;
    user.ProfileId = profileId;
    user.Username = username;
    user.CommunityNickname = communityNickname;
    user.Alias = STA_UtilsStatic.TEST;
    user.TimeZoneSidKey = STA_UtilsStatic.USER_FIELD_TIME_ZONE;
    user.LocaleSidKey = STA_UtilsStatic.USER_FIELD_LOCALEKEY;
    user.EmailEncodingKey = STA_UtilsStatic.USER_FIELD_EMAIL_ENCODING;
    user.LanguageLocaleKey = STA_UtilsStatic.USER_FIELD_LANGUAGE;
    user.isactive = true;
    return user;
  }

  // create a new Account
  public static Account createAccount(
    Id recordTypeID,
    String name,
    String type,
    String billingCountry
  ) {
    Account account = new Account();
    account.RecordTypeID = recordTypeID;
    account.Name = name;
    account.Type = type;
    account.BillingCountry = billingCountry;
    return account;
  }

  // create a new Account with address and pilot by ba
  public static Account createAccount(
    Id recordTypeID,
    String name,
    String type,
    String billingStreet,
    String billingPostalCode,
    String billingCity,
    String billingState,
    String billingCountry,
    Id SMC_PCS_Pilot,
    Id SMC_EE_Pilot,
    Id SMC_PCO_Pilot,
    Id SMC_SERVICE_Pilot,
    Id SMC_ESS_Pilot
  ) {
    Account account = new Account();
    account.RecordTypeID = recordTypeID;
    account.Name = name;
    account.Type = type;
    account.BillingStreet = billingStreet;
    account.BillingPostalCode = billingPostalCode;
    account.BillingCity = billingCity;
    account.BillingState = billingState;
    account.BillingCountry = billingCountry;
    account.SMC_PCS_Pilot__c = SMC_PCS_Pilot;
    account.SMC_EE_Pilot__c = SMC_EE_Pilot;
    account.SMC_PCO_Pilot__c = SMC_PCO_Pilot;
    account.SMC_SERVICE_Pilot__c = SMC_SERVICE_Pilot;
    account.SMC_ESS_Pilot__c = SMC_ESS_Pilot;
    return account;
  }

  //creates a TeamMember called from this.insertTeamMember
  public static AccountTeamMember createTeamMember(Id accountId, Id userId) {
    AccountTeamMember teamMember = new AccountTeamMember();
    teamMember.TeamMemberRole = STA_UtilsStatic.ROLE_COPILOT;
    teamMember.AccountId = accountId;
    teamMember.AccountAccessLevel = STA_UtilsStatic.ROLE_R_W;
    teamMember.CaseAccessLevel = STA_UtilsStatic.ROLE_R;
    teamMember.OpportunityAccessLevel = STA_UtilsStatic.ROLE_R;
    teamMember.ContactAccessLevel = STA_UtilsStatic.ROLE_R_W;
    teamMember.UserId = userId;
    return teamMember;
  }

  //create a new Opportunity
  public static Opportunity createOpportunity(
    Id recordTypeId,
    String name,
    String stage
  ) {
    Opportunity o = new Opportunity();
    o.RecordTypeId = recordTypeId;
    o.Name = name;
    o.StageName = stage;
    o.CloseDate = Date.today().addMonths(1);
    o.SMC_Success_Rate_Range__c = '80';
    return o;
  }

  //create a new Opportunity
  public static Opportunity createOpportunity(
    Id recordTypeId,
    String name,
    String stage,
    Account account,
    Contact contact
  ) {
    Opportunity o = new Opportunity();
    o.RecordTypeId = recordTypeId;
    o.Name = name;
    o.StageName = stage;
    o.CloseDate = Date.today().addMonths(1);
    o.SMC_Success_Rate_Range__c = '80';
    o.AccountId = account.Id;
    o.SMC_Primary_Contact__c = contact.Id;
    return o;
  }

  // create a new Lead
  public static Lead createLead(
    String source,
    String company,
    String firstName,
    String lastName,
    String phone,
    String email,
    String street,
    String postalCode,
    String city,
    String state,
    String country
  ) {
    Lead l = new Lead();
    l.LeadSource = source;
    l.Company = company;
    l.FirstName = firstName;
    l.LastName = lastName;
    l.Phone = phone;
    l.Email = email;
    l.Street = street;
    l.PostalCode = postalCode;
    l.City = city;
    l.State = state;
    l.Country = country;
    return l;
  }

  // create a new Contact
  public static Contact createContact(
    String firstName,
    String lastName,
    String phone,
    String mobilePhone,
    String email,
    String mailingStreet,
    String mailingPostalCode,
    String mailingCity,
    String mailingState,
    String mailingCountry,
    String OtherCity,
    Id accountId
  ) {
    Contact c = new Contact();
    c.FirstName = firstName;
    c.LastName = lastName;
    c.Phone = phone;
    c.MobilePhone = mobilePhone;
    c.Email = email;
    c.MailingStreet = mailingStreet;
    c.MailingPostalCode = mailingPostalCode;
    c.MailingCity = mailingCity;
    c.MailingState = mailingState;
    c.MailingCountry = mailingCountry;
    c.OtherCity = OtherCity;
    c.AccountId = accountId;
    return c;
  }

  // create a new Event
  public static Event createEvent(
    Id ownerId,
    Id whatId,
    Id whoId,
    String subject,
    String description,
    String location,
    Datetime startDateTime,
    dateTime endDateTime
  ) {
    Event e = new Event();
    e.Subject = subject;
    e.StartDateTime = startDateTime;
    e.EndDateTime = endDateTime;
    if (ownerId != null) {
      e.OwnerId = ownerId;
    }
    if (whatId != null) {
      e.WhatId = whatId;
    }
    if (whoId != null) {
      e.WhoId = whoId;
      //e.EventWhoIds = new List<Id> {whoId}; Field not writable consequence not possible to test some functions which use this field
    }
    if (!string.isEmpty(description)) {
      e.Description = description;
    }
    if (!string.isEmpty(location)) {
      e.Location = location;
    }

    return e;
  }

  // create a new Event
  public static Event createEvent(
    Id ownerId,
    Id whatId,
    Id whoId,
    String subject,
    String description,
    String location,
    Datetime startDateTime,
    dateTime endDateTime,
    Integer durationInMinutes
  ) {
    Event e = new Event();
    e.Subject = subject;
    e.StartDateTime = startDateTime;
    e.EndDateTime = endDateTime;
    e.DurationInMinutes = durationInMinutes;
    if (ownerId != null) {
      e.OwnerId = ownerId;
    }
    if (whatId != null) {
      e.WhatId = whatId;
    }
    if (whoId != null) {
      e.WhoId = whoId;
      //e.EventWhoIds = new List<Id> {whoId}; Field not writable consequence not possible to test some functions which use this field
    }
    if (!string.isEmpty(description)) {
      e.Description = description;
    }
    if (!string.isEmpty(location)) {
      e.Location = location;
    }

    return e;
  }

  // create a new EventRelation
  public static EventRelation createEventRelation(
    Id eventId,
    Id relationId,
    Boolean isInvitee
  ) {
    EventRelation oneEventRelation = new EventRelation();
    oneEventRelation.EventId = eventId;
    oneEventRelation.RelationId = relationId;
    oneEventRelation.IsInvitee = isInvitee;
    return oneEventRelation;
  }

  // create a new account actors record
  public static SMC_Account_Actors__c createAccountActors(
    Id p_accountId,
    Id p_linkedAccountId
  ) {
    SMC_Account_Actors__c aa = new SMC_Account_Actors__c();
    aa.SMC_Account_Actors__c = p_accountId;
    aa.SMC_Linked_Account__c = p_linkedAccountId;
    return aa;
  }

  // create a new opportunity actors record
  public static SMC_Opportunity_Actors__c createOpportunityActors(
    Id p_opportunityId,
    Id p_accountId,
    Id p_contactId,
    Boolean isTarget
  ) {
    SMC_Opportunity_Actors__c oa = new SMC_Opportunity_Actors__c();
    oa.SMC_Opportunity_Actors__c = p_opportunityId;
    oa.SMC_Account_Linked__c = p_accountId;
    oa.Contact__c = p_contactId;
    oa.SMC_Is_Favorite_Account__c = isTarget;
    return oa;
  }

  // create a new quote record
  public static Quote createQuote(
    Id p_opportunityId,
    String p_name,
    Id p_accountId
  ) {
    Quote quo = new Quote();
    quo.Name = p_name;
    quo.OpportunityId = p_opportunityId;
    quo.CurrencyIsoCode = STA_UtilsStatic.CURRENCY_EUR;
    quo.SMC_Account__c = p_accountId;
    return quo;
  }

  // create a new case record
  public static Case createCase(
    String subject,
    String description,
    String type,
    String sub_Status
  ) {
    Case oneCase = new Case();
    oneCase.Subject = subject;
    oneCase.Description = description;
    oneCase.Type = type;
    oneCase.SMC_Sub_Status__c = sub_Status;
    return oneCase;
  }

  // create a new case record
  public static Case createCase(
    String subject,
    String description,
    String type,
    String status,
    String sub_Status
  ) {
    Case oneCase = new Case();
    oneCase.Subject = subject;
    oneCase.Description = description;
    oneCase.Type = type;
    oneCase.Status = status;
    oneCase.SMC_Sub_Status__c = sub_Status;
    return oneCase;
  }

  // create a new case comment record
  public static CaseComment createCaseComment(
    Id parentId,
    String commentbody,
    Boolean isPublished
  ) {
    CaseComment oneCaseComment = new CaseComment();
    oneCaseComment.ParentId = parentId;
    oneCaseComment.CommentBody = commentbody;
    oneCaseComment.IsPublished = isPublished;
    return oneCaseComment;
  }

  // create a new email message record
  public static EmailMessage createEmailMessage(
    Id parentId,
    String textBody,
    String subject,
    String fromName,
    String fromAddress,
    String validatedFromAddress,
    String toAddress
  ) {
    EmailMessage oneEmailMessage = new EmailMessage();
    oneEmailMessage.ParentId = parentId;
    oneEmailMessage.TextBody = textBody;
    oneEmailMessage.Subject = subject;
    oneEmailMessage.FromName = fromName;
    oneEmailMessage.FromAddress = fromAddress;
    // oneEmailMessage.ValidatedFromAddress = validatedFromAddress;
    oneEmailMessage.ToAddress = toAddress;
    return oneEmailMessage;
  }

  // create a new content document link record
  public static ContentDocumentLink createContentDocumentLink(
    Id linkedEntityId,
    Id contentDocumentId,
    String shareType,
    String visibility
  ) {
    ContentDocumentLink oneContentDocumenLink = new ContentDocumentLink();
    oneContentDocumenLink.LinkedEntityId = linkedEntityId;
    oneContentDocumenLink.ContentDocumentId = contentDocumentId;
    oneContentDocumenLink.ShareType = shareType;
    oneContentDocumenLink.Visibility = visibility;
    return oneContentDocumenLink;
  }

  // create a new content document link record
  public static SMC_Business_Plan__c createBusinessPlan(
    String name,
    Id accountId
  ) {
    SMC_Business_Plan__c oneBusinessPlan = new SMC_Business_Plan__c();
    oneBusinessPlan.Name = name;
    oneBusinessPlan.SMC_Account__c = accountId;
    return oneBusinessPlan;
  }

  // create a new asset
  public static Product2 createProductFSL(
    Id recordTypeId,
    String name,
    Boolean isActive
  ) {
    Product2 oneProduct = new Product2();
    oneProduct.RecordTypeId = recordTypeId;
    oneProduct.Name = name;
    oneProduct.IsActive = isActive;
    return oneProduct;
  }

  // create a new asset
  public static Product2 createServiceProductFSL(
    Id recordTypeId,
    String name,
    Boolean isActive,
    String productCode,
    String manufacturer,
    String range,
    String model,
    String configuration,
    String phase,
    String power,
    String powerUnit
  ) {
    Product2 oneProduct = new Product2();
    oneProduct.RecordTypeId = recordTypeId;
    oneProduct.Name = name;
    oneProduct.IsActive = isActive;
    oneProduct.ProductCode = productCode;
    oneProduct.SMC_Manufacturer_p__c = manufacturer;
    oneProduct.SMC_Range_p__c = range;
    oneProduct.SMC_Model_p__c = model;
    oneProduct.SMC_Configuration_p__c = configuration;
    oneProduct.SMC_Phase_p__c = phase;
    oneProduct.SMC_Power_p__c = power;
    oneProduct.SMC_Power_Unit_p__c = powerUnit;
    return oneProduct;
  }

  // create a new GTL line
  public static SMC_GTL__c createGTL(
    id prodId,
    String itemCode,
    String status
  ) {
    SMC_GTL__c oneGTL = new SMC_GTL__c();
    oneGTL.SMC_Spare_Part__c = prodId;
    oneGTL.SMC_Quantity__c = 1;
    oneGTL.SMC_Status_GTL__c = status;
    return oneGTL;
  }

  // create a new association GTL/ServiceProduct
  public static SMC_GtlServiceProductAssociation__c createGTLServiceProductAssociation(
    Id productId,
    Id ltgId
  ) {
    SMC_GtlServiceProductAssociation__c gtlAssociation = new SMC_GtlServiceProductAssociation__c();
    gtlAssociation.SMC_Service_Product__c = productId;
    gtlAssociation.SMC_Logistic_Technical_Guide__c = ltgId;
    return gtlAssociation;
  }

  // create a new asset
  public static Asset createAsset(
    Id recordTypeId,
    Id parentId,
    String name,
    Id productId,
    Id soldProductId,
    String serialNumberSoco
  ) {
    Asset oneAsset = new Asset();
    oneAsset.RecordTypeId = recordTypeId;
    oneAsset.ParentId = parentId;
    oneAsset.Name = name;
    oneAsset.Product2Id = productId;
    oneAsset.SMC_Sold_Product_Item__c = soldProductId;
    oneAsset.SMC_SerialNumber__c = serialNumberSoco;
    oneAsset.InstallDate = Date.today();
    return oneAsset;
  }

  // create a new asset
  public static Asset createAsset(
    Id recordTypeId,
    Id parentId,
    Id accountId,
    Id contactId,
    String name,
    Id productId,
    Id soldProductId,
    String serialNumberSoco
  ) {
    Asset oneAsset = new Asset();
    oneAsset.RecordTypeId = recordTypeId;
    oneAsset.ParentId = parentId;
    oneAsset.AccountId = accountId;
    oneAsset.ContactId = contactId;
    oneAsset.Name = name;
    oneAsset.Product2Id = productId;
    oneAsset.SMC_Sold_Product_Item__c = soldProductId;
    oneAsset.SMC_SerialNumber__c = serialNumberSoco;
    oneAsset.InstallDate = Date.today();
    return oneAsset;
  }

  // create a new asset
  public static Asset createAsset(
    Id recordTypeId,
    String name,
    Id productId,
    String serialNumber
  ) {
    Asset oneAsset = new Asset();
    oneAsset.RecordTypeId = recordTypeId;
    oneAsset.Name = name;
    oneAsset.Product2Id = productId;
    oneAsset.SerialNumber = serialNumber;
    oneAsset.InstallDate = Date.today();
    return oneAsset;
  }

  // create a work order
  public static WorkOrder createWorkOrder(Id assetId) {
    WorkOrder oneWorkOrder = new WorkOrder();
    oneWorkOrder.AssetId = assetId;
    return oneWorkOrder;
  }

  // create a work order
  public static WorkType createWorkType(
    String name,
    Decimal estimatedDuration
  ) {
    WorkType oneWorkType = new WorkType();
    oneWorkType.Name = name;
    oneWorkType.EstimatedDuration = estimatedDuration;
    return oneWorkType;
  }

  // create a work order line item
  public static WorkOrderLineItem createWorkOrderLineItem(
    Id workOrderId,
    Id assetId
  ) {
    WorkOrderLineItem oneWorkOrderLineItem = new WorkOrderLineItem();
    oneWorkOrderLineItem.AssetId = assetId;
    oneWorkOrderLineItem.WorkOrderId = workOrderId;
    return oneWorkOrderLineItem;
  }

  // create a skill requirement
  public static SkillRequirement createSkillRequirement(
    Id skillId,
    Id relatedRecordId
  ) {
    SkillRequirement oneSkillRequirement = new SkillRequirement();
    oneSkillRequirement.SkillId = skillId;
    oneSkillRequirement.RelatedRecordId = relatedRecordId;
    return oneSkillRequirement;
  }

  //create Location (Schema.Location)
  public static Schema.Location createLocation(String name) {
    Schema.Location oneLocation = new Schema.Location();
    oneLocation.Name = name;
    return oneLocation;
  }

  //create Associated Location
  public static AssociatedLocation createAssociatedLocation(
    Id locationId,
    Id parentRecordId
  ) {
    AssociatedLocation oneAssociatedLocation = new AssociatedLocation();
    oneAssociatedLocation.LocationId = locationId;
    oneAssociatedLocation.ParentRecordId = parentRecordId;
    return oneAssociatedLocation;
  }

  //create Territory2
  public static Territory2 createTerritory2(
    String devName,
    String name,
    Id modelId,
    Id territory2TypeId
  ) {
    Territory2 theTerritory = new Territory2();
    theTerritory.DeveloperName = devName;
    theTerritory.Name = name;
    theTerritory.Territory2ModelId = modelId;
    theTerritory.Territory2TypeId = territory2TypeId;
    return theTerritory;
  }

  //create Territory2ModelId
  public static Territory2Model createTerritory2Model(
    String devName,
    String name
  ) {
    Territory2Model theTerritoryModel = new Territory2Model();
    theTerritoryModel.DeveloperName = devName;
    theTerritoryModel.Name = name;
    return theTerritoryModel;
  }

  //create UserTerritory2Association
  public static UserTerritory2Association createUserTerritory2Association(
    Id territoryId,
    Id userId
  ) {
    UserTerritory2Association theUserTerritory2Association = new UserTerritory2Association();
    theUserTerritory2Association.Territory2Id = territoryId;
    theUserTerritory2Association.UserId = userId;
    return theUserTerritory2Association;
  }

  //create ERP Invoice
  public static SMC_ERP_Invoice__c createERPInvoice(
    String erpInvoiceNumber,
    Decimal erpFinancialId,
    String accountId
  ) {
    SMC_ERP_Invoice__c erpInvoice = new SMC_ERP_Invoice__c();
    erpInvoice.Name = erpInvoiceNumber;
    erpInvoice.SMC_Account__c = accountId;
    erpInvoice.SMC_FinancialId__c = erpFinancialId;
    return erpInvoice;
  }

  //create ERP Order
  public static SMC_ERP_Order__c createERPOrder(
    String erpOrderNumber,
    Decimal erpFinancialId,
    String accountId
  ) {
    SMC_ERP_Order__c erpOrder = new SMC_ERP_Order__c();
    erpOrder.Name = erpOrderNumber;
    erpOrder.SMC_Account__c = accountId;
    erpOrder.SMC_FinancialId__c = erpFinancialId;
    return erpOrder;
  }

  //create ERP Quote
  public static SMC_ERP_Quote__c createERPQuote(
    String erpQuoteDescription,
    Decimal erpFinancialId,
    String accountId
  ) {
    SMC_ERP_Quote__c erpQuote = new SMC_ERP_Quote__c();
    erpQuote.Name = erpQuoteDescription;
    erpQuote.SMC_Account__c = accountId;
    erpQuote.SMC_FinancialId__c = erpFinancialId;
    return erpQuote;
  }

  public static SMC_Community_Message__c createCommunityMessage(
    String sendFrom,
    String title,
    String message,
    Id contactId
  ) {
    SMC_Community_Message__c oneMessage = new SMC_Community_Message__c();
    oneMessage.SMC_Send_From__c = sendFrom;
    oneMessage.Title__c = title;
    oneMessage.Message__c = message;
    oneMessage.Recipient_Contact__c = contactId;
    return oneMessage;
  }

  //create Warehouse (Schema.Location)
  public static Schema.Location createWarehouse(String name) {
    Schema.Location oneLocation = new Schema.Location();
    oneLocation.Name = name;
    oneLocation.LocationType = 'Warehouse';
    oneLocation.IsInventoryLocation = true;
    return oneLocation;
  }

  //Contract
  public static Contract createContract(String name, Id accountId) {
    Contract oneContract = new Contract();
    oneContract.Name = name;
    oneContract.AccountId = accountId;
    oneContract.StartDate = Date.today();
    oneContract.ContractTerm = 12;
    return oneContract;
  }

  //Contract Subscription
  public static SMC_Contract_Subscription__c createContractSubscription(
    Id contractId,
    Id productId
  ) {
    SMC_Contract_Subscription__c oneSubscription = new SMC_Contract_Subscription__c();
    oneSubscription.Contract__c = contractId;
    oneSubscription.Product__c = productId;
    return oneSubscription;
  }

  //PRM Quote
  public static SMC_PRM_Quote__c createPRMQuote(Id quoteId){
    SMC_PRM_Quote__c prmQuote = new SMC_PRM_Quote__c();
    prmQuote.Quote__c = quoteId;
    return prmQuote;
  }

  //Training
  public static SMC_Training__c createTraining(String name, String code, Integer nbMaxOfAttendees){
    SMC_Training__c training = new SMC_Training__c();
    training.Name = name;
    training.SMC_Code__c = code;
    training.SMC_Nb_Max_of_Attendees__c = nbMaxOfAttendees;
    return training;
  }

  //Training Certificate
  public static SMC_TrainingCertificate__c createTrainingCertificate(String name, 
                                                                     String certificationCode, 
                                                                     String template){
    SMC_TrainingCertificate__c trainingCertificate = new SMC_TrainingCertificate__c();
    trainingCertificate.Name = name;
    trainingCertificate.SMC_CertificateCode__c = certificationCode;
    trainingCertificate.SMC_Template__c = template;
    return trainingCertificate;
  }

  //Training Session
  public static SMC_TrainingSession__c createTrainingSession(String name, 
                                                             String status, 
                                                             Id trainingId,
                                                             Id trainerId){
    SMC_TrainingSession__c trainingSession = new SMC_TrainingSession__c();
    trainingSession.Name = name;
    trainingSession.SMC_Status__c = status;
    trainingSession.SMC_Training__c = trainingId;
    trainingSession.SMC_Trainer__c = trainerId;
    return trainingSession;
  }

  //Training Participant
  public static SMC_TrainingParticipant__c createTrainingParticipant(Id contactOrUserId, 
                                                                     Id trainingSessionId){
    SMC_TrainingParticipant__c trainingParticipant = new SMC_TrainingParticipant__c();
    trainingParticipant.SMC_TrainingSession__c = trainingSessionId;
    if(Schema.User.SObjectType == contactOrUserId.getSobjectType())
      trainingParticipant.SMC_User__c = contactOrUserId;
    else
      trainingParticipant.SMC_Contact__c = contactOrUserId;
    return trainingParticipant;
  }

  //Work Type / Service Product Association
  public static SMC_WorkTypeServiceProductAssociation__c createWorkTypeServiceProductAssociation(Id serviceProductId, Id workTypeId){
    SMC_WorkTypeServiceProductAssociation__c  wtSpAssociation = new SMC_WorkTypeServiceProductAssociation__c();
    wtSpAssociation.SMC_Service_Product__c = serviceProductId;
    wtSpAssociation.SMC_Work_Type__c = workTypeId;
    return wtSpAssociation;
  }
}