({
  refreshServiceProductMethod: function(component, helper) {
    component.set("v.isLoading", true);
    var action = component.get("c.getServiceProduct");
    action.setParams({
      searchkey: "",
      gtlLineId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      component.set("v.isLoading", false);
      if (state == "SUCCESS") {
        component.set("v.isLoading", false);
        var serverData = JSON.parse(response.getReturnValue());
        component.set("v.serverData", serverData);
        var optionsList = [];
        helper.setOptionList(
          component,
          helper,
          serverData.serviceProductList,
          optionsList
        );
        helper.setSelectedList(
          component,
          helper,
          serverData.selectedServiceProductList,
          optionsList
        );
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  refreshSearchProductMethod: function(component, helper) {
    component.set("v.isLoading", true);
    var action = component.get("c.refreshServiceProduct");
    action.setParams({
      searchkey: component.get("v.searchKey"),
      factorOffset: component.get("v.factorOffset"),
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      component.set("v.isLoading", false);
      if (state == "SUCCESS") {
        var serverData = component.get("v.serverData");
        var productList = JSON.parse(response.getReturnValue());
        var optionsList = [];
        if(component.get("v.factorOffset") > 0){
          let oldProductListTmp = serverData.serviceProductList;
          serverData.serviceProductList = oldProductListTmp.concat(productList);
        }
        else{
          serverData.serviceProductList = productList;
        }
        component.set("v.serverData", serverData);
        helper.setOptionList(
          component,
          helper,
          serverData.serviceProductList,
          optionsList
        );
        helper.setSelectedList(
          component,
          helper,
          serverData.selectedServiceProductList,
          optionsList
        );
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  setOptionList: function(component, helper, serviceProductList, optionsList) {
    component.set("v.moreThanHundred", (serviceProductList.length == 100));
    serviceProductList.forEach(element => {
      optionsList.push({
        label: element.Name,
        value: element.Id
      });
    });
  },
  setSelectedList: function(
    component,
    helper,
    selectedServiceProductList,
    optionsList
  ) {
    var selectedList = [];
    var tmpSelectedList = [];
    if (component.get("v.initOrSave")) {
      selectedServiceProductList.forEach(element => {
        optionsList.push({
          label: element.SMC_Service_Product__r.Name,
          value: element.SMC_Service_Product__c
        });
        tmpSelectedList.push({
          label: element.SMC_Service_Product__r.Name,
          value: element.SMC_Service_Product__c
        });
        selectedList.push(element.SMC_Service_Product__c);
      });
      component.set("v.tmpValues", tmpSelectedList);
      component.set("v.initOrSave", false);
    } else {
      selectedList = [];
      component.get("v.tmpValues").forEach(element => {
        let elmtIsAlreadyInOptions = false;
        optionsList.forEach(elmt => {
          if (element.value == elmt.value) {
            elmtIsAlreadyInOptions = true;
          }
        });
        if (!elmtIsAlreadyInOptions) {
          optionsList.push({
            label: element.label,
            value: element.value
          });
        }
        selectedList.push(element.value);
      });
    }
    component.set("v.options", optionsList);
    component.set("v.values", selectedList);
    component.set("v.modificationSaved", true);
  },
  saveGtlLines: function(component, helper) {
    var action = component.get("c.updateAssociation");
    component.set("v.isLoading", true);
    action.setParams({
      idList: JSON.stringify(component.get("v.values")),
      gtlLineId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success",
          message: "GTL lines updated",
          type: "success"
        });
        toastEvent.fire();
        helper.refreshServiceProductMethod(component, helper);
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
      component.set("v.isLoading", false);
      component.set("v.initOrSave", true);
    });
    $A.enqueueAction(action);
    component.set("v.isLoading", true);
  }
});