/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Page_CreateCase
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_Page_CreateCase
--
-- Maintenance History:
--
-- Date 			Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 06-SEP-2019 		VRE		1.0			Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_Page_CreateCase {
  @testVisible
  private static final String SALES = 'sales';
  @testVisible
  private static final String SALES_DEVELOPERNAME = 'Sales';
  @testVisible
  private static final String AFTER_SALES_BASERVICE = 'afterSales_BAService';
  @testVisible
  private static final String AFTER_SALES_LOCAL_CALL_CENTER = 'afterSales_LocalCallCenter';
  @testVisible
  private static final String CREATE_SALES_PURCHASE_ORDER = 'SMC_Create_Sales_Purchase_Order';
  @testVisible
  private static final String SOCOMEC_APPLICATION_SUPPORT = 'socomecApplicationSupport';
  @testVisible
  private static final String MARKETING = 'marketing';
  @testVisible
  private static final String SOA = 'soa';
  @testVisible
  private static final String SUPPLIER_QUALITY_ISSUE = 'supplier_quality_issue';
  @testVisible
  private static Map<String, List<String>> RECORDTYPE_MAP = new Map<String, List<String>>();
  @testVisible
  private static List<String> RECORDTYPE_LIST_SALES = new List<String>{};
  @testVisible
  private static List<String> RECORDTYPE_LIST_AFTER_SALES_BASERVICE = new List<String>{};
  @testVisible
  private static List<String> RECORDTYPE_LIST_AFTER_SALES_LOCAL_CALL_CENTER = new List<String>{};
  @testVisible
  private static List<String> RECORDTYPE_LIST_MARKETING = new List<String>{};
  @testVisible
  private static List<String> RECORDTYPE_LIST_SOA = new List<String>{};
  // @testVisible
  // private static List<String> RECORDTYPE_LIST_SOCOMEC_APPLICATION_SUPPORT = new List<String>{};

  public static Map<String, String> IMG_PATH_CASE_TYPE_LIST = new Map<String, String>{};

  public class GetKindCase implements Comparable {
    @AuraEnabled
    public String kindCase;
    @AuraEnabled
    public String kindCaseLabel;
    @AuraEnabled
    public String kindCaseImg;

    public GetKindCase(
      String kindCase,
      String kindCaseLabel,
      String kindCaseImg
    ) {
      this.kindCase = kindCase;
      this.kindCaseLabel = kindCaseLabel;
      this.kindCaseImg = kindCaseImg;
    }

    public Integer compareTo(Object compareTo) {
      GetKindCase compareToGoal = (GetKindCase) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;

      if (this.kindCaseLabel < compareToGoal.kindCaseLabel) {
        return 1;
      } else if (this.kindCaseLabel > compareToGoal.kindCaseLabel) {
        return -1;
      }
      return returnValue;
    }
  }

  public class PredefinedFieldsValues {
    //Global
    public SMC_Case_RecordType__mdt recordTypeMdt {get;set;}
    public String kindCase {get;set;}
    public String internalUserId {get;set;}
    public String contactId {get;set;}
    public String accountId {get;set;}
    public Boolean doNotShowInactiveProduct = false;
    public Boolean doNotShowServiceProduct = false;
    public Boolean doNotShowSalesProduct = false;
    public Boolean isCreateFromHypercare = false;
    
    //Opportunity + Quote
    public String opportunityId;
    public String endCustomerId;
    public String quoteId;

    public PredefinedFieldsValues() {
      if (
        UserInfo.getProfileId() !=
        [
          SELECT Id
          FROM Profile
          WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
        ]
        .Id
      ) {
        this.internalUserId = UserInfo.getUserId();
      } else {
        User partnerUser = [
          SELECT ContactId, Contact.AccountId
          FROM User
          WHERE Id = :UserInfo.getUserId()
        ];
        this.contactId = partnerUser.ContactId;
        this.accountId = partnerUser.Contact.AccountId;
      }
    }

    public PredefinedFieldsValues(String kindCase) {
      //Internal or Partner init
      if (
        UserInfo.getProfileId() !=
        [
          SELECT Id
          FROM Profile
          WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
        ]
        .Id
      ) {
        this.internalUserId = UserInfo.getUserId();
      } else {
        User partnerUser = [
          SELECT ContactId, Contact.AccountId
          FROM User
          WHERE Id = :UserInfo.getUserId()
        ];
        this.contactId = partnerUser.ContactId;
        this.accountId = partnerUser.Contact.AccountId;
      }
      //Init boolean depend on kind case
      this.kindCase = kindCase;
      if(kindCase == STA_UtilsStatic.KIND_SALES){
        this.doNotShowInactiveProduct = true;
        this.doNotShowServiceProduct = true;
      }
      /*else if(kindCase == STA_UtilsStatic.KIND_AFTERSALES_BASERVICE){
        this.doNotShowServiceProduct = true;
      }*/
      else if(kindCase == STA_UtilsStatic.KIND_SOA){
        this.isCreateFromHypercare = true;
      }
      else {
        this.doNotShowSalesProduct = true;
      }
    }
  }

  public class AssociateCaseTypeToImg {
    public String caseTypeId;
    public String caseTypeName;
    public String caseTypeImg;

    public AssociateCaseTypeToImg(String caseTypeId, String caseTypeName) {
      this.caseTypeId = caseTypeId;
      this.caseTypeName = caseTypeName;
    }
  }

  public class AllInfoToCreateCaseFromAnotherObject {
    public PredefinedFieldsValues pdv;
    public List<AssociateCaseTypeToImg> listActi;

    public AllInfoToCreateCaseFromAnotherObject(PredefinedFieldsValues pdv, List<AssociateCaseTypeToImg> listActi) {
      this.pdv = pdv;
      this.listActi = listActi;
    }
  }

  /**
   * @description : get RecentCase list view
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return ListView
   **/
  @AuraEnabled
  public static ListView getCaseListView() {
    return [
      SELECT Id, Name
      FROM ListView
      WHERE
        SobjectType = 'Case'
        AND Name = :STA_UtilsStatic.RECENT_CASE_LIST_VIEW
    ];
  }

  /**
   * @description : set first choice = Kind Case (Sales/Local Center/BA Service)
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return List<GetKindCase>
   **/
  @AuraEnabled
  public static List<GetKindCase> setKindCaseList() {
    List<GetKindCase> kindCaseList = new List<GetKindCase>();
    String queryAuthorizedToSeeSOA = ' AND DeveloperName != \'' + STA_UtilsStatic.RECORDTYPE_ASOA_HYPERCARE + '\'';
    String queryAuthorizedToSeeSupplierQualityIssue = ' AND DeveloperName != \'' + STA_UtilsStatic.RECORDTYPE_SUPPLIER_QUALITY_ISSUE + '\'';

    try{
      List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name
                                     FROM PermissionSetAssignment 
                                     WHERE AssigneeId = :UserInfo.getUserId() 
                                    AND (PermissionSet.Name = :STA_UtilsStatic.CREATE_SOA_CASE_PERMISSION 
                                    OR PermissionSet.Name = :STA_UtilsStatic.SUPPLIER_QUALITY_CLAIM_CASE_ACCESS_PERMISSION)];
    
      for(PermissionSetAssignment psaChild : psa){
        if(psaChild.PermissionSet.Name == STA_UtilsStatic.CREATE_SOA_CASE_PERMISSION){
          queryAuthorizedToSeeSOA = '';
        } 
        else if (psaChild.PermissionSet.Name == STA_UtilsStatic.SUPPLIER_QUALITY_CLAIM_CASE_ACCESS_PERMISSION){
          queryAuthorizedToSeeSupplierQualityIssue = '';
        }
      }
    }
    catch(Exception e){
      System.debug('User is not authorized to get the bloc "SOA Hypercare" or "Supplier Quality Issue".');
    }
    String query = 'SELECT Label, Kind_Case__c, Img_Path__c, DeveloperName FROM SMC_Case_RecordType__mdt WHERE (NOT DeveloperName LIKE \'' 
            + STA_UtilsStatic.SMC_PREFIX_CASE_QUICK_ACTION + '%\')' + queryAuthorizedToSeeSOA + queryAuthorizedToSeeSupplierQualityIssue;
 
      for (
        SMC_Case_RecordType__mdt oneMdt :  Database.query(query)
      ) {
        kindCaseList.add(
          new GetKindCase(oneMdt.Kind_Case__c, oneMdt.Label, oneMdt.Img_Path__c)
        );
      }
    
    kindCaseList.sort();
    List<GetKindCase> kindCaseListSorted = new List<GetKindCase>();
    for(GetKindCase oneKC : kindCaseList){
      //Real name is "SOA" and "Supplier Quality Issue". The 'A' before is used to sort the list
      if(oneKC.kindCaseLabel == STA_UtilsStatic.RECORDTYPE_ASOA_HYPERCARE_LABEL){
        oneKC.kindCaseLabel = STA_UtilsStatic.RECORDTYPE_SOA_HYPERCARE_LABEL;
      }
      if(oneKC.kindCaseLabel == STA_UtilsStatic.RECORDTYPE_A_SUPPLIER_QUALITY_ISSUE_LABEL){
        oneKC.kindCaseLabel = STA_UtilsStatic.RECORDTYPE_SUPPLIER_QUALITY_ISSUE_LABEL;
      }
      kindCaseListSorted.add(oneKC);
    }
    return kindCaseList;
  }

  /**
   * @description : set case type after choosing a kind of case
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param kindCase
   * @param recordId
   * @return String = serialization(List<AssociateCaseTypeToImg>)
   **/
  @AuraEnabled
  public static String setCaseTypeList(String kindCase, String pdv, String recordId) {
    //Get first part when from another object
    kindCase = kindCase.contains(';') ? kindCase.split(';')[0] : kindCase;
    //Prevent NullPointer
    PredefinedFieldsValues parsedPdv = (pdv != null && pdv != '') ? 
                                        (PredefinedFieldsValues) JSON.deserialize(pdv, PredefinedFieldsValues.class) : 
                                        new PredefinedFieldsValues(kindCase);

    //Check if the creation came from an object
    if(recordId != null && recordId != ''){
      //Opportunity
      if(recordId.startsWith('006')) {
        //Get opportunity
        Opportunity theOpportunitty = [SELECT Id, AccountId FROM Opportunity WHERE Id = :recordId];

        if(kindCase == SMC_AC_Page_CreateCase.SALES){
          //Set Predefined Value
          parsedPdv.opportunityId = theOpportunitty.Id;
          parsedPdv.endCustomerId = theOpportunitty.AccountId;
          //Set Metadata 
          parsedPdv.kindCase = kindCase;
        }
      }
      //Quote
      else if(recordId.startsWith('0Q0')) {
        //Get Quote
        Quote theQuote = [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.SMC_Primary_Contact__c FROM Quote WHERE Id = :recordId];

        if(kindCase == SMC_AC_Page_CreateCase.SALES){
          //Set Predefined Value
          parsedPdv.opportunityId = theQuote.OpportunityId;
          parsedPdv.endCustomerId = theQuote.Opportunity.AccountId;
          parsedPdv.quoteId = theQuote.Id;
        } 
        else if (kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER){
          parsedPdv.accountId = theQuote.Opportunity.AccountId;
          parsedPdv.contactId = theQuote.Opportunity.SMC_Primary_Contact__c;
        }
        else if(kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE){
          parsedPdv.endCustomerId = theQuote.Opportunity.AccountId;
        }
      }
      //Contact
      else if(recordId.startsWith('003')) {
        //Get Contact
        Contact theContact = [SELECT Id, AccountId FROM Contact WHERE Id = :recordId];

        if(kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER){
          //Set Predefined Value
          parsedPdv.accountId = theContact.AccountId;
          parsedPdv.contactId = theContact.Id;
        } 
        else if (kindCase == SMC_AC_Page_CreateCase.SALES 
              || kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE){
          parsedPdv.endCustomerId = theContact.AccountId;
        }
      }
      //Set Metadata 
      parsedPdv.kindCase = kindCase;
    }
    
    /* Regular kind case */
    SMC_AC_Page_CreateCase.initVariables(kindCase, parsedPdv);
    List<RecordType> recordTypeList = new List<RecordType>();
    /* Particular bypass for this kind case : there is only 1 record type
     ==> Start directly case creation */
     if (kindCase == SMC_AC_Page_CreateCase.SOCOMEC_APPLICATION_SUPPORT || 
         kindCase == SMC_AC_Page_CreateCase.SOA ||
         kindCase == SMC_AC_Page_CreateCase.SUPPLIER_QUALITY_ISSUE) {
      
      //Get the Record Type from the KindCase
      String queryRT;
      if(kindCase  == SMC_AC_Page_CreateCase.SOCOMEC_APPLICATION_SUPPORT){
        queryRT = STA_UtilsStatic.RECORDTYPE_INTERNAL_SOCOMEC_APPLICATION_SUPPORT;
      } else if (kindCase == SMC_AC_Page_CreateCase.SOA){
        queryRT = STA_UtilsStatic.RECORDTYPE_SOA_HYPERCARE_CASE;
      } else if(kindCase == SMC_AC_Page_CreateCase.SUPPLIER_QUALITY_ISSUE){
        queryRT = STA_UtilsStatic.RECORDTYPE_SUPPLIER_QUALITY_ISSUE_CASE;
      }

      RecordType theRecordType = [
        SELECT Id, Name, DeveloperName
        FROM RecordType
        WHERE
          SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND RecordType.DeveloperName = :queryRT
      ];
      
      return JSON.serialize(new AllInfoToCreateCaseFromAnotherObject(
        parsedPdv, 
        new List<AssociateCaseTypeToImg>{
          new AssociateCaseTypeToImg(theRecordType.Id, null)
        }
      ));
    }

    //Get record types according to kind case
    if(SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase) != null){
      recordTypeList = [
        SELECT Id, Name, DeveloperName
        FROM RecordType
        WHERE
          SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND RecordType.DeveloperName IN :SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase)
      ];
    }
    //Default = Standard Case
    else {
      recordTypeList = [
        SELECT Id, Name, DeveloperName
        FROM RecordType
        WHERE
          SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_STANDARD_CASE
      ];
    }

    List<AssociateCaseTypeToImg> listActi = new List<AssociateCaseTypeToImg>();
    for (RecordType oneRecordType : recordTypeList) {
      //Remove prefix from record type name
      String buildNameWithtoutPrefix = '';
      for (Integer i = 1; i < oneRecordType.Name.split(' ').size(); ++i) {
        buildNameWithtoutPrefix += oneRecordType.Name.split(' ')[i] + ' ';
      }
      buildNameWithtoutPrefix = buildNameWithtoutPrefix.substring(
        0,
        buildNameWithtoutPrefix.length() - 1
      );
      //Build the JSON to send to the front
      AssociateCaseTypeToImg oneAssociateCaseTypeToImg = new AssociateCaseTypeToImg(
        oneRecordType.Id,
        buildNameWithtoutPrefix
      );
      String prefixSplited = STA_UtilsStatic.SMC_PREFIX;
      //Build the type list
      if (kindCase == SMC_AC_Page_CreateCase.SALES) {
        prefixSplited += oneRecordType.DeveloperName.split(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_SALES
        )[1];
        /** TEMPORARY **/
        if(oneRecordType.DeveloperName == STA_UtilsStatic.RECORDTYPE_SALES_PURCHASE_ORDER){
          prefixSplited = STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT;
        }
        /** TEMPORARY **/
      } else if (kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE) {
        prefixSplited += oneRecordType.DeveloperName.split(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_INTERNAL
        )[1];
      } else if (kindCase == SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER) {
        if (
          oneRecordType.DeveloperName ==
          STA_UtilsStatic.RECORDTYPE_INTERNAL_LOCAL_TECHNICAL_HELP
        ) {
          prefixSplited += oneRecordType.DeveloperName.split(
            STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_INTERNAL
          )[1];
        } else {
          prefixSplited += oneRecordType.DeveloperName.split(
            STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_CUSTOMER
          )[1];
        }
      } else if (kindCase == SMC_AC_Page_CreateCase.MARKETING) {
        //A ajuster quand les images seront données + ajuster MDT
        prefixSplited += oneRecordType.DeveloperName.split(
          STA_UtilsStatic.SMC_PREFIX_CASE_MARKETING_RECORDTYPE
        )[1];
        if(oneRecordType.DeveloperName == STA_UtilsStatic.RECORDTYPE_MARKETING_CATALOGUE){
          oneAssociateCaseTypeToImg.caseTypeName = STA_UtilsStatic.RECORDTYPE_MARKETING_CATALOGUE_LABEL;
        }
        if(oneRecordType.DeveloperName == STA_UtilsStatic.RECORDTYPE_MARKETING_PDT_MANAGEMENT){
          oneAssociateCaseTypeToImg.caseTypeName = STA_UtilsStatic.RECORDTYPE_MARKETING_PDT_MANAGEMENT_LABEL;
        }
      }
      oneAssociateCaseTypeToImg.caseTypeImg =
        STA_UtilsStatic.STATIC_RESOURCE_PREFIX_LINK +
        SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST.get(prefixSplited);

      listActi.add(oneAssociateCaseTypeToImg);
    }

    //Return serializaation
    return JSON.serialize(
      new AllInfoToCreateCaseFromAnotherObject(
        parsedPdv, 
        listActi)
      );
  }

  /**
   * @description : set static variables (to the top of the class)
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param kindCase
   **/
  @TestVisible
  private static void initVariables(String kindCase, PredefinedFieldsValues pdv) {
    if (Test.isRunningTest()) {
      SMC_AC_Page_CreateCase.RECORDTYPE_MAP = new Map<String, List<String>>{};
      // SMC_AC_Page_CreateCase.RECORDTYPE_LIST_SALES = new List<String>{};
      // SMC_AC_Page_CreateCase.RECORDTYPE_LIST_AFTER_SALES_BASERVICE = new List<String>{};
      // SMC_AC_Page_CreateCase.RECORDTYPE_LIST_AFTER_SALES_LOCAL_CALL_CENTER = new List<String>{};
      SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST = new Map<String, String>{};
    }

    //Get img paths
    List<SMC_Case_Type_Img__mdt> caseTypeImgMdtList = [
      SELECT DeveloperName, Case_Type__c, Img_SR_Name__c
      FROM SMC_Case_Type_Img__mdt
    ];

    //Check if from another object than Case
    SMC_Case_RecordType__mdt oneMdt;
    if(pdv != null && pdv.recordTypeMdt != null){
      oneMdt = pdv.recordTypeMdt;
    }
    //From Case
    else{
      oneMdt = [SELECT Kind_Case__c, 
                    RecordType_According_To_Kind_Case__c, 
                    Case_Type_Img_Identifier__c
                FROM SMC_Case_RecordType__mdt
                WHERE Kind_Case__c = :kindCase];
    }
    List<String> caseTypeImgIdentifier = new List<String>();
    if (
      oneMdt.RecordType_According_To_Kind_Case__c != null &&
      oneMdt.RecordType_According_To_Kind_Case__c != ''
    ) {
      SMC_AC_Page_CreateCase.RECORDTYPE_MAP.put(kindCase, oneMdt.RecordType_According_To_Kind_Case__c.split(';'));
      caseTypeImgIdentifier = oneMdt.Case_Type_Img_Identifier__c.split(';');
      for (SMC_Case_Type_Img__mdt imgMdt : caseTypeImgMdtList) {
        //Purchase Order is special cause the RecordType not match with the CaseType
        // if (
        //   imgMdt.Case_Type__c == STA_UtilsStatic.CASE_TYPE_SPARE_PARTS_ORDER
        // ) {
        //   SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST.put(
        //     STA_UtilsStatic.SMC_PREFIX +
        //     STA_UtilsStatic.CASE_TYPE_PURCHASE_ORDER_NAME,
        //     imgMdt.Img_SR_Name__c
        //   );
        // //Others Casetype
        // } else 
        //Others Casetype
        if (caseTypeImgIdentifier.contains(imgMdt.DeveloperName)) {
          SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST.put(
            imgMdt.Case_Type__c,
            imgMdt.Img_SR_Name__c
          );
        }
      }
      // }
    }
  }
}