({
  getAccount: function(component) {
    var recId = component.get("v.recordId");
    var action = component.get("c.getTheAccount");
    action.setParam("recId", recId);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        //Check if the return contains an URL or a restriction message
        var result = response.getReturnValue();
        if (result.substring(0, 1).includes("/")) {
          //Return contains URL
          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url: response.getReturnValue()
          });
          urlEvent.fire();
        } else {
          //Return contains restriction message
          result = result.split("-"); //The value returned is a String -> split to get informations
          var missingFields = [];
          for (var i = 1; i < result.length; ++i) {
            missingFields.push(result[i]);
          }
          component.set("v.errors", result[0]);
          component.set("v.missingFields", missingFields);
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
        component.set("v.isOpen", true);
      }
    });
    $A.enqueueAction(action);
  }
});