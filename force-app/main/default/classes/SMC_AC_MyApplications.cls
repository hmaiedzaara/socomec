/**
 * @File Name          : SMC_AC_MyApplications.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-21-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    02/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public with sharing class SMC_AC_MyApplications {
  public class Wrapper {
    @TestVisible
    String id { get; set; }
    @TestVisible
    String picture { get; set; }
    @TestVisible
    String name { get; set; }
    @TestVisible
    String url { get; set; }
    @TestVisible
    Boolean urlExist { get; set; }
    @TestVisible
    String test { get; set; }
    @TestVisible
    String toTheRecord { get; set; }

    public Wrapper(
      String id,
      String picture,
      String name,
      String url,
      String communityLabel
    ) {
      this.id = id;
      this.picture = picture;
      this.name = name;
      this.url = url;
      this.urlExist = ((url != null && url != '') ? true : false);
      if (communityLabel == 'MySocomec') {
        this.toTheRecord =
          '/mysocomec/s/smc-contract-subscription/' +
          id +
          '/detail';
      } else if (
        communityLabel == 'CustomerPortal' ||
        communityLabel == 'MySpace'
      ) {
        this.toTheRecord =
          '/customerportal/s/smc-contract-subscription/' +
          id +
          '/detail';
      }
    }
  }

  @AuraEnabled
  public static String getRecords(
    String targetObject,
    String communityLabel,
    Integer offset
  ) {
    // Set offset
    if (offset == null) {
      offset = 0;
    }

    List<Wrapper> result = new List<Wrapper>();
    // Apllications - SMC_Contract_Subscription__c
    if (targetObject == 'Applications') {
      for (SMC_Contract_Subscription__c oneSub : [
        SELECT
          Id,
          Product__r.SMC_App_Picture_Path__c,
          Product__r.Name,
          Product__r.DisplayUrl
        FROM SMC_Contract_Subscription__c
        WHERE TECH_Is_Application__c = true
        LIMIT 200
      ]) {
        result.add(
          new Wrapper(
            oneSub.Id,
            oneSub.Product__r.SMC_App_Picture_Path__c,
            oneSub.Product__r.Name,
            oneSub.Product__r.DisplayUrl,
            communityLabel
          )
        );
      }
    }

    return JSON.serialize(result);
  }
}