({
  getGAInformations: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Download",
      eventAction: "click",
      eventLabel:
        "Asset Library Download : Document title [" +
        event.getParam("data") +
        "]"
    });
    analyticsInteraction.fire();
  }
});