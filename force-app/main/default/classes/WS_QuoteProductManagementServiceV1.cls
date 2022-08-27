/*
---------------------------------------------------------------------
-- - Name          : WS_QuoteProductManagementServiceV1
-- - Author        : David SOBCZAK (DOS) - Vincent RECASENS (VRE)
-- - Description   : Web services for extenal app which manage quote product for a quote          
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 20-Nov-2017  DOS    1.0     Initial version
-- 12-MAR-2019  VRE    1.1     Modify deleteOldFile
-- 02-MAY-2019  VRE    1.2     Fix SOQL query --> list creation l.92/95 + where clause l.97 
-- 10-JUL-2019  DOS    2.0     Rename file and bulk "deleteFile"
--------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/quote/product_management/v1/*')
global with sharing class WS_QuoteProductManagementServiceV1 {
  /****************************************************
   *HttpPut method
   *****************************************************/
  // @HttpPut json parameter
  global class pQuoteLineItem {
    public String description;
    public Decimal id;
    public Decimal MAX;
    public Decimal maxApplied;
    public Decimal MAXSUG;
    public Decimal MIN;
    public Decimal minApplied;
    public Decimal REM;
    public String title;
    public Decimal weight;
  }

  /**
   * @description : test uàpdate QuoteLine for new/update File
   * @author Vincent RECASENS (Modis) | 07-15-2020
   * @param p_QuoteLineItems
   * @param p_GeneratedVersion
   * @return WS_ResponseHandlerV1
   **/
  @HttpPut
  global static WS_ResponseHandlerV1 upsertQuoteLine(
    List<pQuoteLineItem> p_QuoteLineItems,
    String p_GeneratedVersion
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> WS_QuoteProductManagementServiceV1 upsertQuoteLine(List<pQuoteLineItem> p_QuoteLineItems):START <<< ##'
    );
    WS_ResponseHandlerV1 response = new WS_ResponseHandlerV1(false);
    Quote quoteContext = new Quote();
    /*****
     *Retrieve quote concerning
     */
    try {
      RestRequest request = RestContext.request;
      String quoteId = request.requestURI.substring(
        request.requestURI.lastIndexOf('/') + 1
      );
      quoteContext = [
        SELECT
          Id,
          OpportunityId,
          Pricebook2Id,
          CurrencyIsoCode,
          SMC_Quote_Doc_Last_Generated_Version__c,
          SMC_Quote_Doc_Version_Generated_Date__c,
          SMC_Quote_Document_Status__c,
          QuoteNumber
        FROM Quote
        WHERE Id = :quoteId
        LIMIT 1
      ];
    } catch (Exception e) {
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0001';
      response.Message = e.getMessage();
    }

    /*****
     *Delete previous quote lines
     */

    try {
      List<QuoteLineItem> oldQuoteLineItems = [
        SELECT Id
        FROM QuoteLineItem
        WHERE QuoteId = :quoteContext.Id
      ];

      delete oldQuoteLineItems;
    } catch (Exception e) {
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0002';
      response.Message = e.getMessage();
    }

    /*****
     *Retrieve pricebook from the quote - If not exist insert the standard pricebook
     */
    try {
      Id priceBookId = quoteContext.Pricebook2Id;
      if (priceBookId == null) {
        priceBookId = [
          SELECT id, name
          FROM Pricebook2
          WHERE isStandard = true
          LIMIT 1
        ]
        .Id;
        quoteContext.Pricebook2Id = priceBookId;
        update quoteContext;
      }
    } catch (Exception e) {
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0003';
      response.Message = e.getMessage();
    }

    /*****
     *Insert new quote lines
     */

    List<String> quoteLineItemTitleToFilterProduct = new List<String>();
    if (p_QuoteLineItems != null) {
      for (pQuoteLineItem quoteLine : p_QuoteLineItems) {
        quoteLineItemTitleToFilterProduct.add(quoteLine.TItle);
      }
    }
    try {
      List<Product2> products = [
        SELECT Id, ProductCode
        FROM Product2
        WHERE ProductCode IN :quoteLineItemTitleToFilterProduct
      ];
      Map<String, Product2> productsMap = new Map<String, Product2>();
      for (Product2 product : products) {
        productsMap.put(product.ProductCode, product);
      }

      List<PricebookEntry> pricebookEntries = [
        SELECT Id, Product2Id
        FROM PricebookEntry
        WHERE
          Pricebook2Id = :quoteContext.Pricebook2Id
          AND CurrencyIsoCode = :quoteContext.CurrencyIsoCode
      ];
      Map<String, PricebookEntry> pricebookEntriesMap = new Map<String, PricebookEntry>();
      for (PricebookEntry pricebookEntry : pricebookEntries) {
        pricebookEntriesMap.put(pricebookEntry.Product2Id, pricebookEntry);
      }

      List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();

      for (pQuoteLineItem quoteLine : p_QuoteLineItems) {
        QuoteLineItem quoteLineItem = new QuoteLineItem();
        quoteLineItem.QuoteId = quoteContext.Id;
        quoteLineItem.Product2Id = productsMap.get(quoteLine.title).Id;
        quoteLineItem.PricebookEntryId = pricebookEntriesMap.get(
            quoteLineItem.Product2Id
          )
          .Id;
        quoteLineItem.Quantity = 1;
        quoteLineItem.UnitPrice = quoteLine.weight;

        quoteLineItem.SMC_Applied_Discount__c = quoteLine.maxApplied;
        quoteLineItem.SMC_Customer_Sales_Discount__c = quoteLine.REM;
        quoteLineItem.SMC_Max_Discount__c = quoteLine.MAX;
        quoteLineItem.SMC_Min_Discount__c = quoteLine.MIN;

        newQuoteLineItems.add(quoteLineItem);
      }
      insert newQuoteLineItems;
      response.isSuccess = true;
      response.Status = STA_UtilsStatic.SUCCESS_STATUS;
      response.Message = 'SUCCESS : New quote lines inserted with success';
    } catch (Exception e) {
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0004';
      response.Message = e.getMessage();
    }

    /*****
     *Delete previous document
     */

    try {
      /* DOS --> Vincent ne decommente pas ce code STP
            List<ContentDocumentLink> docList = new List<ContentDocumentLink>();
            if (quoteContext.SMC_Quote_Doc_Last_Generated_Version__c != null){
                 //Prepare where clauses
                 SF_Technical_User__mdt soc1Id = [SELECT UserId__c FROM SF_Technical_User__mdt LIMIT 1]; //There is only 1 value, the id of the user "SOC1"
                 String contentDocumentTitle = '%' + quoteContext.QuoteNumber + '_' + quoteContext.SMC_Quote_Doc_Last_Generated_Version__c + '%';
                 //Request
                 docList = [SELECT ContentDocumentId 
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId = :quoteContext.Id 
                            AND LinkedEntity.Type = :STA_UtilsStatic.QUOTE 
                            AND ContentDocument.Title LIKE :contentDocumentTitle 
                            AND ContentDocument.OwnerId = :soc1Id.UserId__c 
                            ORDER BY SystemModstamp ASC];
                System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1 upsertQuoteLine(List<pQuoteLineItem> p_QuoteLineItems):SOQL : ' + quoteContext.Id  + ' - ' + STA_UtilsStatic.QUOTE + ' - ' + contentDocumentTitle +' - ' + soc1Id.UserId__c   + ' <<< ##');
            	System.debug(LoggingLevel.INFO, 'docList.size() : ' + docList.size());
            }
            if (docList.size() >= 1){
                 delete docList[0];
            }
			*/
      new WithoutSharingFunctions().deleteOldFile(quoteContext);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'Error catched (Delete previous document) : ' + e
      );
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0005';
      response.Message = e.getMessage();
    }

    /*****
     *Update QT Status and Quote Document Version info
     */

    try {
      quoteContext.SMC_Quote_Doc_Last_Generated_Version__c = p_GeneratedVersion;
      quoteContext.SMC_Quote_Doc_Version_Generated_Date__c = DateTime.now();
      quoteContext.SMC_Quote_Document_Status__c = STA_UtilsStatic.QUOTE_DOC_STATUS;
      update quoteContext;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'Error catched (Update QT and document version) : ' + e
      );
      response.Status = STA_UtilsStatic.ERROR_STATUS;
      response.ErrorCode = 'WS_QuoteProductManagementServiceV1-0006';
      response.Message = e.getMessage();
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> WS_QuoteProductManagementServiceV1 upsertQuoteLine(List<pQuoteLineItem> p_QuoteLineItems):END <<< ##'
    );
    return response;
  }

  /**
   * Class to bypass sharing where non-admins must do operation with admin privilege (ex : delete a file owner by technical user)
   */
  public without sharing class WithoutSharingFunctions {
    // public WithoutSharingFunctions(Quote quoteContext){
    //     deleteOldFile(quoteContext);
    // }
    @TestVisible
    private void deleteOldFile(Quote quoteContext) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:START <<< ##'
      );

      List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
      List<ContentDocumentLink> docLinkListCloneToDelete = new List<ContentDocumentLink>();
      List<ContentDocument> contentsDocToDelete = new List<ContentDocument>();
      if (quoteContext.SMC_Quote_Doc_Last_Generated_Version__c != null) {
        //Prepare where clauses
        SF_Technical_User__mdt soc1 = [
          SELECT UserId__c
          FROM SF_Technical_User__mdt
          WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
        ];
        String contentDocumentTitle =
          STA_UtilsStatic.PERCENT +
          quoteContext.QuoteNumber +
          STA_UtilsStatic.UNDERSCORE +
          quoteContext.SMC_Quote_Doc_Last_Generated_Version__c +
          STA_UtilsStatic.PERCENT;
        ContentDocumentLink theContentDocumentLink;
        try {
          //Find ContentDocument to retrieved all ContentDocumentLink link to this COntenDocumentId
          theContentDocumentLink = [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE
              ContentDocument.Title LIKE :contentDocumentTitle
              AND LinkedEntityId = :quoteContext.Id
              AND ContentDocument.OwnerId = :soc1.UserId__c
          ];
        } catch (Exception e) {
          System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
          System.debug(
            LoggingLevel.INFO,
            '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - No File/Link to delete OR More than 1 <<< ##'
          );
          throw e;
        }

        //Request
        docLinkList = [
          SELECT Id, ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE ContentDocumentId = :theContentDocumentLink.ContentDocumentId
        ];

        //Check if File is link to an Email - If TRUE, it's a Quotation so we won't delete it
        //We keep index of docLink.SOC1 and docLink.EmailMessage in a list to remove them from docLinkList
        Boolean deleteContentDocument = true;
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink oneDocLink : docLinkList) {
          if (
            oneDocLink.LinkedEntityId.getSObjectType() !=
            Schema.EmailMessage.SobjectType &&
            oneDocLink.LinkedEntityId != soc1.UserId__c
          ) {
            docLinkListCloneToDelete.add(oneDocLink);
            contentDocumentIds.add(oneDocLink.ContentDocumentId);
          }
        }

        //Remove element docLink.SOC1 and docLink.EmailMessage
        if ((docLinkList.size() - docLinkListCloneToDelete.size()) > 1) {
          delete docLinkListCloneToDelete;

          /* DOS - 10-JUL-2019 - Rename history file  */
          List<ContentDocument> contentDocuments = new List<ContentDocument>();
          contentDocuments = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds
          ];
          for (ContentDocument oneContentDocument : contentDocuments) {
            oneContentDocument.Title = System.Label.SMC_OfferSent;
          }
          update contentDocuments;

          System.debug(
            LoggingLevel.INFO,
            '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - Historisation <<< ##'
          );
        } else {
          //If the file isn't a Quotation, we delete it
          Database.delete(theContentDocumentLink.ContentDocumentId);
          System.debug(
            LoggingLevel.INFO,
            '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - Delete File <<< ##'
          );
        }
      }
    }

    // @TestVisible
    // private void deleteOldFile(Quote quoteContext){
    //     System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:START <<< ##');

    //     if(quoteContext.SMC_Quote_Doc_Last_Generated_Version__c != null){
    //         //Prepare where clauses
    //         SF_Technical_User__mdt soc1 = [SELECT UserId__c FROM SF_Technical_User__mdt WHERE Username__c =: STA_UtilsStatic.TECHNICAL_USER_SOC1];
    //         String contentDocumentTitle = STA_UtilsStatic.PERCENT +
    //                                       quoteContext.QuoteNumber +
    //                                       STA_UtilsStatic.UNDERSCORE +
    //                                       quoteContext.SMC_Quote_Doc_Last_Generated_Version__c +
    //                                       STA_UtilsStatic.PERCENT;
    //         List<ContentDocumentLink> theContentDocumentLinksToQuote = new List<ContentDocumentLink>();
    //         try{
    //             //Find ContentDocument to retrieved all ContentDocumentLink link to this COntenDocumentId
    //             theContentDocumentLinksToQuote = [SELECT ContentDocumentId, ContentDocument.Title
    //                                                 FROM ContentDocumentLink
    //                                                 WHERE ContentDocument.Title LIKE :contentDocumentTitle
    //                                                 AND LinkedEntityId = :quoteContext.Id
    //                                                 AND ContentDocument.OwnerId = :soc1.UserId__c];

    //             //Rename file
    //             renameOldFile(quoteContext.Name, contentDocumentTitle, soc1);
    //         }
    //         catch(Exception e){
    //             System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
    //             System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - No File/Link to delete <<< ##');
    //             throw e;
    //         }

    //         //Start sorting between link to delete and link to keep
    //         if(theContentDocumentLinksToQuote.size() == 0){
    //             System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - No Link to delete <<< ##');
    //             return;
    //         }
    //         else{
    //             Map<Id, List<ContentDocumentLink>> mapContentDocumentIdToListContentDocumentLink = new Map<Id, List<ContentDocumentLink>>();
    //             Map<Id, List<ContentDocumentLink>> mapContentDocumentIdToListContentDocumentLinkToDelete = new Map<Id, List<ContentDocumentLink>>();
    //             Set<Id> contentDocumentIds = new Set<Id>();
    //             for(ContentDocumentLink oneContentDocumentLink : theContentDocumentLinksToQuote){
    //                 contentDocumentIds.add(oneContentDocumentLink.ContentDocumentId);
    //             }

    //             for(ContentDocumentLink oneContentDocumentLink : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){
    //                 //Build Maps
    //                 if(mapContentDocumentIdToListContentDocumentLink.get(oneContentDocumentLink.ContentDocumentId) != null){
    //                     mapContentDocumentIdToListContentDocumentLink.get(oneContentDocumentLink.ContentDocumentId).add(oneContentDocumentLink);
    //                     //Search link to delete
    //                     if(oneContentDocumentLink.LinkedEntityId.getSObjectType() != Schema.Quote.SobjectType &&
    //                        oneContentDocumentLink.LinkedEntityId != soc1.UserId__c){
    //                         mapContentDocumentIdToListContentDocumentLinkToDelete.get(oneContentDocumentLink.ContentDocumentId).add(oneContentDocumentLink);
    //                     }
    //                 }
    //                 else{
    //                     mapContentDocumentIdToListContentDocumentLink.put(oneContentDocumentLink.ContentDocumentId, new List<ContentDocumentLink>{oneContentDocumentLink});
    //                     //Search link to delete
    //                     if(oneContentDocumentLink.LinkedEntityId.getSObjectType() != Schema.Quote.SobjectType &&
    //                        oneContentDocumentLink.LinkedEntityId != soc1.UserId__c){
    //                         mapContentDocumentIdToListContentDocumentLinkToDelete.put(oneContentDocumentLink.ContentDocumentId, new List<ContentDocumentLink>{oneContentDocumentLink});
    //                     }
    //                     else{
    //                         mapContentDocumentIdToListContentDocumentLinkToDelete.put(oneContentDocumentLink.ContentDocumentId, new List<ContentDocumentLink>());
    //                     }
    //                 }
    //             }

    //             //Compare Maps
    //             List<ContentDocumentLink> docLinkListToDelete = new List<ContentDocumentLink>();
    //             for(Id oneContentDocumentId : contentDocumentIds){
    //                 if(mapContentDocumentIdToListContentDocumentLink.get(oneContentDocumentId).size() - mapContentDocumentIdToListContentDocumentLinkToDelete.get(oneContentDocumentId).size() > 0){
    //                     //Historisation
    //                     docLinkListToDelete.addAll(mapContentDocumentIdToListContentDocumentLinkToDelete.get(oneContentDocumentId));
    //                 }
    //             }

    //             //Delete links
    //             if(docLinkListToDelete.size() > 0){
    //                 Database.delete(docLinkListToDelete);
    //                 System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - Link deleted <<< ##');
    //             }
    //             System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END <<< ##');
    //         }
    //     }
    // }

    // private void renameOldFile(String quoteName, String contentDocumentTitle, SF_Technical_User__mdt soc1){
    //     List<EmailMessage> emailMessageWithAttachment = new List<EmailMessage>();
    //     List<Attachment> attachments = new List<Attachment>();

    //     emailMessageWithAttachment = [SELECT Id, Subject
    //                                     FROM EmailMessage
    //                                     WHERE Subject = :quoteName
    //                                     AND HasAttachment = TRUE];
    //     Set<Id> emailMessageIds = new Set<Id>();
    //     for(EmailMessage oneEmailMessage : emailMessageWithAttachment){
    //         emailMessageIds.add(oneEmailMessage.Id);
    //     }

    //     List<ContentDocumentLink> theContentDocumentLinksToEmailMessage = new List<ContentDocumentLink>();
    //     //Find ContentDocument to retrieved all ContentDocumentLink link to this COntenDocumentId
    //     theContentDocumentLinksToEmailMessage = [SELECT ContentDocumentId, ContentDocument.Title
    //                                                 FROM ContentDocumentLink
    //                                                 WHERE ContentDocument.Title LIKE :contentDocumentTitle
    //                                                 AND LinkedEntityId IN :emailMessageIds
    //                                                 AND ContentDocument.OwnerId = :soc1.UserId__c];
    //     Set<Id> contentDocumentIds = new Set<Id>();
    //     for(ContentDocumentLink oneContentDocumentLink : theContentDocumentLinksToEmailMessage){
    //         contentDocumentIds.add(oneContentDocumentLink.ContentDocumentId);
    //     }

    //     List<ContentDocument> contentDocuments = new List<ContentDocument>();
    //     contentDocuments = [SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIds];

    //     for(ContentDocument oneContentDocument : contentDocuments){
    //         oneContentDocument.Title = System.Label.SMC_OfferSent;
    //     }

    //     update contentDocuments;
    //     System.debug(LoggingLevel.INFO, '## >>> WS_QuoteProductManagementServiceV1.WithoutSharingFunctions deleteOldFile:END - File rename <<< ##');
    // }
  }
}