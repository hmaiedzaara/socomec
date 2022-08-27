/**
 * @description       : This cmp contains all possibles actions on Order Details page [Buy Again / Cancel]
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-27-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-26-2020   Vincent RECASENS (Modis)   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACTION_AVAILABLE from "@salesforce/label/c.SMC_Action_Available";
import BUY_ACTION from "@salesforce/label/c.SMC_Buy_Again";
import BUY_ACTION_MESSAGE from "@salesforce/label/c.SMC_Buy_Again_Message";
// import EDIT from "@salesforce/label/c.SMC_Edit";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import CANCEL_MESSAGE from "@salesforce/label/c.SMC_Cancel_Message";
import YES from "@salesforce/label/c.SMC_Yes";
import NO from "@salesforce/label/c.SMC_No";
import REQ_DEL_DATE from "@salesforce/label/c.SMC_Requested_Delivery_Date";

export default class Smc_lwc_order_details_actions extends LightningElement {
  @api cdord;

  //Dialog variables
  @track confirmationTitle = "";
  @track confirmationMessage = "";
  @track isDialogVisible = false;
  @track originalMessage = "";
  @track buyagain = false;

  actionAvailableLabel = { ACTION_AVAILABLE };
  buyActionLabel = { BUY_ACTION };
  buyActionMessageLabel = { BUY_ACTION_MESSAGE };
  // editLabel = { EDIT };
  cancelLabel = { CANCEL };
  cancelMessageLabel = { CANCEL_MESSAGE };
  yesLabel = { YES };
  noLabel = { NO };
  reqDelDateLabelLabel = { REQ_DEL_DATE };

  handleBuyAgain() {
    //Set dialog
    this.confirmationTitle = this.buyActionLabel.BUY_ACTION;
    this.confirmationMessage = this.buyActionMessageLabel.BUY_ACTION_MESSAGE;
    this.originalMessage = this.buyActionLabel.BUY_ACTION;
    this.buyagain = true;
    this.isDialogVisible = true;
  }

  handleCancel() {
    //Set dialog
    this.confirmationTitle = this.cancelLabel.CANCEL;
    this.confirmationMessage = this.cancelMessageLabel.CANCEL_MESSAGE;
    this.isDialogVisible = true;
    this.originalMessage = this.cancelLabel.CANCEL;
  }

  handleConfirmDialog(event) {
    //check Buy Again or Cancel
    if (event.detail.originalMessage === this.buyActionLabel.BUY_ACTION) {
      // this.buyAgainConfirmed(event.detail.inputDateValue);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          message: "Not implemented",
          variant: "warning"
        })
      );
    } else if (event.detail.originalMessage === this.cancelLabel.CANCEL) {
      this.cancelOrderConfirmed();
    }
  }

  handleCancelDialog() {
    this.isDialogVisible = false;
    this.buyagain = false;
  }

  buyAgainConfirmed(reqDate) {
    // Send event to parent
    this.dispatchEvent(new CustomEvent("buyagainorder", { detail: reqDate }));
    this.isDialogVisible = false;
    this.buyagain = false;
  }

  cancelOrderConfirmed() {
    // Send event to parent
    this.dispatchEvent(new CustomEvent("cancelorder", {}));
    this.isDialogVisible = false;
    this.buyagain = false;
  }
}