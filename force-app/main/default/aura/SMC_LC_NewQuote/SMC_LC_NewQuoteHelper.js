({
  getInformations: function(component, event, helper) {
    var recId = component.get("v.recordId");
    var action = component.get("c.getInformations");
    action.setParam("recId", recId);
    action.setCallback(this, function(response) {
      var state = response.getState();
      component.set("v.isLoading", false);
      if (state === "SUCCESS") {
        var options = response.getReturnValue();

        //If wrong permission set for this user, options == null
        if (options != null) {
          var opportunity = options.opportunity;
          var newQuote = options.newQuote;

          //Set all attributes
          component.set("v.allInformations", options);
          component.set("v.newOpportunity", opportunity);
          component.set("v.newQuote", newQuote);

          component.set("v.contactListNone", options.contacts);
          component.set("v.defaultAccount", options.accounts[0].Id);
          component.set("v.defaultContact", options.contacts[0].Id);

          component.set("v.hasSyncQuote", options.hasSyncQuote);
          component.set("v.warningMissingFields", options.dtoMissingFields);

          component.set("v.users", options.users);
          component.set("v.defaultOwner", options.users[0].Id);
          component.set("v.defaultReminderPilot", options.defaultReminderPilot);
        } else {
          component.set("v.errors", $A.get("$Label.c.SMC_PermissionError"));
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
    });
    $A.enqueueAction(action);
  },

  saveQuote: function(component, event, helper) {
    var recId = component.get("v.recordId");
    var newQuote = component.get("v.newQuote");
    var accountSelectedId = component.get("v.defaultAccount");
    var contactSelectedId = component.get("v.defaultContact");
    var ownerSelectedId = component.get("v.defaultOwner");
    var reminderPilotSlectedId = component.get("v.defaultReminderPilot");
    var isSync = component.get("v.isSync");

    var action = component.get("c.saveNewQuote");
    action.setParams({
      recId: recId,
      quote: newQuote,
      accountId: accountSelectedId,
      contactId: contactSelectedId,
      ownerId: ownerSelectedId,
      reminderPilot: reminderPilotSlectedId,
      isSync: isSync
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //The response.getReturnValue() contains the id of the new Quote
        var newQuoteId = response.getReturnValue();

        //Redirection to the new Quote related page
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: newQuoteId,
          slideDevName: "related"
        });
        navEvt.fire();
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
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  }
});