({
  doInit: function(component, event, helper) {
    helper.findAccountName(component, event, helper);
  },

  sendMessageToSalesContact: function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    var actionAPI = cmp.find("quickActionAPI");
    var args = { actionName: "Account.SMC_Account_Message" };
    actionAPI
      .selectAction(args)
      .then(function(result) {
        toastEvent.setParams({
          title: "Saved",
          message: "Your changes are saved.",
          type: "success"
        });
        toastEvent.fire();
      })
      .catch(function(e) {
        if (e.errors) {
          toastEvent.setParams({
            title: "Error",
            message: "The quick action can not be called.",
            type: "error"
          });
        }
      });
    toastEvent.fire();
  },

  editContacts: function(component, event, helper) {}
});