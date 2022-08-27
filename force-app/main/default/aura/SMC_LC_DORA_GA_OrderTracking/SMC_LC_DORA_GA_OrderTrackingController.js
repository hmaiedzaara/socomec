({
  getGAInformations: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Order Tracking",
      eventAction: "click",
      eventLabel: "One more visitor on page 'Order Traking'."
    });
    analyticsInteraction.fire();
  }
});