import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getData from "@salesforce/apex/SMC_AC_Related_List_From_Related_Object.getData";
import getColumns from "@salesforce/apex/SMC_AC_Related_List_From_Related_Object.getColumns";
import getTitle from "@salesforce/apex/SMC_AC_Related_List_From_Related_Object.getTitle";

export default class Smc_lwc_display_related_list_from_related_object extends LightningElement 
{
    @api recordId;
    @api relatedObjectAPIName; 
    @api relatedListAPIName; 
    @api relatedLookupAPIName; 
    @api listFieldsAPIName;
    @api communityName;
    @api stringTitle;
    spinner = false;
    data = [];
    title;

    //Colonnes 
    columns= [];
    columnsObject = [
        {fieldName: "recordLink", label: "Link", type : "url", typeAttributes: {label: {fieldName: "Id"}, tooltip: "Id", target: "_blank"}}
    ];

    /*columnsFiles = [
        {fieldName: "recordLink", label: "Link", type : "url", typeAttributes: {label: {fieldName: "ContentDocumentId"}, tooltip: "Id", target: "_blank"}}
    ];*/

    connectedCallback() {
        if(this.stringTitle == null || this.stringTitle == undefined){
            this.getTitle();
        } else {
            this.title = this.stringTitle;
        }
        
        this.getAllColumns();
        this.getAllData();
    }

    getTitle(){
        getTitle({
            recId: this.recordId,
            relatedObjectAPIName: this.relatedObjectAPIName,
            relatedListAPIName: this.relatedListAPIName
        })
            .then(result => {
                    this.title = result;
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

    getAllColumns(){
        getColumns({
            relatedListAPIName: this.relatedListAPIName,
            listFieldsAPIName: this.listFieldsAPIName
        })
            .then(result => {
                if(result)
                {
                    for(var key in result)
                    {
                        //if(this.relatedListAPIName == "ContentDocument"){
                        //    this.columnsFiles = [...this.columnsFiles, {fieldName: key, label: result[key], type: 'text'}];
                        //} else{
                            this.columnsObject = [...this.columnsObject, {fieldName: key, label: result[key], type: 'text'}];
                        //}
                        
                    }
                }
                //if(this.relatedListAPIName == "ContentDocument"){
                //    this.columns =this.columnsFiles;
                //} else{
                    this.columns = this.columnsObject;
                //}

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
    
    getAllData() {
        getData({
            recId: this.recordId,
            relatedObjectAPIName: this.relatedObjectAPIName,
            relatedListAPIName: this.relatedListAPIName,
            relatedLookupAPIName: this.relatedLookupAPIName,
            listFieldsAPIName: this.listFieldsAPIName
        })
            .then(result => {
            
            if(result)
            {
                let tempRecList = [];
                for(var key in result)
                {
                    let tempRec = Object.assign({}, result[key]);
                    if(this.communityName !== null && this.communityName !== undefined){
                        //if(this.relatedListAPIName == "ContentDocument"){
                        //    tempRec.recordLink = '/' + this.communityName + '/s/detail/' + tempRec.ContentDocumentId;
                            
                        //} else{
                            tempRec.recordLink = '/' + this.communityName + '/s/detail/' + tempRec.Id;
                        //}           
                    } else {
                        //if(this.relatedListAPIName == "ContentDocument"){
                        //    tempRec.recordLink = '/' + tempRec.ContentDocumentId;;
                        //} else{
                            tempRec.recordLink = '/' + tempRec.Id;
                        //}           
                    }
                    tempRecList.push(tempRec);
                }
                this.data = tempRecList;
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

}