({
  accessToScoringForm: function(component, event, helper) {
    component.set("v.openScoringForm", true);
  },

  closeScoringForm: function(component, event, helper) {
    component.set("v.openScoringForm", false);
  },

  refreshDiscount: function(component, event, helper) {
    var hostComponent = component.find("enclosingComponent");

    $A.createComponent(
      "c:SMC_LC_ScoringForm",
      {
        recordId: component.get("v.recordId")
      },
      function(newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var body = hostComponent.get("v.body");
          body.push(newComponent);
          hostComponent.set("v.body", body);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  }
});