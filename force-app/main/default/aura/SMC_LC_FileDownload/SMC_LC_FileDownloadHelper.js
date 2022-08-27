({
  getUserPermission: function(component, event, helper) {
    var action = component.get("c.userIsAuthorized");
    action.setParams({
      isPublic: component.get("v.isPublic"),
      fileId: component.get("v.fileId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      var result = response.getReturnValue();
      if (state == "SUCCESS") {
        //Authiorisation
        component.set("v.isAuthorized", result);

        //Build url
        var url = window.location.href;
        var tmpValue = url.substr(0, url.lastIndexOf(".com") + 4);
        var fileId = component.get("v.fileId");
        var fileUrl = component.get("v.fileUrl");
        if (fileId != undefined && fileId != null && fileId) {
          component.set(
            "v.urlToDownload",
            tmpValue +
              "/customers/sfc/servlet.shepherd/document/download/" +
              fileId
          );
        } else if (fileUrl != undefined && fileUrl != null && fileUrl) {
          component.set("v.urlToDownload", fileUrl);
        }
        // else{
        // 	var toastEvent = $A.get("e.force:showToast");
        // 	toastEvent.setParams({
        // 		"title": "Warning",
        // 		"message": "There is no ID or URL to identify a file to download. Contact your administrator to fix that.",
        // 		"type": "warning"
        // 	});
        // 	toastEvent.fire();
        // }
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors && Array.isArray(errors) && errors.length > 0) {
            component.set("v.errors", "There is a problem!!");
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});