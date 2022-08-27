import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDiscountInfo from "@salesforce/apex/SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm_v2";
import getBaInformations from "@salesforce/apex/SMC_AC_ScoringForm.getBaInformations";
import ACCESS_DISCOUNT_FORM from "@salesforce/label/c.SMC_Access_Discount_Form";
import DISCOUNT_FORM from "@salesforce/label/c.SMC_Discount_Form";
import DISCOUNT_TITLE from "@salesforce/label/c.SMC_Scoring_Title";
import SELECT_BA from "@salesforce/label/c.SMC_Select_BA";


export default class Smc_lwc_discount_container_v2 extends LightningElement {
    @api recordId;
    //Label
    accessDiscountForm = { ACCESS_DISCOUNT_FORM };
    discountForm = { DISCOUNT_FORM };
    discountTitle = { DISCOUNT_TITLE };
    selectBA = { SELECT_BA };

    //Track variable
    @track modalIsDisplay = false;
    @track record;
    @track token;
    //@track baIds; 
    @track accountName;
    @track getAccount;
    @track baIdsListNotEmpty;
    @track isLoad = false;
    @track searchPricingGroup;
    @track searchDescription;
    @track booleanFilter;
    tabs;
    baIdSelected;
    messageSelectBA = false;

    
    connectedCallback(){
        this.record = this.recordId;

        //Get BA to generate the Tab
        getBaInformations().then(
            result => {
                this.tabs = result;
            }
        ).catch( error => {
            console.error('Error Tab : ' + error);
        });
    }

    openModal(){
        this.modalIsDisplay = true;
        this.isLoad = false;
        this.baIdSelected = null;
        this.messageSelectBA = false;
    }

    closeModal(){
        this.modalIsDisplay = false;
        this.isLoad = false;
        this.baIdSelected = null;
    }

    handleClose(event){
        this.modalIsDisplay = event.detail.modalOnDiplay;

        setTimeout(()=>{
            this.openModal();
        }, 1000);
    
    }

    handleSearchPricingGroup(event){
        this.searchPricingGroup = event.detail.searchPricingGroup ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab_v2').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }
    handleSearchDescription(event){
        this.searchDescription = event.detail.searchDescription ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab_v2').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }

    handleBooleanFilter(event){
        this.booleanFilter = event.detail.maxDiscountFilter ;
        // DPHA - Add filter on the checkbox
        this.template.querySelector('c-smc_lwc_discount_tab_v2').filtrage(this.searchPricingGroup, this.searchDescription, this.booleanFilter);
    }

    handleBA(event){
        //DPHA - Change the CSS the see which tab is selected
        var tablinks, i;
        tablinks = this.template.querySelectorAll('.tablinks');
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].className = tablinks[i].className.replace(' active', '');
        }
        event.currentTarget.className += ' active';

        //DPHA - Change the BA ID by the selected, and refresh the tab
        if(this.baIdSelected === (event.currentTarget.id).split("-")[0]){
            return;
        }
        this.baIdSelected = (event.currentTarget.id).split("-")[0];
        console.log('BA ID du bouton HANDLE BA ++++++++++ ' + this.baIdSelected);
        
        this.messageSelectBA = true;
        this.template.querySelector('c-smc_lwc_discount_filters_and_legend_v2').clearField();
        this.isLoad = false;

        getDiscountInfo({recId: this.recordId})
        .then(result => {
            if (result) {
            console.log(result);
            this.accountName = result.account.Name;
            this.token = result.token;
            this.getAccount = result.account;
            this.isLoad = true;
            console.log('BA ID du bouton handleBA ++++++++++ ' + this.baIdSelected);
            console.log('AccountName handleBA ++++++++++ ' + this.accountName);
            console.log('Token handleBA ++++++++++ ' + this.token);
            console.log('GetAccount handleBA ++++++++++ ' + this.getAccount);
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: "error"
                })
            );
        });
    }
}