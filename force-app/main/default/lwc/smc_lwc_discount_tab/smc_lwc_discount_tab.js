import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PRICING_GROUP from "@salesforce/label/c.SMC_PricingGroup";
import PRICING_GROUP_DESCRIPTION from "@salesforce/label/c.SMC_PricingGroupDescription";
import MIN_DISCOUNT from "@salesforce/label/c.SMC_MinDiscount";
import MAX_DISCOUNT from "@salesforce/label/c.SMC_MaxDiscount";
import MAX_SUGGESTED_DISCOUNT from "@salesforce/label/c.SMC_MaxSuggestedDiscount";
import STANDARD_DISCOUNT from "@salesforce/label/c.SMC_StandardDiscount";
import DISCOUNT_VALIDITY from "@salesforce/label/c.SMC_DiscountValidity";
import LAST_EDI_TDATE from "@salesforce/label/c.SMC_LastEditDate";
import SAVE from "@salesforce/label/c.SMC_Save";
import getDiscountInfo from "@salesforce/apex/SMC_AC_Scoring.getTheScoring";
import saveTheScoring from "@salesforce/apex/SMC_AC_Scoring.saveTheScoring";


export default class Smc_lwc_discount_tab extends LightningElement {
  @api recordid;
  @api account;
  @api tokentab;
  @api baIds;
  @api searchPricingGroup;
  @api searchDescription;
  @api userSeeMaxSuggestedFilter;

  @track recordId;
  @track accountSerialized;
  @track discountLine = [];
  @track wantedLinesId = [];
  @track wantedLinesIdfiltered = [];
  @track memoryList = {};
  @track isAuthorizeToSeeMaxSuggested;
  @track userSeeMaxSuggestedFilter;
  @track manipulatedList = {};
  @track numberOfVisibleLines = 0;
  @track searchDescrip;
  @track searchPricing;
  @track isLoad = false;
  @track isLoadingScoring = true;
  @track isSavingScoring = false;
  @track unsaved = false;
  @track spinner = true;
  @track filteredLines = false;
  @track filterPricingGroup = false;
  @track filterDescription = false;


  //Label
  pricingGroup = { PRICING_GROUP };
  pricingGroupDescription = { PRICING_GROUP_DESCRIPTION };
  minDiscount = { MIN_DISCOUNT };
  maxDiscount = { MAX_DISCOUNT };
  maxSuggestionDiscount = { MAX_SUGGESTED_DISCOUNT };
  standardDiscount = { STANDARD_DISCOUNT };
  discountValidity = { DISCOUNT_VALIDITY };
  lastEditDate = { LAST_EDI_TDATE };
  save = { SAVE };

  connectedCallback() {
    this.recordId = this.recordid;
    this.accountSerialized = JSON.stringify(this.account);
    getDiscountInfo({
      accountSerialize: this.accountSerialized,
      token: this.tokentab,
      baIds: this.baIds
    }).then(result => {
      if (result) {
        console.log('result-->', result);
        /*There is 2 list :
            - scoring = memory list
            - scoringShow = list for manipulation. It is this list whom will be display
        */
        this.memoryList = result[0];
        this.isAuthorizeToSeeMaxSuggested = this.memoryList.userSeeMaxSuggested;

        this.manipulatedList = result[1];

        for (let discountline in this.manipulatedList.scoringLines) {
          this.discountLine.push(this.manipulatedList.scoringLines[discountline]);
        }

        //The number of line is used to determinate if the scroll bar is display or not
        this.numberOfVisibleLines = 0;
        for (var i = 0; i < result[1].scoringLines.length; ++i) {
          ++this.numberOfVisibleLines;
        }

        this.isLoad = true;
        this.spinner = false;
        
      }
    })
      .catch(error => {
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
      });
  }

  handleLine(event) {
    var theLine = JSON.parse(event.detail.line);
    //update new discount 
    var manipulatedListLine = this.manipulatedList.scoringLines.find(oneline => oneline.id === theLine.id);
    manipulatedListLine.discount = theLine.discount;
  }


