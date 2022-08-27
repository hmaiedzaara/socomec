({
  getGAInformations: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Order cancelling",
      eventAction: "click",
      eventLabel: "Order " + event.getParam("detail") + " was cancelled."
    });
    analyticsInteraction.fire();
  }
});