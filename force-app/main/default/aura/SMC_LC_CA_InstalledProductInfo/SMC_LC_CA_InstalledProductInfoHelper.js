({
  getInstalledProductInfos: function(component) {
    // Call SMC_AC_LC_CaseController.getInstalledProductInfosHTML apex function
    var action = component.get("c.getInstalledProductInfosHTML");
    action.setParams({
      serialNumber: component.get("v.simpleRecord.SMC_Serial_Number__c"),
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      // Retrieve response's function
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.installedProductInfosHTML", response.getReturnValue());
        component.set("v.isSpinner", false);
      }
    });
    $A.enqueueAction(action);
  }
});