  saveScoring() {
    console.log("save");
    var memoryDiscount = this.memoryList;
    var discountUpdate = this.manipulatedList;
    var checkIfAtLeastOneLineIsChanged = false;
    for (var j = 0; j < memoryDiscount.scoringLines.length; ++j) {
      if (
        discountUpdate.scoringLines[j].discount != memoryDiscount.scoringLines[j].discount
      ) {
        discountUpdate.scoringLines[j].isModified = true;
        checkIfAtLeastOneLineIsChanged = true;
        discountUpdate.scoringLines[j].createDate = null;
      }

      // if (discountUpdate.scoringLines[j].maxSuggested != memoryDiscount.scoringLines[j].maxSuggested) {
      //     discountUpdate.scoringLines[j].isModified = true;
      // }
    }

    if (!checkIfAtLeastOneLineIsChanged) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "No change apply",
          message: "You tried to save the discount but there is no change.",
          variant: "warning"
        })
      );
      this.isSavingScoring = false;
    } else if (this.unsaved == false) {
      this.saveNewScoring(discountUpdate);
    } else {
      this.isSavingScoring = false;
    }


  }

  saveNewScoring(discountToUpdate) {
    var discountString = JSON.stringify(discountToUpdate);
    saveTheScoring({
      scoring: discountString,
      token: this.tokentab,
      recordId: this.recordId
    }).then(result => {
      if (result) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Saved",
            message: "Your changes are saved.",
            variant: 'success'
          })
        );
        const close = new CustomEvent("close", {
          detail: { modalOnDiplay: false }
        });
        this.dispatchEvent(close);
      }
    })
      .catch(error => {
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
      });
  }

  @api filtrage(searchPricingGroup, searchDescription, booleanFilter) {
    this.filterPricingGroup = true;
    var scoringShow = this.discountLine;
    this.wantedLinesId = [];
    let target1 = this.template.querySelector('.slds-scrollable_y');
    let target = this.template.querySelector('.lastEditDate');

    this.filteredLines = true;
    // Search filters  
    var search = searchPricingGroup;
    var searchDescription = searchDescription;
    var checkOverMaxDiscount = booleanFilter;
    
    searchDescription = searchDescription || '';
    search = search || '';

    // No filter
    if ((search == "") && (searchDescription == "") && (!checkOverMaxDiscount)) {
      this.filteredLines = false;
    }

    // Description null and Customer Discount ≤ Max Discount (Checkbox = false)
    if ((search !== "") && (searchDescription === "") && (!checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strPriceGroup = scoringShow[j].priceGroup.label.toLowerCase(); //Price group - pricegroup.id
        if (strPriceGroup.includes(search.toLowerCase())) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // Pricing null and Customer Discount ≤ Max Discount (Checkbox = false)
    if ((search === "") && (searchDescription !== "") && (!checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strDescription = scoringShow[j].priceGroup.description.toLowerCase(); //Description - pricegroup.label
        if (strDescription.includes(searchDescription.toLowerCase())) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // Customer Discount > Max Discount (Checkbox = true)
    if ((search === "") && (searchDescription === "") && (checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var max = scoringShow[j].max;
        var discount = scoringShow[j].discount;
        if (max < discount) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // Description null and Customer Discount > Max Discount (Checkbox = true)
    if ((search !== "") && (searchDescription === "") && (checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strPriceGroup = scoringShow[j].priceGroup.label.toLowerCase(); //Price group - pricegroup.id
        var max = scoringShow[j].max;
        var discount = scoringShow[j].discount;
        if (strPriceGroup.includes(search.toLowerCase()) && (max < discount)) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // Pricing null and Customer Discount > Max Discount (Checkbox = true)
    if ((search === "") && (searchDescription !== "") && (checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strDescription = scoringShow[j].priceGroup.description.toLowerCase(); //Description - pricegroup.label
        var max = scoringShow[j].max;
        var discount = scoringShow[j].discount;
        if (strDescription.includes(searchDescription.toLowerCase()) && (max < discount)) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // 2 filters : Description, Pricing and Customer Discount ≤ Max Discount (Checkbox = false)
    if ((search != "") && (searchDescription != "") && (!checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strPriceGroup = scoringShow[j].priceGroup.label.toLowerCase(); //Price group - pricegroup.id
        var strDescription = scoringShow[j].priceGroup.description.toLowerCase(); //Description - pricegroup.label
        if (strPriceGroup.includes(search.toLowerCase()) && strDescription.includes(searchDescription.toLowerCase())) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    // 2 filters : Description, Pricing and Customer Discount > Max Discount (Checkbox = true)
    if ((search != "") && (searchDescription != "") && (checkOverMaxDiscount)) {
      for (var j = 0; j < scoringShow.length; ++j) {
        var strPriceGroup = scoringShow[j].priceGroup.label.toLowerCase(); //Price group - pricegroup.id
        var strDescription = scoringShow[j].priceGroup.description.toLowerCase(); //Description - pricegroup.label
        var max = scoringShow[j].max;
        var discount = scoringShow[j].discount;
        if (strPriceGroup.includes(search.toLowerCase()) && strDescription.includes(searchDescription.toLowerCase()) &&  (max < discount)) {
          this.wantedLinesId.push(scoringShow[j]);
        }
      }
    }

    var numberOfVisibleLines = 0;
    for (var i = 0; i < this.wantedLinesId.length; ++i) {
      ++numberOfVisibleLines;
    }

    this.numberOfVisibleLines = numberOfVisibleLines;

    //resizing header if scroller
    if (this.numberOfVisibleLines < 10 && this.filteredLines) {
      target.classList.remove('withScroller');
    } else {
      target.classList.add('withScroller');
    }
    //resize tabs heigth 
    if (this.numberOfVisibleLines <= 5 && this.filteredLines) {
      target1.classList.add('smalltab');
    } else {
      target1.classList.remove('smalltab');
    }
  }
}