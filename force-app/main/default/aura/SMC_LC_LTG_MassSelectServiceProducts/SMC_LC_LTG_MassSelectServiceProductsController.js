({
  doInit: function(component, event, helper) {
    helper.refreshServiceProductMethod(component, helper);
  },
  handleChange: function(component, event, helper) {
    let selectedValues = [];
    component.get("v.values").forEach(element => {
      component.get("v.options").forEach(elmt => {
        if (element == elmt.value) {
          selectedValues.push({ label: elmt.label, value: elmt.value });
        }
      });
    });
    component.set("v.tmpValues", selectedValues);
  },
  handleSaveClick: function(component, event, helper) {
    component.set("v.modificationSaved", false);
    helper.saveGtlLines(component, helper);
  },
  handleKeyUp: function(component, event, helper) {
    component.set("v.factorOffset", 0);
    var isEnterKey = event.keyCode === 13;
    if (isEnterKey) {
      let timeoutid = component.get("v.timeoutid");
      if(timeoutid !== null && timeoutid !== undefined){
        clearTimeout(timeoutid);
        component.set("v.timeoutid", null);
      }
      timeoutid = setTimeout(() => {
        helper.refreshSearchProductMethod(component, helper);
      }, 100);
    }
  },
  handleButtonSearch: function(component, event, helper) {
    component.set("v.factorOffset", 0);
    let timeoutid = component.get("v.timeoutid");
    if(timeoutid !== null && timeoutid !== undefined){
      clearTimeout(timeoutid);
      component.set("v.timeoutid", null);
    }
    timeoutid = setTimeout(() => {
      component.set("v.options", []);
      helper.refreshSearchProductMethod(component, helper);
    }, 100);
  },
  handleLoadMore: function(component, event, helper) {
    component.set("v.factorOffset", component.get("v.factorOffset") + 1);
    helper.refreshSearchProductMethod(component, helper);
  },
});