/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 20-05-2022
 * @last modified by  : Denis PHAM (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   02-10-2021   Vincent RECASENS (Modis)   Initial Version
 * 2.0   20-05-2022   Denis PHAM (Modis)   		 Add SupplierPortal
 **/
@IsTest
public class TEST_SMC_UTILS_GetHost_VFEmailTemplate {
  @isTest
  public static void testGetterMySocomec() {
    SMC_UTILS_GetHost_VFEmailTemplate elmt = new SMC_UTILS_GetHost_VFEmailTemplate();
    elmt.sender = 'MySocomec';
    elmt.caseId = 'fakeId';
    System.assertNotEquals(null, elmt.url);
  }

  @isTest
  public static void testGetterCustomerPortal() {
    SMC_UTILS_GetHost_VFEmailTemplate elmt = new SMC_UTILS_GetHost_VFEmailTemplate();
    elmt.sender = 'CustomerPortal';
    elmt.caseId = 'fakeId';
    System.assertNotEquals(null, elmt.url);
  }
    
  @isTest
  public static void testGetterSupplierPortal() {
    SMC_UTILS_GetHost_VFEmailTemplate elmt = new SMC_UTILS_GetHost_VFEmailTemplate();
    elmt.sender = 'SupplierPortal';
    elmt.caseId = 'fakeId';
    System.assertNotEquals(null, elmt.url);
  }

  @isTest
  public static void testGetterNoSender() {
    SMC_UTILS_GetHost_VFEmailTemplate elmt = new SMC_UTILS_GetHost_VFEmailTemplate();
    elmt.caseId = 'fakeId';
    String resultExpected =
      'https://' +
      System.URL.getSalesforceBaseUrl().getHost().split('\\.')[0] +
      '.lightning.force.com/lightning/r/Case/fakeId/view';
    System.assertEquals(resultExpected, elmt.url);
  }
}