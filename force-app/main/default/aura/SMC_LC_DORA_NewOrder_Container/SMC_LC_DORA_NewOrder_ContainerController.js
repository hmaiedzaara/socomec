({
  handleRefreshView: function(component, event, helper) {
    component.set("v.tooglerefresh", false);
    helper.handleForceRefreshViewForLWC(component);
  },

  getGAInformationsProductAdded: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "New order - ProductAdded",
      eventAction: "click",
      eventLabel:
        "The product " + event.getParam("detail") + " was added to an order."
    });
    analyticsInteraction.fire();
  },

  getGAInformationsSendOrder: function(component, event, helper) {
    //Send info to Google Analytics
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
      hitType: "event",
      eventCategory: "Order sending",
      eventAction: "click",
      eventLabel: "A new order was sent."
    });
    analyticsInteraction.fire();
    //refresh view
    component.set("v.tooglerefresh", false);
    helper.handleForceRefreshViewForLWC(component);
  }
});