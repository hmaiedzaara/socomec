({
  doInit: function(component, event, helper) {
    if (
      component.get("v.selectApprovalByDesign") ==
      $A.get("$Label.c.SMC_AllAproval")
    ) {
      helper.getUserPermission(component, event, helper);
    } else if (
      component.get("v.selectApprovalByDesign") ==
      $A.get("$Label.c.SMC_Item_To_Approve_Delegated")
    ) {
      helper.getApproval(component, event, helper);
    } else {
      component.set(
        "v.errors",
        "The design is not set. Please, go in AppBuilder and select a value for the component (or ask to your administrator) and refresh the page."
      );
    }
  }
});