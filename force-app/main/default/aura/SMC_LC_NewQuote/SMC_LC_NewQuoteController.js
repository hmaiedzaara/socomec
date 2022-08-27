({
  doInit: function(component, event, helper) {
    helper.getInformations(component, event, helper);
  },

  getContacts: function(component, event, helper) {
    component.set("v.warningMissingFields", null);
    var defaultAccount = component.get("v.defaultAccount");
    if (defaultAccount != "-- None --") {
      helper.getContactsFromHelper(component, event, helper);
    } else {
      var contactListNone = component.get("v.contactListNone");
      component.set("v.allInformations.contacts", contactListNone);
    }
  },

  checkAccountAndContactFields: function(component, event, helper) {
    component.set("v.warningMissingFields", null);
    var defaultContact = component.get("v.defaultContact");
    if (defaultContact != "-- None --") {
      helper.checkAccountAndContact(component, event, helper);
    }
  },

  synchrinizedOpportunity: function(component, event, helper) {
    var check = component.find("isSynchronize").get("v.value");
    component.set("v.isSync", check);
  },

  redirectionToCorrection: function(component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/" + event.target.getAttribute("data-id")
    });
    urlEvent.fire();
  },

  handleSaveQuote: function(component, event, helper) {
    component.set("v.isLoading", true);

    // var defaultOwner = component.get("v.defaultOwner");
    // var defaultAccount = component.get("v.defaultAccount");

    var newQuote = component.get("v.newQuote");
    if (
      newQuote.Name != null &&
      newQuote.Name != undefined &&
      newQuote.Name != ""
    ) {
      helper.saveQuote(component, event, helper);
    } else {
      component.set("v.isLoading", false);
      component.set("v.errors", "Fill all field to create a new Quote.");
    }
  },

  openCorrector: function(component, event, helper) {
    var div = component.find("divCorrector");
    $A.util.removeClass(div, "slds-hide");
  }
});