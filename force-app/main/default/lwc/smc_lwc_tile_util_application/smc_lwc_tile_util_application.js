import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecords from "@salesforce/apex/SMC_AC_MyApplications.getRecords";
import NO_DATA from "@salesforce/label/c.SMC_NoResultFound";
import MOBILE_STORES from '@salesforce/resourceUrl/SMC_Mobile_Stores';
import SOLIVE_UPS from '@salesforce/resourceUrl/SMC_SoliveUPS';


export default class Smc_lwc_tile_util_application extends LightningElement {
    @api titleIcon;
    @api title;
    @api link;
    @api targetObject;
    @api communityLabel;
    noData = { NO_DATA };

    @track isLoading = true;
    @track datas = [];
    @track resultIsNull = false;

    @track scrollableY = null;

    //Custom labels
    appStoreLogo = MOBILE_STORES + '/app-store-badge.png';
    googlePlayLogo = MOBILE_STORES + '/google-play-badge.png';

    soLiveUPS = SOLIVE_UPS;
    
    connectedCallback() {
        //Get values
        getRecords({
          targetObject: this.targetObject,
          communityLabel: this.communityLabel
        })
          .then(result => {
            this.datas = JSON.parse(result);
            if (this.datas.length > 4) {
              this.scrollableY = "slds-scrollable_y";
            } else if (this.datas.length === undefined || this.datas.length === 0) {
              this.resultIsNull = true;
            }
            this.isLoading = false;
          })
          .catch(error => {
            this.resultIsNull = true;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: JSON.stringify(error),
                variant: "error"
              })
            );
            this.isLoading = false;
          });
      }
}