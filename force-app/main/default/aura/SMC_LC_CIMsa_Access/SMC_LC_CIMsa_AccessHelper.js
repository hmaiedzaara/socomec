({
  openNewTab: function(component) {
    //Open a New Tab to access CIMsa
    var action = component.get("c.openNewTab");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: response.getReturnValue()
        });
        urlEvent.fire();
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