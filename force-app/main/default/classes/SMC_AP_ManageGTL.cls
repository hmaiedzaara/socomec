/* 
---------------------------------------------------------------------------
-- - Name : SMC_AP_ManageGTL
-- - Author : Emmanuel BERNIER
-- - Description : This class manage GTL
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 19-FEB-2019  EBR  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageGTL {
  /**
   * @description : GTL duplicate rule
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param listGtl
   **/
  public static void checkForDuplicates(list<SMC_GTL__c> listGtl) {
    String searchClause = '';
    map<String, SMC_GTL__c> mapGtL = new Map<String, SMC_GTL__c>();
    for (SMC_GTL__c gtlLine : listGtl) {
      String key = duplicateKey(gtlLine);
      searchClause = searchClause + key;
      mapGtl.put(key, gtlLine);
    }
    String queryString =
      String.escapeSingleQuotes(
        'SELECT id,SMC_ValidityDate__c,SMC_Old_Spare_Part__c, name, SMC_Start_Date__c, SMC_Group__c,SMC_Option__c,SMC_Spare_Part__c,SMC_Quantity__c,SMC_Subset_GTL__c, SMC_Comment__c, SMC_Status_GTL__c FROM SMC_GTL__c WHERE '
      ) + searchClause.removeEnd('OR ');
    for (SMC_GTL__c gtlSuspect : Database.query(queryString)) {
      SMC_GTL__c potential = mapGtl.get(duplicateKey(gtlSuspect));
      if (potential != null) {
        System.debug(
          LoggingLevel.INFO,
          'do not duplicate on same line' + (potential.id != gtlSuspect.id)
        );
        // System.debug(LoggingLevel.INFO, 'both lines have not an infinite validity date'+(gtlSuspect.SMC_ValidityDate__c == null && potential.SMC_ValidityDate__c == null));
        // System.debug(LoggingLevel.INFO, 'start date not in potential validity range'+ (!( gtlSuspect.SMC_ValidityDate__c   <= potential.SMC_Start_Date__c
        // || potential.SMC_ValidityDate__c <= gtlSuspect.SMC_Start_Date__c ) ));

        //Comment field - prevent NullPointer
        String potentialComment = '';
        if (potential.SMC_Comment__c != null) {
          potentialComment = potential.SMC_Comment__c.normalizeSpace();
        }
        String gtlSuspectComment = '';
        if (gtlSuspect.SMC_Comment__c != null) {
          gtlSuspectComment = gtlSuspect.SMC_Comment__c.normalizeSpace();
        }

        System.debug(
          LoggingLevel.INFO,
          'potential.id != gtlSuspect.id : ' + (potential.id != gtlSuspect.id)
        );
        System.debug(LoggingLevel.INFO, 'potential.id : ' + (potential.id));
        System.debug(LoggingLevel.INFO, 'gtlSuspect.id : ' + (gtlSuspect.id));
        System.debug(
          LoggingLevel.INFO,
          'potentialComment == gtlSuspectComment : ' +
          (potentialComment == gtlSuspectComment)
        );
        System.debug(
          LoggingLevel.INFO,
          'potential.SMC_Start_Date__c == gtlSuspect.SMC_Start_Date__c : ' +
          (potential.SMC_Start_Date__c == gtlSuspect.SMC_Start_Date__c)
        );
        //do not duplicate on same line     check comment
        if (
          potential.id != gtlSuspect.id &&
          potentialComment == gtlSuspectComment &&
          potential.SMC_Start_Date__c == gtlSuspect.SMC_Start_Date__c &&
          potential.SMC_ValidityDate__c == gtlSuspect.SMC_ValidityDate__c
        ) {
          potential.addError(
            String.escapeSingleQuotes(
              'A duplicate GTL line exist here! <a href="/' +
              gtlSuspect.id +
              '">' +
              gtlSuspect.name +
              ' </a>'
            ),
            true
          );
        }
      }
    }
  }

  /**
   * @description : escape single quote for query
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param gtl
   * @return string
   **/
  public static string duplicateKey(SMC_GTL__c gtl) {
    return '(SMC_Spare_Part__c=\'' +
      String.escapeSingleQuotes(gtl.SMC_Spare_Part__c) +
      '\'' +
      ' AND SMC_Quantity__c=' +
      gtl.SMC_Quantity__c +
      (gtl.SMC_Subset_GTL__c != null
        ? ' AND SMC_Subset_GTL__c=\'' +
          String.escapeSingleQuotes(gtl.SMC_Subset_GTL__c) +
          '\''
        : '') +
      (gtl.SMC_Group__c != null
        ? ' AND SMC_Group__c=\'' +
          String.escapeSingleQuotes(gtl.SMC_Group__c) +
          '\''
        : '') +
      (gtl.SMC_Option__c != null
        ? ' AND SMC_Option__c=\'' +
          String.escapeSingleQuotes(gtl.SMC_Option__c) +
          '\''
        : '') +
      (gtl.SMC_Old_Spare_Part__c != null
        ? ' AND SMC_Old_Spare_Part__c=\'' +
          String.escapeSingleQuotes(gtl.SMC_Old_Spare_Part__c) +
          '\''
        : '') +
      (gtl.SMC_Status_GTL__c != null
        ? ' AND SMC_Status_GTL__c=\'' +
          String.escapeSingleQuotes(gtl.SMC_Status_GTL__c) +
          '\''
        : '') +
      ') OR ';
  }

  /**
   * @description : clone GTL line when it is invalidated
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void invalidateGtlLine(
    List<SMC_GTL__c> newList,
    Map<Id, SMC_GTL__c> oldMap
  ) {
    List<Id> gtlIdForAssociation = new List<Id>();
    Map<String, SMC_GTL__c> oldNameToNewGtlLineCloned = new Map<String, SMC_GTL__c>();
    for (SMC_GTL__c oneGtlLine : newList) {
      SMC_GTL__c olgGtlLine = oldMap.get(oneGtlLine.Id);
      if (
        oneGtlLine.SMC_Status_GTL__c == STA_UtilsStatic.GTL_OBSOLETE &&
        olgGtlLine.SMC_Status_GTL__c != STA_UtilsStatic.GTL_OBSOLETE &&
        oneGtlLine.SMC_New_Spare_Part__c != null &&
        olgGtlLine.SMC_New_Spare_Part__c == null
      ) {
        //Get Id for association
        gtlIdForAssociation.add(oneGtlLine.Id);
        //Set new GtlLine
        SMC_GTL__c tmpGtlLine = oneGtlLine.clone(false, true, false, false);
        tmpGtlLine.SMC_Spare_Part__c = oneGtlLine.SMC_New_Spare_Part__c;
        tmpGtlLine.SMC_Old_Spare_Part__c = oneGtlLine.SMC_Spare_Part_Code__c;
        tmpGtlLine.SMC_New_Spare_Part__c = null;
        tmpGtlLine.SMC_Start_Date__c = oneGtlLine.SMC_ValidityDate__c;
        tmpGtlLine.SMC_ValidityDate__c = null;
        tmpGtlLine.SMC_Status_GTL__c = STA_UtilsStatic.GTL_NOT_YET_ACTIVE;
        oldNameToNewGtlLineCloned.put(oneGtlLine.Name, tmpGtlLine);
      }
    }

    if (oldNameToNewGtlLineCloned.size() > 0) {
      insert oldNameToNewGtlLineCloned.values();
      System.debug(
        LoggingLevel.INFO,
        'New GtlLine insertion OK : ' + oldNameToNewGtlLineCloned
      );

      //Get GtlAssociations
      String objectName = 'SMC_GtlServiceProductAssociation__c';
      Map<String, Object> objectMap = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .fields.getMap();
      Schema.SObjectType objectMapBis = Schema.getGlobalDescribe()
        .get(objectName);
      String query = 'SELECT ';
      for (
        SObjectField sof : objectMapBis.getDescribe().fields.getMap().values()
      ) {
        query += String.escapeSingleQuotes(String.valueOf(sof)) + ', ';
      }
      query =
        query.substring(0, query.length() - 2) +
        ' FROM ' +
        String.escapeSingleQuotes(objectName) +
        ' WHERE SMC_Logistic_Technical_Guide__c IN (';
      for (Id oneId : gtlIdForAssociation) {
        query += '\'' + String.escapeSingleQuotes(oneId) + '\'';
      }
      query += ')';
      List<SMC_GtlServiceProductAssociation__c> gtlAssociations = new List<SMC_GtlServiceProductAssociation__c>();
      gtlAssociations = Database.query(query);

      //Duplicate them
      List<SMC_GtlServiceProductAssociation__c> cloneGtlAssociationsForNewGtlLine = new List<SMC_GtlServiceProductAssociation__c>();
      for (
        SMC_GtlServiceProductAssociation__c oneGtlAssociation : gtlAssociations
      ) {
        SMC_GtlServiceProductAssociation__c newGtlAssociation = oneGtlAssociation.clone(
          false,
          true,
          false,
          false
        );
        newGtlAssociation.SMC_Logistic_Technical_Guide__c = oldNameToNewGtlLineCloned.get(
            oldMap.get(oneGtlAssociation.SMC_Logistic_Technical_Guide__c).Name
          )
          .Id;
        cloneGtlAssociationsForNewGtlLine.add(newGtlAssociation);
      }

      if (cloneGtlAssociationsForNewGtlLine.size() > 0) {
        insert cloneGtlAssociationsForNewGtlLine;
        System.debug(
          LoggingLevel.INFO,
          'New GtlLineAssociations insertion OK : ' +
          cloneGtlAssociationsForNewGtlLine
        );
      }
    }
  }

  public static void manageGTLComment(
    Map<Id, SMC_GTL__c> newMap,
    Map<Id, SMC_GTL__c> oldMap
  ) {
    Map<Id, ContentNote> mapGtlToContentNoteNote = new Map<Id, ContentNote>();
    //Check if SMC_Comment__c is changed
    for (Id oneId : newMap.keySet()) {
      SMC_GTL__c newGtl = newMap.get(oneId);
      SMC_GTL__c oldGtl = oldMap.get(oneId);
      if (newGtl.SMC_Comment__c != oldGtl.SMC_Comment__c) {
        mapGtlToContentNoteNote.put(
          oneId,
          new ContentNote(
            Title = System.Label.SMC_Previous_Comment,
            Content = Blob.valueOf(oldGtl.SMC_Comment__c == null ? '' : oldGtl.SMC_Comment__c)
          )
        );
      }
    }

    if (mapGtlToContentNoteNote.size() > 0) {
      //Insert new note - contin old SMC_Comment__c
      insert mapGtlToContentNoteNote.values();

      //Create link beteween new note and related GTL
      List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
      for (Id oneId : mapGtlToContentNoteNote.keySet()) {
        cdlToInsert.add(
          new ContentDocumentLink(
            ContentdocumentId = mapGtlToContentNoteNote.get(oneId).Id,
            LinkedEntityId = oneId
          )
        );
      }
      insert cdlToInsert;
    }
  }
}