({
  checkWorkOrderLineItem: function(component, event, helper) {
    var action = component.get("c.validatedWOL");
    action.setParam("workOrderLineItemId", component.get("v.recordId"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != "error") {
        component.set("v.isValidated", response.getReturnValue());
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.errors", errors[0].message);
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});