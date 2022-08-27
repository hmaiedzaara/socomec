import { LightningElement, track } from "lwc";
import LEGEND from "@salesforce/label/c.SMC_Legend";
import LEGEND_TEXT from "@salesforce/label/c.SMC_PS_AssetLibrary_Legend";
import FILTERS from "@salesforce/label/c.SMC_Filters";
import DOCUMENT_LIST from "@salesforce/label/c.SMC_Document_List";
import LABEL_NONE from "@salesforce/label/c.SMC_DefaultPicklistValue_None";
import TARGET from "@salesforce/label/c.SMC_Target";
import DISTRIBUTOR from "@salesforce/label/c.SMC_Distributor";
import SPECIFIER from "@salesforce/label/c.SMC_Specifier";
import BA from "@salesforce/label/c.SMC_BA";
import PRODUCT_FAMILY from "@salesforce/label/c.SMC_Product_Family";
import DOCUMENT_TYPE from "@salesforce/label/c.SMC_Document_Type";
import LANGUAGE from "@salesforce/label/c.SMC_Language";
import SEARCH_BY_NAME from "@salesforce/label/c.SMC_Search_By_Name";
import SORT_BY from "@salesforce/label/c.SMC_Sort_By";
import NO_RESULT from "@salesforce/label/c.SMC_No_Result";
import initAll from "@salesforce/apex/SMC_AC_Marketing_Library.initAll";
import resetProductFamily from "@salesforce/apex/SMC_AC_Marketing_Library.resetProductFamily";
import getDocumentList from "@salesforce/apex/SMC_AC_Marketing_Library.getDocumentList";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class SMC_LWC_Markenting_Library extends LightningElement {
  //Custom labels
  legend = { LEGEND };
  legendText = { LEGEND_TEXT };
  @track legendParagraph1;
  @track legendParagraph2;
  filters = { FILTERS };
  filtersCapitalLetters;
  documentList = { DOCUMENT_LIST };
  labelNone = { LABEL_NONE };
  targetLabel = { TARGET };
  // distributor = { DISTRIBUTOR };
  // specifier = { SPECIFIER };
  ba = { BA };
  productFamily = { PRODUCT_FAMILY };
  documentType = { DOCUMENT_TYPE };
  language = { LANGUAGE };
  searchByName = { SEARCH_BY_NAME };
  sortBy = { SORT_BY };
  noResultLabel = { NO_RESULT };
  //Data
  @track error = "";
  @track parseResult;
  @track mapDocDisplay;
  @track searching = true;
  @track refreshDesktopFilter = true;
  @track noResult = false;
  //Filters
  listTarget = [DISTRIBUTOR, SPECIFIER];
  @track targetSelected = this.listTarget[0];
  @track mapPicklistBA = [];
  @track mapPicklistProductFamily;
  displayNone = "displayNone";
  displayInherit = "displayInherit";
  @track searchNameSelector = "displayNone";
  @track targetSelector = "displayNone";
  @track baSelector = "displayNone";
  @track productFamilySelector = "displayNone";
  @track mapPicklistDocType;
  @track documentTypeSelector = "displayNone";
  @track mapPicklistLanguage;
  @track languageSelector = "displayNone";
  //New filtrage
  @track queryTerm = "";
  @track baSelected = "";
  @track productFamilySelected = "";
  @track docTypeSelected = "";
  @track languageSelected = "";
  @track offsetSelector = 0;
  //Sort
  @track sortList = [];
  @track filterByLastVersionDate = "desc";
  @track filterByName;
  //Pagination
  @track totalrecords;
  @track currentpage = 1;
  @track pagesize;
  @track pagecurrentonmaxpages;
  lastpage = false;
  firstpage = false;

  /** INIT **/
  connectedCallback() {
    this.searching = true;
    this.legendParagraph1 = this.legendText.LEGEND_TEXT.split("<br/>")[0];
    this.legendParagraph2 = this.legendText.LEGEND_TEXT.split("<br/>")[1];
    this.filtersCapitalLetters = FILTERS.toUpperCase();
    this.initAllSelection();
  }

  /** INIT FUNCTION **/
  initAllSelection() {
    initAll({ target: this.targetSelected, ba: this.baSelected })
      .then(result => {
        console.log('result', JSON.parse(JSON.stringify(result)));
        this.parseResult = JSON.parse(JSON.stringify(result));
        this.mapDocDisplay = this.parseResult.docList.documents;
        this.mapPicklistProductFamily = this.parseResult.productFamily.children;
        this.mapPicklistBA = this.parseResult.bas.children;
        this.baSelected = this.mapPicklistBA[0].id;
        this.mapPicklistDocType = this.parseResult.docType.objects;
        this.mapPicklistLanguage = this.parseResult.language.objects;
        this.totalrecords = this.parseResult.docList.nbDocuments;
        this.pagesize = this.parseResult.actualLimit;
        this.sortList = this.parseResult.sortList.objects;
        //Input
        if (this.totalrecords === 0) {
          this.noResult = true;
        } else {
          this.noResult = false;
        }
        let nbOfPages = Math.ceil(this.totalrecords / this.pagesize);
        this.pagecurrentonmaxpages =
          (nbOfPages > 0 ? this.currentpage : "0") + "/" + nbOfPages;
        this.searching = false;
      })
      .catch(error => {
        this.error += JSON.stringify(error) + "\n";
        this.searching = false;
        console.log("error initAll", this.error);
      });
  }

  /** BA change **/
  baIsChanged() {
    this.refreshDesktopFilter = false;
    resetProductFamily({
      target: this.targetSelected,
      baSelected: this.baSelected,
      docType: "",
      language: "",
      textSearch: "",
      filterByLastVersionDate: this.filterByLastVersionDate,
      filterByName: this.filterByName
    })
      .then(result => {
        this.productFamilySelected = "";
        this.mapPicklistProductFamily = [];

        this.parseResult.docList = JSON.parse(JSON.stringify(result)).docList;
        this.parseResult.productFamily = JSON.parse(
          JSON.stringify(result)
        ).productFamily;
        this.mapDocDisplay = JSON.parse(
          JSON.stringify(result)
        ).docList.documents;
        this.mapPicklistProductFamily = JSON.parse(
          JSON.stringify(result)
        ).productFamily.children;
        this.totalrecords = JSON.parse(
          JSON.stringify(result)
        ).docList.nbDocuments;
        this.currentpage = 1;
        this.offsetSelector = 0;
        //Input
        if (this.totalrecords === 0) {
          this.noResult = true;
        } else {
          this.noResult = false;
        }
        // let nbOfPages = Math.ceil(this.totalrecords / this.pagesize);
        // this.pagecurrentonmaxpages =
        //   (nbOfPages > 0 ? this.currentpage : "0") + "/" + nbOfPages;
        //Reset fields
        this.docTypeSelected = "";
        this.languageSelected = "";
        this.refreshDesktopFilter = true;
        this.searching = false;
      })
      .catch(error => {
        this.error += JSON.stringify(error) + "\n";
        this.searching = false;
        console.log("error resetProductFamily", this.error);
      });
  }

  /** Get doc list **/
  getDocList() {
    this.searching = true;
    getDocumentList({
      target: this.targetSelected,
      baSelected: this.baSelected,
      productFamily: this.productFamilySelected,
      docType: this.docTypeSelected,
      language: this.languageSelected,
      offset: this.offsetSelector,
      textSearch: this.queryTerm,
      filterByLastVersionDate: this.filterByLastVersionDate,
      filterByName: this.filterByName,
      frtomReset: false
    })
      .then(result => {
        console.log('result', JSON.parse(JSON.stringify(result)));
        this.parseResult.docList = JSON.parse(JSON.stringify(result)).docList;
        this.mapDocDisplay = JSON.parse(
          JSON.stringify(result)
        ).docList.documents;
        this.totalrecords = JSON.parse(
          JSON.stringify(result)
        ).docList.nbDocuments;
        //Input
        if (this.totalrecords === 0) {
          this.noResult = true;
        } else {
          this.noResult = false;
        }
        let nbOfPages = Math.ceil(this.totalrecords / this.pagesize);
        this.pagecurrentonmaxpages =
          (nbOfPages > 0 ? this.currentpage : "0") + "/" + nbOfPages;
        this.searching = false;
      })
      .catch(error => {
        this.error += JSON.stringify(error) + "\n";
        this.searching = false;
        console.log("error getDocumentList", this.error);
      });
  }

  handleSelectTarget(event) {
    this.searching = true;
    this.targetSelected = JSON.parse(JSON.stringify(event.target.value));
    this.initAllSelection();
  }

  handlePicklistBa(event) {
    this.searching = true;
    this.baSelected = event.target.value;
    this.productFamilySelected = "";
    this.baIsChanged();
  }

  handlePicklistProductFamily(event) {
    // this.searching = true;
    if (event.target.value === this.labelNone.LABEL_NONE) {
      this.productFamilySelected = "";
    } else {
      this.productFamilySelected = event.target.value;
    }
    this.getDocList();
  }

  handlePicklistDocType(event) {
    // this.searching = true;
    if (event.target.value === this.labelNone.LABEL_NONE) {
      this.docTypeSelected = "";
    } else {
      this.docTypeSelected = event.target.value;
    }
    this.getDocList();
  }

  handlePicklistLanguage(event) {
    // this.searching = true;
    if (event.target.value === this.labelNone.LABEL_NONE) {
      this.languageSelected = "";
    } else {
      this.languageSelected = event.target.value;
    }
    this.getDocList();
  }

  handleKeyUp(event) {
    // this.searching = true;
    this.queryTerm = event.target.value.toUpperCase();
    this.getDocList();
  }

  handleSelectLanguageForTheDoc(event) {
    window.open(event.target.value);
  }

  handleSort(event) {
    // this.searching = true;
    if (event.target.value === "dateAsc") {
      this.filterByLastVersionDate = "asc";
      this.filterByName = null;
    } else if (event.target.value === "dateDesc") {
      this.filterByLastVersionDate = "desc";
      this.filterByName = null;
    } else if (event.target.value === "nameAsc") {
      this.filterByLastVersionDate = null;
      this.filterByName = "asc";
    } else if (event.target.value === "nameDesc") {
      this.filterByLastVersionDate = null;
      this.filterByName = "desc";
    }
    this.getDocList();
  }

  /** PAGINATION **/
  get showFirstButton() {
    if (this.currentpage <= 1) {
      return true;
    }
    return false;
  }

  get showLastButton() {
    if (this.currentpage >= Math.ceil(this.totalrecords / this.pagesize)) {
      return true;
    }
    return false;
  }
  //Fire events based on the button actions
  handlePrevious() {
    this.searching = true;
    --this.currentpage;
    if (this.currentpage < 1) {
      this.currentpage = 1;
    }
    this.offsetSelector = this.currentpage - 1;
    this.getDocList();
  }

  handleNext() {
    ++this.currentpage;
    if (this.currentpage >= Math.ceil(this.totalrecords / this.pagesize)) {
      this.currentpage = Math.ceil(this.totalrecords / this.pagesize);
    }
    this.offsetSelector = this.currentpage - 1;
    this.getDocList();
  }

  handleFirst() {
    this.searching = true;
    this.currentpage = 1;
    this.offsetSelector = this.currentpage - 1;
    this.getDocList();
  }

  handleLast() {
    this.searching = true;
    this.currentpage = Math.ceil(this.totalrecords / this.pagesize);
    this.offsetSelector = this.currentpage - 1;
    this.getDocList();
  }

  /** RESPONSIVE FUNCTION **/
  toggleFilterSearchName() {
    if (this.searchNameSelector === this.displayNone) {
      //close other tab
      this.searchNameSelector = this.displayInherit;
      this.targetSelector = this.displayNone;
      this.productFamilySelector = this.displayNone;
      this.documentTypeSelector = this.displayNone;
      this.languageSelector = this.displayNone;
      this.baSelector = this.displayNone;
    } else {
      this.searchNameSelector = this.displayNone;
    }
  }

  toggleFilterBA() {
    if (this.baSelector === this.displayNone) {
      this.baSelector = this.displayInherit;
      //close other tab
      this.searchNameSelector = this.displayNone;
      this.targetSelector = this.displayNone;
      this.productFamilySelector = this.displayNone;
      this.documentTypeSelector = this.displayNone;
      this.languageSelector = this.displayNone;
    } else {
      this.baSelector = this.displayNone;
    }
  }

  toggleFilterProductFamily() {
    if (this.productFamilySelector === this.displayNone) {
      this.productFamilySelector = this.displayInherit;
      //close other tab
      this.searchNameSelector = this.displayNone;
      this.targetSelector = this.displayNone;
      this.baSelector = this.displayNone;
      this.documentTypeSelector = this.displayNone;
      this.languageSelector = this.displayNone;
    } else {
      this.productFamilySelector = this.displayNone;
    }
  }
  toggleFilterDocumentType() {
    if (this.documentTypeSelector === this.displayNone) {
      this.documentTypeSelector = this.displayInherit;
      //close other tab
      this.searchNameSelector = this.displayNone;
      this.targetSelector = this.displayNone;
      this.baSelector = this.displayNone;
      this.productFamilySelector = this.displayNone;
      this.languageSelector = this.displayNone;
    } else {
      this.documentTypeSelector = this.displayNone;
    }
  }

  toggleFilterLanguage() {
    if (this.languageSelector === this.displayNone) {
      this.languageSelector = this.displayInherit;
      //close other tab
      this.searchNameSelector = this.displayNone;
      this.targetSelector = this.displayNone;
      this.baSelector = this.displayNone;
      this.productFamilySelector = this.displayNone;
      this.documentTypeSelector = this.displayNone;
    } else {
      this.languageSelector = this.displayNone;
    }
  }
  toggleFilterTarget() {
    if (this.targetSelector === this.displayNone) {
      this.targetSelector = this.displayInherit;
      //close other tab
      this.searchNameSelector = this.displayNone;
      this.baSelector = this.displayNone;
      this.productFamilySelector = this.displayNone;
      this.documentTypeSelector = this.displayNone;
    } else {
      this.targetSelector = this.displayNone;
    }
  }

  sendToAuraParent(event) {
    const selectedEvent = new CustomEvent("sendtoga", {
      detail: { data: event.detail }
    });
    this.dispatchEvent(selectedEvent);
  }
}