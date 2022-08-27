({
  doInit: function(component, event, helper) {
    component.set("v.columns", [
      {
        label: $A.get("$Label.c.SMC_Product_Name"),
        fieldName: "Name",
        type: "text"
      },
      // { label: $A.get('$Label.c.SMC_ProductCode'), fieldName: 'ProductCode', type: 'text' },
      {
        label: $A.get("$Label.c.SMC_Manufacturer"),
        fieldName: "SMC_Manufacturer_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Range"),
        fieldName: "SMC_Range_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Model"),
        fieldName: "SMC_Model_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Configuration"),
        fieldName: "SMC_Configuration_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Phase"),
        fieldName: "SMC_Phase_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Power"),
        fieldName: "SMC_Power_p__c",
        type: "text"
      },
      {
        label: $A.get("$Label.c.SMC_Power_Unit"),
        fieldName: "SMC_Power_Unit_p__c",
        type: "text"
      }
    ]);
    helper.filtrageManufacturer(component, event, helper);
  },

  filtrageManufacturer: function(component, event, helper) {
    var action = component.get("c.getCacheManufacturer");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        for (var key in options) {
          map.push({ key: key, value: key });
        }
        component.set("v.listManufacturer", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  filtrageRange: function(component, event, helper) {
    var action = component.get("c.getCacheRange");
    action.setParam(
      "manufacturer",
      component.find("selectManufacturer").get("v.value")
    );
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        for (var key in options) {
          map.push({ key: options[key], value: options[key] });
        }
        component.set("v.listRange", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  filtrageModel: function(component, event, helper) {
    var action = component.get("c.getCacheModel");
    action.setParam("range", component.find("selectRange").get("v.value"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        //Manufacturer
        for (var key in options) {
          map.push({ key: options[key], value: options[key] });
        }
        component.set("v.listModel", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  filtrageConfiguration: function(component, event, helper) {
    var action = component.get("c.getCacheConfiguration");
    action.setParam("model", component.find("selectModel").get("v.value"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        //Manufacturer
        for (var key in options) {
          map.push({ key: options[key], value: options[key] });
        }
        component.set("v.listConfiguration", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  filtragePhase: function(component, event, helper) {
    var action = component.get("c.getCachePhase");
    action.setParam(
      "configuration",
      component.find("selectConfiguration").get("v.value")
    );
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        //Manufacturer
        for (var key in options) {
          map.push({ key: options[key], value: options[key] });
        }
        component.set("v.listPhase", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  filtragePower: function(component, event, helper) {
    var action = component.get("c.getCachePower");
    action.setParam("phase", component.find("selectPhase").get("v.value"));
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var options = JSON.parse(response.getReturnValue());
        var map = [];
        //Manufacturer
        for (var key in options) {
          map.push({ key: options[key], value: options[key] });
        }
        component.set("v.listPower", map);
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
      helper.filtrage(component, event, helper);
    });
    $A.enqueueAction(action);
  },

  //It is the controller of checkbox whereClause
  filtrage: function(component, event, helper) {
    // Search whereClause
    var whereClause = "";

    //Product Name
    var searchInputName = component.get("v.inputName");
    if (searchInputName == undefined || searchInputName == null) {
      searchInputName = "";
    }

    //Product Code
    var searchInputCode = component.get("v.inputCode");
    if (
      searchInputCode != undefined &&
      searchInputCode != null &&
      searchInputCode != "" &&
      searchInputCode != $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause += '"productCode":"' + searchInputCode + '",';
    }

    //Manufacturer
    var searchListManufacturerElmt = component.find("selectManufacturer");
    if (
      searchListManufacturerElmt != undefined &&
      searchListManufacturerElmt.get("v.value") != undefined &&
      searchListManufacturerElmt.get("v.value") != null &&
      searchListManufacturerElmt.get("v.value") != "" &&
      searchListManufacturerElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause +=
        '"manufacturer":"' + searchListManufacturerElmt.get("v.value") + '",';
    }

    //Range
    var searchListRangeElmt = component.find("selectRange");
    if (
      searchListRangeElmt != undefined &&
      searchListRangeElmt.get("v.value") != undefined &&
      searchListRangeElmt.get("v.value") != null &&
      searchListRangeElmt.get("v.value") != "" &&
      searchListRangeElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause += '"range":"' + searchListRangeElmt.get("v.value") + '",';
    }

    //Model
    var searchListModelElmt = component.find("selectModel");
    if (
      searchListModelElmt != undefined &&
      searchListModelElmt.get("v.value") != undefined &&
      searchListModelElmt.get("v.value") != null &&
      searchListModelElmt.get("v.value") != "" &&
      searchListModelElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause += '"model":"' + searchListModelElmt.get("v.value") + '",';
    }

    //Configuration
    var searchListConfigurationElmt = component.find("selectConfiguration");
    if (
      searchListConfigurationElmt != undefined &&
      searchListConfigurationElmt.get("v.value") != undefined &&
      searchListConfigurationElmt.get("v.value") != null &&
      searchListConfigurationElmt.get("v.value") != "" &&
      searchListConfigurationElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause +=
        '"configuration":"' + searchListConfigurationElmt.get("v.value") + '",';
    }

    //Phase
    var searchListPhaseElmt = component.find("selectPhase");
    if (
      searchListPhaseElmt != undefined &&
      searchListPhaseElmt.get("v.value") != undefined &&
      searchListPhaseElmt.get("v.value") != null &&
      searchListPhaseElmt.get("v.value") != "" &&
      searchListPhaseElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause += '"phase":"' + searchListPhaseElmt.get("v.value") + '",';
    }

    //Power
    var searchListPowerElmt = component.find("selectPower");
    if (
      searchListPowerElmt != undefined &&
      searchListPowerElmt.get("v.value") != undefined &&
      searchListPowerElmt.get("v.value") != null &&
      searchListPowerElmt.get("v.value") != "" &&
      searchListPowerElmt.get("v.value") !=
        $A.get("$Label.c.SMC_DefaultPicklistValue_None")
    ) {
      whereClause += '"power":"' + searchListPowerElmt.get("v.value") + '",';
    }

    //Adjust whereClause
    if (whereClause.length > 0) {
      whereClause =
        "{" + whereClause.substring(0, whereClause.length - 1) + "}";
    }

    if (
      (component.get("v.inputName") != undefined &&
        component.get("v.inputName").length >= 2) ||
      whereClause != ""
    ) {
      helper.getAllProduct(component, event, helper, whereClause);
    } else {
      component.set("v.isLoading", false);
    }
  },

  getAllProduct: function(component, event, helper, whereClause) {
    var action = component.get("c.getAllProduct");
    action.setParams({
      productName: component.get("v.inputName"),
      jsonWhereClause: whereClause
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS" && response.getReturnValue() != null) {
        component.set("v.data", response.getReturnValue());
        component.set("v.errors", null);
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
  }
});