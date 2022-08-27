/**
 * @File Name          : SMC_AC_Display_ContractSubscription.cls
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 14:29:49
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    25/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_AC_Display_ContractSubscription {
  public class ContractSubscriptionInformations {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String linkContractSubscription;
    @AuraEnabled
    public String contractNumber;
    @AuraEnabled
    public String linkContract;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String linkProduct;

    ContractSubscriptionInformations() {
    }
  }

  /**
   * @description : get all SMC_Contract_Subscription__c to display informations in LC
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return List<ContractSubscriptionInformations>
   **/
  @AuraEnabled
  public static List<ContractSubscriptionInformations> initMethod() {
    List<ContractSubscriptionInformations> returnValue = new List<ContractSubscriptionInformations>();
    for (SMC_Contract_Subscription__c oneSub : [
      SELECT
        Id,
        Name,
        Contract__c,
        Contract__r.ContractNumber,
        Product__c,
        Product__r.Name
      FROM SMC_Contract_Subscription__c
    ]) {
      ContractSubscriptionInformations newSubInfo = new ContractSubscriptionInformations();
      newSubInfo.id = oneSub.Id;
      newSubInfo.name = oneSub.Name;
      newSubInfo.linkContractSubscription =
        '/myspace/s/smc-contract-subscription/' + oneSub.Id;
      newSubInfo.contractNumber = oneSub.Contract__r.ContractNumber;
      newSubInfo.linkContract = '/myspace/s/contract/' + oneSub.Contract__c;
      newSubInfo.productName = oneSub.Product__r.Name;
      newSubInfo.linkProduct = '/myspace/s/product/' + oneSub.Product__c;
      returnValue.add(newSubInfo);
    }
    return returnValue;
  }
}