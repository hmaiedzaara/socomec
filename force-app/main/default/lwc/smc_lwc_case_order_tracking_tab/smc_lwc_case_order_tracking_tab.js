import { LightningElement, api, track } from 'lwc';
import getDatas from "@salesforce/apex/SMC_AC_Case_Order_Tracking.initialisationTab";

export default class Smc_lwc_case_order_tracking_tab extends LightningElement {
    @api recordId;
    @api internalOrexternal;

    //In component
    isError = false;
    errorMessage;
    orderNotFound = false;
    isLoad = false;
    salesOrder;
    thereAreSalesOrder = false;
    thereIsSalesOrderAddress = false;
    warehouseOrder;
    thereAreWarehouseOrder = false;
    thereIsWarehouseOrderAddress = false;
    dataId = 0;
    // @track columnsOrder;
    shipments = [];
    thereAreShipments = false;
    jsonResult;
    // @track columnsShipment;

    connectedCallback(){
        getDatas({
            recordId: this.recordId,
            salesOrderNumber: this.ordernumber,
            internalOrexternal: this.internalOrexternal
          })
        .then(result => {
            //If not error but null or empty
            // console.log('result',result);
            // if(result === null || result === undefined || result.jsonResult === null || result.jsonResult === undefined){
            if(result === null || result === undefined){
                this.orderNotFound = true;
                return;
            }
            //Set datas
            let resultParsed = JSON.parse(result);
            // let resultParsed = result;
            // console.log('resultParsed', resultParsed);
            if(resultParsed === undefined || resultParsed === null || resultParsed.jsonResult === ""){
                this.orderNotFound = true;
            }
            else{
                let jsonResult = JSON.parse(resultParsed.jsonResult);
                // console.log('jsonResult', jsonResult);
                this.jsonResult = jsonResult;
                //Sales Order
                if(jsonResult.salesOrder !== undefined && jsonResult.salesOrder !== null){
                    if(jsonResult.salesOrder.salesOrderHeader.invoiceToAddress !== undefined && jsonResult.salesOrder.salesOrderHeader.invoiceToAddress !== null){
                        this.thereIsSalesOrderAddress = true;
                    }
                    this.formatOrderDates(jsonResult);
                    this.thereAreSalesOrder = true;
                }
                //Warehouse Order
                if(jsonResult.warehousingOrderLines !== undefined && jsonResult.warehousingOrderLines.length > 0){
                    for(let worder in jsonResult.warehousingOrderLines){
                        if(jsonResult.warehousingOrderLines[worder].warehousingOrder !== undefined && 
                            jsonResult.warehousingOrderLines[worder].warehousingOrder !== null && 
                            jsonResult.warehousingOrderLines[worder].warehousingOrder.shipToAddress !== null){
                            this.thereIsWarehouseOrderAddress = true;
                        }
                    }
                    this.formatOrderDates(jsonResult);
                    this.warehouseOrder = jsonResult.warehousingOrderLines;
                    this.thereAreWarehouseOrder = true;
                }
                //Shipments
                if(jsonResult.shipments !== undefined && jsonResult.shipments.length > 0){
                    for(let key in jsonResult.shipments){
                        if(jsonResult.shipments[key].shipmentHeader.shipToAddress !== undefined && jsonResult.shipments[key].shipmentHeader.shipToAddress){
                            jsonResult.shipments[key].hasAnAddress = true;
                        }
                        else{
                            jsonResult.shipments[key].hasAnAddress = false;
                        }
                        this.shipments.push(jsonResult.shipments[key]);
                    }
                    this.thereAreShipments = true;
                }
                this.addDataId(jsonResult);
                this.isLoad = true;

                setTimeout(()=>{
                    if(this.thereAreSalesOrder){
                        this.changeCSSSalesOrder();
                    }
                    if(this.thereAreWarehouseOrder){
                        this.changeCSSWarehouseOrder();
                    }
                    if(this.thereAreShipments){
                        this.changeCSSShipments();
                    }
                }, 10);
            }

            if(!this.thereAreSalesOrder && 
               !this.thereAreWarehouseOrder && 
               !this.thereAreShipments){
                this.orderNotFound = true;
            }
        })
        .catch(error => {
            console.log('error', error);
            this.errorMessage = JSON.stringify(error) + "\n";
            this.isError = true;
        });
    }

