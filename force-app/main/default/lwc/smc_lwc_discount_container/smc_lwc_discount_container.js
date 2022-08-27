import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDiscountInfo from "@salesforce/apex/SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm";
import ACCESS_DISCOUNT_FORM from "@salesforce/label/c.SMC_Access_Discount_Form";
import DISCOUNT_FORM from "@salesforce/label/c.SMC_Discount_Form";
import DISCOUNT_TITLE from "@salesforce/label/c.SMC_Scoring_Title";

export default class Smc_lwc_discount_container extends LightningElement {
    @api recordId;
    //Label
    accessDiscountForm = { ACCESS_DISCOUNT_FORM };
    discountForm = { DISCOUNT_FORM };
    discountTitle = {DISCOUNT_TITLE};

    //Track variable
    @track modalIsDisplay = false;
    @track record;
    @track token;
    @track baIds = []; 
    @track accountName;
    @track getAccount;
    @track baIdsListNotEmpty;
    @track isLoad = false;
    @track searchPricingGroup;
    @track searchDescription;
    @track booleanFilter;
    
    connectedCallback(){
        this.record = this.recordId;
    }

    handleClick(){
        getDiscountInfo({recId: this.recordId})
        .then(result => {
            if (result) {
            console.log(result);
            this.accountName = result.account.Name;
            this.baIds = result.baIds;
            this.token = result.token;
            this.getAccount = result.account;
            this.isLoad = true;
            this.modalIsDisplay = true;
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error,
                    variant: "error"
                })
            );
        });
    }

    closeModal(){
        this.modalIsDisplay = false;
    }

    handleClose(event){
        this.modalIsDisplay = event.detail.modalOnDiplay;

        setTimeout(()=>{
            this.handleClick();
        }, 1000);
    
    }

    handleSearchPricingGroup(event){
        this.searchPricingGroup = event.detail.searchPricingGroup ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }
    
    handleSearchDescription(event){
        this.searchDescription = event.detail.searchDescription ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }

    handleBooleanFilter(event){
        this.booleanFilter = event.detail.maxDiscountFilter ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }
}