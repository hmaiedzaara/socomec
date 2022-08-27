import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import checkAssets from "@salesforce/apex/SMC_AC_Create_Work_Order_From_TQI.checkAssets";
import generateRecords from "@salesforce/apex/SMC_AC_Create_Work_Order_From_TQI.generateRecords";
import GENERATE_WO from "@salesforce/label/c.SMC_Generate_WO";
import SELECT_AN_OPTION from "@salesforce/label/c.SMC_Select_an_option";
import FOR_ALL_ASSETS from "@salesforce/label/c.SMC_For_All_Assets";
import FOR_ASSETS_UNDER_CONTRACT from "@salesforce/label/c.SMC_For_Assets_Under_Contract";
import GENERATE from "@salesforce/label/c.SMC_Generate";
import NO_ASSET from "@salesforce/label/c.SMC_No_Asset_On_TQI";
import NO_ASSET_UNDER_CONTRACT from "@salesforce/label/c.SMC_No_Asset_Under_Contract_on_TQI";
import SUCCESS_MESSAGE from "@salesforce/label/c.SMC_Success_Message_Create_Records_TQI";
import ERROR_MESSAGE from "@salesforce/label/c.SMC_Error_Message_Create_Records_TQI";
import NUMBER_SPARE_PART_ITEMS from "@salesforce/schema/ProductServiceCampaign.SMC_Number_Of_Spare_Part_Items__c";
import START_DATE_TQI from "@salesforce/schema/ProductServiceCampaign.StartDate";
import END_DATE_TQI from "@salesforce/schema/ProductServiceCampaign.EndDate";
import DURATION from "@salesforce/schema/ProductServiceCampaign.SMC_Duration__c";


export default class Smc_lwc_create_wo_from_tqi extends LightningElement {
    //Id of the QTI (Product Service Campaign)
    @api recordId;

    //Label 
    label = {   GENERATE_WO, 
                SELECT_AN_OPTION, 
                FOR_ALL_ASSETS, 
                FOR_ASSETS_UNDER_CONTRACT,
                GENERATE,
                NO_ASSET,
                NO_ASSET_UNDER_CONTRACT,
                SUCCESS_MESSAGE,
                ERROR_MESSAGE
            };
    
    //Tracked Variables
    modalIsDisplay = false;
    isLoading = false;
    hasAsset = true;
    hasAssetUnderContract = true;
    underContract;
    disabledButton = true;
    selectedOption;
    hideForm = false;
    showError = false;
    showSuccess = false;
    errorMessage;


    get options(){
        return [
            { label : FOR_ALL_ASSETS, value: 'all_Assets'},
            { label : FOR_ASSETS_UNDER_CONTRACT, value: 'asset_Under_Contract'}
        ];
    }

    @wire(getRecord, {recordId: '$recordId', fields: [ NUMBER_SPARE_PART_ITEMS, START_DATE_TQI, END_DATE_TQI, DURATION ]})
    tqi;

    get numberSparePartItems(){
        return getFieldValue(this.tqi.data, NUMBER_SPARE_PART_ITEMS);
    }

    get startDateTQI(){
        return getFieldValue(this.tqi.data, START_DATE_TQI);
    }

    get endDateTQI(){
        return getFieldValue(this.tqi.data, END_DATE_TQI);
    }

    get duration(){
        return getFieldValue(this.tqi.data, DURATION);
    }

    handleClick(){
        this.modalIsDisplay = true;
        this.disabledButton = true;
        this.hasAsset = true;
        this.hasAssetUnderContract = true;
    }

    closeModal(){
        location.reload();
        this.modalIsDisplay = false;
        this.disabledButton = true;
        this.hasAsset = true;
        this.hasAssetUnderContract = true;
        this.hideForm = false;
        this.isLoading = false;
        this.showSuccess = false;
        this.showError = false;
    }

    checkHasAsset(event){
        this.selectedOption = event.detail.value;

        if(this.selectedOption == 'all_Assets')
        {
            this.underContract = false;
            checkAssets({recId: this.recordId, underContract: this.underContract})
            .then( result => {
                if (result == true){
                    this.hasAssetUnderContract = true;
                    this.hasAsset = true;
                    this.disabledButton = false;
                } else if(result == false){
                    this.hasAssetUnderContract = true;
                    this.hasAsset = false;
                    this.disabledButton = true;
                }
            })
            .catch( error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
        } 
        else if(this.selectedOption == 'asset_Under_Contract')
        {
            this.underContract = true;
            checkAssets({recId: this.recordId, underContract: this.underContract})
            .then( result => {
                if (result == true){
                    this.hasAsset = true;
                    this.hasAssetUnderContract = true;
                    this.disabledButton = false;
                } else if(result == false){
                    this.hasAsset = true;
                    this.hasAssetUnderContract = false;
                    this.disabledButton = true;
                }
            })
            .catch( error => {
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

    handleGenerateRecords(){
        this.hideForm = true;
        this.disabledButton = true;
        this.isLoading = true;

        generateRecords({recId: this.recordId, underContract: this.underContract, 
                         numberSparePartItems: this.numberSparePartItems , startDateTQI: this.startDateTQI, 
                         endDateTQI: this.endDateTQI, duration: this.duration})
        .then( result => {
            if (result == true){
                this.isLoading = false; 
                this.showSuccess = true;
            } else if(result == false){
                this.isLoading = false; 
                this.showError = true;
            }
        })
        .catch( error => {
            this.isLoading = false; 
            this.showError = true;
            this.errorMessage = error.body.message;

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