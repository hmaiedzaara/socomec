({
  doInit: function(component, event, helper) {
    component.set("v.errors", null);
    helper.getAccount(component, helper, component.get("v.recordId"));
  },

  destroyScoringForm: function(component, event, helper) {
    component.destroy();
  }
});