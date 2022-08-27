({
  getSalesOrderInfos: function(component) {
    // Call SMC_AC_LC_CaseController.getSalesOrderInfos apex function
    var action = component.get("c.getSalesOrderInfos");
    action.setParams({
      orderNumber: component.get("v.simpleRecord.SMC_ERP_Order_Number__c"),
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      // Retrieve response's function
      var state = response.getState();
      if (state == "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.salesOrderJSON", result);

        var prevPackingSlipNumber = "";
        var listWrapper = [];
        var listOrderLine = [];
        for (var i = 0; i < result.length; i++) {
          if (i > 0 && prevPackingSlipNumber != result[i].packingSlipNumber) {
            listWrapper.push(listOrderLine);
            listOrderLine = [];
          }
          listOrderLine.push(result[i]);
          prevPackingSlipNumber = result[i].packingSlipNumber;
        }
        listWrapper.push(listOrderLine);
        component.set("v.salesOrderWrapper", listWrapper);
        component.set("v.isSpinner", false);
      }
    });
    $A.enqueueAction(action);
  }
});