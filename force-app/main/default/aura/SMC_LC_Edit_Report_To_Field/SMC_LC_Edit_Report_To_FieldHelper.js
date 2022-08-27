({
  saveNewManager: function(component) {
    var action = component.get("c.editManagerId");
    action.setParams({
      recordId: component.get("v.recordId"),
      newManagerId: component.get("v.newManagerId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        if (response.getReturnValue()) {
          toastEvent.setParams({
            title: "Success",
            message: "The manager is changed.",
            type: "success"
          });
        } else {
          toastEvent.setParams({
            title: "Error",
            message:
              "There is a problem. Contact your administrator for more details.",
            type: "error"
          });
        }
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
});