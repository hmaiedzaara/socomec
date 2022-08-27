({
  doInit: function(component, event, helper) {
    component.set("v.blockTitle", $A.get("$Label.c.SMC_Create_Case"));
    var predefinedValues = component.get("v.predefinedValues");
    //FROM another object than Case
    if(predefinedValues !== undefined && predefinedValues !== null){
      helper.setSelectionCaseType(component, helper);
    }
    //From Case
    else{
      helper.getKindCase(component);
    }
  },

  cancelStep: function(component, event, helper) {
    var parentCase = component.get("v.parentCase");
    if (parentCase == null || parentCase == undefined) {
      helper.goToList(component, event, helper);
    } else {
      var closeEvent = $A.get("e.c:SMC_LE_Close_SoSales_CreateCase");
      if (closeEvent) closeEvent.fire();
    }
  },

  previousStep: function(component, event, helper) {
    // helper.setSelectionCaseType(component, helper);
    component.set("v.selctedTypeCase", null);
    component.set("v.selctedKindCase", null);
    component.set("v.optionsTypeCase", []);
    component.set("v.blockTitle", $A.get("$Label.c.SMC_Create_Case"));
    component.set("v.chooseKindCase", true);
    component.set("v.chooseTypeCase", false);
  },

  kindIsChoose: function(component, event, helper) {
    component.set("v.selctedKindCase", event.currentTarget.id);
    var kindCase = component.get("v.selctedKindCase");
    //Change title
    if (kindCase == $A.get("$Label.c.SMC_TECH_AFS_BA_Identifier")) {
      component.set(
        "v.blockTitle",
        $A.get("$Label.c.SMC_Create_Case_BA_Service")
      );
    } else if (kindCase == $A.get("$Label.c.SMC_TECH_AFS_LCC_Identifier")) {
      component.set("v.blockTitle", $A.get("$Label.c.SMC_Create_Case_LCC"));
    }
    //Go to the next step
    component.set("v.chooseKindCase", false);
    component.set("v.chooseTypeCase", true);
    helper.setSelectionCaseType(component, helper);
  },

  typeIsChoose: function(component, event, helper) {
    component.set("v.selctedTypeCase", event.currentTarget.id);
    helper.launchCreation(component, component.get("v.predefinedValues"));
  }
});