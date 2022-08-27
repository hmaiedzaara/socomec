({
  getKindCase: function(component) {
    var action = component.get("c.setKindCaseList");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.optionsKindCase", response.getReturnValue());
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
    });
    $A.enqueueAction(action);
  },

  goToList: function(component, event, helper) {
    var action = component.get("c.getCaseListView");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var caseListview = response.getReturnValue();
        var navEvent = $A.get("e.force:navigateToList");
        if (navEvent) {
          navEvent.setParams({
            listViewId: caseListview.Id,
            listViewName: caseListview.Name,
            scope: "Case"
          });
          window.close();
          navEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  },

  setSelectionCaseType: function(component, helper) {
    let pdv = component.get("v.predefinedValues");
    pdv = pdv != null ? JSON.stringify(component.get("v.predefinedValues")) : null;
    var action = component.get("c.setCaseTypeList");
    action.setParams({
      kindCase: component.get("v.selctedKindCase"), 
      pdv: pdv,
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        //Result
        var options = JSON.parse(response.getReturnValue());
        if (options.listActi.length === 1) {
          component.set("v.selctedTypeCase", options.listActi[0].caseTypeId);
          component.set("v.predefinedValues", options.pdv);
          helper.launchCreation(component, options.pdv);
        } else {
          var map = [];
          var elmtOther;
          var elmtMarketingToEnd;
          for (var key in options.listActi) {
            if (
              options.listActi[key].caseTypeName.includes("PIM/DAM")
            ) {
              elmtMarketingToEnd = {
                label: options.listActi[key].caseTypeName,
                value: options.listActi[key].caseTypeId,
                img: options.listActi[key].caseTypeImg
              };
            } else if(!options.listActi[key].caseTypeName.includes($A.get("$Label.c.SMC_Others"))){
              map.push({
                label: options.listActi[key].caseTypeName,
                value: options.listActi[key].caseTypeId,
                img: options.listActi[key].caseTypeImg
              });
            } else {
              elmtOther = {
                label: options.listActi[key].caseTypeName,
                value: options.listActi[key].caseTypeId,
                img: options.listActi[key].caseTypeImg
              };
            }
          }
          //Put element Marketing at the end of the list
          if (elmtMarketingToEnd != undefined && elmtMarketingToEnd != null) {
            map.push(elmtMarketingToEnd);
          }
          //Put element Others at the end of the list
          if (elmtOther != undefined && elmtOther != null) {
            map.push(elmtOther);
          }
          component.set("v.optionsTypeCase", map);
          component.set("v.predefinedValues", options.pdv);
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
    });
    $A.enqueueAction(action);
  },

  launchCreation: function(component, predefinedValues) {
    console.log('predefinedValues', JSON.parse(JSON.stringify(predefinedValues)));
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
      entityApiName: "Case",
      recordTypeId: component.get("v.selctedTypeCase")
    });

    //Set default fields values
    var kindCase = component.get("v.selctedKindCase");
    
    //For Sub-Case - From parent Case
    var parentCase = component.get("v.parentCase");
    if (parentCase != undefined && parentCase != null) {
      //Set default field value dynamically
      var setDefaultFieldValues = '{'; 
      if(parentCase.Id != null && parentCase.Id != undefined){
        setDefaultFieldValues += '"ParentId": "' + parentCase.Id + '",';
      }
      if(kindCase == "afterSales_LocalCallCenter"){
        if(parentCase.AccountId != null && parentCase.AccountId != undefined){
          setDefaultFieldValues += '"AccountId": "' + parentCase.AccountId + '",';
        }
        if(parentCase.ContactId != null && parentCase.ContactId != undefined){
          setDefaultFieldValues += '"ContactId": "' + parentCase.ContactId + '",';
        }    
      }
      if(parentCase.SMC_Internal_Requestor__c != null && parentCase.SMC_Internal_Requestor__c != undefined){
        setDefaultFieldValues += '"SMC_Internal_Requestor__c": "' + parentCase.SMC_Internal_Requestor__c + '",';
      }
      if(parentCase.SMC_SOV_Number__c != null && parentCase.SMC_SOV_Number__c != undefined){
        setDefaultFieldValues += '"SMC_SOV_Number__c": "' + parentCase.SMC_SOV_Number__c + '",';
      }
      if(parentCase.SMC_TECH_Closure_pilot__c != null && parentCase.SMC_TECH_Closure_pilot__c != undefined){
        setDefaultFieldValues += '"SMC_TECH_Closure_pilot__c": "' + parentCase.SMC_TECH_Closure_pilot__c + '",';
      }
      if(parentCase.SMC_Serial_Number__c != null && parentCase.SMC_Serial_Number__c != undefined){
        setDefaultFieldValues += '"SMC_Serial_Number__c": "' + parentCase.SMC_Serial_Number__c + '",';
      }
      if(parentCase.Subject != null && parentCase.Subject != undefined){
        setDefaultFieldValues += '"Subject": "' + $A.get("$Label.c.SMC_Sub_Case") + ' - ' + parentCase.Subject + '",';
      }
      if(parentCase.ProductId != null && parentCase.ProductId != undefined){
        setDefaultFieldValues += '"ProductId": "' + parentCase.ProductId + '",';
      }
      if(parentCase.SMC_Quote__c != null && parentCase.SMC_Quote__c != undefined){
        setDefaultFieldValues += '"SMC_Quote__c": "' + parentCase.SMC_Quote__c + '",';
      }
      if(parentCase.Opportunity__c != null && parentCase.Opportunity__c != undefined){
        setDefaultFieldValues += '"Opportunity__c": "' + parentCase.Opportunity__c + '",';
      }
      if(parentCase.SMC_End_customer__c != null && parentCase.SMC_End_customer__c != undefined){
        setDefaultFieldValues += '"SMC_End_customer__c": "' + parentCase.SMC_End_customer__c + '",' ;
      }
      setDefaultFieldValues = setDefaultFieldValues.slice(0, -1) + '}';
    
      //Set Param of the record
      createRecordEvent.setParam("defaultFieldValues", JSON.parse(setDefaultFieldValues));
  
    }
    //From Case ListView or another object
    else{
      //Set predefined field value dynamically
      var setDefaultFieldValuesFromListView = '{'; 
      if(predefinedValues.doNotShowInactiveProduct != null && predefinedValues.doNotShowInactiveProduct != undefined){
        setDefaultFieldValuesFromListView += '"TECH_SMC_Do_not_show_inactive_product__c": ' + predefinedValues.doNotShowInactiveProduct + ',';
      }
      if(predefinedValues.doNotShowServiceProduct != null && predefinedValues.doNotShowServiceProduct != undefined){
        setDefaultFieldValuesFromListView += '"SMC_Do_not_show_Service_Product__c": ' + predefinedValues.doNotShowServiceProduct + ',';
      }
      if(predefinedValues.doNotShowSalesProduct != null && predefinedValues.doNotShowSalesProduct != undefined){
        setDefaultFieldValuesFromListView += '"SMC_Do_not_show_Sales_Product__c": ' + predefinedValues.doNotShowSalesProduct + ',';
      }      
      if(predefinedValues.isCreateFromHypercare != null && predefinedValues.isCreateFromHypercare != undefined){
        setDefaultFieldValuesFromListView += '"SMC_Is_created_from_Hypercare_Case__c": ' + predefinedValues.isCreateFromHypercare + ',';
      }
      if(predefinedValues.internalUserId != null && predefinedValues.internalUserId != undefined){
        setDefaultFieldValuesFromListView += '"SMC_Internal_Requestor__c": "' + predefinedValues.internalUserId + '",';
      }
      if(predefinedValues.accountId != null && predefinedValues.accountId != undefined){
        setDefaultFieldValuesFromListView += '"AccountId": "' + predefinedValues.accountId + '",';
      }
      if(predefinedValues.contactId != null && predefinedValues.contactId != undefined){
        setDefaultFieldValuesFromListView += '"ContactId": "' + predefinedValues.contactId + '",';
      }
      if(predefinedValues.endCustomerId != null && predefinedValues.endCustomerId != undefined){
        setDefaultFieldValuesFromListView += '"SMC_End_customer__c": "' + predefinedValues.endCustomerId + '",';
      }
      if(predefinedValues.opportunityId != null  && predefinedValues.opportunityId != undefined){
        setDefaultFieldValuesFromListView += '"Opportunity__c": "' + predefinedValues.opportunityId + '",';
      }
      if(predefinedValues.quoteId != null && predefinedValues.quoteId != undefined){
        setDefaultFieldValuesFromListView += '"SMC_Quote__c": "' + predefinedValues.quoteId + '",';
      }
      setDefaultFieldValuesFromListView = setDefaultFieldValuesFromListView.slice(0, -1) + '}';
      console.log('setDefaultFieldValuesFromListView', setDefaultFieldValuesFromListView);

      createRecordEvent.setParam("defaultFieldValues", JSON.parse(setDefaultFieldValuesFromListView));
    }
    createRecordEvent.fire();
  }
});