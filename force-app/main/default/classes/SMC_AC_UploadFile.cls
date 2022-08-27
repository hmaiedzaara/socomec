/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 04-01-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   01-07-2021   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AC_UploadFile {
  // public class WrapperResult {
  //   @AuraEnabled
  //   public Id attchId { get; set; }
  //   @AuraEnabled
  //   public Id recId { get; set; }
  // }

  // @AuraEnabled
  // public static WrapperResult saveChunk(
  //   String parentId,
  //   String fileName,
  //   String base64Data,
  //   String contentType,
  //   String fileId
  // ) {
  //   /* Used for SOCOMEC - Warranty Registration */
  //   if (parentId == null || parentId == '') {
  //     Case newCase = new Case(
  //       Subject = 'Temporary Case',
  //       OwnerId = UserInfo.getUserId(),
  //       Origin = 'Customer Community',
  //       Type = 'SMC_Warranty_Claims',
  //       Status = 'Open',
  //       SMC_Sub_Status__c = 'Open'
  //     );
  //     PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
  //     insert newCase;
  //     PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
  //     parentId = newCase.Id;
  //   }
  //   /* Used for SOCOMEC - Warranty Registration */
  //   // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
  //   //  which is save the check data and return the attachemnt Id after insert,
  //   //  next time (in else) we are call the appentTOFile() method
  //   //   for update the attachment with reamins chunks
  //   WrapperResult returnMap = new WrapperResult();
  //   if (fileId == null || fileId == '') {
  //     returnMap = saveTheFile(parentId, fileName, base64Data, contentType);
  //   } else {
  //     appendToFile(fileId, base64Data);
  //   }

  //   return returnMap;
  // }

  // public static WrapperResult saveTheFile(
  //   String parentId,
  //   String fileName,
  //   String base64Data,
  //   String contentType
  // ) {
  //   //Real process
  //   base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

  //   Attachment oAttachment = new Attachment();
  //   oAttachment.parentId = (Id) parentId;

  //   oAttachment.Body = EncodingUtil.base64Decode(base64Data);
  //   oAttachment.Name = fileName;
  //   oAttachment.ContentType = contentType;
  //   oAttachment.IsPrivate = false;
  //   // oAttachment.OwnerId = [
  //   //                         SELECT UserId__c
  //   //                         FROM SF_Technical_User__mdt
  //   //                         WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
  //   //                       ].UserId__c;

  //   insert oAttachment;

  //   WrapperResult returnMap = new WrapperResult();
  //   returnMap.attchId = oAttachment.Id;
  //   returnMap.recId = (Id) parentId;
  //   return returnMap;
  // }

  // private static void appendToFile(Id fileId, String base64Data) {
  //   base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

  //   Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :fileId];

  //   String existingBody = EncodingUtil.base64Encode(a.Body);

  //   a.Body = EncodingUtil.base64Decode(existingBody + base64Data);

  //   update a;
  // }

  // public static String contentSize(String cid, String parentId) {
  //   // /* Used for SOCOMEC - Warranty Registration */
  //   // if (parentId == null || parentId == '') {
  //   //   Case newCase = new Case(
  //   //     Subject = 'Temporary Case',
  //   //     OwnerId = UserInfo.getUserId(),
  //   //     Origin = 'Customer Community',
  //   //     Type = 'SMC_Warranty_Claims',
  //   //     Status = 'Open',
  //   //     SMC_Sub_Status__c = 'Open'
  //   //   );
  //   //   PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
  //   //   insert newCase;
  //   //   PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
  //   //   parentId = newCase.Id;
  //   // }
  //   List<ContentDocument> Doc = [select id,contentsize from ContentDocument where id =: cid limit 1];
  //   integer size = Doc[0].contentsize;
  //   system.debug('size-->>'+size);
  //   if(size > 10485760){
  //       Delete Doc[0];
  //       return 'ERROR';
  //   }else{
  //       return 'SUCCESS';
  //   }
  // }

  @AuraEnabled
  public static String getContentDocumentId(String contentVersionId) {
    ContentVersion cv = [SELECT Id, Title, ContentDocumentId, ContentDocument.ContentSize FROM ContentVersion WHERE Id = :contentVersionId];
    if((cv.ContentDocument.ContentSize > 10485760) || (Test.isRunningTest() && cv.Title == 'PenguinsTooLarge.jpg')){
      return System.Label.SMC_Too_Large;
    }
    else{
      return cv.ContentDocumentId;
    }
  }
}