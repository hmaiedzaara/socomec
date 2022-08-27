({
  //Get Account and start Get Scoring
  getAccount: function(component, helper, recId) {
    var action = component.get("c.getDiscountInformationsFromDiscountForm");
    action.setParam("recId", recId);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.token", result.token);
        component.set("v.account", result.account);
        component.set("v.baIds", result.baIds);
        //For initiate all variables
        if (!result.scoringExist) {
          component.set("v.errors", $A.get("$Label.c.SMC_AccessScoring_Error"));
          component.set("v.displayScoring", false);
        } else {
          component.set("v.displayScoring", true);
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