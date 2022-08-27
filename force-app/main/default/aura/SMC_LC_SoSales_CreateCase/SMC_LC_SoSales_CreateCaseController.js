({
  doInit: function(component, event, helper) {
    helper.getCurrentCase(component);
  },

  toggleToCreateCase: function(component, event, helper) {
    component.set("v.showCreateCase", !component.get("v.showCreateCase"));
  },

  onRecordUpdated: function(component, event, helper) {
    helper.getCurrentCase(component);
  }
});