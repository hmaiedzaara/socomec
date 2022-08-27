({
  init: function(component, event, helper) {
    helper.parsePageReference(component);
    if (
      component.get("v.selectedRecordTypeString") !=
      $A.get("$Label.c.SMC_UnitAssetRecordType")
    ) {
      helper.fireCreateEvent(component, helper);
    }
  },
  onBack: function(component, event, helper) {
    window.history.back();
  },
  onServiceProductChosen: function(component, event, helper) {
    helper.fireCreateEvent(component, helper);
  }
});