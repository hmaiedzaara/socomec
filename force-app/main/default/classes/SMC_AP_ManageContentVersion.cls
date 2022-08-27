/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageContentVersion
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage Content Version               
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 19-DEC-2018  (VR)    1.0         Initial version 
-- 07-MAR-2019  (VR)    1.0         Manage FileQuotation
---------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageContentVersion {
  /**
  * @description : prevent upload a new file or version on closed case
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param newList   
  **/
  public static void preventUploadFileOnClosedCase(
    List<ContentVersion> newList
  ) {
    List<Id> caseIds = new List<Id>();
    String id;
    for (ContentVersion oneContentVersion : newList) {
      id = oneContentVersion.FirstPublishLocationId;
      if (
        oneContentVersion.FirstPublishLocationId != null &&
        oneContentVersion.FirstPublishLocationId.getSObjectType() ==
        Schema.Case.SObjectType
      ) {
        caseIds.add(oneContentVersion.FirstPublishLocationId);
      }
    }

    Map<Id, Case> mapCase = new Map<Id, Case>();
    if (caseIds.size() > 0) {
      mapCase = new Map<Id, Case>(
        [
          SELECT Id, Status
          FROM Case
          WHERE Id IN :caseIds AND Status = :STA_UtilsStatic.CASE_STATUS_CLOSED
        ]
      );
    }

    if (mapCase.size() > 0) {
      for (ContentVersion oneContentVersion : newList) {
        if (mapCase.get(oneContentVersion.FirstPublishLocationId) != null) {
          oneContentVersion.addError(
            String.escapeSingleQuotes(
              System.Label.SMC_CantUploadFileOnClosedCase
            ),
            true
          );
        }
      }
    }
  }

  /**
  * @description : manage title
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param newList   
  **/
  public static void prepareInsertion(List<ContentVersion> newList) {
    // Map<Id, ContentVersion> mapContentDocumentIdToContentVersion = new Map<Id, ContentVersion>();
    for (ContentVersion oneContentversion : newList) {
      // Populate TECH_SMC_First_Location_Id__c to used FirstLocationId value in formula
      oneContentversion.TECH_SMC_First_Location_Id__c = oneContentversion.FirstPublishLocationId;
      // Attribute visiblity for all users
      oneContentversion.SharingPrivacy = STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS;
      if (oneContentversion.ContentDocumentId == null) {
        if (oneContentversion.FileExtension != null) {
          oneContentversion.Title +=
            STA_UtilsStatic.POINT + oneContentversion.FileExtension;
        } else {
          List<String> tmpTitle = oneContentversion.PathOnClient.split(
            STA_UtilsStatic.SPLIT_POINT
          );
          oneContentversion.Title +=
            STA_UtilsStatic.POINT + tmpTitle.get(tmpTitle.size() - 1);
        }
      }
      // mapContentDocumentIdToContentVersion.put(oneContentversion.ContentDocumentId, oneContentversion);
    }

    // if(mapContentDocumentIdToContentVersion.size() > 0){
    //     SMC_AP_ManageContentDocumentLink.checkEmailSendFromCase(mapContentDocumentIdToContentVersion);
    // }
  }

  /**
  * @description : manage record location visibilty
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param newList 
  * @return Boolean 
  **/
  public static Boolean finishInsertion(List<ContentVersion> newList) {
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentVersion oneContentVersion : newList) {
      contentDocumentIds.add(oneContentVersion.ContentDocumentId);
    }

    return SMC_AP_ManageContentDocumentLink.finishContentVersionInsertion(
      contentDocumentIds
    );
  }

  /**
  * @description : manage version visibility
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param newList 
  * @param oldMap   
  **/
  public static void manageFileVisibility(
    List<ContentVersion> newList,
    Map<Id, ContentVersion> oldMap
  ) {
    //We can't get ConetnDocumentLink with 'IN' clause --> Need to update ContentVersion one by one
    if (newList.size() == 0 || newList.size() > 1) {
      return;
    }

    if (
      newList[0].SMC_File_Privacy_on_Records__c ==
      STA_UtilsStatic.TECH_PRIVATE_ON_RECORD_APINAME
    ) {
      newList[0].SharingPrivacy = STA_UtilsStatic.PRIVATE_ON_RECORD;
    } else if (
      newList[0].SMC_File_Privacy_on_Records__c ==
      STA_UtilsStatic.TECH_VISIBLE_BY_USER_WITH_ACCESS_APINAME
    ) {
      newList[0].SharingPrivacy = STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS;
    }

    //Get ContentDocumentLinks
    String cdlId = newList[0].ContentDocumentId;
    ContentVersion oldContentVersion = oldMap.get(newList[0].Id);
    //Public
    if (
      newList[0].SMC_Is_Visible_By_Partner__c !=
      oldContentVersion.SMC_Is_Visible_By_Partner__c &&
      newList[0].SharingPrivacy == STA_UtilsStatic.VISIBLE_BY_USER_WITH_ACCESS
    ) {
      cdlId = newList[0].ContentDocumentId;
    } else if (newList[0].SharingPrivacy == STA_UtilsStatic.PRIVATE_ON_RECORD) {
      //Not public
      //Add private prefix
      if (
        !newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX) &&
        !newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
      ) {
        newList[0].Title =
          STA_UtilsStatic.FILE_PRIVATE_PREFIX + newList[0].Title;
      } else if (
        !newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX) &&
        newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
      ) {
        //Remove internal prefix and add private prefix
        newList[0].Title =
          STA_UtilsStatic.FILE_PRIVATE_PREFIX + newList[0].Title.substring(11);
      } else if (
        newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX)
      ) {
        //If it's already prefixed private
        SMC_AP_DoNothingClass.doNothing();
      }
      return;
    } else {
      return;
    }

    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility
      FROM ContentDocumentLink
      WHERE ContentDocumentId = :cdlId
    ];
    List<ContentDocumentLink> cdlToUpdate = new List<ContentDocumentLink>();
    //Search ContentDocumentLink linked to the record
    for (ContentDocumentLink oneCDL : contentDocumentLinks) {
      if (oneCDL.LinkedEntityId.getSObjectType() != Schema.User.SObjectType) {
        //Make it public
        // if(newList[0].SMC_Is_Visible_By_Partner__c == null ||newList[0].SMC_Is_Visible_By_Partner__c == STA_UtilsStatic.YES || newList[0].SMC_Is_Visible_By_Partner__c == STA_UtilsStatic.EMPTY_STRING){
        if (newList[0].SMC_Is_Visible_By_Partner__c == STA_UtilsStatic.YES) {
          oneCDL.Visibility = STA_UtilsStatic.ALL_USERS;
          //Remove private prefix
          if (
            newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX)
          ) {
            newList[0].Title = newList[0].Title.substring(10);
          } else if (
            newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
          ) {
            //Remove internal prefix
            newList[0].Title = newList[0].Title.substring(11);
          }
        } else if (
          newList[0].SMC_Is_Visible_By_Partner__c == STA_UtilsStatic.NO
        ) {
          //Make it internal
          //Add internal prefix
          if (
            !newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX) &&
            !newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
          ) {
            newList[0].Title =
              STA_UtilsStatic.FILE_INTERNAL_PREFIX + newList[0].Title;
          } else if (
            newList[0].Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX) &&
            !newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
          ) {
            //Add internal prefix and remove private prefix
            newList[0].Title =
              STA_UtilsStatic.FILE_INTERNAL_PREFIX +
              newList[0].Title.substring(10);
          } else if (
            newList[0].Title.startsWith(STA_UtilsStatic.FILE_INTERNAL_PREFIX)
          ) {
            //If it's already prefixed internal
            SMC_AP_DoNothingClass.doNothing();
          }
          oneCDL.Visibility = STA_UtilsStatic.INTERNAL_USERS;
        } else {
          SMC_AP_DoNothingClass.doNothing();
        }
        cdlToUpdate.add(oneCDL);
      }
    }

    try {
      update cdlToUpdate;
    } catch (DMLException dmlException) {
      System.debug(LoggingLevel.INFO, 'ERROR --> ' + dmlException);
    }
  }
}