import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccounts from "@salesforce/apex/SMC_AC_DORA_Management.getAccounts";
import getSpecificAccount from "@salesforce/apex/SMC_AC_DORA_Management.getSpecificAccount";
import getStaticInformations from "@salesforce/apex/SMC_AC_DORA_Management.getStaticInformations"; //Country code 
import getStates from "@salesforce/apex/SMC_AC_DORA_Management.getStates"; // States
import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";
import ACCOUNT from "@salesforce/label/c.SMC_Account";
import GENERAL_INFORMATIONS from "@salesforce/label/c.SMC_General_Informations";
import SHIPMENT_DETAILS from "@salesforce/label/c.SMC_Shipment_Details";
import SELECT_ACCOUNT from "@salesforce/label/c.SMC_Select_Account";
import SELECT_ADDRESS from "@salesforce/label/c.SMC_Select_Address";
import YOUR_REFERENCE from "@salesforce/label/c.SMC_Your_Reference";
import CONTACT_NAME from "@salesforce/label/c.SMC_Contact_Name";
import CONTACT_PHONE from "@salesforce/label/c.SMC_Contact_Phone";
import REQ_DEL_DATE from "@salesforce/label/c.SMC_Requested_Delivery_Date";
import PREF_TIME from "@salesforce/label/c.SMC_Prefered_Time";
import TAIL_LIFT from "@salesforce/label/c.SMC_Tail_Lift";
import RESET from "@salesforce/label/c.SMC_Reset";
import NEW_ADDRESS from "@salesforce/label/c.SMC_NEW_ADDRESS";

export default class Smc_lwc_neworder_generalinformation extends LightningElement {
  //Labels
  chooseHereLabel = { CHOOSE_HERE };
  accountLabel = { ACCOUNT };
  generalInformationsLabel = { GENERAL_INFORMATIONS };
  shimpentDetailsLabel = { SHIPMENT_DETAILS };
  selectAccountLabel = { SELECT_ACCOUNT };
  selectAddressLabel = { SELECT_ADDRESS };
  yourReferenceLabel = { YOUR_REFERENCE };
  contactNameLabel = { CONTACT_NAME };
  contactPhoneLabel = { CONTACT_PHONE };
  reqDelDateLabel = { REQ_DEL_DATE };
  preftimeLabel = { PREF_TIME };
  tailliftLabel = { TAIL_LIFT };
  resetLabel = { RESET };
  newAddress = { NEW_ADDRESS };

  //Cache
  @api cacheinfos;
  //Account
  @track accountIsSelected = false;
  @track haveOnlyOneAccount = false;
  @track accounts = [];
  @track accountKeys = [];
  @track accountsMap = new Map();
  @track specificAccount;
  //Address
  @track haveOnlyOneAddress = false;
  @track addresses = [];
  @track selectNewAddress = false;
  @track addressFromCache = false;
  @track specificAddress;
  @track countryvalues = [];
  @track countryIsSelected = true;
  @track initstate = [];
  @track statevalues = [];
  @track country;
  //Taillift
  // tailliftOptions = [
  //   { label: "No", value: "no" },
  //   { label: "Yes", value: "yes" }
  // ];
  @track taillift = false;
  @track tailliftLabelValue;

  //Cache
  @track custRef;
  @track reqDate;
  @track contactName;
  @track contactPhone;
  @track prefTime;
  @track note;

  connectedCallback() {
    this.getAllAccounts();
  }

