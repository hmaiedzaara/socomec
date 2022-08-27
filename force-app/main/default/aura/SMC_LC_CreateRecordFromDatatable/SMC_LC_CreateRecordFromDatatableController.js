({
  doInit: function(component, event, helper) {
    component.set("v.isLoading", true);
    helper.getObjects(component, event, helper);
  },

  handleSave: function(component, event, helper) {
    component.set("v.isLoading", true);
    var draftValuesFind = component.find("dataTable").get("v.draftValues");
    var selectedRows = component.find("dataTable").getSelectedRows();

    draftValuesFind.forEach(function(element) {
      selectedRows.forEach(function(elementSelected) {
        if (elementSelected.id == element.id) {
          Object.keys(element).forEach(function(elmt) {
            elementSelected[elmt] = element[elmt];
          });
        }
      });
    });
    helper.saveObject(component, selectedRows);
  },

  handleOnlyBattery: function(component, event, helper) {
    component.set("v.isLoading", true);
    component.set("v.data", []);
    component.set("v.onlyBattery", !component.get("v.onlyBattery"));
    if(!component.get("v.onlyBattery")){
      component.set("v.factorOffset", 0);
      component.set("v.data", null);
    }
    helper.getObjects(component, event, helper);
  },

  handleLoadMore: function(component, event, helper) {
    component.set("v.isLoading", true);
    component.set("v.factorOffset", component.get("v.factorOffset") + 1);
    helper.getObjects(component, event, helper);
  },

  handleSearchSparePartCode: function(component, event, helper){
    let timeoutid = component.get("v.timeoutid");
    if(timeoutid !== null && timeoutid !== undefined){
      clearTimeout(timeoutid);
      component.set("v.timeoutid", null);
    }
    timeoutid = setTimeout(() => {
      component.set("v.isLoading", true);
      component.set("v.data", []);
      helper.getObjects(component, event, helper);
    }, 250);
    component.set("v.timeoutid", timeoutid);
  },
});