({
  getGAInformations: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Order Tracking (from Home page)",
      eventAction: "click",
      eventLabel: "One more tracking from the page 'Home'."
    });
    analyticsInteraction.fire();
  }
});