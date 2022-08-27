({
  doInit: function(component, event, helper) {
    helper.lauchQuotationTool(component, event, helper);
  },

  redirectionToCorrection: function(component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/" + event.target.getAttribute("data-id")
    });
    urlEvent.fire();
  }
});