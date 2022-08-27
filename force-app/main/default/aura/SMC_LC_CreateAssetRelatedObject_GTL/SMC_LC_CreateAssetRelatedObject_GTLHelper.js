({
  createAssetRelatedObject: function(component, event, helper) {
    //Get related list
    var action = component.get("c.getGTLfromAssetId");
    action.setParam("assetId", component.get("v.recordId"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      var toastEvent = $A.get("e.force:showToast");
      if (state == "SUCCESS") {
        var result = JSON.parse(response.getReturnValue());
        //Success
        if (result.isSuccess) {
          toastEvent.setParams({
            title: "Success",
            message: "All related objects are created.",
            type: "success"
          });
        }
        //Input list is empty
        else if (result.emptyList) {
          toastEvent.setParams({
            title: "Fail",
            message: "There is no asset in the input list.",
            type: "error"
          });
        }
        //Wrong record type
        else if (result.badRecordTypeAsset.length > 0) {
          var message =
            "You can't create Related Obect for a group or related object Asset, as following assets : ";
          for (var i = 0; i < result.badRecordTypeAsset.length; ++i) {
            message +=
              "\nName = " +
              result.badRecordTypeAsset[i].Name +
              " / Id = " +
              result.badRecordTypeAsset[i].Id;
          }
          if (result.rigthRecordTypeAsset.length > 0 && result.isSuccess) {
            message += "\n\nBut it's done for following assets : ";
            for (var i = 0; i < result.rigthRecordTypeAsset.length; ++i) {
              message +=
                "\nName = " +
                result.rigthRecordTypeAsset[i].Name +
                " / Id = " +
                result.rigthRecordTypeAsset[i].Id;
            }
          }
          toastEvent.setParams({
            title: "Warning",
            message: message,
            type: "warning"
          });
        }
        //Related objects already existing
        else if (result.badAsset.length > 0) {
          var message =
            "You can't create Related Obect for an asset if they are already created, as following assets : ";
          for (var i = 0; i < result.badAsset.length; ++i) {
            message +=
              "\nName = " +
              result.badAsset[i].Name +
              " / Id = " +
              result.badAsset[i].Id;
          }
          if (result.rigthAsset.length > 0 && result.isSuccess) {
            message += "\n\nBut it's done for following assets : ";
            for (var i = 0; i < result.rigthAsset.length; ++i) {
              message +=
                "\nName = " +
                result.rigthAsset[i].Name +
                " / Id = " +
                result.rigthAsset[i].Id;
            }
          }
          toastEvent.setParams({
            title: "Warning",
            message: message,
            type: "warning"
          });
        }
        //Update failed
        else if (result.errorOccur) {
          toastEvent.setParams({
            title: "Fail",
            message:
              "An error occur during the creation of related objects. Contact your administrator.",
            type: "error"
          });
        }
      }
      //Apex failed
      else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            toastEvent.setParams({
              title: "Fail",
              message: errors[0].message + "\nContact your administrator.",
              type: "error"
            });
          }
        } else {
          toastEvent.setParams({
            title: "Fail",
            message: "Unknown error. Contact your administrator.",
            type: "error"
          });
        }
      }
      toastEvent.fire();
      $A.get("e.force:closeQuickAction").fire();
    });
    $A.enqueueAction(action);
  }
});