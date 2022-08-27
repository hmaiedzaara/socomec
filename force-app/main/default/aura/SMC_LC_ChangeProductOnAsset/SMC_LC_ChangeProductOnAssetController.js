({
  close: function(component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },
  save: function(component, event, helper) {
    component.set(
      "v.currentAsset.Product2Id",
      component.get("v.selectedRow")[0]
    );
    component.find("recordLoader").saveRecord(function(response) {
      $A.get("e.force:closeQuickAction").fire();
    });
  }
});