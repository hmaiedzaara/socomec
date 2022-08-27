import { LightningElement, track, api } from "lwc";
import getInformations from "@salesforce/apex/SMC_AC_PipeSummarize.getInformations";

export default class Smc_lwc_pipe_summarize extends LightningElement {
  @api title;
  @api elementSelectedForPipe;
  @track displayPortfolioOrProjectPortfolio = false;
  @track amount;
  @track elementNbs;
  @track userDefaultCurrency;

  connectedCallback() {
    getInformations({ elementSelectedForPipe: this.elementSelectedForPipe })
      .then(result => {
        if (result) {
          this.amount = result.amountPipe;
          this.elementNbs = result.elementPipe;
          this.userCurrency = result.userCurrency;

          //With permission => show Opp (Project) + Quote
          //Without permission => show Opp (Project)
          if (
            (result.haveQuotationToolPermission &&
              this.elementSelectedForPipe === "Quote Pipe") ||
            (!result.haveQuotationToolPermission &&
              this.elementSelectedForPipe === "Project Pipe") ||
            (result.haveQuotationToolPermission &&
              this.elementSelectedForPipe === "Followed Quote")
          ) {
            this.displayPortfolioOrProjectPortfolio = true;
          }
        }
      })
      .catch(error => {
        this.error += error + "\n";
        console.log(JSON.parse(JSON.stringify(this.error)));
      });
  }
}