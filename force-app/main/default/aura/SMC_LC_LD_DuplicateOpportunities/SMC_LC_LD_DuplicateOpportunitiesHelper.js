({
  getDuplicateOpps: function(component) {
    var action = component.get("c.getDuplicatesOpportunities");
    action.setParam(
      "projectLocation",
      component.get("v.simpleRecord.rvpe_projectlocation__c")
    );
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.opps", response.getReturnValue());
        var action2 = component.get("c.getOpportunityFieldsLabel");
        action2.setCallback(this, function(response2) {
          var state2 = response2.getState();
          if (state2 === "SUCCESS") {
            console.log(response2.getReturnValue());
            component.set("v.oppFieldsLabel", response2.getReturnValue());
          }
          component.set("v.isSpinner", false);
        });
        $A.enqueueAction(action2);
      } else {
        component.set("v.isSpinner", false);
      }
    });
    $A.enqueueAction(action);
  }
});