    changeCSSSalesOrder(){
        let order = this.salesOrder;
        for(let ord in order.salesOrderLines){
            /*if (order.salesOrderLines[ord].shippedQuantityString === order.salesOrderLines[ord].orderedQuantityString) {
                let target = this.template.querySelector('[data-id="' + order.salesOrderLines[ord].dataId + '"]');
                target.classList.add('shipped');  
            }*/
            var target = this.template.querySelector('[data-id="' + order.salesOrderLines[ord].dataId + '"]');
            if (order.salesOrderLines[ord].shippedStatus == 'shipped') {   
                target.classList.add('shipped');  
            } else if (order.salesOrderLines[ord].shippedStatus == 'transferred'){
                target.classList.add('ep');
            }
        }
    }
    changeCSSWarehouseOrder(){
        let worder = this.warehouseOrder;
        for(let worderLine in worder){
            for(let ord in worder[worderLine].outboundOrderLines){
                /*if (worder[worderLine].outboundOrderLines[ord].shippedQuantityString === worder[worderLine].outboundOrderLines[ord].orderedQuantityString) {
                    let target = this.template.querySelector('[data-id="' + worder[worderLine].outboundOrderLines[ord].dataId + '"]');
                    target.classList.add('shipped');  
                }*/
                var target = this.template.querySelector('[data-id="' + worder[worderLine].outboundOrderLines[ord].dataId + '"]');
                if (worder[worderLine].outboundOrderLines[ord].shippedStatus == 'shipped') {
                    target.classList.add('shipped');  
                } else if (worder[worderLine].outboundOrderLines[ord].shippedStatus == 'transferred') {
                    target.classList.add('ep');  
                }
            }
        }
    }

    changeCSSShipments(){
        let shipements = this.jsonResult.shipments;
        for(let ship in shipements){
            let shipement = shipements[ship].shipmentLines;
            for (let key in shipement) {
                /*if ( shipement[key].salesOrder === undefined || shipement[key].salesOrder === null) { 
                    let target = this.template.querySelector('[data-id="' + shipement[key].dataId + '"]');
                    target.classList.add('ep');  
                }*/
                var target = this.template.querySelector('[data-id="' + shipement[key].dataId + '"]');
                if ( shipement[key].shippedStatus == 'shipped') { 
                    target.classList.add('shipped');  
                } else if ( shipement[key].shippedStatus == 'transferred') { 
                    target.classList.add('ep');  
                }
            }
        }
    }

    addDataId(jsonResult){
        if(this.thereAreSalesOrder){
            let order = jsonResult.salesOrder;
            for(let idx in order.salesOrderLines){
                // Generation dataId
                let newSalesOrderObj = {
                    dataId: this.dataId ,
                    confirmedDate: order.salesOrderLines[idx].confirmedDate,
                    confirmedDateString: order.salesOrderLines[idx].confirmedDateString,
                    item: order.salesOrderLines[idx].item,
                    itemDescription: order.salesOrderLines[idx].itemDescription,
                    line:order.salesOrderLines[idx].line,
                    warehouse:order.salesOrderLines[idx].warehouse,
                    orderedQuantity: order.salesOrderLines[idx].orderedQuantity,
                    orderedQuantityString: order.salesOrderLines[idx].orderedQuantityString,
                    remainingQuantity: order.salesOrderLines[idx].remainingQuantity,
                    remainingQuantityString: order.salesOrderLines[idx].remainingQuantityString,
                    transferredQuantity: order.salesOrderLines[idx].transferredQuantity,
                    transferredQuantityString: order.salesOrderLines[idx].transferredQuantityString,
                    requestedDate: order.salesOrderLines[idx].requestedDate,
                    requestedDateString: order.salesOrderLines[idx].requestedDateString,
                    reviewedDateString: order.salesOrderLines[idx].reviewedDateString,
                    shippedQuantity: order.salesOrderLines[idx].shippedQuantity,
                    shippedQuantityString: order.salesOrderLines[idx].shippedQuantityString,
                    shippedStatus: order.salesOrderLines[idx].shippedStatus
                }
                order.salesOrderLines[idx] = newSalesOrderObj;   
                ++ this.dataId ;   
            }
            this.salesOrder = order;
        }
        if(this.thereAreWarehouseOrder){
            let worder = this.warehouseOrder;
            // console.log('worder', worder);
            for(let worderLine in worder){
                for(let idx in worder[worderLine].outboundOrderLines){
                    // Generation dataId
                    let newWarehouseOrderObj = {
                        dataId: this.dataId,
                        item: worder[worderLine].outboundOrderLines[idx].item,
                        itemDescription: worder[worderLine].outboundOrderLines[idx].itemDescription,
                        line: worder[worderLine].outboundOrderLines[idx].line,
                        sequence: worder[worderLine].outboundOrderLines[idx].sequence,
                        orderedQuantity: worder[worderLine].outboundOrderLines[idx].orderedQuantity,
                        orderedQuantityString: worder[worderLine].outboundOrderLines[idx].orderedQuantityString,
                        shippedQuantity: worder[worderLine].outboundOrderLines[idx].shippedQuantity,
                        shippedQuantityString: worder[worderLine].outboundOrderLines[idx].shippedQuantityString,
                        order: worder[worderLine].outboundOrderLines[idx].order,
                        orderDate: worder[worderLine].outboundOrderLines[idx].orderDate,
                        orderDateString: worder[worderLine].outboundOrderLines[idx].orderDateString,
                        orderOrigin: worder[worderLine].outboundOrderLines[idx].orderOrigin,
                        plannedDeliveryDate: worder[worderLine].outboundOrderLines[idx].plannedDeliveryDate,
                        plannedDeliveryDateString: worder[worderLine].outboundOrderLines[idx].plannedDeliveryDateString,
                        set: worder[worderLine].outboundOrderLines[idx].set,
                        shippedStatus: worder[worderLine].outboundOrderLines[idx].shippedStatus
                    }
                    worder[worderLine].outboundOrderLines[idx] = newWarehouseOrderObj;   
                    ++ this.dataId ;   
                }
            }
            // console.log('worder', worder);
            this.warehouseOrder = worder;
        }
        if(this.thereAreShipments){
            let shipements = jsonResult.shipments;
            for(let ship in shipements){
                let shipement = shipements[ship].shipmentLines;
                for (let key in shipement) {
                    let newSalesOrderObj = {
                        dataId: this.dataId ,
                        item: shipement[key].item,
                        itemDescription: shipement[key].itemDescription,
                        line: shipement[key].line,
                        orderLine: shipement[key].orderLine,
                        orderOrigin: shipement[key].orderOrigin,
                        order: shipement[key].order,
                        orderSet: shipement[key].orderSet,
                        orderSequence: shipement[key].orderSequence,
                        salesOrder: shipement[key].salesOrder,
                        shippedQuantity: shipement[key].shippedQuantity,
                        shippedQuantityString: shipement[key].shippedQuantityString,
                        shippedStatus: shipement[key].shippedStatus
                    }
                    shipement[key] = newSalesOrderObj;
                    ++ this.dataId ;  
                }
                shipements[ship].shipmentLines = shipement;
            }
            this.shipments = shipements;
        }
    }

