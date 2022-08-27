import { LightningElement, api, track } from 'lwc';
import SEARCH_PRICING_GROUP from "@salesforce/label/c.SMC_Search_PricingGroup";
import PRINCING_GROUP from "@salesforce/label/c.SMC_PricingGroup";
import SEARCH_DESCRIPTION from "@salesforce/label/c.SMC_Search_Description";
import PRICING_GROUP_DESCRIPTION from "@salesforce/label/c.SMC_PricingGroupDescription";
import FILTERS from "@salesforce/label/c.SMC_Filters";
import HIGH_DISCOUNT from "@salesforce/label/c.SMC_High_Discount";
import HIDE_MAX_SUGGESTED from "@salesforce/label/c.SMC_Hide_Max_Suggested";
import LEGEND from "@salesforce/label/c.SMC_Legend";
import DISCOUNT_VALID from "@salesforce/label/c.SMC_Discount_Valid";

export default class Smc_lwc_discount_filters_and_legend extends LightningElement {
    @api recordid;
    @api getaccountname;

    //label
    searchPricingGroup = {SEARCH_PRICING_GROUP};
    pricingGroup = {PRINCING_GROUP};
    searchDescription = {SEARCH_DESCRIPTION};
    pricingGroupDescription = {PRICING_GROUP_DESCRIPTION};
    filters = {FILTERS};
    highDiscount = {HIGH_DISCOUNT};
    hideMaxSuggested = {HIDE_MAX_SUGGESTED};
    legend = {LEGEND};
    discountValid = {DISCOUNT_VALID};
   
    handleSearchPricingGroup(event){
        var filterValue = event.target.value;
        const searchPricingGroup = new CustomEvent("searchpricingproup", {        
            detail: { searchPricingGroup: filterValue } 
          });
          this.dispatchEvent(searchPricingGroup); 
    }
    handleSearchDescription(event){
        var filterValue = event.target.value;
        const searchDescription = new CustomEvent("searchdescription", {        
            detail: { searchDescription: filterValue } 
          });
          this.dispatchEvent(searchDescription); 
    }

    timeoutFiltrage(event){
        var maxDiscountFilter = event.target.checked;
        const booleanFilter = new CustomEvent("booleanfilter", {        
            detail: { maxDiscountFilter: maxDiscountFilter } 
          });
          this.dispatchEvent(booleanFilter); 
    }
}