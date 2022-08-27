({
  lauchQuotationTool: function(component, event, helper) {
    //Get the Contact ID Record
    var recId = component.get("v.recordId");
    var action = component.get("c.checkInformationsValidity");
    action.setParams({
      recId: recId
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //The value returned contains authorization for redirection and the URL
        //OR
        //The value returned contains authorization for redirection and restriction message
        var options = response.getReturnValue();
        if (options.isRedirect) {
          //Redirection to the new Quotation Tool
          var navEvtUrl = $A.get("e.force:navigateToURL");
          navEvtUrl.setParams({
            url: options.resultList[0]
          });
          console.log('options', options);
          console.log('navEvtUrl', navEvtUrl);
          navEvtUrl.fire();
          $A.get("e.force:closeQuickAction").fire();
        } else {
          if (options.dtoMissingFields != null) {
            component.set("v.warningMissingFields", options.dtoMissingFields);
          } else {
            component.set(
              "v.errors",
              $A.get("$Label.c.SMC_QuotaitonToolAccesDenied")
            );
          }
        }
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.errors", errors[0].message);
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
      }
      //component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  }
});