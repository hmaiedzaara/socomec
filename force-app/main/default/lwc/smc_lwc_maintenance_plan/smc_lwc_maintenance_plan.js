import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Labels
import JANUARY from "@salesforce/label/c.SMC_January";
import FEBRUARY from "@salesforce/label/c.SMC_February";
import MARCH from "@salesforce/label/c.SMC_March";
import APRIL from "@salesforce/label/c.SMC_April";
import MAY from "@salesforce/label/c.SMC_May";
import JUNE from "@salesforce/label/c.SMC_June";
import JULY from "@salesforce/label/c.SMC_July";
import AUGUST from "@salesforce/label/c.SMC_August";
import SEPTEMBER from "@salesforce/label/c.SMC_September";
import OCTOBER from "@salesforce/label/c.SMC_October";
import NOVEMBER from "@salesforce/label/c.SMC_November";
import DECEMBER from "@salesforce/label/c.SMC_December";
// import ALL_MONTHS from "@salesforce/label/c.SMC_All_Months";
import MONTH_SELECTOR from "@salesforce/label/c.SMC_Maintenance_Plan_Month_Selector";
import SAVE from "@salesforce/label/c.SMC_Save";
//Method Apex
import checkInformationsAndLaunchMaintenancePlans from "@salesforce/apex/SMC_AC_Maintenance_Plan.checkInformationsAndLaunchMaintenancePlans";
import sendInformationsToFlow from "@salesforce/apex/SMC_AC_Maintenance_Plan.sendInformationsToFlow";

export default class Smc_lwc_maintenance_plan extends LightningElement {

    customLabels = {
        JANUARY, 
        FEBRUARY,
        MARCH,
        APRIL,
        MAY,
        JUNE,
        JULY,
        AUGUST,
        SEPTEMBER,
        OCTOBER,
        NOVEMBER,
        DECEMBER,
        // ALL_MONTHS,
        MONTH_SELECTOR,
        SAVE
    };

    @api recordid;
    @track initMaintenancePlanIsWorking = false;

    @track JANUARYCheckbox = false;
    @track FEBURARYCheckbox = false;
    @track MARCHCheckbox = false;
    @track APRILCheckbox = false;
    @track MAYCheckbox = false;
    @track JUNECheckbox = false;
    @track JULYCheckbox = false;
    @track AUGUSTCheckbox = false;
    @track SEPTEMBERCheckbox = false;
    @track OCTOBERCheckbox = false;
    @track NOVEMBERCheckbox = false;
    @track DECEMBERCheckbox = false;
    // @track allMonths = false;
    @track monthsSelected = [];

