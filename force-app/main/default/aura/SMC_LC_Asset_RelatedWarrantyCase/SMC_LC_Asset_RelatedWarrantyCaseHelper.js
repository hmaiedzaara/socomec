({
  getCases: function(component, event, helper) {
    //Check filter
    helper.checkFilterSelected(component, event);

    //Get related list
    var action = component.get("c.getRelatedCase");
    action.setParam("assetId", component.get("v.recordId"));
    if (component.get("v.badFilterSelected") === undefined) {
      action.setParam("whereClause", component.get("v.filterWhereClause"));
    } else {
      component.set("v.whereClause", "-- None --");
    }
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.caseList", response.getReturnValue());
        component.set(
          "v.displayTableBool",
          response.getReturnValue().length > 0
        );
        component.set("v.mycolumns", [
          { label: "Case Number", fieldName: "CaseNumber", type: "text" },
          { label: "Subject", fieldName: "Subject", type: "text" },
          { label: "Status", fieldName: "Status", type: "text" },
          { label: "Sub Status", fieldName: "SMC_Sub_Status__c", type: "text" },
          {
            label: "Requested Deadline",
            fieldName: "SMC_Requested_Deadline__c",
            type: "date"
          },
          {
            type: "action",
            typeAttributes: {
              rowActions: [
                {
                  label: "Redirection",
                  iconName: "utility:expand",
                  name: "redirection"
                }
              ]
            }
          }
        ]);
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

  checkFilterSelected: function(component, event) {
    var filter = component.get("v.filterWhereClause");
    if (
      filter == "TYPE = TYPE" ||
      filter == "STATUS = STATUS" ||
      filter == "PRIORITY = PRIORITY" ||
      filter == "PRODUCT FAMILY = PRODUCT FAMILY"
    ) {
      component.set(
        "v.badFilterSelected",
        "The filter is incorrectly adjusted. Contact to your administrator to select a filter"
      );
    } else {
      component.set("v.badFilterSelected", undefined);
    }
  }
});