    formatOrderDates(jsonResult){
        if(this.thereAreSalesOrder){
            let order = jsonResult.salesOrder;
            for(let idx in order.salesOrderLines){
                if(order.salesOrderLines[idx].requestedDateString !== undefined){
                    order.salesOrderLines[idx].requestedDateString = order.salesOrderLines[idx].requestedDateString.includes('T') ? order.salesOrderLines[idx].requestedDateString.split('T')[0] : order.salesOrderLines[idx].requestedDateString.split(' ')[0];
                }
                else{
                    order.salesOrderLines[idx].requestedDateString = '';
                }
                if(order.salesOrderLines[idx].confirmedDateString !== undefined){
                    order.salesOrderLines[idx].confirmedDateString = order.salesOrderLines[idx].confirmedDateString.includes('T') ? order.salesOrderLines[idx].confirmedDateString.split('T')[0] : order.salesOrderLines[idx].confirmedDateString.split(' ')[0];
                }
                else{
                    order.salesOrderLines[idx].confirmedDateString = '';
                }
                if(order.salesOrderLines[idx].reviewedDateString !== undefined){
                    order.salesOrderLines[idx].reviewedDateString = order.salesOrderLines[idx].reviewedDateString.includes('T') ? order.salesOrderLines[idx].reviewedDateString.split('T')[0] : order.salesOrderLines[idx].reviewedDateString.split(' ')[0];
                }
                else{
                    order.salesOrderLines[idx].reviewedDateString = '';
                }
              
            }
            this.salesOrder = order;
        }
        if(this.thereAreWarehouseOrder){
            let worder = this.warehouseOrder;
            for(let worderLine in worder){
                for(let idx in worder[worderLine].outboundOrderLines){
                    if(worder[worderLine].outboundOrderLines[idx].requestedDateString !== undefined){
                       worder[worderLine].outboundOrderLines[idx].requestedDateString = 
                            worder[worderLine].outboundOrderLines[idx].requestedDateString.includes('T') ? 
                                worder[worderLine].outboundOrderLines[idx].requestedDateString.split('T')[0] : 
                                worder[worderLine].outboundOrderLines[idx].requestedDateString.split(' ')[0];
                    }
                    else{
                        worder[worderLine].outboundOrderLines[idx].requestedDateString = '';
                    }
                    if(worder[worderLine].outboundOrderLines[idx].confirmedDateString !== undefined){
                       worder[worderLine].outboundOrderLines[idx].confirmedDateString = 
                            worder[worderLine].outboundOrderLines[idx].confirmedDateString.includes('T') ? 
                                worder[worderLine].outboundOrderLines[idx].confirmedDateString.split('T')[0] : 
                                worder[worderLine].outboundOrderLines[idx].confirmedDateString.split(' ')[0];
                    }
                    else{
                        worder[worderLine].outboundOrderLines[idx].confirmedDateString = '';
                    }
                    if(worder[worderLine].outboundOrderLines[idx].reviewedDateString !== undefined){
                       worder[worderLine].outboundOrderLines[idx].reviewedDateString = 
                            worder[worderLine].outboundOrderLines[idx].reviewedDateString.includes('T') ? 
                                worder[worderLine].outboundOrderLines[idx].reviewedDateString.split('T')[0] : 
                                worder[worderLine].outboundOrderLines[idx].reviewedDateString.split(' ')[0];
                    }
                    else{
                        worder[worderLine].outboundOrderLines[idx].reviewedDateString = '';
                    }
                
                }
            }
            this.warehouseOrder = worder;
        }
    }

}