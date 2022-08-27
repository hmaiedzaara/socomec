({
  recordUpdate: function(component, event, helper) {
    component.set("v.isSpinner", true);
    helper.getDuplicateOpps(component);
  }
});