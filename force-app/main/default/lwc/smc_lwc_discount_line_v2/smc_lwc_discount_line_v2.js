import { LightningElement, api, track } from 'lwc';
import HIGH_DISCOUNT from "@salesforce/label/c.SMC_High_Discount";
import DISCOUNT_VALID from "@salesforce/label/c.SMC_Discount_Valid";

export default class Smc_lwc_discount_line_v2 extends LightningElement {
    @api recordid;
    @api getaccountname;
    @api numberofvisiblelines;
    @api userSeeMaxSuggestedFilter;
    @api isAuthorizeToSeeMaxSuggested;
    @api dline;

    @track oneline;
    @track maxSupDiscount = false;
    @track notMaxSupDiscount = false;
    @track toggleIconValidity = true;
    @track priceGroupLabel;
    @track priceGroupDescription;
    @track priceGroupTier;
    @track priceGroupType;
    @track min;
    @track max;
    @track maxSuggested;
    @track discount;
    @track createDate;
    @track newDate = false;
    @track noNewDate = true;
    @track line;
    @track linestr;
       
    //Label
    highDiscount = {HIGH_DISCOUNT};
    discountValid = {DISCOUNT_VALID};

    connectedCallback(){
        this.oneline = this.dline;
        this.linestr = JSON.stringify(this.dline);
        if ( this.oneline.max >= this.oneline.discount) {
            this.maxSupDiscount = true;
        } else if(this.oneline.max < this.oneline.discount){
            this.notMaxSupDiscount = true;
        }

    }

    onDiscountBlur(event){
        this.toggleIconValidity = false;
        
        let lineDiscount = event.target.value;

        //To limit discount in range (0 - 100)
        if (lineDiscount > 100) {
            lineDiscount = 100;
        }
        if (lineDiscount < 0) {
            lineDiscount = 0;
        }
        lineDiscount = Math.round(10 * lineDiscount) / 10; //To limit discount with one decimal
        
        //get the line to update
        var theLine = JSON.parse(this.linestr);

        theLine.discount = lineDiscount;
        var isInit = false;
        this.checkDoubleInteger(isInit, theLine);
    }

    checkDoubleInteger(isInit, theLine){
        var lineDiscount = theLine.discount;
        //Check if discount is empty
        if (lineDiscount.toString().length == 0) {
          lineDiscount = 0;
        }
        //Check if discount is integer
        var isDoubleInteger =
          Math.floor(lineDiscount) == Math.ceil(lineDiscount);
        if (isDoubleInteger && !lineDiscount.toString().includes(".")) {
          lineDiscount = lineDiscount + ".0";
        }

       
        theLine.discount = lineDiscount;

        this.toggleIconValidity = true;
        ///change icon color if discount         
        if ( theLine.max >= theLine.discount ) {
            this.notMaxSupDiscount = false; 
            this.maxSupDiscount = true;         
        } else if(theLine.max < theLine.discount){
            this.maxSupDiscount = false;
            this.notMaxSupDiscount = true;
            
        }

        if (!isInit) {
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1;
            if (mm < 10) {
                mm = '0' + mm;
            }
            var yyyy = today.getFullYear();
            let newDate = yyyy + '-' + mm + '-' + dd;
            theLine.createDate = newDate;
            
        }
        
        this.line = JSON.stringify(theLine);

        const theLineToUpdate = new CustomEvent("line", {        
            detail: { line: this.line } 
        });
        this.dispatchEvent(theLineToUpdate); 
        
    }
    
}