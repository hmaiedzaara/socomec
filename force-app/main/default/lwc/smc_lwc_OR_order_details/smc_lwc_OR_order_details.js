import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOrderRows from "@salesforce/apex/SMC_AC_DORA_Management.getOrderRows";
import postSendOrder from "@salesforce/apex/SMC_AC_DORA_Management.postSendOrder";
import deleteOrder from "@salesforce/apex/SMC_AC_DORA_Management.deleteOrder";

export default class Smc_lwc_OR_order_details extends NavigationMixin(
  LightningElement
) {
  @track cdcli;
  @track cdord;
  @track order;
  @track orderLines = [];
  @track orderRetrieved = false;
  @track orderIsCreated = false;

  connectedCallback() {
    this.cdcli = new URL(window.location.href).searchParams.get("cdcli");
    this.cdord = new URL(window.location.href).searchParams.get("cdord");
    getOrderRows({
      cdord: JSON.parse(JSON.stringify(this.cdord))
    })
      .then(result => {
        if (!JSON.parse(result).getOrderRows.error) {
          this.order = JSON.parse(result).getOrderRows.data;
          this.orderRetrieved = true;
          if (JSON.parse(result).getOrderRows.data.STATUS === "Created") {
            this.orderIsCreated = true;
          }
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: JSON.parse(result).getOrder.message,
              variant: "error"
            })
          );
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

  handleCancelOrder() {
    deleteOrder({ cdord: this.cdord })
      .then(result => {
        let resultElmt = JSON.parse(result);
        if (!resultElmt.getPostResult.error) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message:
                "The order is cancelled. You will be redirect to the My Order page.",
              variant: "success"
            })
          );
          this.sendToGoogleAnalytics();
          setTimeout(() => {
            const pageRef = {
              type: "standard__webPage",
              attributes: {
                url: "/my-orders"
              }
            };
            this[NavigationMixin.Navigate](pageRef);
          }, 2000);
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: resultElmt.getPostResult.message,
              variant: "error"
            })
          );
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

  // handleBuyAgainOrder(event) {
  //   let orderParsed = JSON.parse(JSON.stringify(this.order));
  //   for (let key in orderParsed.rows) {
  //     orderParsed.rows[key].REQUESTEDDATE = event.detail;
  //     this.orderLines.push(orderParsed.rows[key]);
  //   }
  //   this.sendOrder(orderParsed, event.detail);
  // }

  // sendOrder(orderParsed, reqDate) {
  //   //Callout : buy again order --> same WS as Post New Order
  //   postSendOrder({
  //     fromWhere: "post_orderBuyAgain",
  //     cdord: "",
  //     cdcli:
  //       orderParsed.CDCLI === undefined || orderParsed.CDCLI === null
  //         ? ""
  //         : orderParsed.CDCLI,
  //     requestedDate: reqDate,
  //     addresscode:
  //       orderParsed.address.ADDRESSCODE === undefined ||
  //       orderParsed.address.ADDRESSCODE === null
  //         ? ""
  //         : orderParsed.address.ADDRESSCODE,
  //     custref:
  //       orderParsed.CUSTREF === undefined || orderParsed.CUSTREF === null
  //         ? ""
  //         : orderParsed.CUSTREF,
  //     rows: JSON.stringify(this.orderLines)
  //   })
  //     .then(result => {
  //       if (!JSON.parse(result).getPostResult.error) {
  //         this.dispatchEvent(
  //           new ShowToastEvent({
  //             title: "Order sent",
  //             message: JSON.parse(result).getPostResult.message,
  //             variant: "success"
  //           })
  //         );
  //       } else {
  //         this.dispatchEvent(
  //           new ShowToastEvent({
  //             title: "Error",
  //             message: JSON.parse(result).getPostResult.message,
  //             variant: "error"
  //           })
  //         );
  //       }
  //     })
  //     .catch(error => {
  //       this.dispatchEvent(
  //         new ShowToastEvent({
  //           title: "Error",
  //           message: JSON.stringify(error),
  //           variant: "error"
  //         })
  //       );
  //     });
  // }

  sendToGoogleAnalytics() {
    // Send event to parent
    const selectedEvent = new CustomEvent("ordercancelled", {
      detail: this.cdord
    });
    this.dispatchEvent(selectedEvent);
  }
}