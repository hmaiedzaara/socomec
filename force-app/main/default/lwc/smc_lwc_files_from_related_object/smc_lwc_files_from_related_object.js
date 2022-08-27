import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getData from "@salesforce/apex/SMC_AC_Files_From_Related_Object.getData";
import getTitle from "@salesforce/apex/SMC_AC_Files_From_Related_Object.getTitle";
import TITLE from "@salesforce/label/c.SMC_Title";
import OWNER from "@salesforce/label/c.SMC_Owner";
import LAST_MODIFIED_DATE from "@salesforce/label/c.SMC_LastEditDate";
import CONTENT_SIZE from "@salesforce/label/c.SMC_Content_size";

export default class Smc_lwc_files_from_related_object extends LightningElement {

    @api recordId;
    @api relatedObjectAPIName; 
    @api communityName;
    @api stringTitle;
    spinner = false;
    data = [];
    titleCard;

    //Label 
    label = {   TITLE, 
                OWNER,
                LAST_MODIFIED_DATE,
                CONTENT_SIZE
            };


    connectedCallback() {
        if(this.stringTitle == null || this.stringTitle == undefined || this.stringTitle == ''){
            this.getTitleCard();
        } else {
            this.titleCard = this.stringTitle;
        }
        this.getAllData();
    }

    getAllData(){
        getData({           
            recId: this.recordId,
            relatedObjectAPIName: this.relatedObjectAPIName,
            communityName: this.communityName
        })
        .then(result => {
            
            if(result)
            {
                this.data = result;
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
        this.spinner = false;
        });
    }

    getTitleCard(){
        getTitle({
            recId: this.recordId,
            relatedObjectAPIName: this.relatedObjectAPIName
        })
            .then(result => {
                    this.titleCard = result;
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