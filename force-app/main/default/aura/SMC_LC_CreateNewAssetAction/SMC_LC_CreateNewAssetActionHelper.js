({
  parsePageReference: function(component) {
    var pageRef = component.get("v.pageReference");
    if (pageRef) {
      var state = pageRef.state; // state holds any query params
      var base64Context = state.inContextOfRef;
      if (base64Context) {
        // For some reason, the string starts with "1.", if somebody knows why,
        // this solution could be better generalized.
        if (base64Context.startsWith("1.")) {
          base64Context = base64Context.substring(2);
        }
        component.set("v.selectedRecordTypeString", state.recordTypeId);
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set(
          "v.inContextOfRef",
          addressableContext.attributes.recordId
        );
      }
    }
  },
  fireCreateEvent: function(component) {
    var sObjectType = "Asset";
    var createRecordEvent = $A.get("e.force:createRecord");
    var inContextOfRef =
      component.get("v.inContextOfRef") != undefined
        ? component.get("v.inContextOfRef")
        : "";
    var defaultFieldValues = {};
    if (inContextOfRef.startsWith("131")) {
      defaultFieldValues.Locationid = inContextOfRef;
    }
    if (inContextOfRef.startsWith("001")) {
      defaultFieldValues.AccountId = inContextOfRef;
    }
    if (component.get("v.selectedRow")) {
      defaultFieldValues.Product2Id = component.get("v.selectedRow")[0];
    }
    defaultFieldValues.RecordTypeId = component.get(
      "v.selectedRecordTypeString"
    );
    if (
      component.get("v.selectedRecordTypeString") !=
      $A.get("$Label.c.SMC_GroupAssetRecordType")
    ) {
      defaultFieldValues.Name = "DoNotFill this will be autopopulated";
    }
    if (
      component.get("v.selectedRecordTypeString") ==
      $A.get("$Label.c.SMC_UnitAssetRecordType")
    ) {
      defaultFieldValues.Quantity = 1;
    }

    if (inContextOfRef.startsWith("02i")) {
      defaultFieldValues.ParentId = inContextOfRef;
      var action = component.get("c.getParentInformation");
      action.setParam("parentId", inContextOfRef);
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var parentAsset = response.getReturnValue();
          defaultFieldValues.AccountId = parentAsset.AccountId;
          defaultFieldValues.ContactId = parentAsset.ContactId;
          if (parentAsset.LocationId != null) {
            defaultFieldValues.LocationId = parentAsset.LocationId;
          }

          createRecordEvent.setParams({
            entityApiName: sObjectType,
            defaultFieldValues: defaultFieldValues
          });
          createRecordEvent.fire();

          component.set("v.errors", null);
        } else {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              component.set("v.errors", errors[0].message);
            }
          } else {
            component.set("v.errors", "Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      createRecordEvent.setParams({
        entityApiName: sObjectType,
        defaultFieldValues: defaultFieldValues
      });
      createRecordEvent.fire();
    }

    component.set("v.currentStep", "blank");
  },
  buildSelectOption: function(component) {
    var possibleValue = [
      { label: "Group", value: "Group" },
      { label: "Unit", value: "Unit" },
      { label: "Service Component", value: "Service Component" }
    ];
    if (
      component.get("v.inContextOfRef") &&
      component.get("v.inContextOfRef").startsWith("02i")
    ) {
      possibleValue.push({ label: "Firmware", value: "Firmware" });
    }
    component.set("v.recordTypeOptions", possibleValue);
  }
});