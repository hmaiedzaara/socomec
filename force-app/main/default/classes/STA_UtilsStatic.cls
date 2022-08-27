/*
---------------------------------------------------------------------
-- - Name          : STA_UtilsStatic
-- - Author        : Xavier BRANCHE (XBR)
-- - Description   : static Resources for  apex class              
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 25-Aug-2017  DOS    1.2     Add vars for AccountActors
-- 08-Jun-2017  DOS    1.1     Add vars for Event
-- 30-Mai-2017  XBR    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public without sharing class STA_UtilsStatic {
  /* ROLE */
  public static final String ROLE_R_W = 'Edit';
  public static final String ROLE_R = 'Read';
  public static final String ROLE_PILOT = 'Pilot';
  public static final String ROLE_COPILOT = 'Co-pilot';
  public static final String ROLE_OWNER = 'Owner';

  /* USER ROLE */
  public static final String ROLE_CEO_DEVNAME = 'CEO';
  public static final String ROLE_GCO_DEVNAME = 'GCO';
  public static final String ROLE_SUPPORT_DEVNAME = 'Support';
  public static final String ROLE_BE_DEVNAME = 'BE';
  public static final String ROLE_SALES_MANAGER_SBG_PCO_SERV_DEVNAME = 'Sales_Manager_SBG_PCO_SERV';

  /*CLASS*/
  public static final String CLASS_ACCOUNT_MANAGEMENT = 'SMC_TGR_AccountTrigger';
  public static final String CLASS_SMCACCOUNTACTORS_MANAGEMENT = 'SMC_TGR_SMCAccountActors';
  public static final String CLASS_ASSET_MANAGEMENT = 'SMC_TGR_AssetTrigger';
  public static final String CLASS_GTL_MANAGEMENT = 'SMC_TGR_GTLTrigger';
  public static final String CLASS_EVENT_MANAGEMENT = 'SMC_TGR_EventTrigger';
  public static final String CLASS_CONTACT_MANAGEMENT = 'SMC_TGR_ContactTrigger';
  public static final String CLASS_CASE_MANAGEMENT = 'SMC_TGR_CaseTrigger';
  public static final String CLASS_CASECOMMENT_MANAGEMENT = 'SMC_TGR_CaseCommentTrigger';
  public static final String CLASS_EMAILMESSAGE_MANAGEMENT = 'SMC_TGR_EmailMessageTrigger';
  public static final String CLASS_CONTENTVERSION_MANAGEMENT = 'SMC_TGR_ContentVersion';
  public static final String CLASS_CONTENTDOCUMENT_MANAGEMENT = 'SMC_TGR_ContentDocument';
  public static final String CLASS_CONTENTDOCUMENTLINK_MANAGEMENT = 'SMC_TGR_ContentDocumentLinkTrigger';
  public static final String CLASS_OPPORTUNITY_MANAGEMENT = 'SMC_TGR_OpportunityTrigger';
  public static final String CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT = 'SMC_TGR_SMCOpportunityActors';
  public static final String CLASS_QUOTE_MANAGEMENT = 'SMC_TGR_QuoteTrigger';
  public static final String CLASS_QUOTELINEITEM_MANAGEMENT = 'SMC_TGR_QuoteLineItemTrigger';
  public static final String CLASS_TASK_MANAGEMENT = 'SMC_TGR_TaskTrigger';
  public static final String CLASS_USER_MANAGEMENT = 'SMC_TGR_UserTrigger';
  public static final String CLASS_SKILLREQUIREMENT_MANAGEMENT = 'SMC_TGR_SkillRequirementTrigger';
  public static final String CLASS_ASSOCIATED_LOCATION_MANAGEMENT = 'SMC_TGR_AssociatedLocationTrigger';
  public static final String CLASS_ACCOUNT_TEAM_MEMBER_MANAGEMENT = 'SMC_TGR_AccountTeamMemberTrigger';
  public static final String CLASS_COMMUNITY_MESSAGE_MANAGEMENT = 'SMC_TGR_CommunityMessageTrigger';
  public static final String CLASS_ACCOUNT_CONTACT_ADDRESSES_BATCH = 'SMC_AP_AccountContactAddressesBatch';
  public static final String CLASS_WORKORDER_MANAGEMENT = 'SMC_TGR_WorkOrder';
  public static final String CLASS_PRODUCTREQUIRED_MANAGEMENT = 'SMC_TGR_ProductRequired';
  public static final String CLASS_SERVICERESOURCE_MANAGEMENT = 'SMC_TGR_ServiceResource';
  public static final String CLASS_SERVICE_APPOINTMENT = 'SMC_AP_ManageServiceAppointment';
  public static final String CLASS_LOCATION_MANAGEMENT = 'SMC_TGR_LocationTrigger';
  public static final String CLASS_LORA_KEY_REQUESTOR_MANAGEMENT = 'SMC_TGR_LoraKeyRequestor';
  public static final String CLASS_PRODUCT2_MANAGEMENT = 'SMC_TGR_Product2';
  public static final String CLASS_QTTECHLINE_MANAGEMENT = 'SMC_AP_ManageQTTechLine';
  public static final String CLASS_SERVICECONTRACT_MANAGEMENT = 'SMC_TGR_ServiceContract';
  public static final String CLASS_PRMQUOTE_MANAGEMENT = 'SMC_TGR_PRMQuoteTrigger';
  public static final String CLASS_COSTING_SIMULATION_MANAGEMENT = 'SMC_TGR_CostingSimulationTrigger';
  /* METHOD */
  public static final String METHOD_WOLI_UNIQUENESS_CLASS_WOLI_MANAGEMENT = 'CWOLI_keepUniquenessOnWorkOrder';

  /*VALIDATIN RULE*/
  public static final String CONTENTVERSION_DONT_MODIFY_QUOTATION = 'SMC_DontModifyQuotation';
  public static final String GENERIC_ACCOUNT_SBOM_BYPASS = 'SMC_Lock_record_type';

  /*PROFILE*/
  public static final String TECHNICAL_USER_SOC1 = 'SOC1';
  public static final String TECHNICAL_USER_SOC1_ID_FROM_MDT = 'SOC1Id';
  public static final String TECHNICAL_USER_SOC3 = 'SOC3';
  public static final String TECHNICAL_USER_SOC3_ID_FROM_MDT = 'SOC3Id';
  public static final String PROFILE_SALE_STANDARD = 'SMC Standard Sales Socomec';
  public static final String PREFIX_NAME_STANDARD = 'standard-';
  public static final String PROFILE_SMC_ADMIN = 'SMC IT Administrator';
  public static final String PREFIX_NAME_ADMIN = 'admin-';
  // public static final String PROFILE_SMC_STANDARD_SUPPORT = 'SMC Standard Support Socomec';
  public static final String PROFILE_SMC_STANDARD_SERVICE_SOCOMEC = 'SMC Standard Service Socomec';
  public static final String PREFIX_NAME_SUPPORT = 'support-';
  public static final String PROFILE_SMC_PARTNER_COMMUNITY = 'SMC Partner Community User';
  public static final String PREFIX_NAME_PARTNER = 'partner-';
  public static final String PROFILE_SMC_CHATTER_FREE = 'SMC Chatter Free User';
  public static final String PREFIX_NAME_CHATTER_FREE = 'chatter_free-';
  public static final String PROFIL_WARRANTY_REGISTRATION_NAME = 'Warranty Registration Profile';
  public static final String PROFIL_CUSTOMER_PORTAL_NAME = 'CustomerPortal Profile';

  /*LISENCE*/
  public static final String STANDARD = 'Standard';
  public static final String PARTNER = 'PowerPartner';
  public static final String CHATTER_FREE = 'CsnOnly';
  public static final String GUEST_USER = 'Guest';

  /*RECORD TYPE ACCOUNT*/
  public static final String RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT = '1 - Qualified Prospect';
  public static final String RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME = 'SMC_Qualified_prospect';
  public static final String RECORDTYPE_ACCOUNT_CUSTOMER = '2 - Customer (Direct/Indirect/Consultant)';
  public static final String RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME = 'SMC_Customer';
  public static final String RECORDTYPE_ACCOUNT_SPECIFIER = '3 - Specifier';
  public static final String RECORDTYPE_ACCOUNT_SPECIFIER_DEVNAME = 'SMC_Specifier';
  public static final String RECORDTYPE_ACCOUNT_INTERNAL = 'Internal Account';
  public static final String RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME = 'SMC_Internal_Account';
  public static final String RECORDTYPE_ACCOUNT_EXTERNAL_SALES_AGENCY = '4 - External sales agency';
  public static final String RECORDTYPE_ACCOUNT_EXTERNAL_SALES_AGENCY_DEVNAME = 'SMC_Partner_Distributors';
  public static final String RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED = 'Group Consolidated Account';
  public static final String RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED_DEVNAME = 'SMC_Group_Consolidated_Account';
  public static final String RECORDTYPE_ACCOUNT_CASE_TEAM = 'Case Team';

  /*RECORD TYPE CONTACT*/
  public static final String RECORDTYPE_CONTACT_CUSTOMER = 'SMC_Contact_Customer';
  public static final String RECORDTYPE_CONTACT_EXTERNAL_SALES_REPRESENTATIVE = 'SMC_Contact_Internal';
  public static final String RECORDTYPE_CONTACT_INTERNAL = 'SMC_Internal_Contact';
  public static final String RECORDTYPE_CONTACT_RESTRICTED = 'SMC_Contact_Restricted';

  /*RECORD TYPE OPPORTUNITY*/
  public static final String RECORDTYPE_OPPORTUNITY_PROJECT = 'SMC_Project';
  public static final String RECORDTYPE_QUICK_OPPORTUNITY = 'SMC_Quick_Quotation';
  public static final String RECORDTYPE_SIMU_EXPRESS_OPPORTUNITY = 'Simu_Express';

  /*RECORD TYPE CASE*/
  public static final String SMC_PREFIX_CASE_MARKETING_RECORDTYPE_NAME = 'Marketing ';
  public static final String SMC_PREFIX_CASE_MARKETING_RECORDTYPE = 'SMC_Marketing_';
  public static final String SMC_PREFIX_CASE_RECORDTYPE = 'SMC_Create_';
  public static final String SMC_PREFIX_CASE_RECORDTYPE_INTERNAL = 'SMC_Create_Internal_';
  public static final String SMC_PREFIX_CASE_RECORDTYPE_CUSTOMER = 'SMC_Create_Customer_';
  public static final String SMC_PREFIX_CASE_RECORDTYPE_SALES = 'SMC_Create_Sales_';
  public static final String SMC_PREFIX_CASE_RECORDTYPE_SALES_NAME = 'Sales';
  public static final String SMC_PREFIX_CASE_RECORDTYPE_HYPERCARE_NAME = 'Hypercare Case';
  public static final String SMC_PREFIX_CASE_QUICK_ACTION = 'Quick_Action_From_';
  public static final String RECORDTYPE_STANDARD_CASE = 'Standard_Case';
  public static final String RECORDTYPE_INTERNAL_OTHERS = 'SMC_Create_Internal_Others';
  public static final String RECORDTYPE_INTERNAL_PURCHASE_ORDER = 'SMC_Create_Internal_Purchase_Order';
  public static final String RECORDTYPE_INTERNAL_TECHNICAL_SUPPORT = 'SMC_Create_Internal_Technical_Support';
  public static final String RECORDTYPE_INTERNAL_TOOL_SUPPORT = 'SMC_Create_Internal_Tool_Support';
  public static final String RECORDTYPE_INTERNAL_WARRANTY_CLAIMS = 'SMC_Create_Internal_Warranty_Claims';
  public static final String RECORDTYPE_INTERNAL_LOCAL_TECHNICAL_HELP = 'SMC_Create_Internal_Local_Technical_Help';
  public static final String RECORDTYPE_CUSTOMER_OTHERS = 'SMC_Create_Customer_Others';
  public static final String RECORDTYPE_CUSTOMER_PURCHASE_ORDER = 'SMC_Create_Customer_Purchase_Order';
  public static final String RECORDTYPE_CUSTOMER_TECHNICAL_SUPPORT = 'SMC_Create_Customer_Technical_Support';
  public static final String RECORDTYPE_SALES_PURCHASE_ORDER = 'SMC_Create_Sales_Purchase_Order';
  public static final String RECORDTYPE_SALES_PRICING = 'SMC_Create_Sales_Pricing';
  public static final String RECORDTYPE_SALES_PRODUCT_AVAILABILITY = 'SMC_Create_Sales_Product_Availability';
  public static final String RECORDTYPE_SALES_TECHNICAL_SUPPORT = 'SMC_Create_Sales_Technical_Support';
  public static final String RECORDTYPE_INTERNAL_SOCOMEC_APPLICATION_SUPPORT = 'SMC_Internal_Socomec_Application_Support';
  public static final String RECORDTYPE_MARKETING_LIKE = 'SMC_Marketing%';
  public static final String RECORDTYPE_MARKETING_CATALOGUE = 'SMC_Marketing_Catalogue';
  public static final String RECORDTYPE_MARKETING_CATALOGUE_LABEL = 'Catalogue & Price list';
  public static final String RECORDTYPE_MARKETING_PDT_MANAGEMENT = 'SMC_Marketing_Product_Management';
  public static final String RECORDTYPE_MARKETING_PDT_MANAGEMENT_LABEL = 'PIM/DAM';
  public static final String RECORDTYPE_ASOA_HYPERCARE_LABEL = 'ASOA Hypercare';
  public static final String RECORDTYPE_ASOA_HYPERCARE = 'ASOA_Hypercare';
  public static final String RECORDTYPE_SOA_HYPERCARE_LABEL = 'SOA Hypercare';
  public static final String RECORDTYPE_SOA_HYPERCARE_CASE = 'SMC_Create_SOA_Case';
  public static final String RECORDTYPE_A_SUPPLIER_QUALITY_ISSUE_LABEL = 'A Supplier Quality Issue';
  public static final String RECORDTYPE_SUPPLIER_QUALITY_ISSUE_LABEL = 'Supplier Quality Issue';
  public static final String RECORDTYPE_SUPPLIER_QUALITY_ISSUE = 'Supplier_Quality_Issue';
  public static final String RECORDTYPE_SUPPLIER_QUALITY_ISSUE_CASE = 'SMC_Create_Supplier_Quality_Issue';

  /*RECORD TYPE PRODUCT2*/
  public static final String RECORDTYPE_SPARE_PART_PRODUCT = 'SMC_Spare_Part';
  public static final String RECORDTYPE_SERVICE_PRODUCT = 'SMC_Service_Product';
  public static final String RECORDTYPE_SALES_PRODUCT = 'SMC_Sales_Product';
  public static final String RECORDTYPE_QUOTE_TOOL_PRODUCT = 'SMC_Quotation_Tool';
  public static final String RECORDTYPE_WORK_ITEM_PRODUCT = 'SMC_Work_Item';
  public static final String RECORDTYPE_WORKORDER_ITEM_PRODUCT = 'SMC_WorkOrder_Item';

  /*RECORD TYPE QUOTE*/
  public static final String RECORDTYPE_QUOTE_PROJECT = 'SMC_Quote_for_Project';
  public static final String RECORDTYPE_QUICK_QUOTE = 'SMC_Quick_Quotation';
  public static final String RECORDTYPE_SIMU_EXPRESS = 'SMC_Simu_Express';

  /*RECORD TYPE ASSET*/
  public static final String RECORDTYPE_ASSET = 'SMC_Asset';
  public static final String RECORDTYPE_ASSET_GROUP = 'SMC_Group';
  public static final String RECORDTYPE_ASSET_RELATED_OBJECT = 'SMC_RelatedObject';

  /*RECORD TYPE QT TECH LINE*/
  public static final String RECORDTYPE_QTTECHLINE_CONTRACT_GROUP = 'QT_Contract_Group';
  public static final String RECORDTYPE_QTTECHLINE_CONTRACT_DETAIL = 'QT_Contract_Detail';
  public static final String RECORDTYPE_QTTECHLINE_INTERVENTION_GROUP = 'QT_Intervention_Group';
  public static final String RECORDTYPE_QTTECHLINE_INTERVENTION_DETAIL = 'QT_Intervention_Detail';

  /*PICKLIST*/
  public static final String PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT = 'PM';
  public static final String PICKLIST_ACCOUNT_TYPE_QUALIFIED_PROSPECT = 'PRQ';
  public static final String PICKLIST_ACCOUNT_TYPE_CUSTOMER = 'CLI';
  public static final String PICKLIST_LOGS_PROCESS_TYPE_AB = 'Apex Batch';
  public static final String PICKLIST_LOGS_PROCESS_TYPE_WS = 'Webservice';
  public static final String PICKLIST_LOGS_PROCESS_TYPE_DML = 'DML Execution';
  public static final String PICKLIST_LOGS_PROCESS_TYPE_SOQL = 'SOQL Query';
  public static final String LOGS_PROCESS_NAME = 'processName';

  /*CURRENCY*/
  public static final String CURRENCY_EUR = 'EUR';

  /*PERMISSION SET*/
  public static final String ACCESS_MYSOCOMEC_QUOTE = 'SMC_Access_MySocomec_Quote';
  public static final String ACCESS_MYSOCOMEC_QUOTATION_TOOL = 'SMC_Access_MySocomec_Quotation_Tool';
  public static final String QUOTATION_TOOL_PERMISSION = 'SMC_Quotation_Tool';
  public static final String MASS_DELETE_PERMISSION = 'SMC_Sales_Key_User';
  public static final String KEY_USER_PERMISSION = 'SMC_Key_User';
  public static final String BUSINESS_ADMIN_PERMISSION = 'Business_Admin';
  public static final String BUSINESS_DEVELOPPER = 'SMC_Business_Developper';
  public static final String FSL_KEY_USER = 'SMC_FSl_Key_User';
  public static final String FSL_ADMIN_LICENSE = 'FSL_Admin_License';
  public static final String FSL_ADMIN_PERMISSION = 'FSL_Admin_Permissions';
  public static final String FSL_AGENT_LICENSE = 'FSL_Agent_License';
  public static final String FSL_AGENT_PERMISSION = 'FSL_Agent_Permissions';
  public static final String BAES_MEMBERS = 'SMC_BAES_Members';
  public static final String FRENCH_ADDON_PERMISSION = 'SMC_French_User_Addon';
  public static final String CREATE_SOA_CASE_PERMISSION = 'SMC_Create_SOA_Case';
  public static final String SUPPLIER_QUALITY_CLAIM_CASE_ACCESS_PERMISSION = 'SMC_Supplier_Quality_Claim_Case_Access';

  /*CUSTOM PERMISSION*/
  public static final String DELETE_OPPORTUNITY_PERMISSION = 'SMC_Delete_Opportunity';
  public static final String KEY_USER_DEVELOPERNAME = 'SMC_Key_User';
  public static final String BUSINESS_ADMIN_DEVELOPERNAME = 'SMC_Business_Admin';
  public static final String DELETE_ASSET_PERMISSION = 'SMC_Delete_Asset';
  public static final String OVERRIDE_NET_PRICE_ONLINE_ORDERING = 'SMC_NetPrice_OrderOnline';

  //Error
  public static final String MASS_DELETE_WITHOUT_PERMISSION = 'You are not authorised to use the Mass Delete function.';
  public static final String DELETE_ACCOUNT_WITHOUT_PERMISSION = 'You are not authorised to delete an Account.';
  public static final String DELETE_CONTACT_WITHOUT_PERMISSION = 'You are not authorised to delete an Contact.';
  public static final String ACCOUNT_LINK_ERP = 'You are not authorised to delete an Account that is linked to the ERP.';
  public static final String ACCOUNT_LINK_OPPORTUNITY = 'There is one or more Account linked with at least one Opportunity and can\'t be deleted.';
  public static final String CONTACT_LINK_OPPORTUNITY = 'There is one or more Contact linked with at least one Opportunity and can\'t be deleted.';
  public static final String TO_MUCH_ACCOUNT_TO_CONTROL_P1 = 'There are to much Account to delete in once. Select ';
  public static final String TO_MUCH_ACCOUNT_TO_CONTROL_P2 = ' Account at maximum and retry to delete them.';
  public static final String TO_MUCH_CONTACT_TO_CONTROL_P1 = 'There are to much Contact to delete in once. Select ';
  public static final String TO_MUCH_CONTACT_TO_CONTROL_P2 = ' Contact at maximum and retry to delete them.';
  public static final String SERVICE_APPOINTMENT_ESTIMATED_LABOR_TIME_NULL = 'Service appointment cannot be created when estimated labor time is null.';

  /*USER*/
  public static final String USERNAME_TEST = 'dataTest@test.fr';
  public static final String USERNAME_TEST2 = 'dataTest2@test.fr';
  public static final String USERNAME_TEST3 = 'dataTest3@test.fr';
  public static final String USERNAME_TEST4 = 'dataTest4@test.fr';
  public static final String USERNAME_TEST5 = 'dataTest5@test.fr';
  public static final String USER_NICKNAME = 'communityNickname1';
  public static final String USER_NICKNAME2 = 'communityNickname2';
  public static final String USER_NICKNAME3 = 'communityNickname3';
  public static final String USER_NICKNAME4 = 'communityNickname4';
  public static final String USER_NICKNAME5 = 'communityNickname5';
  public static final String USER_FIELD_TIME_ZONE = 'Europe/Paris';
  public static final String USER_FIELD_EMAIL_ENCODING = 'UTF-8';
  public static final String USER_FIELD_LOCALEKEY = 'fr_FR';
  public static final String USER_FIELD_LANGUAGE = 'fr';

  /*LEAD*/
  //1
  public static final String LEAD_SOURCE1 = 'Events';
  public static final String LEAD_COMPANY1 = 'Examiner California';
  public static final String LEAD_FIRSTNAME1 = 'Jenni';
  public static final String LEAD_LASTNAME1 = 'Greenman';
  public static final String LEAD_PHONE1 = '1-(949)309-4865';
  public static final String LEAD_EMAIL1 = 'jgreenmane@examiner.test';
  public static final String LEAD_STREET1 = '5265 Kensington Pass';
  public static final String LEAD_STREET1_VERY_LONG =
    '5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass ' +
    '5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass ' +
    '5265 Kensington Pass 5265 Kensington Pass 5265 Kensington Pass';
  public static final String LEAD_POSTALCODE1 = '92619';
  public static final String LEAD_CITY1 = 'Irvine';
  public static final String LEAD_STATE1 = 'CA';
  public static final String LEAD_COUNTRY1 = 'US';
  public static final String LEAD_PROJECT_LOCATION1 = 'Inbox SF-Lead';

  /*ACCOUNT*/
  public static final String GENERIC_ACCOUNT_NAME_SBOM = '#GENERIC# SERVICE BOM';
  public static final String ACCOUNT_PRICELIST = 'LPL';
  public static final String ACCOUNT_ERPID_PCS = 'ERP_PCS_Code';
  public static final String ACCOUNT_PRICE_LIST_TIER = 'TIER1';
  public static final String ACCOUNT_QUEUE_FRANCE_OSL = 'France OSL';
  public static final String ACCOUNT_QUEUE_FRANCE_TOS = 'France TOS';
  public static final String ACCOUNT_CATEGORY_USERS = 'U';
  public static final String ACCOUNT_SOURCE_WARRANTY_REGISTRATION = 'Warranty Registration';
  //1
  public static final String ACCOUNT_NAME1 = 'Ucoz and co';
  public static final String ACCOUNT_BILLINGSTREET1 = '112 Hallows Parkway';
  public static final String ACCOUNT_BILLINGPOSTALCODE1 = '39210';
  public static final String ACCOUNT_BILLINGCITY1 = 'Jackson';
  public static final String ACCOUNT_BILLINGSTATE1 = 'MS';
  public static final String ACCOUNT_BILLINGSTATECODE1 = 'MS';
  public static final String ACCOUNT_BILLINGCOUNTRY1 = 'US';
  public static final String ACCOUNT_CATEGORY1 = 'S';
  public static final String ACCOUNT_ACTIVITY1 = 'S15';
  public static final String ACCOUNT_BUSINESS1 = 'S15SH';
  //2
  public static final String ACCOUNT_NAME2 = 'Magma etc';
  public static final String ACCOUNT_BILLINGSTREET2 = '262 Hooker Terrace';
  public static final String ACCOUNT_BILLINGPOSTALCODE2 = '77030';
  public static final String ACCOUNT_BILLINGCITY2 = 'Houston';
  public static final String ACCOUNT_BILLINGSTATE2 = 'TX';
  public static final String ACCOUNT_BILLINGCOUNTRY2 = 'US';
  public static final String ACCOUNT_CATEGORY2 = 'U';
  public static final String ACCOUNT_ACTIVITY2 = 'U10';
  public static final String ACCOUNT_BUSINESS2 = 'U10EG';
  //3
  public static final String ACCOUNT_NAME3 = 'Toto inc';
  public static final String ACCOUNT_BILLINGSTREET3 = '108 Hooker Terrace';
  public static final String ACCOUNT_BILLINGPOSTALCODE3 = '77030';
  public static final String ACCOUNT_BILLINGCITY3 = 'Houston';
  public static final String ACCOUNT_BILLINGSTATE3 = 'TX';
  public static final String ACCOUNT_BILLINGCOUNTRY3 = 'US';

  /*CONTACT*/
  //RecordType
  public static final String PARTNER_CONTACT_RECORDTYPE_NAME = 'SMC_Contact_Customer';
  public static final String CHATTER_FREE_CONTACT_RECORDTYPE_NAME = 'SMC_Internal_Contact';
  //1
  public static final String CONTACT_FIRSTNAME1 = 'Delainey';
  public static final String CONTACT_LASTNAME1 = 'Salazar';
  public static final String CONTACT_SALUTATION = 'Mr.';
  public static final String CONTACT_PHONE1 = '1-(601)228-1951';
  public static final String CONTACT_MOBILEPHONE1 = '1-(215)343-7719';
  public static final String CONTACT_EMAIL1 = 'dsalazar1@ucoz.test';
  public static final String CONTACT_MAILINGSTREET1 = '4 Hallows Parkway';
  public static final String CONTACT_MAILINGPOSTALCODE1 = '39210';
  public static final String CONTACT_MAILINGCITY1 = 'Jackson';
  public static final String CONTACT_MAILINGSTATE1 = 'MS';
  public static final String CONTACT_MAILINGCOUNTRY1 = 'US';
  public static final String CONTACT_OTHERCITY1 = null;
  //2
  public static final String CONTACT_FIRSTNAME2 = 'Fabe';
  public static final String CONTACT_LASTNAME2 = 'Uren';
  public static final String CONTACT_PHONE2 = '1-(713)664-1032';
  public static final String CONTACT_MOBILEPHONE2 = '1-(704)540-7305';
  public static final String CONTACT_EMAIL2 = 'furen5@google.test';
  public static final String CONTACT_MAILINGSTREET2 = '2 Pond Hill';
  public static final String CONTACT_MAILINGPOSTALCODE2 = '77030';
  public static final String CONTACT_MAILINGCITY2 = 'Houston';
  public static final String CONTACT_MAILINGSTATE2 = 'TX';
  public static final String CONTACT_MAILINGCOUNTRY2 = 'US';
  public static final String CONTACT_OTHERCITY2 = 'Other Houston';
  //3
  public static final String CONTACT_FIRSTNAME3 = 'Jack';
  public static final String CONTACT_LASTNAME3 = 'Smith';
  public static final String CONTACT_PHONE3 = '1-(713)664-1032';
  public static final String CONTACT_MOBILEPHONE3 = '1-(704)540-7305';
  public static final String CONTACT_EMAIL3 = 'smith@google.test';
  public static final String CONTACT_MAILINGSTREET3 = '2 Pond Hill';
  public static final String CONTACT_MAILINGPOSTALCODE3 = '77030';
  public static final String CONTACT_MAILINGCITY3 = 'Houston';
  public static final String CONTACT_MAILINGSTATE3 = 'TX';
  public static final String CONTACT_MAILINGCOUNTRY3 = 'US';
  public static final String CONTACT_OTHERCITY3 = 'Other Houston';
  //Errors
  public static final String CONTACT_SYNCED_TO_AN_ACCOUNT = 'If your Contact has an address that is different from that of the Account, please uncheck the “Sync with Account address” box. Alternatively leave the box ticked and the contact address field empty so that the auto completion process will update it automatically.';

  /* EVENT */
  //1
  public static final String EVENT_SUBJECT1 = 'Subject 1';
  public static final String EVENT_DESCRIPTION1 = 'Description 1';
  public static final DateTime EVENT_DATESTART1 = Datetime.newInstance(
    2017,
    10,
    20,
    12,
    30,
    0
  );
  public static final DateTime EVENT_DATEEND1 = Datetime.newInstance(
    2017,
    10,
    20,
    13,
    30,
    0
  );
  //2
  public static final String EVENT_SUBJECT2 = 'Subject 2';
  public static final String EVENT_DESCRIPTION2 = 'Description 2';
  public static final DateTime EVENT_DATESTART2 = Datetime.newInstance(
    2017,
    10,
    20,
    14,
    30,
    0
  );
  public static final DateTime EVENT_DATEEND2 = Datetime.newInstance(
    2017,
    10,
    20,
    15,
    30,
    0
  );
  //3
  public static final String EVENT_SUBJECT3 = 'Subject 3';
  public static final String EVENT_DESCRIPTION3 = 'Description 3';
  public static final DateTime EVENT_DATESTART3 = Datetime.newInstance(
    2017,
    10,
    20,
    16,
    30,
    0
  );
  public static final DateTime EVENT_DATEEND3 = Datetime.newInstance(
    2017,
    10,
    20,
    17,
    30,
    0
  );
  public static final String SCHEDULE_MEETING_CALENDAR_NAME = 'Meeting to schedule';
  public static final String GROUP_SCHEDULER = 'Scheduler meetings';

  /* CASE */
  public static final String CASE_SUBJECT1 = 'Case Subject 1';
  public static final String CASE_DESCRIPTION1 = 'Case Description 1';
  public static final String CASE_SUBJECT2 = 'Case Subject 2';
  public static final String CASE_DESCRIPTION2 = 'Case Description 2';
  public static final String CASE_SUBJECT3 = 'Case Subject 3';
  public static final String CASE_DESCRIPTION3 = 'Case Description 3';
  public static final String CASE_SUB_STATUS_REOPEN = 'Re Open';
  public static final String CASE_SUB_STATUS_OPEN = 'Open';
  public static final String CASE_STATUS_OPEN = 'Open';
  public static final String CASE_STATUS_CLOSED = 'Closed';
  public static final String CASE_SUB_STATUS_CLOSED_DEFINITLY = 'Closed';
  public static final String EMAIL = 'EMAIL';
  public static final String CONTENT_DOCUMENT_LINK = 'CONTENT_DOCUMENT_LINK';
  public static final String COMMENT = 'COMMENT';
  public static final String CASE_UPDATE_EMAIL = '*** Update Email Flag ***';
  public static final String CASE_UPDATE_CONTENT_DOCUMENT_LINK = '*** Update ContentDocumentLink Flag ***';
  public static final String CASE_UPDATE_COMMENT = '*** Update Comment Flag ***';
  public static final String CASE_COMMENT_DELETION = 'A case comment was deleted';
  public static final String CASE_COMMENT_DELETION_CASE = 'Case concerned - Subject : ';
  public static final String CASE_COMMENT_DELETION_BY = 'Deletion performed by : ';
  public static final String CASE_TYPE = 'TYPE';
  public static final String CASE_TYPE_APINAME = 'Type';
  public static final String CASE_STATUS = 'STATUS';
  public static final String CASE_STATUS_APINAME = 'Status';
  public static final String CASE_PRIORITY = 'PRIORITY';
  public static final String CASE_PRIORITY_APINAME = 'Priority';
  public static final String CASE_PRIORITY_P1 = 'P1';
  public static final String CASE_PRIORITY_P2 = 'P2';
  public static final String CASE_PRIORITY_P3 = 'P3';
  public static final String CASE_PRODUCT_FAMILY = 'PRODUCT FAMILY';
  public static final String CASE_PRODUCT_FAMILY_APINAME = 'SMC_Product_Family__c';
  public static final String CASE_BODY = 'Body test';
  public static final String CASE_TYPE_CUSTOMER_CLAIM = 'SMC_Customer_Claim';
  public static final String CASE_CATEGORY_OTHER = '257';
  //Callout
  public static final String INSTALLED_PRODUCT_INFORMATIONS = 'Installed_Product_Informations';
  public static final String SALES_ORDER_INFORMATIONS = 'Sales_Order_Informations';
  public static final String SN_PRODUCT_INFORMATIONS = 'SN_Product_Informations';
  public static final String ERP_DATA = 'ERP_Data';
  public static final String CIMSA_VISIT = 'CIMSA_Visit';
  //CIMSA
  public static final String DEFAULT_ORG_CIMSA_USER_SUBSIDIARY = 'SIC_EXP - Socomec Italy Export';
  public static final String USER_SUBSIDIARY_ITALY_EXPORT = 'SIC_EXP';
  public static final String DEFAULT_VISIT_UNDER_LABEL = 'PAID BY CUSTOMER';
  public static final String VISIT_UNDER_PAID_BY_CUSTOMER_APINAME = '7';
  public static final String DEFAULT_VISIT_CATEGORY_LABEL = 'PREVENTIVE MAINTENANCE';
  public static final String VISIT_CATEGORY_SPARE_PART_APINAME = '22';
  //Type
  public static final String CASE_TYPE_WARRANTY_CLAIMS = 'SMC_Warranty_Claims';
  public static final String CASE_TYPE_WARRANTY_CLAIMS_SR_NAME = 'SMC_CaseType_Warranty_Claims';
  public static final String CASE_TYPE_SPARE_PARTS_ORDER = 'SMC_Spare_Parts_Order';
  public static final String CASE_TYPE_SPARE_PARTS_ORDER_SR_NAME = 'SMC_CaseType_Purchase_Order';
  public static final String CASE_TYPE_PURCHASE_ORDER_NAME = 'Purchase_Order';
  public static final String CASE_TYPE_TECHNICAL_SUPPORT = 'SMC_Technical_Support';
  public static final String CASE_TYPE_TECHNICAL_SUPPORT_SR_NAME = 'SMC_CaseType_Technical_Support';
  public static final String CASE_TYPE_TOOL_SUPPORT = 'SMC_Tool_Support';
  public static final String CASE_TYPE_TOOL_SUPPORT_SR_NAME = 'SMC_CaseType_Tool_Support';
  public static final String CASE_TYPE_PRICING = 'SMC_Quotation_and_Pricing';
  public static final String CASE_TYPE_PRODUCT_AVAILABILITY = 'SMC_Product_Availability';
  public static final String CASE_TYPE_OTHERS_SR_NAME = 'SMC_CaseType_Others';
  public static final String SMC_CASE_TYPE = 'SMC_CaseType';
  //Kind Case
  public static final String KIND_SALES = 'sales';
  public static final String KIND_AFTERSALES_BASERVICE = 'afterSales_BAService';
  public static final String KIND_SOA = 'soa';
  //Orign
  public static final String CASE_ORIGIN_INTERNAL = 'Internal';
  public static final String CASE_ORIGIN_CUSTOMER_COMMUNITY = 'Customer Community';

  /* OPPORTUNITY */
  public static final String OPPORTUNITY_NAME_TEST = 'Opportunity Test - ';
  public static final String OPPORTUNITY_NAME1 = 'Opportunity 1 Test';
  public static final String OPPORTUNITY_NAME2 = 'Opportunity 2 Test';
  public static final String OPPORTUNITY_PROJECT_DETECTED = 'SMC_Project_Detected';
  public static final String OPPORTUNITY_TENDER_QUOTATION = 'SMC_Tender/Quotation';

  /* QUOTE */
  public static final String QUOTE_NAME1 = 'Quote 1 Test';
  public static final String QUOTE_NAME2 = 'Quote 2 Test';
  public static final String QUOTE_NAME3 = 'Quote 3 Test';
  public static final String QTO_STEP_S50 = 'S50';
  public static final String QUOTE_DOC_STATUS = 'GEN';

  /* QUOTE STATUS */
  public static final String QUOTE_OPEN = 'Open';
  public static final String QUOTE_DRAFT = 'Draft';

  /* PROCESS INSTANCE (ItemApprovalProcess) */
  public static final String STATUS_APPROVED = 'Approved';
  public static final String STATUS_REJECTED = 'Rejected';
  public static final String STATUS_PENDING = 'Pending';
  public static final String STATUS_REASSIGNED = 'Reassigned';
  public static final String STATUS_APPROVAL_PENDING = 'Approval pending';
  public static final String ALL_APPROVAL_LABEL = 'All Items to Approve';
  public static final String ITEM_TO_APPROVE_DELEGATED_LABEL = 'Items To Approve - Delegated';
  public static final String APPROVAL_PROCESS_QUOTE_NAME = 'Quote_Approval_Process_3_1';

  /* PRICEBOOK2 */
  public static final String PRICEBOOK_NAME = 'prcbkName';
  public static final String STANDARD_PRICEBOOK_NAME = 'Standard Price Book';

  /* GTL */
  //Status
  public static final String GTL_OBSOLETE = 'Obsolete';
  public static final String GTL_ACTIVE = 'Active';
  public static final String GTL_NOT_YET_ACTIVE = 'Not Yet Active';

  /* PRODUCT2 */
  public static final String TECHNICAL_ITEM_GROUP_BATTERY = 'battery';
  //Status
  public static final String PRODUCT_OBSOLETE = 'Obsolete';
  //Fields
  public static final String PRODUCT_NAME = 'prdctName';
  public static final String PRODUCT_CODE_ABLE = 'ABLE-DELPHYS MX IP Process-C1-3/3--100kVA';
  public static final String PRODUCT_CODE_ABLE_BIS = 'ABLE-DELPHYS MX elite';
  public static final String PRODUCT_CODE_SOC_CP = 'SOC-CP-DELPHYS MX elite IP Process-C7-NU--NU';
  //
  public static final String PRODUCT_MANUFACTEUR_ABLE = 'ABLE';
  public static final String PRODUCT_RANGE_ABLE = 'MAS2';
  public static final String PRODUCT_MODEL_ABLE = 'MS116000';
  public static final String PRODUCT_MODEL_ABLE_BIS = 'MS116000';
  public static final String PRODUCT_CONFIGURATION_ABLE = 'C1';
  public static final String PRODUCT_PHASE_ABLE = '3/3';
  public static final String PRODUCT_POWER_ABLE = '100';
  public static final String PRODUCT_MOCK_ABLE =
    '{' +
    '"manufacturer":"ABLEREX (ABLE)",' +
    '"range":"MS 11",' +
    '"model":"MS 11 6000 (MS116000)",' +
    '"configuration":"C1 - UPS Single Unit(s) with Bypass",' +
    '"phase":"3/3",' +
    '"power":"100"' +
    '}';
  public static final String PRODUCT_MOCK_ABLE_ALL =
    '{' +
    '"manufacturer":"ABLEREX (ABLE)",' +
    '"range":"MS 11"' +
    '}';
  //
  public static final String PRODUCT_MANUFACTEUR_SOC_CP = 'SOC-CP';
  public static final String PRODUCT_RANGE_SOC_CP = 'DMX';
  public static final String PRODUCT_MODEL_SOC_CP = 'DMX-INP1';
  public static final String PRODUCT_MODEL_SOC_CP_LABEL = 'DELPHYS MX elite IP Process';
  public static final String PRODUCT_CONFIGURATION_SOC_CP = 'C7';
  public static final String PRODUCT_PHASE_SOC_CP = 'NU';
  public static final String PRODUCT_POWER_SOC_CP = '300';
  public static final String PRODUCT_MOCK_SOC_CP =
    '{' +
    '"manufacturer":"SOCOMEC CP (SOC-CP)",' +
    '"range":"DELPHYS MX (DMX)",' +
    '"model":"DELPHYS MX elite IP Process (DMX-INP1)",' +
    '"configuration":"C7 - Modular parallel system other than 2 redundant UPS Units",' +
    '"phase":"NU",' +
    '"power":"300"' +
    '}';
  public static final String SALES_PRODUCT_RANGE = 'A2S070';
  public static final String SALES_PRODUCT_MODEL = 'DELPHYS-AA';
  
  // Chatter notif title
  public static final String EVENT_NOTIF_REQUEST = 'MEETING CONFIRMATION';
  public static final String EVENT_NOTIF_UPDATE = 'MEETING UPDATE';
  public static final String EVENT_NOTIF_CANCELLED = 'MEETING CANCELLED';
  public static final String EVENT_NOTIF_DECLINED_TITLE = 'MEETING DECLINED';
  public static final String EVENT_NOTIF_DECLINED_BY = ' declined your invitation to the event ';
  // Email notif
  public static final String EVENT_CHILD_NOT_UPDATED_TITLE = 'YOU CANT UPDATE EVENT WHERE YOU ARE INVITED';
  public static final String EVENT_CHILD_NOT_UPDATED_CONTENT =
    'You have been invited to this event.' +
    '\n You can not edit or delete an event where you are invited.' +
    '\n If you need to make a change, please contact the event pilot.';
  public static final String NO_ACCOUNT_TEAM = 'The account team not exist yet';
  public static final String NEW_ACCOUNT_TEAM_PILOT = ' has been added as a pilot on the Account ';

  /*EMAIL*/
  public static final String NOREPLY_NAME = 'NoReply';
  public static final String NOREPLY_EMAIL = 'noreply-salesforce@socomec.com';
  public static final String NOREPLY_EMAIL_NAME = 'No Reply Socomec Salesforce Support';

  /*EMAIL TEMPLATE*/
  public static final String ONLINE_ORDERING_ET = 'Online_Ordering_Email_Multiplang';
  public static final String TRAINING_CERTIFICATION_ET = 'SMC_Training_Certification';

  /*FILES*/
  //Picklist From Front
  public static final String FILE_PUBLIC = 'public';
  public static final String FILE_INTERNAL = 'internal';
  public static final String FILE_INTERNAL_PREFIX = '[Internal] ';
  public static final String FILE_PRIVATE = 'private';
  public static final String FILE_PRIVATE_PREFIX = '[Private] ';
  //Content Version
  public static final String VISIBLE_BY_USER_WITH_ACCESS = 'N';
  public static final String TECH_VISIBLE_BY_USER_WITH_ACCESS_APINAME = 'SMC_Public';
  public static final String PRIVATE_ON_RECORD = 'P';
  public static final String TECH_PRIVATE_ON_RECORD_APINAME = 'SMC_Private';
  //Content Document Link
  public static final String ALL_USERS = 'AllUsers';
  public static final String INTERNAL_USERS = 'InternalUsers';
  public static final String SHARED = 'SharedUsers';
  public static final String VIEWER_PERMISSION = 'V';
  public static final String COLLABORATOR_PERMISSION = 'C';
  public static final String INFERRED_PERMISSION = 'I';
  //Email
  public static final String EMAIL_MESSAGE_TYPE = 'EmailMessage';
  public static final String EMAIL_SUBJECT = 'Subject : ';
  public static final String EMAIL_FROM_NAME = 'FROM (Name) : ';
  public static final String EMAIL_FROM_ADDRESS = 'FROM (Address) : ';
  public static final String EMAIL_TO_ADDRESSES = 'TO (Addresses) : ';
  public static final String EMAIL_CC = 'CC : ';

  /*ASSET*/
  public static final String ALL_CONFIGURATION = 'ALL_CONFIGURATION';
  public static final String ALL_FAMILY = 'ALL_FAMILY';
  public static final String ALL_GROUP = 'ALL_GROUP';
  public static final String ALL_MANUFACTURER = 'ALL_MANUFACTURER';
  public static final String ALL_MODEL = 'ALL_MODEL';
  public static final String ALL_POWER = 'ALL_POWER';
  public static final String ALL_UNIT = 'ALL_UNIT';
  public static final String ALL_SUBSET = 'ALL_SUBSET';
  public static final String ALL_TYPE = 'ALL_TYPE';
  //Group
  public static final String AC_INPUT_CAPACITOR = 'AC_INPUT_CAPACITOR';
  public static final String AC_OUTPUT_CAPACITOR = 'AC_OUTPUT_CAPACITOR';
  public static final String DC_CAPACITOR = 'DC_CAPACITOR';
  public static final String FAN = 'FAN';
  public static final String BATTERY = 'BATTERY';
  public static final String POWER_SUPPLY = 'POWER_SUPPLY';
  public static final String FAN_CONTROL = 'FAN_CONTROL';
  //Status
  public static final String STATUS_WAREHOUSE = 'Warehouse';
  public static final String STATUS_SHIPPED = 'Shipped';
  public static final String STATUS_INSTALLED = 'Installed';
  public static final String STATUS_DECOMMISSIONNING = 'DeCommissioning';
  public static final String PICKLIST_ASSET_DECOMISSION = 'DeCommissionned';
  //Parent Srevice Organisation
  public static final String PSO_FR = 'FR';
  // public static final String PSO_PUBLIC = 'PUBLIC';
  // public static final String PSO_DE = 'DE';
  // public static final String PSO_BAES = 'BAES';
  //Option
  public static final String ACS = 'ACS';

  /* PRODUCT2 */
  public static final String PDT_WT_CAT_REPLACEMNT_AC_INPUT_CAPACITOR = 'ACI';
  public static final String PDT_WT_CAT_REPLACEMNT_AC_OUTPUT_CAPACITOR = 'ACO';
  public static final String PDT_WT_CAT_REPLACEMNT_DC_CAPACITOR = 'CSS';
  public static final String PDT_WT_CAT_REPLACEMNT_FAN = 'FAN';
  public static final String PDT_WT_CAT_REPLACEMNT_POWER_SUPPLY = 'PSUP';

  /* WORK TYPE */
  public static final String WT_TYPE_INSTALLATION = 'INST';
  public static final String WT_TYPE_COMMISSIONING = 'MES';
  public static final String WT_TYPE_DECOMMISSIONNING = 'DCOM';
  public static final String WT_TYPE_FAN = 'FAN';
  public static final String WT_TYPE_DURATION_TYPE_HOURS = 'Hours';
  public static final String WT_TYPE_DURATION_TYPE_MINUTES = 'Minutes';

  /* ASSOCIATED LOCATION */
  public static final String ASSOCIATED_LOCATION_TYPE_BILLTO = 'Bill To';
  public static final String ASSOCIATED_LOCATION_TYPE_SHIPTO = 'Ship To';
  public static final String ASSOCIATED_LOCATION_TYPE_SITE = 'Site';
  public static final String ASSOCIATED_LOCATION_TYPE_OTHER = 'Other';

  /* SERVICE RESOURCE */
  public static final String SERVICE_RESOURCE_TECHNICIAN_APINAME = 'T';

  /* PUBLIC GROUP */
  public static final String SUFFIX_DEVELOPER_NAME_PUBLIC_GROUP_PARTNERS = 'SMC_Partners_';

  /*TYPE METHOD WS*/
  public static final String SCORING_MOCK = 'MOCK';
  public static final String SCORING_ARE_SCORED = 'ARE_SCORED';
  public static final String SCORING_GET_ALL = 'GET_ALL';
  public static final String SCORING_UPSERT = 'UPSERT';
  public static final String SCORING_SAVE = 'SAVE';
  public static final String ASSIGN_TERRITORIES_RESPONSE = '"hasErrors":false';
  public static final String GET_METHOD = 'GET';
  public static final String POST_METHOD = 'POST';
  public static final String PUT_METHOD = 'PUT';
  public static final String TOKEN = 'TOKEN';
  public static final String DATAS = 'DATAS';
  public static final String DATAS_VAULT = 'DATAS_VAULT';
  public static final String DOC_LIST_COMMUNITY = 'Doc List';
  public static final String PICKLIST_DOC_LIST_COMMUNITY = 'Picklist-';
  public static final String BA = 'BA';
  public static final String PRODUCT_FAMILY = 'Product Family';
  public static final String DOC_TYPE = 'Document Type';
  public static final String LANGUAGE = 'Language';
  public static final String FC_STATISTICS = 'SMC_FC_Statistics';
  public static final String FAMILIY_DISCOUNT = 'Family_Discount';
  public static final String PRODUCT_NET_PRICE = 'Product_Net_Price';
  public static final String FC_DISCOUNT = 'SMC_FC_Discount';
  public static final String FC_NET_PRICE = 'SMC_FC_Net_Price';
  public static final String FC_DISCOUNT_PER_ITEM = 'SMC_FC_Discount_Per_Item';
  public static final String FC_DISCOUNT_PER_PRODUCT_LINE = 'SMC_FC_Discount_Per_Product_Line';
  public static final String ORDERTRACKING = 'Order_Tracking';
  //Authorization/Content...
  public static final String BASIC = 'BASIC';
  public static final String BASIC_MINOR = 'Basic ';
  public static final String AUTHORIZATION = 'Authorization';
  public static final String CONTENT_TYPE = 'Content-Type';
  public static final String ACCEPT = 'Accept';
  public static final String EXTERNAL_REQUEST_ID = 'External-Request-Id';
  public static final String APPLICATION_JSON = 'application/json';
  public static final String APPLICATION_X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded';
  public static final String BEARER = 'Bearer';
  //SMC_Endpoint_Webmethod__mdt
  public static final String SMC_URL_ENDPOINT = 'EndPoint';
  public static final String ORGANIZATION = 'Organization';
  public static final String SHA512 = 'SHA-512';
  //Error
  public static final String BAD_STATUS_CODE = 'The status code returned was not expected : ';
  public static final String MALFORMED_JSON = 'The response is not formatted as expected (JSON format) : ';

  /* BATCH */
  public static final String BATCH_TEMPLATE_NAME = 'BatchReportTemplate';
  public static final String BATCH_CRON_EXPRESSION_EVERY_DAY_AT_22PM = '0 0 22 1/1 * ? *';
  public static final String BATCH_DELETE_OLD_SIMUEXPRESS_QUOTE = 'Batch - Delete old SimuEpxress Quote';
  public static final String BATCH_SYNCHRONIZED_ACCOUNT_CONTACT_ADDRESS = 'Batch - Synchronized Account and Contact address';

  /* CACHE */
  public static final String ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER = 'ServiceProductManufacturer';
  public static final String ORG_CACHE_SERVICE_PRODUCT_RANGE = 'ServiceProductRange';
  public static final String ORG_CACHE_SERVICE_PRODUCT_MODEL = 'ServiceProductModel';
  public static final String ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION = 'ServiceProductConfiguration';
  public static final String ORG_CACHE_SERVICE_PRODUCT_PHASE = 'ServiceProductPhase';
  public static final String ORG_CACHE_SERVICE_PRODUCT_POWER = 'ServiceProductPower';

  /* TEST */
  public static final String TEST_FAIL_SYSDEBUG = 'ERROR - Test fail if we\'ll see this message\n';

  /* ERROR */
  //Technical
  public static final String ERROR_TECHNICAL = 'TECHNICAL PROBLEM : Contact your Salesforce Administrator';
  public static final String ERROR_PARAM_LIST_NULL = 'List in params null';
  //Opportunity
  public static final String ERROR_NO_OPPORTUNITY_LINK = 'There is no Opportunity link to this Case';
  //Case
  public static final String ERROR_REQUESTOR_NOT_FOUND = 'Requestor not found';
  //File
  public static final String ERROR_CANT_DELETE_FILE = 'You can\'t delete a file';
  //Location
  public static final String ERROR_LOCATION_NAME_DUPLICATE = 'This Location Name already exists';

  /* ERROR LOG */
  //CIMSA
  public static final String ERROR_CIMSA_ACCESS = 'ERROR - Unknown org. Check Custom Metadata Types "CIMsa_Access"';
  //QLIVIEW - Depreciated
  public static final String ERROR_QLIVIEW_ACCESS = 'ERROR - Unknown org. Check Custom Metadata Types "QliView Access"';
  //QLISENSE
  public static final String ERROR_QLISENSE_ACCESS = 'ERROR - Unknown org. Check Custom Metadata Types "QliSense Access"';
  //Discount
  public static final String ERROR_DISCOUNT_LOG_GET_DISCOUNT_TOKEN = 'Get Discount Token';
  public static final String ERROR_DISCOUNT_LOG_GET = 'Get Discount';
  public static final String ERROR_DISCOUNT_LOG_GET_ALL = 'Get All Discount';
  public static final String ERROR_DISCOUNT_LOG_SAVE = 'Save Discount';
  public static final String ERROR_DISCOUNT_LOG_UPSERT = 'Upsert Discount';
  public static final String ERROR_DISCOUNT_LOG_INITIATE = 'Initiate Discount';
  public static final String ERROR_DISCOUNT_LOG_UPDATE = 'Update Discount';
  public static final String ERROR_DISCOUNT_LOG_ARESCORED = 'AreScored Discount';
  //Account
  public static final String ERROR_ACCOUNT_LOG_CALL_ASSIGN_TERRITORIES = 'Call Assign Territories';
  //Case
  public static final String ERROR_CASE_LOG_INSTALLED_PRODUCT_INFO_HTML = 'Installed Product Info HTML';
  public static final String ERROR_CASE_LOG_SALES_ORDER_INFOS = 'Sales Order Infos';
  public static final String ERROR_CASE_LOG_SN_PRODUCT_INFO = 'SN PRoduct Info';
  public static final String ERROR_CASE_LOG_CIMSA_VISIT = 'CIMSA Visit';
  //Event
  public static final String ERROR_ACCOUNT_GROUP_CONSOLIDATED_CANT_ASSOCIATED_TO_EVENT = 'Group consolidated Account cannot be linked to any Events';
  public static final String ERROR_ACCOUNT_GROUP_CONSOLIDATED_CANT_ASSOCIATED_TO_TASK = 'Group consolidated Account cannot be linked to any Tasks';
  //Doc List Community
  public static final String ERROR_MARKETING_DOC_LIST = 'Marketing Community - Document List';
  public static final String ERROR_MARKETING_PICKLIST_BA = 'Marketing Community - Picklist:BA';
  public static final String ERROR_MARKETING_PICKLIST_PRODUCT_FAMILY = 'Marketing Community - Picklist:Product Family';
  public static final String ERROR_MARKETING_PICKLIST_DOC_TYPE = 'Marketing Community - Picklist:Document Type';
  public static final String ERROR_MARKETING_PICKLIST_LANGUAGE = 'Marketing Community - Picklist:Language';
  //ERP Invoice/Order/Quote
  public static final String ERROR_ERP_INVOICE_LINE = 'ERP Invoice Line';
  public static final String ERROR_ERP_ORDER_LINE = 'ERP Order Line';
  public static final String ERROR_ERP_QUOTE_LINE = 'ERP Quote Line';
  public static final String ERP_INVOICE_LINES = 'ERP Invoice Lines';
  public static final String ERP_ORDER_LINES = 'ERP Order Lines';
  public static final String ERP_QUOTE_LINES = 'ERP Quote Lines';
  public static final String ICON_ERP_INVOICE = 'custom:custom25';
  public static final String ICON_ERP_ORDER = 'custom:custom20';
  public static final String ICON_ERP_QUOTE = 'custom:custom5';
  //Follow Customer
  public static final String ERROR_FOLLOW_FAMILY_DISCOUNT = 'Follow Customer - Statistics';
  public static final String ERROR_FOLLOW_STATISTICS = 'Follow Customer - Statistics';
  public static final String ERROR_FOLLOW_DISCOUNT_PER_FAMILY = 'Follow Customer - Discount';
  public static final String ERROR_FOLLOW_DISCOUNT = 'Follow Customer - Discount (New)';
  public static final String ERROR_FOLLOW_PRODUCT_NET_PRICE = 'Follow Customer - Product Net Price (New)';
  public static final String ERROR_FOLLOW_DISCOUNT_PER_ITEM = 'Follow Customer - Discount Per Item';
  public static final String ERROR_FOLLOW_DISCOUNT_PER_PRODUCT_LINE = 'Follow Customer - Discount Per Product Line';
  // public static final String ERROR_FOLLOW_FAMILY_DISCOUNT = 'Follow Customer - Family Discount'; 
  // public static final String ERROR_FOLLOW_DISCOUNT_PER_FAMILY = 'Follow Customer - Discount Per Family';
  // public static final String ERROR_FOLLOW_PRODUCT_NET_PRICE = 'Follow Customer - Product Net Price';
  //Web Service
  public static final String ERROR_SMS_OVH = 'Error SMS OVH';

  //POST CHATTER
  public static final String TARGET_ID = 'targetId';
  public static final String MENTION_USER_ID = 'mentionUserId';
  public static final String MESSAGE = 'message';
  public static final String THE_QUOTE = 'TheQuote';
  public static final String THE_PROCESS_INSTANCE_ID = 'TheProcessInstanceId';
  public static final String THE_COSTING_SIMULATION = 'TheCostingSimulation';

  //WO Status
  public static final String WO_SUB_STATUS_CANCELED = 'CANCELED';
  public static final String WO_IN_PROGRESS = 'IN PROGRESS';

  //WOLI STATUS
  public static final String WOLI_CANCELED = 'SMC_Cancelled';
  public static final String WOLI_ABORTED = 'SMC_Aborted';
  public static final String WOLI_COMPLETED = 'SMC_Completed';
  public static final String WOLI_COMPLETED_MAIN_STATUS = 'Completed';

  //STATIC RESOURCE
  public static final String MOCK_ERROR = 'SMC_WS_Error';
  public static final String MOCK_MAINTENANCE_PLAN = 'SMC_MaintenancePlan_Mock';
  public static final String MOCK_MARKETING_LIBRARY_DOCUMENT_LIST = 'SMC_Marketing_Library_Document_List';
  public static final String MOCK_MARKETING_LIBRARY_PICKLIST_BA = 'SMC_Marketing_Library_BA';
  public static final String MOCK_MARKETING_LIBRARY_PICKLIST_PRODUCT_FAMILY = 'SMC_Marketing_Library_Picklist_ProductFamily';
  public static final String MOCK_MARKETING_LIBRARY_PICKLIST_DOCUMENT_TYPE = 'SMC_Marketing_Library_Picklist_DocType';
  public static final String MOCK_MARKETING_LIBRARY_PICKLIST_LANGUAGE = 'SMC_Marketing_Library_Picklist_Language';
  public static final String MOCK_MARKETING_LIBRARY_CHECK_PICTURE = 'SMC_Marketing_Library_Check_Picture';
  public static final String MOCK_ERP_OBJECTS_INVOICE = 'SMC_ERP_Objects_Invoice';
  public static final String MOCK_ERP_OBJECTS_ORDER = 'SMC_ERP_Objects_Order';
  public static final String MOCK_ERP_OBJECTS_QUOTE = 'SMC_ERP_Objects_Quote';
  public static final String MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT = 'SMC_FC_FamilyDiscount';
  public static final String MOCK_FOLLOW_CUSTOMER_FAMILY_TURNOVER = 'SMC_FC_FamilyTurnover';
  public static final String MOCK_FOLLOW_CUSTOMER_PRICE_LIST = 'SMC_FC_PriceList';
  public static final String MOCK_LORAWAN_TOKEN = 'MOCK_LoRaWan_TOKEN';
  public static final String MOCK_LORAWAN_KEY = 'MOCK_LoRaWan_CLIENT';
  public static final String MOCK_LORAWAN_CONFIG = 'MOCK_LoRaWan_NKE';
  //Document
  public static final String TRAINING_SUCCESS_PICTURE_DEVNAME = 'SMC_Training_Success';

  //ERP OBJECTS

  /*OTHERS*/
  public static final String GOOGLE_URL = 'https://google.com';
  public static final String HTTPS_SOCOMEC_DOT_MY_DOT = 'https://socomec.my.';
  public static final String DOT_MY_DOT_SALESFORCE_DOT_COM = '.my.salesforce.com';
  public static final String DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM = '.sandbox.my.salesforce.com';
  public static final String RECENT_CASE_LIST_VIEW = 'Recently Viewed Cases';
  public static final String AUTOMATED_PROCESS = 'AutomatedProcess';
  public static final String COMMUNITY = 'Community';
  public static final String CUSTOMERS = 'Customers';
  public static final String CUSTOMERS_MIN = 'customers';
  public static final String COMMUNITY_CUSTOMERS = 'Community_Customers';
  public static final String MYSPACE = 'MySpace';
  public static final String MYSPACE_MIN = 'myspace';
  public static final String COMMUNITY_MYSPACE = 'Community_MySpace';
  public static final String SALESFORCE = 'Salesforce';
  public static final String OTHER = 'Other';
  public static final String ERROR_NOT_FOUND = 'ERROR 404 : Not found';
  public static final String SMC_PREFIX = 'SMC_';
  public static final String ENGLISH_CODE = 'EN';
  public static final String ENGLISH_CODE_ISO = 'en_Us';
  public static final String STR_PARTNER = 'Partner';
  public static final String STR_LINKED_PARTNER = 'Linked to Partner';
  public static final String STR_DISTRIBUTOR = 'Distributor';
  public static final String STR_SUPPLIER = 'Supplier';
  public static final String STR_CUSTOMER = 'Customer';
  public static final String CHECK_FIELD = 'checkField';
  public static final String PRJECT_NBS = 'projectNbs';
  public static final String QUOTE_NBS = 'quoteNbs';
  public static final String AMOUNT_CONVERTED = 'amntConverted';
  public static final String QUEUE = 'Queue';
  public static final String CASE_LABEL = 'Case';
  public static final String ACCOUNT = 'Account';
  public static final String CONTACT = 'Contact';
  public static final String ASSET = 'Asset';
  public static final String EVENT = 'Event';
  public static final String EVENTS = 'Events';
  public static final String QUOTE = 'Quote';
  public static final String OPPORTUNITY = 'Opportunity';
  public static final String SOBJECT_CASE = 'Case';
  public static final String SHIPMENT = 'Shipment';
  public static final String WORK_ORDER = 'WorkerOrder';
  public static final String WORK_ORDER_LINE_ITEM = 'WorkOrderLineItem';
  public static final String INVOICE = 'Invoice';
  public static final String ORDER = 'Order';
  public static final String SUBJECT = 'Subject';
  public static final String WHAT_ID = 'WhatId';
  public static final String WHO_ID = 'WhoId';
  public static final String START_DATETIME = 'StartDateTime';
  public static final String END_DATETIME = 'EndDateTime';
  public static final String LOCATION = 'Location';
  public static final String PROJECT_PIPE = 'Project Pipe';
  public static final String QUOTE_PIPE = 'Quote Pipe';
  public static final String QUOTE_FOLLOWED = 'Followed Quote';
  public static final String CREATOR = 'Creator';
  public static final String TRAINING = 'TRAINING';
  public static final String PREPROD = 'PREPROD';
  public static final String ERROR_STATUS = 'ERROR';
  public static final String SUCCESS_STATUS = 'SUCCESS';
  public static final String ERROR_SYSDEBUG = 'ERROR : ';
  public static final String BODY_SYSDEBUG = 'BODY : ';
  public static final String QUERY_SYSDEBUG = 'QUERY : ';
  public static final String BAD_JSON = 'Bad JSON';
  public static final String EE = 'EE';
  public static final String PCO = 'PCO';
  public static final String PCS = 'PCS';
  public static final String ES = 'ES';
  public static final String SCORING = 'Scoring';
  public static final String TERRITORY = 'territory';
  public static final String MASS_DELETE = 'Mass_Delete';
  public static final String SIMU_EXPRESS = 'Simu Express';
  public static final String ADMIN = 'ADMIN';
  public static final String IPAGCT = 'IPAGCT';
  public static final String CUSTOMER = 'Customer';
  public static final String ENGINEER = 'Engineer';
  public static final String INSERTED = 'Inserted';
  public static final String STR_INSERT = 'INSERT';
  public static final String STR_UPDATE = 'UPDATE';
  public static final String STR_DELETE = 'DELETE';
  public static final String STR_NEW = 'New';
  public static final String CLONED = 'Cloned';
  public static final String OPEN = 'OPEN';
  public static final String MINOR_OPEN = 'Open';
  public static final String CLOSED = 'CLOSED';
  public static final String WON = 'Won';
  public static final String COMPLETE = 'Complete';
  public static final String COMPLETED = 'Completed';
  public static final String COMPLETED_ALL_CAPS = 'COMPLETED';
  public static final String SMC_CANCELLED = 'SMC_Cancelled';
  public static final String SMC_ABORTED = 'SMC_Aborted';
  public static final String SMC_COMPLETED = 'SMC_Completed';
  public static final String ACTIVE = 'Active';
  public static final String MANDATORY = 'mandatory';
  public static final String END_POINT = 'endPoint';
  public static final String TEST = 'test';
  public static final String TEST_DIESE = 'test#';
  public static final String EMAIL_TEST = 'test@test.fr';
  public static final String PROSPECT = 'Prospect';
  public static final String AND_MAJOR = 'AND';
  public static final String AND_MINOR = 'and';
  public static final String YES = 'Yes';
  public static final String NO = 'No';
  public static final String NONE = 'None';
  public static final String DEFAULT_PICKLIST_VALUE = '-- None --';
  public static final String UNKNOWN_VALUE = 'N/A';
  public static final String NA_VALUE = 'N/A';
  public static final String LINE_BREAK = '\n';
  public static final String UNDERSCORE = '_';
  public static final String PERCENT = '%';
  public static final String HYPHEN = '-';
  public static final String PLUS = '+';
  public static final String SPLIT_PLUS = '\\+';
  public static final String COLON = ':';
  public static final String SLASH = '/';
  public static final String OPEN_ACCOLADE = '{';
  public static final String CLOSE_ACCOLADE = '}';
  public static final String SPACE = ' ';
  public static final String POINT = '.';
  public static final String SPLIT_POINT = '\\.';
  public static final String EMPTY_STRING = '';
  public static final String ONE = '1';
  public static final String STATIC_RESOURCE_PREFIX_LINK = '/resource/';
  public static final String PUBLIC_STR = 'Public';

  /** CACHE MOCk - TO MOVE IN A MOCK CLASS **/
  public static String MANUFACTURER_CACHE = '{"-- None --":["-- None --"],"SOC-CP":["-- None --","DMX"]}';
  public static String RANGE_CACHE = '["-- None --","DMX"]';
  public static String MODEL_CACHE = '["-- None --","DMX-ELI2","DMX-ELI1","DMX-AA","DMX-INP1"]';
  public static String CONFIGURATION_CACHE = '["-- None --","C7","C3","C4","C5","C2","C6","C1"]';
  public static String PHASE_CACHE = '["-- None --","3/3"]';
  public static String POWER_CACHE = '["-- None --","300","400",null,"3200","250","900","100","200","800","500","1000","2000","60","1200","700","1500","1600","2500","2400","40","600","3000","80","160","120","20"]';

  /** COMMUNITY NAME **/
  public static final String CUSTOMER_PORTAL_DEVELOPER_NAME = 'CustomerPortal';
  public static final String CUSTOMERS_DEVELOPER_NAME = 'Customers';
  public static final String ONLINE_ORDERING_PORTAL_DEVELOPER_NAME = 'Online_Ordering_Portal';
  public static final String SUPPLIER_PORTAL_DEVELOPER_NAME = 'SupplierPortal';
  public static final String WARRANTY_REGISTRATION_DEVELOPER_NAME = 'Warranty_Registration';

  /** ERROR MAINTENANCE PLAN **/
  public static final String ERROR_MP_NO_ASSET = 'There is no asset on the line ';
  public static final String ERROR_MP_NO_LOCATION = 'There is no location link to the asset on the line ';
  public static final String ERROR_MP_NO_ADDRESS = 'There is no address link to the asset\'s location on the line ';
  public static final String ERROR_MP_NO_SERVICE_PRODUCT = 'There is no service product link to the asset on the line ';
  public static final String ERROR_MP_NO_MAINTENANCE_PLAN_TO_INITIALIZE = 'There is no maintenance plan to initlize.';

  /*CATEGORY WORK TYPE*/
  public static final String TQI = 'TQI';
  public static final String PMV = 'PMV';

  /*STATUS WORK ORDER*/
  public static final String TO_BE_SCHEDULED = 'TO BE SCHEDULED';
}