({
  getCurrentCase: function(component) {
    var action = component.get("c.getCase");
    action.setParam("recordId", component.get("v.recordId"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.currentCase", response.getReturnValue());
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