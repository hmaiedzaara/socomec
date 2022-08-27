/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_View_Files_Case
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is Apex controller of LWC View Files Case
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 20-SEP-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AC_View_Files_Case {
  public SMC_AC_View_Files_Case() {
  }

  /**
   * @description : get file link to project ref SMC_Project_Reference__c
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @return Map<String, ContentDocument>
   **/
  @AuraEnabled(cacheable=true)
  public static Map<String, ContentDocument> getCaseFiles(String recordId) {
    //Get the case
    Case theCase = [
      SELECT Id, CaseNumber, SMC_Project_Reference__c
      FROM Case
      WHERE Id = :recordId
    ];
    //Get all case ids with the same SMC_Project_Reference__c
    Map<Id, Case> mapCases;
    if (
      theCase.SMC_Project_Reference__c != null &&
      theCase.SMC_Project_Reference__c != ''
    ) {
      mapCases = new Map<Id, Case>(
        [
          SELECT Id, CaseNumber
          FROM Case
          WHERE
            SMC_Project_Reference__c = :theCase.SMC_Project_Reference__c
            AND SMC_Project_Reference__c != null
        ]
      );
    } else {
      mapCases = new Map<Id, Case>{ theCase.Id => theCase };
    }

    //Get all documents
    Map<Id, ContentDocumentLink> mapContentDocumentLinks = new Map<Id, ContentDocumentLink>(
      [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :mapCases.keySet()
      ]
    );
    Map<Id, Id> mapContentDocumentIdToCaseId = new Map<Id, Id>();
    if (mapCases.size() > 0) {
      for (Id oneCdlIds : mapContentDocumentLinks.keySet()) {
        mapContentDocumentIdToCaseId.put(
          mapContentDocumentLinks.get(oneCdlIds).ContentDocumentId,
          mapCases.get(mapContentDocumentLinks.get(oneCdlIds).LinkedEntityId).Id
        );
      }
    }

    //Mapping case number to document
    Map<String, ContentDocument> mapCaseNumberSlashContentDocumentIdToContentDocument = new Map<String, ContentDocument>();
    if (mapContentDocumentIdToCaseId.size() > 0) {
      for (ContentDocument oneDC : [
        SELECT Id, Title, FileType, FileExtension, Description, ContentSize
        FROM ContentDocument
        WHERE
          Id IN :mapContentDocumentIdToCaseId.keySet()
          AND (OwnerId = :UserInfo.getUserId()
          OR (SharingPrivacy != :STA_UtilsStatic.PRIVATE_ON_RECORD
          AND OwnerId != :UserInfo.getUserId()))
      ]) {
        mapCaseNumberSlashContentDocumentIdToContentDocument.put(
          mapCases.get(mapContentDocumentIdToCaseId.get(oneDC.Id)).CaseNumber +
          '/' +
          oneDC.Id,
          oneDC
        );
      }
    }

    //return the list of document
    if (mapCaseNumberSlashContentDocumentIdToContentDocument.size() > 0) {
      return mapCaseNumberSlashContentDocumentIdToContentDocument;
    } else {
      return null;
    }
  }
}