/**
 * @File Name          : SMC_UTIL_CaseCalloutMockJSON.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 17:00:42
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2019   Vincent RECASENS (Modis)     Initial Version
 **/

public without sharing class SMC_UTIL_CaseCalloutMockJSON {
  public final static String SERIAL_NUMBER = 'serialNumber';
  public final static String SERIAL_NUMBER_JSON_KEY = '"serialNumbers":';
  public final static String PRODUCTS = 'products';
  public final static String ORDER_NUMBER = 'orderNumber';
  public final static String PRODUCT_FAMILY = 'productFamily';

  public final static String SERIAL_NUMBER_FOR_MOCK = 'BP171860';
  public final static String SERIAL_NUMBER_MOCK = '{"serialNumber":["BP171860"]}';
  public final static String PRODUCT_FAMILY_MOCK = '146';
  public final static String SN_PRODUCT_INFO =
    '[' +
    '{' +
    '"id":"73562",' +
    '"serialNumber":"BP171860",' +
    '"rate":"1.0",' +
    '"productFamily":"146",' +
    '"productFamilyDescription":"EDP70",' +
    '"productModel":"169",' +
    '"productModelDescription":"ANY_OTHER",' +
    '"productConfig":"NU",' +
    '"productConfigDescription":"Not used"' +
    '}' +
    ']';

  public final static String PRODUCT_INFO_HTML = '{"products": ["Product1", "Product2", "Product3"]}';

  public final static String CIMSA_VISIT_MOCK =
    '{' +
    '"VISUNDID":"7",' +
    '"VISSN":"BP171860",' +
    '"VISPL":"28/03/2019",' +
    '"VISCATID":"1",' +
    '"VIEWH":"1,0",' +
    '"VICODE":"NUVI1903388",' +
    '"USRID":"",' +
    '"SFUSER":"vreca",' +
    '"SFCASE":"C-1902-00314964",' +
    '"REQID":"",' +
    '"PS":"INSERT_VISIT_FOR_SOCOLINE",' +
    '"calloutResponse":false' +
    '}';
  public final static String VICODE_FOR_MOCK = 'NUVI1903388';

  public final static String SALES_ORDER_DETAILS =
    '[{' +
    '"salesOrderFlowCategory":null,' +
    '"salesOrder":"salesOrder1",' +
    '"positionNumber":2,' +
    '"packingSlipTrackingNumber":null,' +
    '"packingSlipShippingDate":null,' +
    '"packingSlipNumber":null,' +
    '"packingSlipCarrier":null,' +
    '"orderedQuantity":5,' +
    '"lineReviewDate":null,' +
    '"lineExWorkConfirmed":null,' +
    '"itemDescription":"itemDescription1",' +
    '"item":"item1",' +
    '"invoiceNumber":null,' +
    '"deliverySlipDate":null,' +
    '"deliveredQuantity":null,' +
    '"backOrder":null' +
    '},' +
    '{' +
    '"salesOrderFlowCategory":null,' +
    '"salesOrder":"salesOrder2",' +
    '"positionNumber":2,' +
    '"packingSlipTrackingNumber":null,' +
    '"packingSlipShippingDate":null,' +
    '"packingSlipNumber":null,' +
    '"packingSlipCarrier":null,' +
    '"orderedQuantity":5,' +
    '"lineReviewDate":null,' +
    '"lineExWorkConfirmed":null,' +
    '"itemDescription":"itemDescription2",' +
    '"item":"item2",' +
    '"invoiceNumber":null,' +
    '"deliverySlipDate":null,' +
    '"deliveredQuantity":null,' +
    '"backOrder":null' +
    '}]';
  public final static String INSTALLED_PRODUCT_INFO =
    '<html>' +
    '<head>' +
    '<style type="text/css">table { font-size: 12px; color: #333333; background-color: inherit; border: 1px solid #888888; margin-bottom: 15px; }table tr { height: 20px; }table tr.l1 { background-color: #FFFFFF; color: inherit; }table tr.l2 { background-color: #E6F4FD; color: inherit; }table th { border: 1px solid #FFFFFF; height: 23px; white-space: nowrap; padding-left: 10px; padding-right: 10px; color: #666666; background-color: inherit; }table td { white-space: nowrap; padding-left: 10px; padding-right: 10px; }h1 { font-size: 12px; }</style>' +
    '</head>' +
    '<body>' +
    '<br />' +
    '<h1>CUSTOMER INFORMATION</h1>' +
    '<table>' +
    '<tr>' +
    '<td>Id account</td>' +
    '<td>E10024</td>' +
    '<td>Cust Code</td>' +
    '<td>E10024</td>' +
    '</tr>' +
    '<tr>' +
    '<td>Account</td>' +
    '<td>INGEBAT SL</td>' +
    '<td>Account 2</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Address</td>' +
    '<td>MATIAS PERELLO 53 BAJOS' +
    '<br />46005 VALENCIA' +
    '<br />SPAIN' +
    '</td>' +
    '</td>' +
    '</tr>' +
    '<tr>' +
    '<td>Area</td>' +
    '<td>Comunidad Valenciana</td>' +
    '</td>' +
    '</tr>' +
    '<td colspan="2">' +
    '<b>Local language address</b>' +
    '</td>' +
    '<tr>' +
    '<td>Account</td>' +
    '<td></td>' +
    '<td>Account 2</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Address 1</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Address 2</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Address 3</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Zip code</td>' +
    '<td></td>' +
    '<td>City</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>County</td>' +
    '<td></td>' +
    '<td>State/Region</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Country</td>' +
    '<td></td>' +
    '</tr>' +
    '<tr>' +
    '<td>Note</td>' +
    '<td>' +
    '<pre></pre>' +
    '</td>' +
    '</tr>' +
    '</table>' +
    '<h1>CONTRACT INFORMATION</h1>' +
    '<table>' +
    '<tr>' +
    '<th>Code</th>' +
    '<th>Start date</th>' +
    '<th>End date</th>' +
    '<th>Type</th>' +
    '<th>Options</th>' +
    '<th>Status</th>' +
    '<th>Length</th>' +
    '<th>Note</th>' +
    '</tr>' +
    '</table>' +
    '<table>' +
    '<tr>' +
    '<th>Unit</th>' +
    '<th>Type</th>' +
    '<th>Contract</th>' +
    '<th>Revision month</th>' +
    '<th>On site response time</th>' +
    '<th>Repair response time</th>' +
    '<th>On site working hour</th>' +
    '<th>Remote access</th>' +
    '</tr>' +
    '</table>' +
    '<h1>INSTALL BASE INFORMATION</h1>' +
    '<table>' +
    '<tr>' +
    '<th>Equipment</th>' +
    '<th>Manufacturer</th>' +
    '<th>Family</th>' +
    '<th>Model</th>' +
    '<th>Configuration</th>' +
    '<th>In/Out Phase</th>' +
    '<th>Power</th>' +
    '<th>Autonomy</th>' +
    '<th>Add other</th>' +
    '<th>Note</th>' +
    '</tr>' +
    '<tr class="l1">' +
    '<td>BN05B00064</td>' +
    '<td>SOCOMEC CP</td>' +
    '<td>NeTYS (NET)</td>' +
    '<td>NeTYS PR (NET-PR)</td>' +
    '<td>Line-Interactive UPS with AVR</td>' +
    '<td>1/1</td>' +
    '<td>2 kVA</td>' +
    '<td>8</td>' +
    '<td>' +
    '<pre></pre>' +
    '</td>' +
    '<td></td>' +
    '</tr>' +
    '</table>' +
    '<table>' +
    '<tr>' +
    '<th>Unit</th>' +
    '<th>Equipment</th>' +
    '<th>Power</th>' +
    '<th>Type</th>' +
    '<th>Run date</th>' +
    '<th>Warranty date</th>' +
    '</tr>' +
    '<tr class="l2">' +
    '<td>BN05B00064</td>' +
    '<td>BN05B00064</td>' +
    '<td>2</td>' +
    '<td>UPS</td>' +
    '<td>22/05/06</td>' +
    '<td>22/05/08</td>' +
    '</tr>' +
    '</table>' +
    '<table>' +
    '<tr>' +
    '<th>Component</th>' +
    '<th>Unit</th>' +
    '<th>Type</th>' +
    '<th>Manufacturer</th>' +
    '<th>Reference</th>' +
    '<th>Quantity</th>' +
    '<th>String number</th>' +
    '<th>Element number</th>' +
    '<th>Installed date</th>' +
    '<th>Next replaced date</th>' +
    '<th>Warranty end date</th>' +
    '</tr>' +
    '</table>' +
    '<h1>RELATED VISITS INFORMATION</h1>' +
    '<table>' +
    '<tr>' +
    '<th>Visit</th>' +
    '<th>Unit</th>' +
    '<th>Type</th>' +
    '<th>Status</th>' +
    '<th>Techs</th>' +
    '<th>End date</th>' +
    '<th>Description</th>' +
    '<th>Note</th>' +
    '</tr>' +
    '<tr class="l1">' +
    '<td>SPVI08106261</td>' +
    '<td>BN05B00064</td>' +
    '<td>REPAIR TO SOCOMEC OFFICE</td>' +
    '<td>CLOSED</td>' +
    '<td>OMA</td>' +
    '<td>27/10/08</td>' +
    '<td>' +
    '<pre></pre>' +
    '</td>' +
    '<td>' +
    '<pre>EQUIPO REPARADO.NO SE DETECTAN ANOMALIAS.</pre>' +
    '</td>' +
    '</tr>' +
    '<tr class="l2">' +
    '<td>SPVI09058061</td>' +
    '<td>BN05B00064</td>' +
    '<td>REPAIR TO SOCOMEC OFFICE</td>' +
    '<td>CLOSED</td>' +
    '<td>OMA</td>' +
    '<td>04/05/09</td>' +
    '<td>' +
    '<pre></pre>' +
    '</td>' +
    '<td>' +
    '<pre>EQUIPO REPARADO.NO SE DETECTAN ANOMALIAS.EL CLIENTE SE QUEJA DE QUE ES LA 3ª VEZ QUE EL SAI SE ESTROPEA.</pre>' +
    '</td>' +
    '</tr>' +
    '</table>' +
    '<table>' +
    '<tr>' +
    '<th>Unit</th>' +
    '<th>End intervention date</th>' +
    '<th>Visit</th>' +
    '<th>Spare part number</th>' +
    '<th>Spare part description</th>' +
    '<th>Quantity used</th>' +
    '</tr>' +
    '<tr class="l1">' +
    '<td>BN05B00064</td>' +
    '<td>27/10/08</td>' +
    '<td>SPVI08106261</td>' +
    '<td>9190000002</td>' +
    '<td>VISIT</td>' +
    '<td>1</td>' +
    '</tr>' +
    '<tr class="l2">' +
    '<td>BN05B00064</td>' +
    '<td>04/05/09</td>' +
    '<td>SPVI09058061</td>' +
    '<td>9190000002</td>' +
    '<td>VISIT</td>' +
    '<td>1</td>' +
    '</tr>' +
    '</table>' +
    '</body>' +
    '</html>';
}