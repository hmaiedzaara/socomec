({
  getGAInformations: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Product Selection",
      eventAction: "click",
      eventLabel: "Product selected : " + event.getParam("detail")
    });
    analyticsInteraction.fire();
  }
});