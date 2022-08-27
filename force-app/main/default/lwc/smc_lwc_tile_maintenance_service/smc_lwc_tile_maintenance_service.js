import { LightningElement, api } from "lwc";
import M_ACTIVITIES from "@salesforce/label/c.SMC_Maintenance_Activities";
import M_CONTRACTS from "@salesforce/label/c.SMC_Maintenance_Contracts";
import S_CATALOG from "@salesforce/label/c.SMC_Service_Catalog";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_tile_maintenance_service extends LightningElement {
  // Design attributes
  @api titleIcon;
  @api title;
  // Labels
  m_activities = { M_ACTIVITIES };
  m_contracts = { M_CONTRACTS };
  s_catalog = { S_CATALOG };
}