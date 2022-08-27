import { LightningElement, api } from "lwc";
import QUANTITY from "@salesforce/label/c.SMC_Quantity";
import AMOUNT from "@salesforce/label/c.SMC_Amount";
import STATUS from "@salesforce/label/c.SMC_Status";
import BA from "@salesforce/label/c.SMC_BA_Label";

export default class smc_lwc_erp_line_unit extends LightningElement {
  @api isinvoice;
  @api isorder;
  @api isquote;
  @api elementcurrency;
  @api thedata;

  quantity = { QUANTITY };
  amount = { AMOUNT };
  status = { STATUS };
  ba = { BA };
}