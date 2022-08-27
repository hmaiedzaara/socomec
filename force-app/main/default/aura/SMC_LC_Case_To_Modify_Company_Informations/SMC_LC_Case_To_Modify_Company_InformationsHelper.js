({
  findAccountName: function(component, event, helper) {
    var action = component.get("c.getAccountName");
    action.setParams({
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.accountName", response.getReturnValue());
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors && Array.isArray(errors) && errors.length > 0) {
            var er = component.get("v.errors");
            component.set("v.errors", er + "\n" + errors[0].message);
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});

//   var toastEvent = $A.get("e.force:showToast");
//Close discount
// toastEvent.setParams({
//   title: "Saved",
//   message: "Your changes are saved.",
//   type: "success"
// });
//
// toastEvent.setParams({
//   title: "Error",
//   message: errors,
//   type: "error"
// });
// toastEvent.fire();