    connectedCallback(){
        this.initMaintenancePlanIsWorking = true;
        checkInformationsAndLaunchMaintenancePlans({serviceContractId : this.recordid})
        .then(result => {
            if(result !== null && 
               result !== undefined && 
               result['error'] !== '' && 
               result['error'] !== null && 
               result['error'] !== undefined){
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: result['error'],
                    variant: "error"
                });
                this.dispatchEvent(evt);
            }
            else if(result !== null && 
                    result !== undefined && 
                    result['warning'] !== '' && 
                    result['warning'] !== null && 
                    result['warning'] !== undefined){
                const evt = new ShowToastEvent({
                    title: "Warning",
                    message: result['warning'],
                    variant: "warning"
                });
                this.dispatchEvent(evt);
            }
            this.initMaintenancePlanIsWorking = false;
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: "Error",
                message:
                    error,
                variant: "error"
                });
            this.dispatchEvent(evt);
            this.initMaintenancePlanIsWorking = false;
        });
    }

    handleJANUARYCheckbox(){
        this.JANUARYCheckbox = !this.JANUARYCheckbox;
    }
    handleFEBURARYCheckbox(){
        this.FEBURARYCheckbox = !this.FEBURARYCheckbox;
    }
    handleMARCHCheckbox(){
        this.MARCHCheckbox = !this.MARCHCheckbox;
    }
    handleAPRILCheckbox(){
        this.APRILCheckbox = !this.APRILCheckbox;
    }
    handleMAYCheckbox(){
        this.MAYCheckbox = !this.MAYCheckbox;
    }
    handleJUNECheckbox(){
        this.JUNECheckbox = !this.JUNECheckbox;
    }
    handleJULYCheckbox(){
        this.JULYCheckbox = !this.JULYCheckbox;
    }
    handleAUGUSTCheckbox(){
        this.AUGUSTCheckbox = !this.AUGUSTCheckbox;
    }
    handleSEPTEMBERCheckbox(){
        this.SEPTEMBERCheckbox = !this.SEPTEMBERCheckbox;
    }
    handleOCTOBERCheckbox(){
        this.OCTOBERCheckbox = !this.OCTOBERCheckbox;
    }
    handleNOVEMBERCheckbox(){
        this.NOVEMBERCheckbox = !this.NOVEMBERCheckbox;
    }
    handleDECEMBERCheckbox(){
        this.DECEMBERCheckbox = !this.DECEMBERCheckbox;
    }
    // handleSelectAllMonths(){
    //     this.allMonths = !this.allMonths;
    //     // this.JANUARYCheckbox = this.allMonths;
    //     // this.FEBURARYCheckbox = this.allMonths;
    //     // this.MARCHCheckbox = this.allMonths;
    //     // this.APRILCheckbox = this.allMonths;
    //     // this.MAYCheckbox = this.allMonths;
    //     // this.JUNECheckbox = this.allMonths;
    //     // this.JULYCheckbox = this.allMonths;
    //     // this.AUGUSTCheckbox = this.allMonths;
    //     // this.SEPTEMBERCheckbox = this.allMonths;
    //     // this.OCTOBERCheckbox = this.allMonths;
    //     // this.NOVEMBERCheckbox = this.allMonths;
    //     // this.DECEMBERCheckbox = this.allMonths;
    //     this.template.querySelectorAll('lightning-input').forEach(element => {
    //         element.value = this.allMonths;
    //     });
    //     console.log('this.allMonths', this.allMonths);
    //     console.log('this.JANUARYCheckbox', this.JANUARYCheckbox);
    // }

    checkInputs(){
        let atLeastOnMonthSelected = false;
        if(this.JANUARYCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(1);
        }
        if(this.FEBURARYCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(2);
        }
        if(this.MARCHCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(3);
        }
        if(this.APRILCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(4);
        }
        if(this.MAYCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(5);
        }
        if(this.JUNECheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(6);
        }
        if(this.JULYCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(7);
        }
        if(this.AUGUSTCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(8);
        }
        if(this.SEPTEMBERCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(9);
        }
        if(this.OCTOBERCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(10);
        }
        if(this.NOVEMBERCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(11);
        }
        if(this.DECEMBERCheckbox){
            atLeastOnMonthSelected = true;
            this.monthsSelected.push(12);
        }

        return atLeastOnMonthSelected;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('closequickaction');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleSaveFrequency(){
        if(this.checkInputs()){
            this.initMaintenancePlanIsWorking = true;
            sendInformationsToFlow({
                serviceContractId : this.recordid,
                monthsSelected: this.monthsSelected
            })
            .then(result => {
                if(result){
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: 'The maintenance plan is initiate.',
                        variant: "success"
                        });
                    this.dispatchEvent(evt);
                }
                else{
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message:
                            error,
                        variant: "error"
                        });
                    this.dispatchEvent(evt);
                }
                this.initMaintenancePlanIsWorking = false;
                this.closeQuickAction();
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message:
                        error,
                    variant: "error"
                    });
                this.dispatchEvent(evt);
                this.initMaintenancePlanIsWorking = false;
                this.closeQuickAction();
            });
        }
        else{
            const evt = new ShowToastEvent({
                title: "Selection missing",
                message: 'Select at least one month to pass to the next step.',
                variant: "error"
                });
            this.dispatchEvent(evt);
        }
    }
}