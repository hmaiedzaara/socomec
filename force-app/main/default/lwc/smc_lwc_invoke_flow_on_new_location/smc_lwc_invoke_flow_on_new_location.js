import { LightningElement, api } from 'lwc';
import startFlow from "@salesforce/apex/SMC_AP_ManageLocation.invokeFlowCreateLocationAndRelatedAddress";

export default class Smc_lwc_invoke_flow_on_new_location extends LightningElement {
    @api recordId;

    connectedCallback(){
        console.log('start invoke flow');
        startFlow({locId: this.recordId});
        console.log('end invoke flow');
        
    }
}