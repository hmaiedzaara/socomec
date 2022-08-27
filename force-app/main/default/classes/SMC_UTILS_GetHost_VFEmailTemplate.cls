/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 02-01-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   11-23-2020   Vincent RECASENS (Modis)   Initial Version
 * 2.0   05-19-2022   Denis PHAM (Modis)         Add redirection for Supplier Portal
 **/
public without sharing class SMC_UTILS_GetHost_VFEmailTemplate {
  public String sender { get; set; }
  public String caseId { get; set; }
  public String url {
    get {
      if (this.url == null) {
        // this.url = 'https://';
        if (this.sender == 'MySocomec') {
          String host;
          host = System.URL.getSalesforceBaseUrl().getHost();
          Service_Customer_Community_URL__mdt[] urlComm = [
            SELECT Organization__c, Organization_Community__c, URL__c
            FROM Service_Customer_Community_URL__mdt
          ];
          for (Service_Customer_Community_URL__mdt mdt : urlComm) {
            //If host == mdt.Organization__c -> PRODUCTION
            if (
              host == mdt.Organization__c ||
              host == mdt.Organization_Community__c
            ) {
              this.url = mdt.URL__c;
              break;
            } else if (
              host.contains(mdt.Organization__c) &&
              mdt.Organization__c.length() <= 10
            ) {
              //If host contains 'DEV', 'QA', or 'INT' -> mdt.Organization__c length is lower of 5 char
              this.url = mdt.URL__c;
              break;
            }
          }
          this.url += '/case/' + this.caseId + '/view';
          // this.url = 'https://';
        } else if (this.sender == 'CustomerPortal') {
          String host;
          host = System.URL.getSalesforceBaseUrl().getHost();
          Customer_Portal_Community_URL__mdt[] urlComm = [
            SELECT Organization__c, Organization_Community__c, URL__c
            FROM Customer_Portal_Community_URL__mdt
          ];
          for (Customer_Portal_Community_URL__mdt mdt : urlComm) {
            //If host == mdt.Organization__c -> PRODUCTION
            if (
              host == mdt.Organization__c ||
              host == mdt.Organization_Community__c
            ) {
              this.url = mdt.URL__c;
              break;
            } else if (
              host.contains(mdt.Organization__c) &&
              mdt.Organization__c.length() <= 10
            ) {
              //If host contains 'DEV', 'QA', or 'INT' -> mdt.Organization__c length is lower of 5 char
              this.url = mdt.URL__c;
              break;
            }
          }
          this.url += '/case/' + this.caseId + '/view';
        } else if (this.sender == 'SupplierPortal') {
          String host;
          host = System.URL.getSalesforceBaseUrl().getHost();
          Supplier_Portal_Community_URL__mdt[] urlComm = [
            SELECT Organization__c, Organization_Community__c, URL__c
            FROM Supplier_Portal_Community_URL__mdt
          ];
          for (Supplier_Portal_Community_URL__mdt mdt : urlComm) {
            //If host == mdt.Organization__c -> PRODUCTION
            if (
              host == mdt.Organization__c ||
              host == mdt.Organization_Community__c
            ) {
              this.url = mdt.URL__c;
              break;
            } else if (
              host.contains(mdt.Organization__c) &&
              mdt.Organization__c.length() <= 10
            ) {
              //If host contains 'DEV', 'QA', or 'INT' -> mdt.Organization__c length is lower of 5 char
              this.url = mdt.URL__c;
              break;
            }
          }
          this.url += '/case/' + this.caseId + '/view';
        } else {
          this.url =
            'https://' +
            System.URL.getSalesforceBaseUrl().getHost().split('\\.')[0] +
            '.lightning.force.com/lightning/r/Case/' +
            this.caseId + '/view';
        }
      }
      return this.url;
    }
    set;
  }

  public SMC_UTILS_GetHost_VFEmailTemplate() {
  }
}