  /* CACHE MANAGEMENT */
  setDataFromCache(){
    let cacheinfos = JSON.parse(JSON.stringify(this.cacheinfos));
    this.custRef = cacheinfos.custref;
    this.reqDate = cacheinfos.requestedDeliveryDate;
    this.contactName = cacheinfos.contactname;
    this.contactPhone = cacheinfos.contactphone;
    this.prefTime = cacheinfos.preftime;
    this.taillift = cacheinfos.taillift;
    this.tailliftLabelValue = this.taillift ? 'yes' : 'no';
    this.note = cacheinfos.note;
    this.specificAccount = cacheinfos.specificAccount;
    this.specificAddress = cacheinfos.specificAddress;
    if ((this.specificAccount !== null && this.specificAccount !== undefined) || this.accounts.length === 1) {
      this.haveOnlyOneAccount = true;
      this.accountIsSelected = true;
      this.addresses = JSON.parse(
        JSON.stringify(this.specificAccount)
      ).addresses;
      if(this.specificAddress !== null){
        this.getAddressFromCache();
      }
      else{
        this.accountIsSelected = true;
      }
    }
  }
  getAddressFromCache(){
    this.addressFromCache = true;
    let add = JSON.parse(JSON.stringify(this.addresses));
    this.addresses = [];
    let cacheinfosAddress = JSON.parse(JSON.stringify(this.cacheinfos.specificAddress));
    for (let key in add) {
      if (cacheinfosAddress.isNewAddress !== true && add[key].ADDRESSCODE === this.cacheinfos.specificAddress.ADDRESSCODE) {
        this.specificAddress = add[key];
        this.sendToParent("addressselected", this.specificAddress);
      }
      else{
        this.addresses.push(add[key]);
      }
    }
    if(cacheinfosAddress.isNewAddress){
      this.selectNewAddress = true;
      this.handleNewAddress(true);
    }
  }

  /* ACCOUNT */
  accountSelector(event) {
    this.specificAccount = this.accountsMap.get(event.target.value);
    if (this.specificAccount !== undefined) {
      this.getSpecificAccountInformation();
    }
  }

  /* CONTACT */
  //Name
  handleContactName(event) {
    this.sendToParent("contactnameselected", event.target.value);
  }
  //Phone
  handleContactPhone(event) {
    this.sendToParent("contactphoneselected", event.target.value);
  }
  /* CUST REF */
  handleCustRef(event) {
    this.sendToParent("custrefselected", event.target.value);
  }
  /* REQUESTED DATE */
  handleRequestedDeliveryDate(event) {
    this.sendToParent("requesteddeliverydateselected", event.target.value);
  }
  /* PREF TIME */
  handlePreftime(event) {
    this.sendToParent("preftimeselected", event.target.value);
  }
  /* ADDRESS */
  addressSelector(event) {
    //Check cache
    if(this.addressFromCache){
      this.addresses.unshift(this.specificAddress);
      this.addressFromCache = false;
    }
    //Address management
    let add = JSON.parse(JSON.stringify(this.addresses));
    for (let key in add) {
      if (add[key].ADDRESSCODE === event.target.value) {
        this.selectNewAddress = false;
        this.specificAddress = add[key];
      }
    }
    //New address management
    if (NEW_ADDRESS === event.target.value) {
      this.selectNewAddress = true;
      this.handleNewAddress(false);
    }
    if (this.specificAddress !== undefined) {
      this.sendToParent("addressselected", this.specificAddress);
    }
  }

  handleNewAddress(getForcache) {
    //get country and states
    getStaticInformations({})
      .then(result => {
        let parsedResult = JSON.parse(JSON.stringify(result));
        this.wrapperInformations = parsedResult;
        this.countryvalues = parsedResult.countries;
        if(getForcache){
          let cacheinfosAddress = JSON.parse(JSON.stringify(this.cacheinfos.specificAddress));
          const address = this.template.querySelector('lightning-input-address');
          address.street = cacheinfosAddress.ADDRESS;
          address.city = cacheinfosAddress.CITY;
          address.postalCode = cacheinfosAddress.ZIPCODE;
          address.province = cacheinfosAddress.PROV;
          address.country = cacheinfosAddress.COUNTRY;
          this.handleChangeNewAddress();
        }
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
      });
  }

