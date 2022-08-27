/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_Marketing_Library
-- - Author : Vincent RECASENS
-- - Description : This class is Apex controller of LWC Marketing Library
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 12-AUG-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AC_Marketing_Library {
  // private static final Set<String> DONT_DISPLAY_LANGUAGE = new Set<String>{
  //   'BLUE',
  //   'WHITE',
  //   'MULTI',
  //   'FRAME',
  //   'JPG',
  //   'PNG'
  // };
  // private static final Set<String> DONT_DISPLAY_DOCUMENT_TYPE = new Set<String>{
  //   'CHARTER',
  //   'CORPO',
  //   'PRICE LIST',
  //   'TRAINING',
  //   'EASYREF'
  // };
  private static final Set<String> DONT_DISPLAY_BA = new Set<String>();
  private static final Set<String> DONT_DISPLAY_PDT_FAMILY = new Set<String>();
  private static final Set<String> DONT_DISPLAY_DOCUMENT_TYPE = new Set<String>();
  private static final Set<String> DONT_DISPLAY_LANGUAGE = new Set<String>();
  private static final String BA = 'BA';
  private static final String PDT_FAMILY = 'Product Family';
  private static final String DOCUMENT_TYPE = 'Document Type';
  private static final String LANGUAGE = 'Language';

  /**
   * @description : init all picklist and document list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param target
   * @param ba
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @AuraEnabled(cacheable=false)
  public static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData initAll(
    String target,
    String ba
  ) {
    //Get user's account
    //String userEmail = UserInfo.getUserEmail();
    User partnerUser;
    try {
      partnerUser = [
        SELECT SMC_Partner_Level__c, ContactId, Contact.Account.SMC_Community_Products_Interests__c
        /*, CUSTOM_CATEGORY --> need matching table*/ FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Warning for internal user --> ' + e);
    }

    //Get endpoints
    Endpoint_DocList_Community__mdt endpointInformations = getEndpoint();
    String publicHost = endpointInformations.Public_Host_Name__c;
    //Get datas
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData();
    if (Test.isRunningTest()) {
      //DocList
      StaticResource static_resource_doc_list = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_DOCUMENT_LIST
      ];
      allData.docList = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents) JSON.deserialize(
        static_resource_doc_list.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents.class
      );
      //BA
      StaticResource static_resource_ba = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_BA
      ];
      allData.bas = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
        static_resource_ba.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
      );
      //Product Family
      StaticResource static_resource_product_family = [
        SELECT Id, Body
        FROM StaticResource
        WHERE
          Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_PRODUCT_FAMILY
      ];
      allData.productFamily = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
        static_resource_product_family.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
      );
      //DocType
      StaticResource static_resource_doc_type = [
        SELECT Id, Body
        FROM StaticResource
        WHERE
          Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_DOCUMENT_TYPE
      ];
      allData.docType = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
        static_resource_doc_type.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
      );
      //Language
      StaticResource static_resource_language = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_LANGUAGE
      ];
      allData.language = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
        static_resource_language.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
      );
    } else {
      allData.docList = getDocumentListByTargetFromWS(
        target,
        ba,
        null,
        null,
        null,
        String.valueOf(allData.actualLimit),
        '0',
        null,
        partnerUser,
        'desc',
        null
      );
      allData.bas = getPicklistBaAndProductFamily(
        STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.BA,
        null,
        endpointInformations
      );
      allData.productFamily = getPicklistBaAndProductFamily(
        STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY +
        STA_UtilsStatic.PRODUCT_FAMILY,
        (ba != null ? ba : '1'),
        endpointInformations
      );
      allData.docType = getPicklistDocTypeAndLanguage(
        STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.DOC_TYPE,
        endpointInformations
      );
      allData.language = getPicklistDocTypeAndLanguage(
        STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.LANGUAGE,
        endpointInformations
      );
    }

    allData = getTranslationsAndImgAndPath(allData, false);
    allData = getSortList(allData);
    return allData;
  }

  /**
   * @description : get filtered picklists (except BA) and filtered document list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param target
   * @param baSelected
   * @param docType
   * @param language
   * @param offset
   * @param textSearch
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @AuraEnabled(cacheable=false)
  public static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData resetProductFamily(
    String target,
    String baSelected,
    String docType,
    String language,
    String offset,
    String textSearch,
    String filterByLastVersionDate,
    String filterByName
  ) {
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData();
    if (Test.isRunningTest()) {
      //DocList
      StaticResource static_resource_doc_list = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_DOCUMENT_LIST
      ];
      allData.docList = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents) JSON.deserialize(
        static_resource_doc_list.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents.class
      );
      //BA
      StaticResource static_resource_ba = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_BA
      ];
      allData.bas = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
        static_resource_ba.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
      );
      //DocType
      StaticResource static_resource_doc_type = [
        SELECT Id, Body
        FROM StaticResource
        WHERE
          Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_DOCUMENT_TYPE
      ];
      allData.docType = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
        static_resource_doc_type.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
      );
      //Language
      StaticResource static_resource_language = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_LANGUAGE
      ];
      allData.language = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
        static_resource_language.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
      );
    } else {
      allData = getDocumentList(
        target,
        baSelected,
        null,
        docType,
        language,
        ((offset == null || Integer.valueOf(offset) == 0 || offset == '' || offset == '0' ) ? '0' : String.valueOf(Integer.valueOf(offset)*allData.actualLimit)),
        textSearch,
        filterByLastVersionDate,
        filterByName
      );
    }
    allData.productFamily = getPicklistBaAndProductFamily(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY +
      STA_UtilsStatic.PRODUCT_FAMILY,
      baSelected,
      getEndpoint()
    );

    allData = getTranslationsAndImgAndPath(allData, true);
    return allData;
  }

  /**
   * @description : get document list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param target
   * @param baSelected
   * @param productFamily
   * @param docType
   * @param language
   * @param offset
   * @param String
   * @param textSearch
   * @param filterByLastVersionDate
   * @param filterByName
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @AuraEnabled(cacheable=false)
  public static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData getDocumentList(
    String target,
    String baSelected,
    String productFamily,
    String docType,
    String language,
    String offset, //page
    String textSearch,
    String filterByLastVersionDate,
    String filterByName
  ) {
    User partnerUser;
    try {
      partnerUser = [
        SELECT SMC_Partner_Level__c, ContactId, Contact.Account.SMC_Community_Products_Interests__c
        /*, CUSTOM_CATEGORY --> need matching table*/ FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
    }
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData();
    allData.docList = getDocumentListByTargetFromWS(
      target,
      baSelected,
      productFamily,
      docType,
      language,
      String.valueOf(allData.actualLimit),
      ((offset == null || Integer.valueOf(offset) == 0 || offset == '' || offset == '0' ) ? '0' : String.valueOf(Integer.valueOf(offset)*allData.actualLimit)),
      textSearch,
      partnerUser,
      filterByLastVersionDate,
      filterByName
    );
    allData = findImgAndPath(allData);
    return allData;
  }

  /**
   * @description : get callout informations
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Endpoint_DocList_Community__mdt
   **/
  @TestVisible
  private static Endpoint_DocList_Community__mdt getEndpoint() {
    String host = URL.getSalesforceBaseUrl().toExternalForm();
    Endpoint_DocList_Community__mdt theMdt = [
      SELECT
        Org__c,
        Organization_Community__c,
        URL_Endpoint__c,
        Authorization__c,
        Complement_URL_Document_List_By_Target__c,
        Complement_URL_Picklist_BA__c,
        Complement_URL_Picklist_Product_Family__c,
        Complement_URL_Picklist_Document_Type__c,
        Complement_URL_Picklist_Language__c,
        Public_Host_Name__c,
        SMC_Is_Mocking_Mode__c,
        URL_Endpoint_PROD__c
      FROM Endpoint_DocList_Community__mdt
      LIMIT 1
    ];

    //If host == mdt.Org__c -> PRODUCTION
    if (host.contains(theMdt.Organization_Community__c)) {
      theMdt.URL_Endpoint__c = theMdt.URL_Endpoint_PROD__c;
    }
    return theMdt;
  }

  /**
   * @description : get translations and img path from MDT
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param allDataToTranslate
   * @param isReset
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData getTranslationsAndImgAndPath(
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allDataToTranslate,
    Boolean isReset
  ) {
    //Setup return elmt
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allDataTranslated = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData();
    allDataTranslated.docList = allDataToTranslate.docList;
    allDataTranslated.actualLimit = allDataToTranslate.actualLimit;
    allDataTranslated.totalrecords = allDataToTranslate.totalrecords;
    allDataTranslated.productFamily = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent();

    //Product Family Group
    Map<String, String> metadataTradProductFamilyGroup = new Map<String, String>();
    Schema.DescribeFieldResult fieldResultProductFamilyGroup = SMC_Dynamic_Translation__mdt.ML_Product_Family_Group__c.getDescribe();
    List<Schema.PicklistEntry> entriesProductFamilyGroup = fieldResultProductFamilyGroup.getPicklistValues();
    for (Integer i = entriesProductFamilyGroup.size() - 1; i >= 0; --i) {
      // System.debug(LoggingLevel.INFO, 'MDT Product Family Group - value : ' + entriesProductFamilyGroup[i].getValue() + ' / label : ' + entriesProductFamilyGroup[i].getLabel());
      metadataTradProductFamilyGroup.put(
        entriesProductFamilyGroup[i].getValue(),
        entriesProductFamilyGroup[i].getLabel()
      );
    }
    //Product Family
    Map<String, String> metadataTradProductFamily = new Map<String, String>();
    Schema.DescribeFieldResult fieldResultProductFamily = SMC_Dynamic_Translation__mdt.ML_Product_Family__c.getDescribe();
    List<Schema.PicklistEntry> entriesProductFamily = fieldResultProductFamily.getPicklistValues();
    for (Integer i = entriesProductFamily.size() - 1; i >= 0; --i) {
      // System.debug(LoggingLevel.INFO, 'MDT Product Family Child - value : ' + entriesProductFamily[i].getValue() + ' / label : ' + entriesProductFamily[i].getLabel());
      if (entriesProductFamily[i].getValue().contains('/')) {
        metadataTradProductFamily.put(
          entriesProductFamily[i].getValue().split('/')[0],
          entriesProductFamily[i].getLabel()
        );
        metadataTradProductFamily.put(
          entriesProductFamily[i].getValue().split('/')[1],
          entriesProductFamily[i].getLabel()
        );
      } else {
        metadataTradProductFamily.put(
          entriesProductFamily[i].getValue(),
          entriesProductFamily[i].getLabel()
        );
      }
    }
    //Get value to exclude
    for(Dynamic_Translation_To_Exclude__mdt oneExclude : [SELECT Type__c, Value__c FROM Dynamic_Translation_To_Exclude__mdt WHERE To_Hide__c = TRUE]){
      if(oneExclude.Type__c == SMC_AC_Marketing_Library.BA){
        SMC_AC_Marketing_Library.DONT_DISPLAY_BA.add(oneExclude.Value__c);
      }
      else if(oneExclude.Type__c == SMC_AC_Marketing_Library.PDT_FAMILY){
        SMC_AC_Marketing_Library.DONT_DISPLAY_PDT_FAMILY.add(oneExclude.Value__c);
      }
      else if(oneExclude.Type__c == SMC_AC_Marketing_Library.DOCUMENT_TYPE){
        SMC_AC_Marketing_Library.DONT_DISPLAY_DOCUMENT_TYPE.add(oneExclude.Value__c);
      }
      else if(oneExclude.Type__c == SMC_AC_Marketing_Library.LANGUAGE){
        SMC_AC_Marketing_Library.DONT_DISPLAY_LANGUAGE.add(oneExclude.Value__c);
      }
    }
    //Set translation
    Integer iPF = 0;
    for (
      SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children oneChildren : allDataToTranslate.productFamily.children
    ) {
      if(metadataTradProductFamilyGroup.get(oneChildren.id) != null && 
      !SMC_AC_Marketing_Library.DONT_DISPLAY_PDT_FAMILY.contains(oneChildren.id)){
        allDataTranslated.productFamily.children.add(
          new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children(
            metadataTradProductFamilyGroup.get(oneChildren.id),
            oneChildren.id
          )
        );
        for (
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_GrandChildren oneGrandChildren : oneChildren.grandChildren
        ) {
          if(metadataTradProductFamily.get(oneGrandChildren.id) != null){
            allDataTranslated.productFamily.children[iPF]
              .grandchildren.add(
                new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_GrandChildren(
                  metadataTradProductFamily.get(oneGrandChildren.id),
                  oneGrandChildren.id
                )
              );
          }
        }
        ++iPF;
      }
    }

    if (!isReset) {
      allDataTranslated.bas = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent();
      allDataTranslated.docType = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others();
      allDataTranslated.language = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others();

      //BA
      Map<String, String> metadataTradBA = new Map<String, String>();
      Schema.DescribeFieldResult fieldResultBA = SMC_Dynamic_Translation__mdt.ML_BA__c.getDescribe();
      List<Schema.PicklistEntry> entriesBA = fieldResultBA.getPicklistValues();
      for (Integer i = entriesBA.size() - 1; i >= 0; --i) {
        metadataTradBA.put(entriesBA[i].getValue(), entriesBA[i].getLabel());
      }
      for (
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children oneChildren : allDataToTranslate.bas.children
      ) {
        if(metadataTradBA.get(oneChildren.id) != null && 
        !SMC_AC_Marketing_Library.DONT_DISPLAY_BA.contains(oneChildren.id)){
          allDataTranslated.bas.children.add(
            new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children(
              metadataTradBA.get(oneChildren.id),
              oneChildren.id
            )
          );
        }
      }

      //Document Type
      Map<String, String> metadataTradDocumentType = new Map<String, String>();
      Schema.DescribeFieldResult fieldResultDocumentType = SMC_Dynamic_Translation__mdt.ML_Document_Type__c.getDescribe();
      List<Schema.PicklistEntry> entriesDocumentType = fieldResultDocumentType.getPicklistValues();
      for (Integer i = entriesDocumentType.size() - 1; i >= 0; --i) {
        metadataTradDocumentType.put(
          entriesDocumentType[i].getValue(),
          entriesDocumentType[i].getLabel()
        );
      }
      for (
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails oneOtherDetail : allDataToTranslate.docType.objects
      ) {
        if(metadataTradDocumentType.get(oneOtherDetail.value) != null && 
          !SMC_AC_Marketing_Library.DONT_DISPLAY_DOCUMENT_TYPE.contains(oneOtherDetail.value)){
          allDataTranslated.docType.objects.add(
            new SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails(
              metadataTradDocumentType.get(oneOtherDetail.value),
              oneOtherDetail.value
            )
          );
        }
      }

      //Language
      Map<String, String> metadataTradLanguage = new Map<String, String>();
      Schema.DescribeFieldResult fieldResultLanguage = SMC_Dynamic_Translation__mdt.ML_Language__c.getDescribe();
      List<Schema.PicklistEntry> entriesLanguage = fieldResultLanguage.getPicklistValues();
      for (Integer i = entriesLanguage.size() - 1; i >= 0; --i) {
        metadataTradLanguage.put(
          entriesLanguage[i].getValue(),
          entriesLanguage[i].getLabel()
        );
      }
      for (
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails oneOtherDetail : allDataToTranslate.language.objects
      ) {
        if (metadataTradLanguage.get(oneOtherDetail.value) != null && 
            !SMC_AC_Marketing_Library.DONT_DISPLAY_LANGUAGE.contains(oneOtherDetail.value) && 
            !Test.isRunningTest()
        ) {
          allDataTranslated.language.objects.add(
            new SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails(
              metadataTradLanguage.get(oneOtherDetail.value),
              oneOtherDetail.value
            )
          );
        }
      }
    }

    //Get Img and path
    allDataTranslated = findImgAndPath(allDataTranslated);
    return allDataTranslated;
  }

  /**
   * @description : build img path and path to downloadable PDF
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param allData
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData findImgAndPath(
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData
  ) {
    String publicHost = getEndpoint().Public_Host_Name__c;
    System.debug('albator allData : ' + allData);
    System.debug('albator allData.docList : ' + allData.docList);
    //Sort datas
    for (
      SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document oneDoc : allData.docList.documents
    ) {
      //Init img path and settings Map for language filters
      if (
        oneDoc.publicPicturePath == null ||
        !oneDoc.publicPicturePath.contains(publicHost)
      ) {
        oneDoc.publicPicturePath = publicHost + oneDoc.publicPicturePath;
      }
      if (
        oneDoc.files != null &&
        oneDoc.files.size() > 0 &&
        !oneDoc.files[0].publicPath.contains(publicHost)
      ) {
        oneDoc.publicPictureDefaultPath =
          publicHost + oneDoc.files[0].publicPath;
      }
      for (SMC_DTO_ML_Wrappers.SMC_DTO_ML_File oneFile : oneDoc.files) {
        if (
          oneFile.publicPath == null || !oneFile.publicPath.contains(publicHost)
        ) {
          oneFile.publicPath = publicHost + oneFile.publicPath;
        }
      }
      //If no lang for the user, use EN
      String pathEn;
      if (oneDoc.publicPictureDefaultPath == null && pathEn != null) {
        oneDoc.publicPictureDefaultPath = pathEn;
      } else if (oneDoc.publicPictureDefaultPath == null && pathEn == null) {
        //Or the first path
        if (
          oneDoc.files != null &&
          oneDoc.files.size() > 0 &&
          !oneDoc.files[0].publicPath.contains(publicHost)
        ) {
          oneDoc.publicPictureDefaultPath =
            publicHost + oneDoc.files[0].publicPath;
        } else if (
          oneDoc.files != null &&
          oneDoc.files.size() > 0 &&
          oneDoc.files[0].publicPath.contains(publicHost)
        ) {
          oneDoc.publicPictureDefaultPath = oneDoc.files[0].publicPath;
        } else if (oneDoc.files == null && oneDoc.files.size() == 0) {
          oneDoc.publicPictureDefaultPath = oneDoc.publicPicturePath;
        }
      }

      //Set title with camel case
      String[] wordTab = oneDoc.documentType.split(' ');
      String tmpStr = '';
      for (String str : wordTab) {
        if (str.length() > 1) {
          tmpStr +=
            str.substring(0, 1).toUpperCase() +
            str.substring(1).toLowerCase() +
            ' ';
        } else if (str.length() > 0) {
          tmpStr += str.substring(0).toUpperCase() + ' ';
        }
      }
      oneDoc.documentType = tmpStr.substring(0, tmpStr.length() - 1);
    }
    return allData;
  }

  /**
   * @description : return the sort list frm metadata
   * @author Vincent RECASENS (Modis) | 29/06/2020
   * @param allData
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData getSortList(
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData
  ) {
    Map<String, String> metadataTradSortList = new Map<String, String>();
    Schema.DescribeFieldResult fieldResultSortList = SMC_Dynamic_Translation__mdt.ML_SortList__c.getDescribe();
    List<Schema.PicklistEntry> entriesSortList = fieldResultSortList.getPicklistValues();
    for (Integer i = 0; i < entriesSortList.size(); ++i) {
      allData.sortList.objects.add(
        new SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails(
          entriesSortList[i].getLabel(),
          entriesSortList[i].getValue()
        )
      );
    }
    return allData;
  }

  /**
   * @description : build body for callout
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param target
   * @param ba
   * @param productFamily
   * @param docType
   * @param language
   * @param limitByPage
   * @param doc
   * @param page
   * @param offset
   * @param String
   * @param textSearch
   * @return Map<String, String>
   **/
  @TestVisible
  private static Map<String, String> buildMapDocList(
    String target,
    String ba,
    String productFamily,
    String docType,
    String language,
    String limitByPage, //nb doc by page
    String offset, //page
    String textSearch,
    String filterByLastVersionDate, //sort by date
    String filterByName, //sort by name
    String partnerLevel //sort by date
  ) {
    Map<String, String> mapValues = new Map<String, String>();
    if (target != null) {
      mapValues.put('target', target);
    }
    if (ba != null) {
      mapValues.put('level0', ba);
    }
    if (productFamily != null) {
      mapValues.put('levelGroup', productFamily);
    }
    if (docType != null) {
      mapValues.put('content_family', docType);
    }
    if (language != null) {
      mapValues.put('language', language);
    }
    if (limitByPage != null) {
      mapValues.put('limit', limitByPage);
    }
    if (offset != null) {
      mapValues.put('offset', offset);
    }
    if (textSearch != null && textSearch != '') {
      mapValues.put('text_search', String.escapeSingleQuotes(textSearch));
    }
    if (filterByLastVersionDate != null && filterByLastVersionDate != '') {
      mapValues.put(
        'filter_by_last_version_date',
        String.escapeSingleQuotes(filterByLastVersionDate)
      );
    }
    if (filterByName != null && filterByName != '') {
      mapValues.put('filter_by_name', String.escapeSingleQuotes(filterByName));
    }
    if (partnerLevel != null && partnerLevel != '') {
      mapValues.put('filter_by_acl', String.escapeSingleQuotes(partnerLevel));
    }

    return mapValues;
  }

  /**
   * @description : encode the body
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param vals
   * @return String
   **/
  @TestVisible
  private static String stringEncode(Map<String, String> vals) {
    String result = '';
    for (String thisKey : vals.keySet()) {
      result += thisKey + '=' + vals.get(thisKey) + '&';
    }
    return result.removeEnd('&');
  }

  /**
   * @description : callout to get document list
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param target
   * @param ba
   * @param productFamily
   * @param docType
   * @param language
   * @param limitByPage
   * @param doc
   * @param page
   * @param offset
   * @param String
   * @param Contact
   * @param partnerUser
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents getDocumentListByTargetFromWS(
    String target,
    String ba,
    String productFamily,
    String docType,
    String language,
    String limitByPage, //nb doc by page
    String offset, //page
    String textSearch,
    User partnerUser,
    String filterByLastVersionDate,
    String filterByName
  ) {
    //Check if call mock
    Endpoint_DocList_Community__mdt endpointInformations = getEndpoint();
    if (endpointInformations.SMC_Is_Mocking_Mode__c) {
      StaticResource static_resource = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_DOCUMENT_LIST
      ];
      return (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents) JSON.deserialize(
        static_resource.Body.toString(),
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents.class
      );
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      endpointInformations.URL_Endpoint__c +
      endpointInformations.Complement_URL_Document_List_By_Target__c
    );
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    request.setTimeout(60000);

    //Build request body
    String accountBa;
    if (partnerUser != null && partnerUser.ContactId != null && ba == null) {
      try {
        accountBa = [
          SELECT Numeric_Id__c
          FROM SMC_PS_AssetLibrary_Ba__mdt
          WHERE
            DeveloperName = :partnerUser.Contact.Account.SMC_Community_Products_Interests__c
        ]
        .Numeric_Id__c;
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          e + ' ==> The BA take the default value "PCO".'
        );
        accountBa = '1'; //PCO by default
      }
    } else if (ba != null) {
      accountBa = ba;
    }

    if (accountBa == null || accountBa == STA_UtilsStatic.EMPTY_STRING) {
      accountBa = '1'; //PCO by default
    }

    request.setBody(
      stringEncode(
        buildMapDocList(
          target,
          accountBa,
          productFamily,
          docType,
          language,
          limitByPage,
          offset,
          textSearch,
          filterByLastVersionDate,
          filterByName,
          (partnerUser != null ? partnerUser.SMC_Partner_Level__c : '')
        )
      )
    );

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery = STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String responseBody = STA_UtilsStatic.EMPTY_STRING;
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents jsonResult;
    try {
      response = http.send(request);
      responseBody = response.getBody();
      System.debug('response : ' + responseBody);
      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
          );
          throw calloutException;
        }
        jsonResult = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents) JSON.deserialize(
          responseBody,
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents.class
        );
        jsonResult.responseBody = responseBody;
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<CalloutException>{ calloutException },
        STA_UtilsStatic.ERROR_MARKETING_DOC_LIST,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_MARKETING_DOC_LIST,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    }

    return jsonResult;
  }

  /**
   * @description : callout to get picklist BA and ProductFamily
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param wsToCall
   * @param baSelected
   * @param endpointInformations
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent getPicklistBaAndProductFamily(
    String wsToCall,
    String baSelected,
    Endpoint_DocList_Community__mdt endpointInformations
  ) {
    //Check if call mock
    String choosePicklist = wsToCall.split('-')[1];
    if (endpointInformations.SMC_Is_Mocking_Mode__c) {
      if (choosePicklist == STA_UtilsStatic.BA) {
        StaticResource static_resource = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_BA
        ];
        return (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
          static_resource.Body.toString(),
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
        );
      } else if (choosePicklist == STA_UtilsStatic.PRODUCT_FAMILY) {
        StaticResource static_resource = [
          SELECT Id, Body
          FROM StaticResource
          WHERE
            Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_PRODUCT_FAMILY
        ];
        return (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
          static_resource.Body.toString(),
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
        );
      }
    }

    //Build the callout*****
    String errorLog;
    HttpRequest request = new HttpRequest();
    if (choosePicklist == STA_UtilsStatic.BA) {
      request.setEndpoint(
        endpointInformations.URL_Endpoint__c +
        endpointInformations.Complement_URL_Picklist_BA__c
      );
      errorLog = STA_UtilsStatic.ERROR_MARKETING_PICKLIST_BA;
    } else if (choosePicklist == STA_UtilsStatic.PRODUCT_FAMILY) {
      request.setEndpoint(
        endpointInformations.URL_Endpoint__c +
        endpointInformations.Complement_URL_Picklist_Product_Family__c
      );
      if (baSelected != null) {
        request.setBody(
          stringEncode(new Map<String, String>{ 'level0' => baSelected })
        );
      }
      errorLog = STA_UtilsStatic.ERROR_MARKETING_PICKLIST_LANGUAGE;
    }
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String responseBody = STA_UtilsStatic.EMPTY_STRING;
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent jsonResult;

    try {
      response = http.send(request);
      responseBody = response.getBody();
      jsonResult = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent) JSON.deserialize(
        responseBody,
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent.class
      );

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<CalloutException>{ calloutException },
        errorLog,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<Exception>{ e },
        errorLog,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    }

    return jsonResult;
  }

  /**
   * @description : callout to get Type and Language
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param wsToCall
   * @param endpointInformations
   * @return SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others
   **/
  @TestVisible
  private static SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others getPicklistDocTypeAndLanguage(
    String wsToCall,
    Endpoint_DocList_Community__mdt endpointInformations
  ) {
    //Check if call mock
    String choosePicklist = wsToCall.split('-')[1];
    if (endpointInformations.SMC_Is_Mocking_Mode__c) {
      if (choosePicklist == STA_UtilsStatic.DOC_TYPE) {
        StaticResource static_resource = [
          SELECT Id, Body
          FROM StaticResource
          WHERE
            Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_DOCUMENT_TYPE
        ];
        return (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
          static_resource.Body.toString(),
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
        );
      } else if (choosePicklist == STA_UtilsStatic.LANGUAGE) {
        StaticResource static_resource = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = :STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_LANGUAGE
        ];
        return (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
          static_resource.Body.toString(),
          SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
        );
      }
    }

    //Build the callout*****
    String errorLog;
    HttpRequest request = new HttpRequest();
    if (choosePicklist == STA_UtilsStatic.DOC_TYPE) {
      request.setEndpoint(
        endpointInformations.URL_Endpoint__c +
        endpointInformations.Complement_URL_Picklist_Document_Type__c
      );
      errorLog = STA_UtilsStatic.ERROR_MARKETING_PICKLIST_DOC_TYPE;
    } else if (choosePicklist == STA_UtilsStatic.LANGUAGE) {
      request.setEndpoint(
        endpointInformations.URL_Endpoint__c +
        endpointInformations.Complement_URL_Picklist_Language__c
      );
      errorLog = STA_UtilsStatic.ERROR_MARKETING_PICKLIST_LANGUAGE;
    }
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + 'empty';
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String responseBody = STA_UtilsStatic.EMPTY_STRING;
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others jsonResult;

    try {
      response = http.send(request);
      responseBody = response.getBody();
      jsonResult = (SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others) JSON.deserialize(
        responseBody,
        SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others.class
      );

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<CalloutException>{ calloutException },
        errorLog,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_AC_Marketing_Library.sendErrorLog(
        new List<Exception>{ e },
        errorLog,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery
      );
    }
    return jsonResult;
  }

  @AuraEnabled
  public static String checkPictureUrl(String url) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setMethod(STA_UtilsStatic.GET_METHOD);

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String htmlResponse = STA_UtilsStatic.EMPTY_STRING;

    try {
      response = http.send(request);
      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        return System.Label.SMC_NoPicture_Path;
      }
    } catch (Exception e) {
      return System.Label.SMC_NoPicture_Path;
    }

    return url;
  }

  /**
   * @description : generate a SMC_Log__c
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param exceptions
   * @param errorProcessName
   * @param typeProcess
   * @param body
   * @param query
   * @return void
   **/
  public static void sendErrorLog(
    List<Exception> exceptions,
    String errorProcessName,
    String typeProcess,
    String body,
    String query
  ) {
    SMC_UTIL_Methods_Batch.createErrorLog(
      exceptions,
      errorProcessName,
      STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
      body,
      query,
      null
    );
  }
}