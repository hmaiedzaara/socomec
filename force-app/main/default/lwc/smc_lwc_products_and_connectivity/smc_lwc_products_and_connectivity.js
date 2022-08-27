import { LightningElement } from "lwc";
import PRODUCTS from "@salesforce/label/c.SMC_Products";
import CONNECTIVITY from "@salesforce/label/c.SMC_Connectivity";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_products_and_connectivity extends LightningElement {
  // Labels
  title = "My Products & Connectivity";
  products = { PRODUCTS };
  connectivity = { CONNECTIVITY };
}