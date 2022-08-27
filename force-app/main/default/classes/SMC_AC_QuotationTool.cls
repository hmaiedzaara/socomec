/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_QuotationTool
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
                   component SMC_LC_Quotation_Tool
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-MAR-2018  Vincent RECASENS        1.0         Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_QuotationTool {
  /**
   * @description : check user permission and validity informations of account, contact and quote
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recId
   * @return SMC_DTO_SimuExpress
   **/
  @AuraEnabled
  public static SMC_DTO_SimuExpress checkInformationsValidity(String recId) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_QuotationTool : checkInformationsValidity - START'
    );

    //Get PermissionSet
    List<PermissionSetAssignment> pasList = [
      SELECT
        Assignee.Id,
        Assignee.Name,
        PermissionSet.Id,
        PermissionSet.Label,
        PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE Assignee.Id = :UserInfo.getUserId()
    ];

    Boolean isAuthorizeToManageQuote = false;
    for (PermissionSetAssignment onePas : pasList) {
      if (
        onePas.PermissionSet.Name == STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
      ) {
        isAuthorizeToManageQuote = true;
        break;
      }
    }

    if (isAuthorizeToManageQuote) {
      Quote quote = [
        SELECT Id, Name, SMC_Account__c, ContactId, OwnerId, RecordTypeId
        FROM Quote
        WHERE Id = :recId
      ];

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteQuickQuotationId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUICK_QUOTE
        )
        .getRecordTypeId();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      Account account = [
        SELECT Name, BillingCountryCode, SMC_Category__c, SMC_PCO_Price_List__c
        FROM Account
        WHERE Id = :quote.SMC_Account__c
      ];

      SMC_DTO_QuotationTool_MissingFields dtoMissingFIelds = new SMC_DTO_QuotationTool_MissingFields();

      //Check if the Quote is for a project or other
      if (
        quote.RecordTypeId == quoteProjectId ||
        quote.RecordTypeId == quoteQuickQuotationId
      ) {
        Contact contact;
        if (quote.ContactId != null) {
          contact = [
            SELECT Id, Name, Salutation, Email, Phone, MobilePhone
            FROM Contact
            WHERE Id = :quote.ContactId
          ];
        }
        dtoMissingFields = SMC_UTIL_Quotation.checkAccount(
          dtoMissingFields,
          account
        );
        dtoMissingFields = SMC_UTIL_Quotation.checkContact(
          dtoMissingFields,
          contact
        );
        dtoMissingFields = SMC_UTIL_Quotation.checkQuote(
          dtoMissingFields,
          quote
        );
      } else {
        dtoMissingFields = SMC_UTIL_Quotation.checkAccount(
          dtoMissingFields,
          account
        );
        dtoMissingFields = SMC_UTIL_Quotation.checkQuote(
          dtoMissingFields,
          quote
        );
      }

      //If a field isn't fill, the is no redirection
      SMC_DTO_SimuExpress dtoResult;
      if (dtoMissingFields.fieldMiss || dtoMissingFIelds.nullExist) {
        dtoResult = new SMC_DTO_SimuExpress(dtoMissingFields);
      } else {
        List<String> resultList = new List<String>();
        String host;
        host = URL.getSalesforceBaseUrl().getHost();
        Quotation_Tool__mdt[] simuExpress = [
          SELECT Org__c, Organization_Community__c, Quote_Related_Page__c
          FROM Quotation_Tool__mdt
        ];
        for (Quotation_Tool__mdt mdt : simuExpress) {
          //If host == mdt.Org__c -> PRODUCTION
          if (host == mdt.Org__c || host == mdt.Organization_Community__c) {
            resultList.add(mdt.Quote_Related_Page__c + quote.Id);
            break;
          } else if (
            host.contains(mdt.Org__c) &&
            (mdt.Org__c.length() < 5 ||
            mdt.Org__c == STA_UtilsStatic.PREPROD)
          ) {
            //If host contains 'DEV', 'QA', or 'INT' -> mdt.Org__c length is less than 5 chars
            resultList.add(mdt.Quote_Related_Page__c + quote.Id);
            break;
          }
        }
        dtoResult = new SMC_DTO_SimuExpress(resultList);
      }

      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_QuotationTool : checkInformationsValidity - END'
      );
      System.debug(LoggingLevel.INFO, 'dtoResult : ' + dtoResult);
      return dtoResult;
    } else {
      //User hasn't permission
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_QuotationTool : checkInformationsValidity - END without permission'
      );
      return new SMC_DTO_SimuExpress();
    }
  }
}