import { LightningElement, api, track } from "lwc";
import PRODUCT_REFERENCE from "@salesforce/label/c.SMC_Product_Reference_Label";
import NO_RESULT from "@salesforce/label/c.SMC_NoResultFound";
import initialization from "@salesforce/apex/SMC_AC_ERP_Line.initialization";

export default class smc_lwc_erp_line extends LightningElement {
  productReference = { PRODUCT_REFERENCE };
  noResultLabel = { NO_RESULT };

  @api recordId;

  @track error = false;
  @track errorMessage;
  @track thereAreData = true;
  @track isInvoice;
  @track isOrder;
  @track isQuote;
  @track iconName;
  @track erpLineTitle;
  @track elementCurrency;
  @track datas;

  //doInit to find record object type + call WS

  /** INIT **/
  connectedCallback() {
    this.searching = true;
    initialization({
      recordId: this.recordId
    })
      .then(result => {
        let parseResult = JSON.parse(JSON.stringify(result));
        if (parseResult.error === undefined) {
          this.isInvoice = parseResult.isInvoice;
          this.isOrder = parseResult.isOrder;
          this.isQuote = parseResult.isQuote;
          this.iconName = parseResult.iconName;
          this.erpLineTitle = parseResult.erpLineTitle;
          this.elementCurrency = parseResult.elementCurrency;
          this.datas = parseResult.datas;

          if (this.datas === undefined || this.datas.length === 0) {
            this.thereAreData = false;
          }
        } else {
          this.error = true;
          this.searching = false;
          this.errorMessage = parseResult.error;
          this.thereAreData = false;
        }
        this.searching = false;
      })
      .catch(error => {
        this.error = true;
        this.errorMessage += JSON.stringify(error) + "\n";
        this.searching = false;
      });
  }
}