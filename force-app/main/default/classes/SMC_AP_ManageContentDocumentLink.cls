/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageContentDocumentLink
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage ContentDocumentLink               
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 31-JUL-2018  (VR)    1.0         Initial version 
---------------------------------------------------------------------
*/
public without sharing class SMC_AP_ManageContentDocumentLink {
  /**
   * @description : inform of a new file on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList 
   **/
  public static void updateCaseNewContentDocumentLink(
    List<ContentDocumentLink> newList
  ) {
    Map<Id, Boolean> linkedEntities = new Map<Id, Boolean>();
    for (ContentDocumentLink oneContentDocumentLink : newList) {
      if (
        Schema.Case.SObjectType ==
        oneContentDocumentLink.LinkedEntityId.getSobjectType()
      ) {
        linkedEntities.put(oneContentDocumentLink.LinkedEntityId, false);
      }
    }

    if (linkedEntities.size() > 0) {
      SMC_AP_ManageCase.updateCaseNewObject(
        linkedEntities,
        STA_UtilsStatic.CONTENT_DOCUMENT_LINK
      );

      //send notif with calling PB
    }
  }

  /**
   * @description : manage visibilty after insert/update
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param contentDocumentIds
   * @return Boolean
   **/
  public static Boolean finishContentVersionInsertion(
    Set<Id> contentDocumentIds
  ) {
    List<ContentDocumentLink> contentDocumentsLink = new List<ContentDocumentLink>();
    contentDocumentsLink = [
      SELECT Id, Visibility, LinkedEntityId
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :contentDocumentIds
    ];
    for (ContentDocumentLink oneContentDocumentLink : contentDocumentsLink) {
      if (
        oneContentDocumentLink.LinkedEntityId.getSObjectType() !=
        Schema.User.SObjectType &&
        oneContentDocumentLink.LinkedEntityId.getSObjectType() !=
        Schema.EmailMessage.SObjectType
      ) {
        oneContentDocumentLink.Visibility = STA_UtilsStatic.ALL_USERS;
      }
    }

    try {
      update contentDocumentsLink;
    } catch (DMLException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR during SMC_AP_ManageContentVersion.finishInsertion --> ' +
        dmlException
      );
      return false;
    }
    return true;
  }

  /**
  * @description : used to duplicate file link from quote to prm quote linked
  * @author Vincent RECASENS (Modis) | 02-01-2022 
  * @param newMap 
  **/
  public static void duplicateLinkQuoteToPRMQuoteOrOpposite(Map<Id, ContentDocumentLink> newMap){
    Map<Id, List<Id>> mapQuoteId_ContentDocumentId = new Map<Id, List<Id>>();
    Map<Id, List<Id>> mapPRMQuoteId_ContentDocumentId = new Map<Id, List<Id>>();
    for (ContentDocumentLink oneCdl : newMap.values()) {
      //Check Quote
      if (oneCdl.LinkedEntityId != null && oneCdl.LinkedEntityId.getSObjectType() == Schema.Quote.SObjectType) {
        if(mapQuoteId_ContentDocumentId.get(oneCdl.LinkedEntityId) == null){
          mapQuoteId_ContentDocumentId.put(oneCdl.LinkedEntityId, new List<Id>());
        }
        mapQuoteId_ContentDocumentId.get(oneCdl.LinkedEntityId).add(oneCdl.ContentDocumentId);
      }
      //Check PRM Quote
      else if (oneCdl.LinkedEntityId != null && oneCdl.LinkedEntityId.getSObjectType() == Schema.SMC_PRM_Quote__c.SObjectType) {
        if(mapPRMQuoteId_ContentDocumentId.get(oneCdl.LinkedEntityId) == null){
          mapPRMQuoteId_ContentDocumentId.put(oneCdl.LinkedEntityId, new List<Id>());
        }
        mapPRMQuoteId_ContentDocumentId.get(oneCdl.LinkedEntityId).add(oneCdl.ContentDocumentId);
      }
    }

    //If there are no Quote or PRM Quote, get out of method
    if(mapQuoteId_ContentDocumentId.size() == 0 && mapPRMQuoteId_ContentDocumentId.size() == 0)
      return;

    List<ContentDocumentLink> contentDocumentLinksToPRMQuote = new List<ContentDocumentLink>();
    //For Quote
    if(mapQuoteId_ContentDocumentId.size() > 0){
      Map<Id, Quote> mapQuotes = 
        new Map<Id, Quote>([SELECT Id, 
                                   SMC_PRM_Quote__c 
                            FROM Quote 
                            WHERE Id IN :mapQuoteId_ContentDocumentId.keySet()]);

      for (Id quoteId : mapQuoteId_ContentDocumentId.keySet()) {
        Quote theQuote = mapQuotes.get(quoteId);
        if(theQuote.SMC_PRM_Quote__c != null){
          for(Id cdId : mapQuoteId_ContentDocumentId.get(quoteId)){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ShareType = 'I';
            cdl.ContentDocumentId = cdId;
            cdl.LinkedEntityId = theQuote.SMC_PRM_Quote__c;
            contentDocumentLinksToPRMQuote.add(cdl);
          }
        }
      }
    }
    //For PRM Quote
    if(mapPRMQuoteId_ContentDocumentId.size() > 0){
      Map<Id, SMC_PRM_Quote__c> mapPRMQuotes = 
        new Map<Id, SMC_PRM_Quote__c>([SELECT Id, 
                                              Quote__c 
                                       FROM SMC_PRM_Quote__c 
                                       WHERE Id IN :mapPRMQuoteId_ContentDocumentId.keySet()]);
                                       
      for (Id prmQuoteId : mapPRMQuoteId_ContentDocumentId.keySet()) {
        SMC_PRM_Quote__c thePRMQuote = mapPRMQuotes.get(prmQuoteId);
        if(thePRMQuote.Quote__c != null){
          for(Id cdId : mapPRMQuoteId_ContentDocumentId.get(prmQuoteId)){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cdId;
            cdl.ShareType = 'I';
            cdl.LinkedEntityId = thePRMQuote.Quote__c;
            contentDocumentLinksToPRMQuote.add(cdl);
          }
        }
      }
    }

    if(contentDocumentLinksToPRMQuote.size() > 0){
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
      insert contentDocumentLinksToPRMQuote;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
    }
  }

  public static void deletePRMQuoteOrQuoteLink(Map<Id, ContentDocumentLink> oldMap){
    Map<Id, List<Id>> mapQuoteId_ListCdId = new Map<Id, List<Id>>();
    Map<Id, List<Id>> mapPRMQuoteId_ListCdId = new Map<Id, List<Id>>();
    for(Id oneId : oldMap.keySet()){
      ContentDocumentLink oneCdl = oldMap.get(oneId);
      //Check Quote
      if (oneCdl.LinkedEntityId != null && oneCdl.LinkedEntityId.getSObjectType() == Schema.Quote.SObjectType) {
        if(mapQuoteId_ListCdId.get(oneCdl.LinkedEntityId) == null){
          mapQuoteId_ListCdId.put(oneCdl.LinkedEntityId, new List<Id>());
        }
        mapQuoteId_ListCdId.get(oneCdl.LinkedEntityId).add(oneCdl.ContentDocumentId);
      }
      //Check PRM Quote
      else if (oneCdl.LinkedEntityId != null && oneCdl.LinkedEntityId.getSObjectType() == Schema.SMC_PRM_Quote__c.SObjectType) {
        if(mapPRMQuoteId_ListCdId.get(oneCdl.LinkedEntityId) == null){
          mapPRMQuoteId_ListCdId.put(oneCdl.LinkedEntityId, new List<Id>());
        }
        mapPRMQuoteId_ListCdId.get(oneCdl.LinkedEntityId).add(oneCdl.ContentDocumentId);
      }
    }

    if(mapQuoteId_ListCdId.size() > 0 || mapPRMQuoteId_ListCdId.size() > 0){
      System.enqueueJob(new DeletePRMQuoteLink(mapQuoteId_ListCdId, mapPRMQuoteId_ListCdId));
    }
  }

  public without sharing class DeletePRMQuoteLink implements Queueable {
    Map<Id, List<Id>> mapQuoteId_ListCdId;
    Map<Id, List<Id>> mapPRMQuoteId_ListCdId;
    // List<ContentDocumentLink> cdlToDeleteOverMaxSize;

    public DeletePRMQuoteLink(Map<Id, List<Id>> mapQuoteId_ListCdId, Map<Id, List<Id>> mapPRMQuoteId_ListCdId){
      this.mapQuoteId_ListCdId = mapQuoteId_ListCdId;
      this.mapPRMQuoteId_ListCdId = mapPRMQuoteId_ListCdId;
    }

    // public DeletePRMQuoteLink(List<ContentDocumentLink> cdlToDeleteOverMaxSize){
    //   this.cdlToDeleteOverMaxSize = cdlToDeleteOverMaxSize;
    // }

    public void execute(QueueableContext context) {
      List<ContentDocumentLink> cdlToDelete = new List<ContentDocumentLink>();
      //Check PRM Quote link
      if(this.mapQuoteId_ListCdId.size() > 0){
        cdlToDelete = deleteLinkPRMQuote(cdlToDelete);
      }
      //Check Quote link
      if(this.mapPRMQuoteId_ListCdId.size() > 0){
        cdlToDelete = deleteLinkQuote(cdlToDelete);
      }

      //Delete list of content document link
      if(cdlToDelete.size() > 0){
        PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
        delete cdlToDelete;
        PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT);
      }

      /* IF NEEDED */
      //First execution - For more than 10000 record to delete
      // if(this.mapQuoteId_ListCdId != null)
      //   firstExecution();
      // else
      //   deleteListOverMaxSize();

      // //Check if there are more than 10000 record to delete and relaunch if needed
      // finish();
    }

    public List<ContentDocumentLink> deleteLinkPRMQuote(List<ContentDocumentLink> cdlToDelete){
      Map<Id, List<Id>> mapPRMQuoteId_ListCdIds = new Map<Id, List<Id>>();
      List<Id> cdIds = new List<Id>();
      for(Quote oneQuote : [SELECT Id, SMC_PRM_Quote__c FROM Quote WHERE Id IN :this.mapQuoteId_ListCdId.keySet()]){
        mapPRMQuoteId_ListCdIds.put(oneQuote.SMC_PRM_Quote__c, this.mapQuoteId_ListCdId.get(oneQuote.Id));
        cdIds.addAll(this.mapQuoteId_ListCdId.get(oneQuote.Id));
      }

      for(ContentDocumentLink oneCdl : [SELECT Id, 
                                               LinkedEntityId, 
                                               ContentDocumentId 
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId IN :cdIds AND 
                                              LinkedEntityId IN :mapPRMQuoteId_ListCdIds.keySet()]){
        if(mapPRMQuoteId_ListCdIds.get(oneCdl.LinkedEntityId) != null && 
           mapPRMQuoteId_ListCdIds.get(oneCdl.LinkedEntityId).contains(oneCdl.ContentDocumentId)){
            cdlToDelete.add(oneCdl);
        }
      }

      return cdlToDelete;
    }

    public List<ContentDocumentLink> deleteLinkQuote(List<ContentDocumentLink> cdlToDelete){
      Map<Id, List<Id>> mapQuoteId_ListCdIds = new Map<Id, List<Id>>();
      List<Id> cdIds = new List<Id>();
      for(SMC_PRM_Quote__c onePRMQuote : [SELECT Id, Quote__c FROM SMC_PRM_Quote__c WHERE Id IN :this.mapPRMQuoteId_ListCdId.keySet()]){
        mapQuoteId_ListCdIds.put(onePRMQuote.Quote__c, this.mapPRMQuoteId_ListCdId.get(onePRMQuote.Id));
        cdIds.addAll(this.mapPRMQuoteId_ListCdId.get(onePRMQuote.Id));
      }

      for(ContentDocumentLink oneCdl : [SELECT Id, 
                                               LinkedEntityId, 
                                               ContentDocumentId 
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId IN :cdIds AND 
                                              LinkedEntityId IN :mapQuoteId_ListCdIds.keySet()]){
        if(mapQuoteId_ListCdIds.get(oneCdl.LinkedEntityId) != null && 
           mapQuoteId_ListCdIds.get(oneCdl.LinkedEntityId).contains(oneCdl.ContentDocumentId)){
            cdlToDelete.add(oneCdl);
        }
      }

      return cdlToDelete;
    }

    // public void firstExecution(){
    //   Map<Id, List<Id>> mapPRMQuoteId_ListCdIds = new Map<Id, List<Id>>();
    //   List<Id> cdIds = new List<Id>();
    //   for(Quote oneQuote : [SELECT Id, SMC_PRM_Quote__c FROM Quote WHERE Id IN :this.mapQuoteId_ListCdId.keySet()]){
    //     mapPRMQuoteId_ListCdIds.put(oneQuote.SMC_PRM_Quote__c, this.mapQuoteId_ListCdId.get(oneQuote.Id));
    //     cdIds.addAll(this.mapQuoteId_ListCdId.get(oneQuote.Id));
    //   }

    //   List<ContentDocumentLink> cdlToDelete = new List<ContentDocumentLink>();
    //   this.cdlToDeleteOverMaxSize = new List<ContentDocumentLink>();
    //   for(ContentDocumentLink oneCdl : [SELECT Id, 
    //                                            LinkedEntityId, 
    //                                            ContentDocumentId 
    //                                     FROM ContentDocumentLink 
    //                                     WHERE ContentDocumentId IN :cdIds AND 
    //                                           LinkedEntityId IN :mapPRMQuoteId_ListCdIds.keySet()]){
    //     if(mapPRMQuoteId_ListCdIds.get(oneCdl.LinkedEntityId) != null && 
    //        mapPRMQuoteId_ListCdIds.get(oneCdl.LinkedEntityId).contains(oneCdl.ContentDocumentId)){
    //         if(cdlToDelete.size() < 10000)
    //           cdlToDelete.add(oneCdl);
    //         else
    //           this.cdlToDeleteOverMaxSize.add(oneCdl);
    //     }
    //   }

    //   if(cdlToDelete.size() > 0){
    //     delete cdlToDelete;
    //   }
    // }

    // public void deleteListOverMaxSize(){
    //   List<ContentDocumentLink> cdlToDelete = new List<ContentDocumentLink>();
    //   if(this.cdlToDeleteOverMaxSize.size() <= 10000){
    //     delete this.cdlToDeleteOverMaxSize;
    //     this.cdlToDeleteOverMaxSize = new List<ContentDocumentLink>();
    //   }
    //   else{
    //     List<ContentDocumentLink> cdlToDeleteOverMaxSizeTmp = this.cdlToDeleteOverMaxSize;
    //     this.cdlToDeleteOverMaxSize = new List<ContentDocumentLink>();
    //     for(ContentDocumentLink oneCdl : cdlToDeleteOverMaxSizeTmp){
    //       if(cdlToDelete.size() < 10000){
    //         cdlToDelete.add(oneCdl);
    //       }
    //       else{
    //         this.cdlToDeleteOverMaxSize.add(oneCdl);
    //       }
    //     }
    //   }

    //   if(cdlToDelete.size() > 0){
    //     delete cdlToDelete;
    //   }
    // }

    // public void finish(){
    //   if(this.cdlToDeleteOverMaxSize == null || this.cdlToDeleteOverMaxSize.size() > 0){
    //     System.enqueueJob(new DeletePRMQuoteLink(this.cdlToDeleteOverMaxSize));
    //   }
    // }
  }
}