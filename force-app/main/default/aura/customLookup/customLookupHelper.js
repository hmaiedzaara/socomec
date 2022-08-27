({
  searchHelper: function(component, event, getInputkeyWord) {
    // call the apex class method
    var action = component.get("c.fetchLookUpValues");
    var isParent = false;
    if (
      (component.get("v.selectedId") == null ||
        component.get("v.selectedId") == undefined) &&
      component.get("v.label").includes("Parent")
    ) {
      isParent = true;
    }
    action.setParams({
      searchKeyWord: getInputkeyWord,
      additionalWhere: component.get("v.additionalWhere"),
      ObjectName: component.get("v.objectAPIName"),
      isParent: isParent
    });
    // set a callBack
    action.setCallback(this, function(response) {
      $A.util.removeClass(component.find("mySpinner"), "slds-show");
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
        if (storeResponse.length == 0) {
          component.set("v.Message", "No Result Found...");
        } else {
          component.set("v.Message", "");
        }
        // set searchResult list with return value from server.
        var transformResponse = [];
        if (!isParent) {
          if (component.get("v.objectAPIName") != "Case") {
            component.set("v.listOfSearchRecords", storeResponse);
          } else {
            storeResponse.forEach(element => {
              transformResponse.push({
                Id: element.Id,
                Name: element.CaseNumber
              });
            });
            component.set("v.listOfSearchRecords", transformResponse);
          }
        } else {
          if (component.get("v.objectAPIName") != "Case") {
            storeResponse.forEach(element => {
              transformResponse.push({ Id: element.Id, Name: element.Name });
            });
          } else {
            storeResponse.forEach(element => {
              transformResponse.push({
                Id: element.Id,
                Name: element.CaseNumber
              });
            });
          }
          component.set("v.listOfSearchRecords", transformResponse);
        }
      }
    });
    // enqueue the Action
    $A.enqueueAction(action);
  },

  /*For Socomec*/
  getDefaultObject: function(component) {
    // call the apex class method
    var action = component.get("c.fetchDefaultObject");
    // set a callBack
    action.setParams({
      objectName: component.get("v.objectAPIName"),
      recordId: component.get("v.selectedId")
    });
    action.setCallback(this, function(response) {
      $A.util.removeClass(component.find("mySpinner"), "slds-show");
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        if (storeResponse != null) {
          // call the event
          var compEvent = component.getEvent("oSelectedRecordEvent");
          if (component.get("v.objectAPIName") != "Case") {
            // set the Selected sObject Record to the event attribute.
            compEvent.setParams({ recordByEvent: storeResponse });
          } else {
            compEvent.setParams({
              recordByEvent: {
                Id: storeResponse.Id,
                Name: storeResponse.CaseNumber
              }
            });
          }
          // fire the event
          compEvent.fire();
        }
      }
    });
    // enqueue the Action
    $A.enqueueAction(action);
  }
});