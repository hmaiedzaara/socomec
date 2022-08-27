({
  getUserPermission: function(component, event, helper) {
    var action = component.get("c.getPermission");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        //Stock permission
        component.set("v.hasPermission", response.getReturnValue());

        //Get process instance
        if (response.getReturnValue()) {
          helper.getApproval(component, event, helper);
        }
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
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getApproval: function(component, event, helper) {
    var action = component.get("c.searchApproval");
    action.setParam(
      "selectApprovalByDesign",
      component.get("v.selectApprovalByDesign")
    );
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        component.set("v.processInstanceList", result);
        component.set("v.numberOfItem", result.length);
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
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  }
});