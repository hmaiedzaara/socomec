/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AP_InboundEmail_EmailToLead
-- - Author : Vincent RECASENS
-- - Description : This class is used for EmailService "Email-to-Lead Service"
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 09-JAN-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AP_InboundEmail_EmailToLead implements Messaging.InboundEmailHandler {
  /**
   * @description : handle inbound email for Email-To-Lead
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param email
   * @param env
   * @return Messaging.InboundEmailResult
   **/
  public Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope env
  ) {
    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_InboundEmail_EmailToLead - handleInboundEmail : START'
    );
    /**************************** */
    //A SUPPRIMER LORSQUE L'ADRESSE SERA VALIDEE EN PROD!!
    System.debug(LoggingLevel.INFO, 'email.subject : ' + email.subject);
    /**************************** */

    // Create an InboundEmailResult object for returning the result of the Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    try {
      //Get reference Id from subject to link the email to the right Lead
      String regexToFindLeadRef = '\\[RefId:';
      String[] subjectSplited = email.subject.split(regexToFindLeadRef);
      String refStringLead = subjectSplited.get(subjectSplited.size() - 1)
        .substring(
          0,
          subjectSplited.get(subjectSplited.size() - 1).length() - 1
        );
      //Format --> Lead (Lead.Name) [RefId:(Lead.Id)]

      //Check if reference Id is a LeadId
      Id refIdLead = (Id) refStringLead;
      if (refIdLead.getSObjectType() != Schema.Lead.SObjectType) {
        //If the reference Id is not a Lead, the email is LOST!!
        result.success = false;
        return result;
      }

      /***********Convert Email to File*************/
      List<ContentVersion> cVList = new List<ContentVersion>();
      //Convert the email to a File
      ContentVersion contentVersion = new ContentVersion();
      // To keep the historic, we can't use the ContentVersion.VersionNumber
      contentVersion.Title = email.subject.split(regexToFindLeadRef).get(0);
      //Need to have a PthOnClient
      //Format of path : 'subject' without RefId and camelUpperCase without sapce between words
      String pathOnClient = contentVersion.Title.deleteWhitespace();
      contentVersion.PathOnClient =
        STA_UtilsStatic.SLASH +
        pathOnClient +
        '.doc';
      contentVersion.FirstPublishLocationId = refIdLead;
      contentVersion.IsMajorVersion = true;
      contentVersion.VersionData = Blob.valueOf(
        STA_UtilsStatic.EMAIL_SUBJECT +
        contentVersion.Title +
        '\n\n' +
        STA_UtilsStatic.EMAIL_FROM_NAME +
        email.fromName +
        '\n' +
        STA_UtilsStatic.EMAIL_FROM_ADDRESS +
        email.fromAddress +
        '\n' +
        STA_UtilsStatic.EMAIL_TO_ADDRESSES +
        email.toAddresses +
        '\n' +
        STA_UtilsStatic.EMAIL_CC +
        email.ccAddresses +
        '\n\n\n\n' +
        email.plainTextBody
      );
      // contentVersion.SharingPrivacy = STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS;
      cVList.add(contentVersion);

      // contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];

      //Get ContentdocumentLink to apply the right visibility for the new File
      // ContentDocumentLink contentDocumentLink = [SELECT Id, ContentDocumentId, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :contentVersion.ContentDocumentId AND LinkedEntityId = :refIdLead];
      // contentDocumentLink.Visibility = STA_UtilsStatic.INTERNAL_USERS;
      // update contentDocumentLink;

      /***********Convert Attachment to File*************/

      if (email.binaryAttachments != null) {
        for (
          Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments
        ) {
          //Convert the email to a File
          ContentVersion attachmentCV = new ContentVersion();
          // To keep the historic, we can't use the ContentVersion.VersionNumber
          attachmentCV.Title =
            contentVersion.Title +
            STA_UtilsStatic.SPACE +
            STA_UtilsStatic.HYPHEN +
            STA_UtilsStatic.SPACE +
            attachment.fileName;
          //Need to have a PthOnClient
          //Format of path : 'subject' without RefId and camelUpperCase without sapce between words
          attachmentCV.PathOnClient =
            STA_UtilsStatic.SLASH + attachment.fileName;
          attachmentCV.VersionData = attachment.body;
          attachmentCV.FirstPublishLocationId = refIdLead;
          // attachmentCV.SharingPrivacy = STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS;
          attachmentCV.IsMajorVersion = true;
          cVList.add(attachmentCV);
          // attachmentCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :attachmentCV.Id];

          //Get ContentdocumentLink to apply the right visibility for the new File
          // ContentDocumentLink contentDocumentLinkAttachmentCV = [SELECT Id, ContentDocumentId, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :attachmentCV.ContentDocumentId AND LinkedEntityId = :refIdLead];
          // contentDocumentLink.Visibility = STA_UtilsStatic.INTERNAL_USERS;
          // attachmentsCDLList.add(contentDocumentLink);
        }
      }

      if (email.textAttachments != null) {
        for (
          Messaging.InboundEmail.TextAttachment attachment : email.textAttachments
        ) {
          //Convert the email to a File
          ContentVersion attachmentCV = new ContentVersion();
          // To keep the historic, we can't use the ContentVersion.VersionNumber
          attachmentCV.Title =
            contentVersion.Title +
            STA_UtilsStatic.SPACE +
            STA_UtilsStatic.HYPHEN +
            STA_UtilsStatic.SPACE +
            attachment.fileName;
          //Need to have a PthOnClient
          //Format of path : 'subject' without RefId and camelUpperCase without sapce between words
          attachmentCV.PathOnClient =
            STA_UtilsStatic.SLASH + attachment.fileName;
          attachmentCV.VersionData = Blob.valueOf(attachment.body);
          attachmentCV.FirstPublishLocationId = refIdLead;
          // attachmentCV.SharingPrivacy = STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS;
          attachmentCV.IsMajorVersion = true;
          cVList.add(attachmentCV);
          // attachmentCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :attachmentCV.Id];

          //Get ContentdocumentLink to apply the right visibility for the new File
          // ContentDocumentLink contentDocumentLinkAttachmentCV = [SELECT Id, ContentDocumentId, Visibility, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :attachmentCV.ContentDocumentId AND LinkedEntityId = :refIdLead];
          // contentDocumentLink.Visibility = STA_UtilsStatic.INTERNAL_USERS;
          // attachmentsCDLList.add(contentDocumentLink);
        }
      }

      PAD.bypassAll = true;
      insert cvList;
      PAD.bypassAll = false;

      result.success = true;
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR TO SAVING EMAIL --> ' + e);
      result.success = false;
    }

    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_InboundEmail_EmailToLead - handleInboundEmail : END'
    );
    return result;
  }
}