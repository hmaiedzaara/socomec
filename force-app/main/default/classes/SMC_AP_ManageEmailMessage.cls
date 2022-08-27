/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageEmailMessage
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage EmailMessage         
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 30-JUL-2018  (VR)    1.0         Initial version 
-- 20-FEB-2019  (VR)    2.0         Rework
---------------------------------------------------------------------
*/
public with sharing class SMC_AP_ManageEmailMessage {
  /**
   * @description : inform of a new email on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @return Boolean
   **/
  public static Boolean updateCaseNewEmailMessage(List<EmailMessage> newList) {
    Map<Id, Boolean> parentId = new Map<Id, Boolean>();
    for (EmailMessage oneEmailMessage : newList) {
      if (
        oneEmailMessage.ParentId != null &&
        oneEmailMessage.ParentId.getSobjectType() == Schema.Case.SObjectType
      ) {
        parentId.put(oneEmailMessage.ParentId, oneEmailMessage.HasAttachment);
      }
    }
    if (parentId.size() > 0) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_AP_ManageEmailMessage updateCaseNewEmailMessage - Launch SMC_AP_ManageCase.updateCaseNewObject <<< ##'
      );
      return SMC_AP_ManageCase.updateCaseNewObject(
        parentId,
        STA_UtilsStatic.EMAIL
      );
    }

    return false;
  }

  /**
   * @description : check email attachment
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList 
   **/
  public static void emailAttachmentNotVisibleByCommunityUsers(
    List<EmailMessage> newList
  ) {
    Set<Id> emailMessageIds = new Set<Id>();
    for (EmailMessage oneEmailMessage : newList) {
      if (
        oneEmailMessage.RelatedToId != null &&
        oneEmailMessage.RelatedToId.getSobjectType() ==
        Schema.Case.SObjectType &&
        oneEmailMessage.HasAttachment
      ) {
        emailMessageIds.add(oneEmailMessage.Id);
      }
    }

    if (emailMessageIds.size() > 0) {
      hideEmailAttachmentFromCase(emailMessageIds);
    }
  }

  /**
   * @description : calling to hidde email attachment to partner
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param emailMessageIds 
   **/
  @Future
  public static void hideEmailAttachmentFromCase(Set<Id> emailMessageIds) {
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink oneContentDocumentLink : [
      SELECT Id, Visibility, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :emailMessageIds
    ]) {
      contentDocumentIds.add(oneContentDocumentLink.ContentDocumentId);
    }

    if (contentDocumentIds.size() > 0) {
      //Make private on ContentVersion
      List<ContentVersion> cvs = new List<ContentVersion>();
      for (ContentVersion oneCV : [
        SELECT Id, SharingPrivacy
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocumentIds
      ]) {
        oneCV.SMC_File_Privacy_on_Records__c = STA_UtilsStatic.TECH_PRIVATE_ON_RECORD_APINAME;
        oneCV.SharingPrivacy = STA_UtilsStatic.PRIVATE_ON_RECORD;
        cvs.add(oneCV);
      }
      if (cvs.size() > 0) {
        update cvs;
      }
    }
  }
}