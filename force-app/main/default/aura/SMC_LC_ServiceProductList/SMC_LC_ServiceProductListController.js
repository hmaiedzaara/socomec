({
  doInit: function(component, event, helper) {
    helper.doInit(component, event, helper);
  },

  setProductNameAndCodeFilter: function(component, event, helper) {
    component.set("v.isLoading", true);
    var timer = component.get("v.timer");

    clearTimeout(timer);

    var timer = setTimeout(function() {
      clearTimeout(timer);
      helper.filtrage(component, event, helper);
      component.set("v.timer", null);
    }, 1000);

    component.set("v.timer", timer);
  },

  setRange: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtrageRange(component, event, helper);
  },

  setModel: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtrageModel(component, event, helper);
  },

  setConfiguration: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtrageConfiguration(component, event, helper);
  },

  setPhase: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtragePhase(component, event, helper);
  },

  setPower: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtragePower(component, event, helper);
  },

  setFinalFilter: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.filtrage(component, event, helper);
  },

  selectServiceProduct: function(component, event, helper) {
    var selectedRows = event.getParam("selectedRows");
    var selectedRowId = component.get("v.selectedRowId");
    var selectedProduct = component.get("v.selectedProduct");
    var selectedRow = [];
    //Unique select
    if (component.find("selectionUniqueOrMultiple").get("v.value")) {
      if (selectedRows.length > 0) {
        if (
          selectedRowId != undefined &&
          selectedRowId != null &&
          selectedRowId.length > 0
        ) {
          selectedRow.push(
            selectedRows[selectedRows.indexOf(selectedProduct) == 0 ? 1 : 0].Id
          );
          component.set("v.selectedRowId", selectedRow);
          component.set(
            "v.selectedProduct",
            selectedRows[selectedRows.indexOf(selectedProduct) == 0 ? 1 : 0]
          );
        } else {
          selectedRow.push(selectedRows[0].Id);
          component.set("v.selectedRowId", selectedRow);
          component.set("v.selectedProduct", selectedRows[0]);
        }
      } else {
        component.set("v.selectedRowId", []);
      }
    }
    //Multiple select
    else {
      selectedRows.forEach(row => {
        selectedRow.push(row.Id);
      });
      component.set("v.selectedRowId", selectedRow);
      component.set("v.selectedProduct", []);
    }
  }
});