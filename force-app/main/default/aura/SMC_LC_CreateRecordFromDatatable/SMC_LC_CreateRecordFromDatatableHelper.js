({
  getObjects: function(component, event, helper) {
    let factorOffset = component.get("v.factorOffset");
    var action = component.get("c.getInformations");
    action.setParams({
      recordId: component.get("v.recordId"),
      factorOffset: component.get("v.factorOffset"),
      onlyBattery: component.get("v.onlyBattery"),
      searchSparePartCode: component.get("v.searchSparePartCode")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      var result = JSON.parse(response.getReturnValue());
      if (state == "SUCCESS") {
        if(factorOffset === 0 && result.length > 0){
          this.init(component, result, this);
        }
        this.setDatas(component, result);
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors && Array.isArray(errors) && errors.length > 0) {
            var er = component.get("v.errors");
            component.set("v.errors", er + "\n" + errors[0].message);
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  init: function(component, result, contexte){
    component.set("v.dataType", result[0].targetObject);
    if (result[0].targetObject == "WorkOrderLineItem") {
      contexte.setColumnsWorkOrder(component);
    } else if (result[0].targetObject == "Asset") {
      contexte.setColumnsAsset(component);
    }
  },

  setColumnsWorkOrder: function(component) {
    component.set("v.columns", [
      {
        label: "Product Name",
        fieldName: "sparePartProductName",
        type: "text"
      },
      { label: "Group", fieldName: "gtlGroup", type: "text" },
      { label: "Subset", fieldName: "gtlSubset", type: "text" },
      {
        label: "Quantity",
        fieldName: "quantity",
        type: "number",
        editable: false
      }
    ]);
  },

  setColumnsAsset: function(component) {
    component.set("v.columns", [
      {
        label: "Spare Part Code",
        fieldName: "serviceSparePartCode",
        type: "text"
      },
      { label: "Product Name", fieldName: "serviceProductName", type: "text" },
      { label: "Group", fieldName: "gtlGroup", type: "text" },
      { label: "Subset", fieldName: "gtlSubset", type: "text" },
      { label: "Option", fieldName: "gtlOption", type: "text" },
      {
        label: "Quantity",
        fieldName: "quantity",
        type: "number",
        editable: false
      }
    ]);
  },

  setDatas: function(component, result){
    let currentDatas = component.get('v.data');
    if(currentDatas === null && result.length === 0){
      component.set("v.infoTitle", $A.get("$Label.c.SMC_Empty_List"));
      component.set("v.infos", $A.get("$Label.c.SMC_No_Record_Found"));
      component.set("v.dataIsNotEmpty", false);
    } else if (currentDatas === null && result.length !== 0) {
      component.set("v.data", result);
      component.set("v.infos", null);
      component.set("v.dataIsNotEmpty", true);
    }  else if (currentDatas !== null && result.length === 0) {
      //do nothing
    } else{
      result.forEach(element => {
        currentDatas.push(element);
      });
      component.set("v.data", currentDatas);
      component.set("v.infos", null);
      component.set("v.dataIsNotEmpty", true);
    }
  },

  saveObject: function(component, selectedRows) {
    var toastEvent = $A.get("e.force:showToast");

    var action = component.get("c.saveRecord");
    action.setParams({
      recordId: component.get("v.recordId"),
      selectedRows: JSON.stringify(selectedRows)
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        if (response.getReturnValue()) {
          toastEvent.setParams({
            title: "Success",
            message: "All related objects are created.",
            type: "success"
          });
        } else {
          toastEvent.setParams({
            title: "Fail",
            message: "An error occur durnig related object creation",
            type: "error"
          });
        }
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors && Array.isArray(errors) && errors.length > 0) {
            var er = component.get("v.errors");
            component.set("v.errors", er + "\n" + errors[0].message);
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
      component.set("v.isLoading", false);
      toastEvent.fire();
      $A.get("e.force:closeQuickAction").fire();
      $A.get("e.force:refreshView").fire();
    });
    $A.enqueueAction(action);
  }
});