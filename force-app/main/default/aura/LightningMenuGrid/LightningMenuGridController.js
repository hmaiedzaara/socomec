({
  navTo1: function(component, event, helper) {
    var allowBack = component.get("{!v.allowback1}");
    var recUrl = component.get("{!v.url1}");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: recUrl,
      isredirect: allowBack
    });
    urlEvent.fire();
  },

  navTo2: function(component, event, helper) {
    var allowBack = component.get("{!v.allowback2}");
    var recUrl = component.get("{!v.url2}");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: recUrl,
      isredirect: allowBack
    });
    urlEvent.fire();
  },

  navTo3: function(component, event, helper) {
    var allowBack = component.get("{!v.allowback3}");
    var recUrl = component.get("{!v.url3}");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: recUrl,
      isredirect: allowBack
    });
    urlEvent.fire();
  }
});