  handleChangeNewAddress(){
    const address =
        this.template.querySelector('lightning-input-address');
    const companyName = this.template.querySelector('.companyName');
    var companyNameNA = this.specificAccount.COMPANYNAME; //company name for New Address

    if (companyName.value !== '' && companyName.value !== null && companyName.value !== undefined) {
      companyNameNA = companyName.value;
    } 

    //creation of the new address
    if(address.street || address.city || address.country || address.postalCode ) {
      // let concatAddress = (address.street !== null)
      this.specificAddress = { 
        COMPANYNAME: companyNameNA,
        ADDRESS : address.street ,
        CITY: address.city,
        ZIPCODE: address.postalCode,
        PROV: address.province,
        COUNTRY: address.country,
        concatAddress: [this.specificAccount.COMPANYNAME, address.street + ',' + address.postalCode + ' ' + address.city , address.province +' '+ address.country].join(';'),
        formattedAddress: [this.specificAccount.COMPANYNAME, address.street + ',' + address.postalCode ,address.province + ' ' +address.country ],
        isNewAddress: true
      } ;
    }
    
    // this.handleCountry(address.country);
    this.country = address.country;
    if(address.country === null || address.country === "" || address.country === undefined) {
      address.setCustomValidityForField('Complete this field', 'country');
    }
    else {
      address.setCustomValidityForField("", 'country');  
    }

    if (address.province.length > 2) {
      address.setCustomValidityForField('max character : 2 ', 'province');
    } else {
      address.setCustomValidityForField("", 'province');  
    }
    
    if (address.street.length > 35) {
      address.setCustomValidityForField('max character : 35 ', 'street');
    } else {
      address.setCustomValidityForField("", 'street');  
    }

    if (address.city.length > 35) {
      address.setCustomValidityForField('max character : 35 ', 'city');
    } else {
      address.setCustomValidityForField("", 'city');  
    }

    if (address.postalCode.length > 9) {
      address.setCustomValidityForField('max character : 9 ', 'postalCode');
    } else {
      address.setCustomValidityForField("", 'postalCode');  
    }
    if (this.specificAddress !== undefined && address.street.length < 35 && address.city.length < 35 && address.postalCode.length < 9 && (address.province === null || address.province.length <= 2 || address.province === undefined)) {
      this.sendToParent("addressselected", this.specificAddress);
    }
  }

  handleCountry(event) {
    this.country = event;
    getStates({})
        .then(result => {
          let parsedResult = JSON.parse(JSON.stringify(result));
          this.initstate = parsedResult.statesDepenciesAndValues;
          this.searchState();
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
        })      
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

    //If country has no state
    if (this.statevalues.length === 0) {
      this.countryIsSelected = true;
    }
  }

  /* TAIL-LIFT */
  handleTaillift(event) {
    this.tailliftLabelValue = event.target.value;
    this.taillift = this.tailliftLabelValue === 'yes' ? true : false;
    this.sendToParent("tailliftselected", event.target.value);
  }

  /* TAIL-LIFT */
  handleNote(event) {
    this.sendToParent("noteselected", event.target.value);
  }

  sendToParent(eventName, detail) {
    // Send event to parent
    const selectedEvent = new CustomEvent(eventName, {
      detail: detail
    });
    this.dispatchEvent(selectedEvent);
  }

  /* CALL SERVER */
  getAllAccounts() {
    getAccounts()
      .then(result => {
        this.accounts = JSON.parse(result).getAccounts.data;
        for (let key in this.accounts) {
          this.accountKeys.push(this.accounts[key].CDCLI);
          this.accountsMap.set(this.accounts[key].CDCLI, this.accounts[key]);
        }
        if(this.cacheinfos !== null && this.cacheinfos !== undefined){
          this.setDataFromCache();
        }
        else if (this.accounts.length === 1) {
          this.specificAccount = JSON.parse(result).getAccounts.data[0];
          this.haveOnlyOneAccount = true;
          this.getSpecificAccountInformation();
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
  }

  getSpecificAccountInformation() {
    getSpecificAccount({
      cdcli: JSON.parse(JSON.stringify(this.specificAccount)).CDCLI
    })
      .then(result => {
        if (!JSON.parse(result).getSpecificAccount.error) {
          this.accountIsSelected = true;
          this.specificAccount = JSON.parse(result).getSpecificAccount.data;
          this.sendToParent("accountselected", this.specificAccount);
          this.addresses = JSON.parse(
            JSON.stringify(this.specificAccount)
          ).addresses;
          if (this.addresses.length === 1) {
            this.specificAddress = this.addresses[0];
            this.haveOnlyOneAddress = true;
            this.sendToParent("addressselected", this.specificAddress);
          }
        } else {
          this.accountIsSelected = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: JSON.parse(result).getSpecificAccount.message,
              variant: "warning"
            })
          );
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
}