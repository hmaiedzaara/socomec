/**
 * @description       : This is an text input receving a list of values to perform an autocomplete text input
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-26-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-26-2020   Vincent RECASENS (Modis)   Initial Version
 **/
import { LightningElement, api, track } from "lwc";
import SELECT from "@salesforce/label/c.SMC_Select";

export default class Smc_lwc_autocompleteinput extends LightningElement {
  @api label = "";
  @api value = "";
  @api placeholder = "";
  @api required = false;
  @api listvalues = [];
  @api cdparlist = [];

  customLabels = {SELECT};

  @track initialized = false;
  @track isEdge = false;


  elmtClose = 'slds-form-element slds-lookup slds-is-close';
  elmtOpen = 'slds-form-element slds-lookup slds-is-open';
  @track elmtCss = this.elmtClose;
  @track selectedRecord;
  @track searchKeyWord;


  renderedCallback() {
    if (this.initialized) {
      return;
    }
    this.initialized = true;
    this.value = '';
    this.checkBrowser();
    let listId = this.template.querySelector("datalist").id;
    this.template.querySelector("input").setAttribute("list", listId);
  }
  checkBrowser() {
    let context = this;
    var browserType = navigator.sayswho= (function(){
        var ua= navigator.userAgent, tem,
            M= ua.match(/(opera|edge|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
        if(/trident/i.test(M[1])){
            tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
            // alert("IE"+'IE '+(tem[1] || ''));
            // return 'IE '+(tem[1] || '');
        }
        let mInputSplited = M.input.split(' ');
        let tabSize = mInputSplited.length - 1;
        if(mInputSplited[tabSize].includes('Edg')){
          context.isEdge = true;
          context.value = null;
        }
        else if(M[1]=== 'Chrome'){
            tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
            if(tem!= null){
              return tem.slice(1).join(' ').replace('OPR', 'Opera');
            }
            // alert('chrome');
        }
        M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
        if((tem= ua.match(/version\/(\d+)/i))!= null){
          M.splice(1, 1, tem[1]);
        }
        // return M.join(' ');
    })();
    // if (browserType.startsWith("IE")) {
        // component.set("v.isIE", true);
        // alert("IE");
    // }
  }

  //Send selected value to the parent cmp and empty the input
  handleChange(event) {
    if (this.cdparlist.includes(event.target.value)) {
      // Send event to parent
      const selectedEvent = new CustomEvent("elementselected", {
        detail: event.target.value
      });
      this.dispatchEvent(selectedEvent);
      this.value = "";
    }
  }
}