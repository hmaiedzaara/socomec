({
  closeQuickAction: function(component, event, helper) {
    //Toast
    var toastEvent = $A.get("e.force:showToast");
    if (event.getParam("isCreated")) {
      toastEvent.setParams({
        type: "success",
        title: "Message send",
        message: "Your message is saved and send."
      });
    } else {
      toastEvent.setParams({
        type: "error",
        title: "Message not send",
        message:
          "Your message is not saved. Contact your administrator to report him the problem."
      });
    }
    toastEvent.fire();

    //Close QuickAction
    $A.get("e.force:closeQuickAction").fire();
  }
});