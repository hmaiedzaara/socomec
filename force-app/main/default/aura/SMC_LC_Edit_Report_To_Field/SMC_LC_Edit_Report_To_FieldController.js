({
  handleComponentEvent: function(component, event, helper) {
    component.set("v.newManagerId", event.getParam("recordByEvent").Id);
  },

  onSave: function(component, event, helper) {
    helper.saveNewManager(component);
  }
});