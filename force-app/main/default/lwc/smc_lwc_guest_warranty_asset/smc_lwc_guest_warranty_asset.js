import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//LABELS
//Account|Contact|Location
import WARRANTY_INFORMATION from "@salesforce/label/c.SMC_Warranty_Information";
import PERSON_ACCOUNT from "@salesforce/label/c.SMC_Youre_not_a_company";
import CONTACT_INFORMATION from "@salesforce/label/c.SMC_Contact_Information";
import FIRST_NAME from "@salesforce/label/c.SMC_First_Name";
import LAST_NAME from "@salesforce/label/c.SMC_Last_Name";
import JOB_TITLE from "@salesforce/label/c.SMC_Job_Title";
import COMPANY_NAME from "@salesforce/label/c.SMC_CompanyName";
import MAIN_ACTIVITY from "@salesforce/label/c.SMC_Main_Activity";
import YOUR_ORGANIZATION from "@salesforce/label/c.SMC_Your_Organization";
import PURCHASED_COMPANY from "@salesforce/label/c.SMC_Purchased_from_company";
import PURCHASED_COUNTRY from "@salesforce/label/c.SMC_Purchased_from_country";
import MOBILE_PHONE from "@salesforce/label/c.SMC_Mobile_Phone";
import EMAIL from "@salesforce/label/c.SMC_Email";
import CONFIRM_EMAIL from "@salesforce/label/c.SMC_Confirm_Email";
import SEND_CONFIRMATION from "@salesforce/label/c.SMC_Send_Confirmation_Email";
import SEND_CONFIRMATION_LABEL from "@salesforce/label/c.SMC_Send_Confirmation_Email_Label";
import SEND_NEWSLETTER from "@salesforce/label/c.SMC_Send_Newsletter_WR";
import SEND_NEWSLETTER_LABEL from "@salesforce/label/c.SMC_Send_Newsletter_WR_Label";
import CASE_REGISTERED from "@salesforce/label/c.SMC_WR_Case_Registered";
//Address
import COUNTRY from "@salesforce/label/c.SMC_Country";
import STREET from "@salesforce/label/c.SMC_Street";
import ZIP_POSTAL_CODE from "@salesforce/label/c.SMC_Zip_Postal_Code";
import CITY from "@salesforce/label/c.SMC_City";
import STATE from "@salesforce/label/c.SMC_State";
//Asset
import PRODUCT_INFORMATION from "@salesforce/label/c.SMC_Product_Information";
import PRODUCT from "@salesforce/label/c.SMC_Product";
import SERIAL_NUMBER from "@salesforce/label/c.SMC_Serial_Number";
import PURCHASED_DATE from "@salesforce/label/c.SMC_Purchased_Date";
//Commons
import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";
import UPLOAD_FILE from "@salesforce/label/c.SMC_Upload_File";
// import RESET from "@salesforce/label/c.SMC_Reset";
// import SAVE from "@salesforce/label/c.SMC_Save";
import SEARCH from "@salesforce/label/c.SMC_Search";
//METHODS
import getStaticInformations from "@salesforce/apex/SMC_AC_WarrantyRegistration.getStaticInformations"; //Country code + metadatas MainActivity/YourOrganization
import getStates from "@salesforce/apex/SMC_AC_WarrantyRegistration.getStates"; //Country code + metadatas MainActivity/YourOrganization
import saveRequest from "@salesforce/apex/SMC_AC_WarrantyRegistration.saveRequest";
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class Smc_lwc_guest_warranty_asset extends LightningElement {
  //Labels
  customLabels = {
    WARRANTY_INFORMATION,
    PERSON_ACCOUNT,
    CONTACT_INFORMATION,
    FIRST_NAME,
    LAST_NAME,
    JOB_TITLE,
    COMPANY_NAME,
    MAIN_ACTIVITY,
    YOUR_ORGANIZATION,
    PURCHASED_COMPANY,
    PURCHASED_COUNTRY,
    EMAIL,
    CONFIRM_EMAIL,
    MOBILE_PHONE,
    COUNTRY,
    STREET,
    ZIP_POSTAL_CODE,
    CITY,
    STATE,
    PRODUCT_INFORMATION,
    PRODUCT,
    SERIAL_NUMBER,
    PURCHASED_DATE,
    CHOOSE_HERE,
    UPLOAD_FILE,
    SEND_CONFIRMATION,
    SEND_CONFIRMATION_LABEL,
    SEND_NEWSLETTER,
    SEND_NEWSLETTER_LABEL,
    SEARCH
  };

  //Const
  paddingTop = 'padding-top-5';
  widthMax = 'width-100';
  sldsHasError = 'slds-has-error';

  isPersonAccount = false;
  //Contact attributes
  contactInformations = true;
  contactFirstName;
  contactLastName;
  contactJobTitle;
  contactEmail;
  emailRequired = true;
  contactConfirmEmail;
  contactMobilePhone;
  contactCompanyName = '';
  showErrorLabelForCompanyName = false;
  companyNameCssClass = this.paddingTop;
  companyNameIsRequired = true;
  //Address
  countryvalues = [];
  countryIsSelected = true;
  stateNotLoaded = true;
  initstate = [];
  statevalues = [];
  mainactivtyvalues = [];
  mainactivty;
  yourorganizationvalues = [];
  yourorganization = "";
  country;
  street;
  zippostalcode;
  city;
  state;
  //Asset
  product;
  serialnumber;
  purchaseddate;
  purchaseddateCssClass = this.paddingTop + ' ' + this.widthMax;
  showErrorLabelForPurchasedDate = false;
  purchasedcompany;
  purchasedcountry;
  //Wrapper
  wrapperInformations;
  //Spinner
  spinnerDuringSave = true;
  refreshView = true;
  //Send confirmation/newsletter
  sendConfirmation = true;
  sendNewsletter = false;

  //From aprent
  @api caseid;
  documentId;
  @api handleDocumentId(documentId) {
    console.log('documentId', documentId);
    this.documentId = documentId;
  }
  @api handleCaseId(caseid) {
    this.caseid = caseid;
  }

  connectedCallback() {
    this.purchaseddate =
      new Date().getFullYear() +
      "-" +
      (new Date().getMonth() + 1) +
      "-" +
      new Date().getDate();
    this.getUrlParams();
    this.refreshView = true;
    getStaticInformations({})
      .then(result => {
        let parsedResult = JSON.parse(JSON.stringify(result));
        this.wrapperInformations = parsedResult;
        this.countryvalues = parsedResult.countries;
        this.mainactivtyvalues = parsedResult.mainactivities;
        this.yourorganizationvalues = parsedResult.yourorganizations;
        this.spinnerDuringSave = false;
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error",
          message:
            "There is an error when trying to get country code values : " +
            error,
          variant: "error"
        });
        this.dispatchEvent(evt);
        this.spinnerDuringSave = false;
      });

    //States
    getStates({})
    .then(result => {
      let parsedResult = JSON.parse(JSON.stringify(result));
      this.initstate = parsedResult.statesDepenciesAndValues;
      this.stateNotLoaded = false;
    })
    .catch(error => {
      const evt = new ShowToastEvent({
        title: "Error",
        message:
          "There is an error when trying to get states values : " +
          error,
        variant: "error"
      });
      this.dispatchEvent(evt);
      this.stateNotLoaded = false;
    });
  }

  getUrlParams() {
    var key = false,
      res = {},
      itm = null;
    // get the query string without the ?
    var qs = location.search.substring(1);
    // check for the key as an argument
    if (arguments.length > 0 && arguments[0].length > 1) key = arguments[0];
    // make a regex pattern to grab key/value
    var pattern = /([^&=]+)=([^&]*)/g;
    // loop the items in the query string, either
    // find a match to the argument, or build an object
    // with key/value pairs
    let decodeURIvar;
    while ((itm = pattern.exec(qs))) {
      if (key !== false && decodeURIComponent(itm[1]) === key)
        decodeURIvar = decodeURIComponent(itm[2]);
      else if (key === false)
        res[decodeURIComponent(itm[1])] = decodeURIComponent(itm[2]);
    }

    //Get serial number
    if (
      res === null ||
      res === undefined ||
      res.serialnumber === null ||
      res.serialnumber === undefined
    ) {
      this.serialnumber = undefined;
    } else {
      this.serialnumber = res.serialnumber;
    }

    //Get product description
    if (
      res === null ||
      res === undefined ||
      res.product === null ||
      res.product === undefined
    ) {
      this.product = undefined;
    } else {
      if(res.product.includes('%20')){
        this.product = res.product.replace('%20', ' ');
      }
      else if(res.product.includes('+')){
        this.product = res.product.replace('+', ' ');
      }
      else{
        this.product = res.product;
      }
    }
  }

  //HANDLERS ***********
  handleIsPersonAccount() {
    this.isPersonAccount = !this.isPersonAccount;
    if (this.isPersonAccount) {
        let companyNewName = (this.contactFirstName != undefined && this.contactFirstName != ""
        ? this.contactFirstName + " "
        : "") +
      (this.contactLastName != undefined && this.contactLastName != ""
        ? this.contactLastName
        : "");
        this.contactCompanyName = companyNewName;
    } else {
      this.contactCompanyName = "";
    }
    this.handleContactCompanyNameFocusOut();
  }
  //Contact
  handleContactFirstName(event) {
    this.contactFirstName = event.target.value;
    if (this.isPersonAccount) {
      this.contactCompanyName =
        (this.contactFirstName != undefined && this.contactFirstName != ""
          ? this.contactFirstName + " "
          : "") +
        (this.contactLastName != undefined && this.contactLastName != ""
          ? this.contactLastName
          : "");
      this.handleContactCompanyNameMouseOut();
    }
  }
  handleContactLastName(event) {
    this.contactLastName = event.target.value;
    if (this.isPersonAccount) {
      this.contactCompanyName =
        (this.contactFirstName != undefined && this.contactFirstName != ""
          ? this.contactFirstName + " "
          : "") +
        (this.contactLastName != undefined && this.contactLastName != ""
          ? this.contactLastName
          : "");
      this.handleContactCompanyNameMouseOut();
    }
  }
  handleJobTitle(event) {
    this.contactJobTitle = event.target.value;
  }
  handleContactCompanyName(event) {
    this.contactCompanyName = (event.target.value === '' ? null : event.target.value);
  }
  handleContactCompanyNameFocusOut() {
    this.showErrorLabelForCompanyName = (this.contactCompanyName === null || this.contactCompanyName === undefined || this.contactCompanyName === '') && !this.isPersonAccount;
    if(this.showErrorLabelForCompanyName){
      this.companyNameCssClass = this.paddingTop;
      setTimeout(() => {
        this.companyNameCssClass = this.paddingTop + ' ' + this.sldsHasError;
      }, 10);
    }
    else{
      this.companyNameCssClass = this.paddingTop;
    }
  }
  handleContactEmail(event) {
    this.contactEmail = event.target.value;
  }
  handleContactConfirmEmail(event) {
    this.contactConfirmEmail = event.target.value;
  }
  handlePasteConfirmEmail(event) {
    this.contactConfirmEmail = "";
    event.preventDefault();
  }
  handleMainActivity(event) {
    this.mainactivity = event.target.value;
  }
  handleYourOrganization(event) {
    this.yourorganization = event.target.value;
  }
  handleContactMobilePhone(event) {
    this.contactMobilePhone = event.target.value;
  }
  handleSendConfirmation() {
    this.sendConfirmation = !this.sendConfirmation;
  }
  handleSendNewsletter() {
    this.sendNewsletter = !this.sendNewsletter;
  }
  //Address
  handleCountry(event) {
    this.country = event.target.value;
    if(this.initstate === undefined || this.initstate === null || this.initstate.length === 0){
      const evt = new ShowToastEvent({
        title: "Warning",
        message:
          "States are not loaded. You will be allowed to select a state in a few secondes." +
          error,
        variant: "warning"
      });
      this.dispatchEvent(evt);
    }
    else{
      this.searchState();
    }
  }

  searchState(){
    //Search states
    let countryLabel;
    //Get country label
    for (let key in this.countryvalues) {
      // console.log('this.countryvalues[key].value', this.countryvalues[key].value);
      if (this.countryvalues[key].value === this.country) {
        countryLabel = this.countryvalues[key].label;
      }
    }
    //Search state if country is found
    if (
      countryLabel !== undefined &&
      countryLabel !== null &&
      countryLabel !== ""
    ) {
      //Empty state list if country is changed
      this.statevalues = [];
      for (let key in this.initstate) {
        //Search state list according to country label
        if (key === countryLabel) {
          //Fill state list
          for (let state in this.initstate[key]) {
            this.statevalues.push({
              label: this.initstate[key][state],
              value: state
            });
          }
          this.countryIsSelected = false;
          break;
        }
      }
    }
  }

  handleStreet(event) {
    this.street = event.target.value;
  }
  handleZipPostalCode(event) {
    this.zippostalcode = event.target.value;
  }
  handleCity(event) {
    this.city = event.target.value;
  }
  handleState(event) {
    this.state = event.target.value;
  }
  //Asset
  handleAssetSerialNumber(event) {
    this.serialnumber = event.target.value;
  }
  handleProduct(event) {
    this.product = event.target.value;
  }
  handleAssetPurchasedDate(event) {
    this.purchaseddate = event.target.value;
    this.handleAssetPurchasedDateMouseOut();
  }
  handleAssetPurchasedDateMouseOut() {
    if(this.purchaseddate === undefined || this.purchaseddate === null || this.purchaseddate === ''){
      this.purchaseddateCssClass = this.paddingTop + ' ' + this.widthMax + ' ' + this.sldsHasError;
      this.showErrorLabelForPurchasedDate = true;
    }
    else{
      this.purchaseddateCssClass = this.paddingTop + ' ' + this.widthMax;
      this.showErrorLabelForPurchasedDate = false;
    }
  }
  handleAssetPurchasedCompany(event) {
    this.purchasedcompany = event.target.value;
  }
  handleAssetPurchasedCountry(event) {
    this.purchasedcountry = event.target.value;
  }
  checkEmails() {
    if (this.contactEmail != this.contactConfirmEmail) {
      const evt = new ShowToastEvent({
        title: "Error",
        message:
          "Confirm email not match with email field. Please check it before send your request.",
        variant: "error"
      });
      this.dispatchEvent(evt);
      return false;
    }
    return true;
  }
  checkFields() {
    let tabFieldsInError = [];
    //First name
    if (this.contactFirstName === undefined || this.contactFirstName === "") {
      tabFieldsInError.push("Contact first name");
    }
    //Last name
    if (this.contactLastName === undefined || this.contactLastName === "") {
      tabFieldsInError.push("Contact last name");
    }
    //Email
    if (this.contactEmail === undefined || this.contactEmail === "") {
      tabFieldsInError.push("Contact email");
    }
    //Confirm email
    if (
      this.contactConfirmEmail === undefined ||
      this.contactConfirmEmail === ""
    ) {
      tabFieldsInError.push("Contact confirm email");
    }
    //Check confirm email
    if (!this.checkEmails()) {
      tabFieldsInError.push("Email and confirm email not matching.");
    }
    //Mobile phone
    if (
      this.contactMobilePhone === undefined ||
      this.contactMobilePhone === ""
    ) {
      tabFieldsInError.push("Contact mobile phone");
    }
    //Company name
    if (
      this.contactCompanyName === undefined ||
      this.contactCompanyName === ""
    ) {
      tabFieldsInError.push("Company name");
    }
    //Main activity
    if (this.mainactivity === undefined || this.mainactivity === "") {
      tabFieldsInError.push("Main activity");
    }
    //Your organization
    if (this.yourorganization === undefined || this.yourorganization === "") {
      tabFieldsInError.push("Your organization");
    }
    //Country
    if (this.country === undefined || this.country === "") {
      tabFieldsInError.push("Country");
    }
    //Serial number
    if (this.serialnumber === undefined || this.serialnumber === "") {
      tabFieldsInError.push("Serial Number");
    }
    //Purchased date
    if (this.purchaseddate === undefined || this.purchaseddate === "") {
      tabFieldsInError.push("Purchased Date");
    }

    //Display error
    if (tabFieldsInError.length > 0) {
      let str = "";
      for (let key in tabFieldsInError) {
        str += tabFieldsInError[key] + ", ";
      }
      const evt = new ShowToastEvent({
        title: "Error",
        message:
          "Please fill the following fields before save : " +
          str.substring(0, str.length - 2),
        variant: "error"
      });
      this.dispatchEvent(evt);
      this.spinnerDuringSave = false;
      return false;
    } else {
      return true;
    }
  }
  //Call Apex method
  @api handleSaveContactInformations() {
    this.spinnerDuringSave = true;
    if (this.checkFields()) {
      //Save request
      saveRequest({
        isPersonAccount: this.isPersonAccount,
        firstname: this.contactFirstName,
        lastname: this.contactLastName,
        email: this.contactEmail,
        mobilephone: this.contactMobilePhone,
        jobTitle: this.contactJobTitle,
        companyname: this.contactCompanyName,
        country: this.country,
        street: this.street,
        zippostalcode: this.zippostalcode,
        city: this.city,
        state: this.state,
        mainactivity: this.mainactivity,
        yourorganization: this.yourorganization,
        purchasedcompany: this.purchasedcompany,
        purchasedcountry: this.purchasedcountry,
        serialnumber: this.serialnumber,
        product: this.product,
        purchaseddate: this.purchaseddate,
        caseId: this.caseid,
        attachmentId: this.documentId,
        sendConfirmation: this.sendConfirmation,
        sendNewsletter: this.sendNewsletter
      })
        .then(result => {
          let isNotInError = result.isNotInError;
          let theMessage = result.message;
          let theTitle;
          let theVariant;
          if (isNotInError && result.message === CASE_REGISTERED) {
            theTitle = "Success";
            theVariant = "success";
          } else if (
            isNotInError &&
            result.message !== CASE_REGISTERED
          ) {
            theTitle = "Warning";
            theVariant = "warning";
          } else {
            theTitle = "Error";
            theVariant = "error";
          }
          this.dispatchEvent(
            new ShowToastEvent({
              title: theTitle,
              message: theMessage,
              variant: theVariant
            })
          );
          if (isNotInError) {
            this.resetInformation();
          }
          this.spinnerDuringSave = false;
        })
        .catch(error => {
          const evt = new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          });
          this.dispatchEvent(evt);
          this.spinnerDuringSave = false;
        });
    }
  }
  @api handleResetInformations() {
    this.resetInformation();
  }

  resetInformation() {
    this.dispatchEvent(new CustomEvent("refreshview", {}));

    // this.isPersonAccount = false;
    // //Contact attributes
    // this.contactInformations = true;
    // this.contactFirstName = null;
    // this.contactLastName = null;
    // this.contactJobTitle = null;
    // this.contactEmail = null;
    // this.emailRequired = false;
    // this.contactConfirmEmail = null;
    // this.contactMobilePhone = null;
    // this.contactCompanyName = '';
    // this.showErrorLabelForCompanyName = false;
    // this.companyNameCssClass = this.paddingTop;
    // this.companyNameIsRequired = true;
    // //Address
    // // this.countryvalues = [];
    // this.countryIsSelected = true;
    // this.stateNotLoaded = true;
    // // this.initstate = [];
    // // this.statevalues = [];
    // // this.mainactivtyvalues = [];
    // this.mainactivty = null;
    // // this.yourorganizationvalues = [];
    // this.yourorganization = "";
    // this.country = null;
    // this.street = null;
    // this.zippostalcode = null;
    // this.city = null;
    // this.state = null;
    // //Asset
    // this.product = null;
    // this.serialnumber = null;
    // this.purchaseddate = null;
    // this.purchaseddateCssClass = this.paddingTop + ' ' + this.widthMax;
    // this.showErrorLabelForPurchasedDate = false;
    // this.purchasedcompany = null;
    // this.purchasedcountry = null;
    // //Wrapper
    // this.wrapperInformations = null;
    // //Spinner
    // this.spinnerDuringSave = true;
    // this.refreshView = true;
    // //Send confirmation/newsletter
    // this.sendConfirmation = true;
    // this.sendNewsletter = false;

    // setTimeout(() => {
    //     this.emailRequired = true;
    // }, 10);
  }
}