({
  doInit: function(component, event, helper) {
    //Open a new tab to access to CIMsa
    var action = component.get("c.getRelatedWarrantyCase");
    action.setParam("sourceCaseId", component.get("v.recordId"));

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
      }
    });
    $A.enqueueAction(action);
  },

  redirectToCase: function(component, event, helper) {
    var action = event.getParam("action");
    var row = event.getParam("row");

    var url = window.location.href;
    var tmpValue = url.substr(0, url.lastIndexOf("/"));
    var resultValut = tmpValue.substr(
      0,
      tmpValue.lastIndexOf("/") + row.Id + "/" + row.Subject
    );
    // window.history.back();
  }
});