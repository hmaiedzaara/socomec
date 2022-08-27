({
  doInit: function(component, event, helper) {
    helper.getCases(component, event, helper);
  },

  handleCheckFilterSelected: function(component, event, helper) {
    helper.checkFilterSelected(component, event);
  },

  redirectToCase: function(component, event, helper) {
    //Get event "Select a row"
    var row = event.getParam("row");
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: row.Id,
      slideDevName: "detail"
    });
    navEvt.fire();
  }
});