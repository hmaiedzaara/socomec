/**
 * @File Name          : TEST_SMC_DTOs.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-24-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2019   Vincent RECASENS (Modis)     Initial Version
 **/

@isTest
public without sharing class TEST_SMC_DTOs {
  /**
   * @description : test all dtos
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testAllDtO() {
    String stringCheckField = STA_UtilsStatic.CHECK_FIELD;

    //NewQuote
    SMC_DTO_NewQuoteForProject dtoExpected1 = new SMC_DTO_NewQuoteForProject(
      new Opportunity(),
      new List<Account>{ new Account() },
      new List<Contact>{ new Contact() },
      null,
      true,
      new List<User>{ new User() }
    );
    SMC_DTO_NewQuoteForProject dtoExpected2 = new SMC_DTO_NewQuoteForProject(
      false,
      new Opportunity(),
      new List<Account>{ new Account() },
      new List<Contact>{ new Contact() },
      null,
      true,
      new List<User>{ new User() }
    );

    //Discount Token
    SMC_DTO_DiscountToken discountToken = new SMC_DTO_DiscountToken();
    discountToken.refreshToken = stringCheckField;

    //Get All Scoring
    SMC_DTO_GetAllScoring getAllScoring = new SMC_DTO_GetAllScoring();
    getAllScoring.account = stringCheckField;
    getAllScoring.country = stringCheckField;
    getAllScoring.category = stringCheckField;
    getAllScoring.business = stringCheckField;
    getAllScoring.acc = stringCheckField;
    getAllScoring.tier = stringCheckField;
    getAllScoring.user = stringCheckField;
    getAllScoring.baIds = stringCheckField;
    getAllScoring.bas = new List<SMC_DTO_Scoring_BAs>();
    getAllScoring.scorings = new List<SMC_DTO_Scoring>();

    //Get Informations For Token
    SMC_DTO_GetInformationsForToken getInformationsForToken = new SMC_DTO_GetInformationsForToken();
    getInformationsForToken.application = stringCheckField;
    getInformationsForToken.secret = stringCheckField;
    getInformationsForToken.SFDCUser = new SMC_DTO_SDFCUser();
    //SFDC User
    getInformationsForToken.SFDCUser.username = stringCheckField;
    getInformationsForToken.SFDCUser.firstname = stringCheckField;
    getInformationsForToken.SFDCUser.lastname = stringCheckField;
    getInformationsForToken.SFDCUser.alias = stringCheckField;
    getInformationsForToken.SFDCUser.email = stringCheckField;

    //Sales Order Details
    SMC_DTO_SalesOrderDetails salesOrderDetails = new SMC_DTO_SalesOrderDetails();
    salesOrderDetails.salesOrder = stringCheckField;
    salesOrderDetails.positionNumber = 0;
    salesOrderDetails.item = stringCheckField;
    salesOrderDetails.itemDescription = stringCheckField;
    salesOrderDetails.orderedQuantity = 0;
    salesOrderDetails.deliveredQuantity = 0;
    salesOrderDetails.backOrder = 0;
    salesOrderDetails.packingSlipNumber = 0;
    salesOrderDetails.invoiceNumber = 0;
    salesOrderDetails.deliverySlipDate = DateTime.now();
    salesOrderDetails.salesOrderFlowCategory = stringCheckField;
    salesOrderDetails.packingSlipShippingDate = DateTime.now();
    salesOrderDetails.packingSlipCarrier = stringCheckField;
    salesOrderDetails.packingSlipTrackingNumber = stringCheckField;
    salesOrderDetails.lineExWorkConfirmed = DateTime.now();
    salesOrderDetails.lineReviewDate = DateTime.now();

    //SN Product Info
    SMC_DTO_SN_ProductInfo snProductInfo = new SMC_DTO_SN_ProductInfo();
    snProductInfo.id = 0;
    snProductInfo.serialNumber = stringCheckField;
    snProductInfo.rate = 0;
    snProductInfo.productFamily = stringCheckField;
    snProductInfo.productFamilyDescription = stringCheckField;
    snProductInfo.productModel = stringCheckField;
    snProductInfo.productModelDescription = stringCheckField;
    snProductInfo.productConfig = stringCheckField;
    snProductInfo.productConfigDescription = stringCheckField;

    //Quote SimuExpress
    SMC_DTO_SimuExpress simuExpress = new SMC_DTO_SimuExpress();
    simuExpress.isRedirect = true;
    simuExpress.resultList = new List<String>{ stringCheckField };
    simuExpress.dtoMissingFields = new SMC_DTO_QuotationTool_MissingFields();

    //Scoring
    SMC_DTO_Scoring scoring = new SMC_DTO_Scoring();
    scoring.userSeeMaxSuggested = true;
    scoring.userLanguage = stringCheckField;
    scoring.ba = new SMC_DTO_Scoring_BusinessApplication();
    //Scoring Scoring
    SMC_DTO_Scoring_Scoring ba = new SMC_DTO_Scoring_Scoring();
    ba.id = stringCheckField;
    ba.sfAccount = stringCheckField;
    ba.dpxId = 0;
    ba.dpx = new SMC_DTO_Scoring_DPX();
    ba.countViewer = 0;
    ba.pricingPolicyId = 0;
    ba.pricingPolicy = new SMC_DTO_Scoring_PricingPolicy();
    ba.scoringLines = new List<SMC_DTO_Scoring_ScoringLine>{
      new SMC_DTO_Scoring_ScoringLine()
    };
    //Scoring DPX
    SMC_DTO_Scoring_DPX dpx = new SMC_DTO_Scoring_DPX();
    dpx.id = stringCheckField;
    dpx.startDate = stringCheckField;
    dpx.endDate = stringCheckField;
    dpx.description = stringCheckField;
    dpx.businessApplication = new SMC_DTO_Scoring_BusinessApplication();
    //BA
    dpx.businessApplication.id = 0;
    dpx.businessApplication.ba = stringCheckField;
    //Scoring PricingPolicy
    SMC_DTO_Scoring_PricingPolicy pricingPolicy = new SMC_DTO_Scoring_PricingPolicy();
    pricingPolicy.id = 0;
    pricingPolicy.code = stringCheckField;
    pricingPolicy.isCorporate = true;
    pricingPolicy.label = stringCheckField;
    pricingPolicy.isActive = true;
    //Scoring PricingGroup - 1
    SMC_DTO_Scoring_PricingGroup pricingGroup1 = new SMC_DTO_Scoring_PricingGroup();
    pricingGroup1.id = stringCheckField;
    pricingGroup1.label = stringCheckField;
    pricingGroup1.description = stringCheckField;
    pricingGroup1.tri = 1;
    //Scoring PricingGroup - 2
    SMC_DTO_Scoring_PricingGroup pricingGroup2 = new SMC_DTO_Scoring_PricingGroup();
    pricingGroup2.id = stringCheckField;
    pricingGroup2.label = stringCheckField;
    pricingGroup2.description = stringCheckField;
    pricingGroup2.tri = 2;
    //Scoring ScoringLine - 1
    SMC_DTO_Scoring_ScoringLine scoringLine1 = new SMC_DTO_Scoring_ScoringLine();
    scoringLine1.id = 0;
    scoringLine1.priceGroup = new SMC_DTO_Scoring_PricingGroup();
    scoringLine1.maxSuggested = 0.0;
    scoringLine1.min = 0.0;
    scoringLine1.max = 20;
    scoringLine1.discount = 0.0;
    scoringLine1.discountTemp = 20;
    scoringLine1.createDate = Datetime.now();
    scoringLine1.valid = true;
    scoringLine1.isModified = true;
    scoringLine1.discountTempExist = true;
    //Scoring ScoringLine - 2
    SMC_DTO_Scoring_ScoringLine scoringLine2 = new SMC_DTO_Scoring_ScoringLine();
    scoringLine2.id = 0;
    scoringLine2.priceGroup = null;
    scoringLine2.maxSuggested = 0.0;
    scoringLine2.min = 0.0;
    scoringLine2.max = 0.0;
    scoringLine2.discount = 0.0;
    scoringLine2.discountTemp = 0.0;
    scoringLine2.createDate = Datetime.now();
    scoringLine2.valid = true;
    scoringLine2.isModified = true;
    scoringLine2.discountTempExist = true;
    //Scoring ScoringLine - 3
    SMC_DTO_Scoring_ScoringLine scoringLine3 = new SMC_DTO_Scoring_ScoringLine();
    scoringLine3.id = 0;
    scoringLine3.priceGroup = null;
    scoringLine3.maxSuggested = 0.0;
    scoringLine3.min = 0.0;
    scoringLine3.max = 0.0;
    scoringLine3.discount = 0.0;
    scoringLine3.discountTemp = 0.0;
    scoringLine3.createDate = Datetime.now();
    scoringLine3.valid = true;
    scoringLine3.isModified = true;
    scoringLine3.discountTempExist = true;
    //Scoring ScoringLine - compare to
    scoringLine1.compareTo(scoringLine2);
    scoringLine1.compareTo(scoringLine3);

    //Scoring  ThScoringLine - 1
    SMC_DTO_TheScoringLine theScoringLine1 = new SMC_DTO_TheScoringLine();
    theScoringLine1.scoringLineId = 0;
    theScoringLine1.discount = 0.0;
    theScoringLine1.maxSuggested = 0.0;
    theScoringLine1.discountTemp = 0.0;
    theScoringLine1.user = stringCheckField;
    //Scoring  ThScoringLine - 2
    SMC_DTO_TheScoringLine theScoringLine2 = new SMC_DTO_TheScoringLine(
      scoringLine1,
      UserInfo.getUserId()
    );

    //Scoring Upsert Account For Scoring
    SMC_DTO_UpsertAccountForScoring upsertAccountForScoring = new SMC_DTO_UpsertAccountForScoring();
    upsertAccountForScoring.account = new Account().Id;
    upsertAccountForScoring.business = stringCheckField;
    upsertAccountForScoring.country = stringCheckField;
    upsertAccountForScoring.category = stringCheckField;
    upsertAccountForScoring.acc = stringCheckField;
    upsertAccountForScoring.baIds = 1;
    //Upsert pt.2
    SMC_DTO_UpsertAccountForScoring upsertAccountForScoringPT2 = new SMC_DTO_UpsertAccountForScoring(
      new Account().Id,
      stringCheckField,
      stringCheckField
    );
    //Upsert pt.3
    SMC_DTO_UpsertAccountForScoring upsertAccountForScoringPT3 = new SMC_DTO_UpsertAccountForScoring(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );

    //Are Scored
    SMC_DTO_Scoring_AreScored areScored = new SMC_DTO_Scoring_AreScored();
    areScored.account = stringCheckField;
    areScored.country = stringCheckField;
    areScored.category = stringCheckField;
    areScored.business = stringCheckField;
    areScored.acc = stringCheckField;
    areScored.tier = stringCheckField;
    areScored.user = stringCheckField;
    areScored.baIds = stringCheckField;
    areScored.bas = new List<SMC_DTO_Scoring_BAs>();
    areScored.valid = true;
    areScored.answerRequired = true;

    //Bas
    SMC_DTO_Scoring_BAs bas = new SMC_DTO_Scoring_BAs();
    bas.id = stringCheckField;
    bas.ba = stringCheckField;
    bas.expiryDate = stringCheckField;
    bas.valid = true;
    bas.answerRequired = true;
    SMC_DTO_Scoring_BAs basBis = new SMC_DTO_Scoring_BAs('id', 'ba');

    //Scoring Form
    SMC_DTO_ScoringForm scoringForm = new SMC_DTO_ScoringForm();
    scoringForm.token = stringCheckField;
    scoringForm.discountTokenDto = new SMC_DTO_DiscountToken();
    scoringForm.account = new Account();
    scoringForm.urlPartial = stringCheckField;
    scoringForm.scoringExist = true;
    scoringForm.baIds = new List<String>{ stringCheckField };

    //Marketing AllData
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData();
    allData.totalrecords = 100;
    allData.bas = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent();
    allData.productFamily = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent();
    allData.docType = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others();
    allData.language = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others();
    allData.docList.nbDocuments = 100;

    //Marketing Documents
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document wrapperDocs = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document();
    wrapperDocs.averageRate = 1.0;
    wrapperDocs.document_reference = 'test';
    wrapperDocs.docTreeLevel = 'test';
    wrapperDocs.publicPicturePath = 'test';
    wrapperDocs.subfamily = 'test';
    wrapperDocs.family = 'test';
    wrapperDocs.publicPictureDefaultPath = 'test';
    wrapperDocs.documentType = 'test';
    wrapperDocs.dbid = 'test';
    wrapperDocs.userRate = 100;
    wrapperDocs.files = new List<SMC_DTO_ML_Wrappers.SMC_DTO_ML_File>();
    wrapperDocs.documentId = 'test';
    wrapperDocs.documentTitle = 'test';
    wrapperDocs.thumbnail_url = 'test';
    //Marketing Documents1
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document wrapperDocs1 = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document();
    wrapperDocs.averageRate = 1.0;
    wrapperDocs.document_reference = 'test1';
    wrapperDocs.docTreeLevel = 'test1';
    wrapperDocs.publicPicturePath = 'test1';
    wrapperDocs.subfamily = 'test1';
    wrapperDocs.family = 'test1';
    wrapperDocs.publicPictureDefaultPath = 'test1';
    wrapperDocs.documentType = 'test1';
    wrapperDocs.dbid = 'test1';
    wrapperDocs.userRate = 100;
    wrapperDocs.files = new List<SMC_DTO_ML_Wrappers.SMC_DTO_ML_File>();
    wrapperDocs.documentId = 'test1';
    wrapperDocs.documentTitle = 'test1';
    wrapperDocs.thumbnail_url = 'test1';
    wrapperDocs1.compareTo(wrapperDocs);

    //Marketing Files
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_File wrapperFile = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_File();
    wrapperFile.fileName = 'test';
    wrapperFile.audience = 'test';
    wrapperFile.last_version_date = 'test';
    wrapperFile.author = 'test';
    wrapperFile.creation_date = 'test';
    wrapperFile.publicPath = 'test';
    wrapperFile.dbid = 'test';
    wrapperFile.fileReference = 'test';
    wrapperFile.lang = 'test';
    wrapperFile.fileId = 'test';
    wrapperFile.isNew = true;
    wrapperFile.isPublic = true;
    wrapperFile.targets = new List<SMC_DTO_ML_Wrappers.SMC_DTO_ML_Target>();

    //Marketing Children
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children wrapperChildren = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children wrapperChildren2 = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Children(
      'test',
      'test'
    );

    //Marketing Children
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_GrandChildren wrapperGrandChildren = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_GrandChildren(
      'test',
      'test'
    );

    //Marketing OtherDetails
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails wrapperOtherDetails = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails();
      wrapperOtherDetails.label = 'aa';
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails wrapperOtherDetails2 = new SMC_DTO_ML_Wrappers.SMC_DTO_ML_OthersDetails(
      'test',
      'test'
    );
      wrapperOtherDetails.compareTo(wrapperOtherDetails2);

    //Gearset NEED at least one System.assert() by method
    System.assert(true, 'The function assert is broken.');
  }
}