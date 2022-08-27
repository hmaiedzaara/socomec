/**
 * @File Name          : AC_DisplayImage.cls
 * @Description        :
 * @Author             : ?????? | ???/??/2017
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 10:16:27
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2017         ??????                 Initial Version
 **/
public without sharing class SMC_AC_DisplayImage {
  /**
   * @description
   * @author ?????? | ???/??/2017
   * @param Name
   * @param prefixInterfaceName
   * @param isPrefixByUserAlias
   * @param isPrefixByTodayDate
   * @return Id
   **/
  @AuraEnabled
  public static Id getIdDocumentFromImageName(
    String Name,
    String prefixInterfaceName,
    boolean isPrefixByUserAlias,
    boolean isPrefixByTodayDate
  ) {
    System.debug(
      LoggingLevel.Info,
      '## >>> AC_DisplayImage getIdDocumentFromImageName(String Name, String prefixInterfaceName, boolean isPrefixByUserAlias, boolean isPrefixByTodayDate):START <<< ##'
    );
    String nameForYesterdayImage = STA_UtilsStatic.EMPTY_STRING;
    if (isPrefixByTodayDate) {
      nameForYesterdayImage =
        Datetime.now().addDays(-1).format('yyyyMMdd') +
        STA_UtilsStatic.UNDERSCORE +
        Name;
      Name =
        Datetime.now().format('yyyyMMdd') +
        STA_UtilsStatic.UNDERSCORE +
        Name;
    }

    if (isPrefixByUserAlias) {
      String Alias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserID()]
      .Alias;
      Name = Alias.toUpperCase() + STA_UtilsStatic.UNDERSCORE + Name;
      if (isPrefixByTodayDate) {
        nameForYesterdayImage =
          Alias.toUpperCase() +
          STA_UtilsStatic.UNDERSCORE +
          nameForYesterdayImage;
      }
    }

    if (!String.isBlank(prefixInterfaceName)) {
      Name = prefixInterfaceName + STA_UtilsStatic.UNDERSCORE + Name;
      if (isPrefixByTodayDate) {
        nameForYesterdayImage =
          prefixInterfaceName +
          STA_UtilsStatic.UNDERSCORE +
          nameForYesterdayImage;
      }
    }
    String[] names = new List<String>{ Name, nameForYesterdayImage };
    System.debug(
      LoggingLevel.Info,
      '## >>> AC_DisplayImage getIdDocumentFromImageName(String Name, String prefixInterfaceName, boolean isPrefixByUserAlias, boolean isPrefixByTodayDate):END <<< ##'
    );

    return [
      SELECT Id
      FROM Document
      WHERE Name IN :names AND FolderId = :UserInfo.getUserID()
      ORDER BY Name DESC
      LIMIT 1
    ]
    .Id;
  }
}