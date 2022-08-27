import { LightningElement, track, api } from 'lwc';
import ALTERNATIVE_PDT_MESSAGE from "@salesforce/label/c.SMC_Alternative_Products";
import NOT_INTERESTED from "@salesforce/label/c.SMC_Not_Interested";
import KEEP_ORIGINAL from "@salesforce/label/c.SMC_Keep_Original";

export default class Smc_lwc_neworder_altpdt_modal extends LightningElement {

    customLabels = {ALTERNATIVE_PDT_MESSAGE, NOT_INTERESTED, KEEP_ORIGINAL};

    @api altpdts;

    handleClick(event){
        this.sendEventToParent("clickaltpdt", JSON.parse(JSON.stringify(event.target.value)));
    }
    handleKeepOriginal(){
        this.sendEventToParent("clickaltpdt", "keep original");
    }
    handleNotInterested(){
        this.sendEventToParent("clickaltpdt", "not interested");
    }

    sendEventToParent(label, detail) {
      // Send event to parent
      const selectedEvent = new CustomEvent(label, {
        detail: detail
      });
      this.dispatchEvent(selectedEvent);
    }
}