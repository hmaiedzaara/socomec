({
  recaptchaValidation: function(component, event, helper) {
    var validation = event.getParam("status");
    if (!validation) {
      alert("There is an error. Try again.");
    } else {
      component.set("v.recaptchaValidated", validation);
      try {
        component.find("warrantyForm").handleSaveContactInformations();
      } catch (error) {
        console.error(error);
        // expected output: ReferenceError: nonExistentFunction is not defined
        // Note - error messages will vary depending on browser
      }
    }
  },
  
  // doSubmit: function(component, event, helper) {
  //   // var validation = event.getParam("status");
  //   // if (!validation) {
  //   //   alert("There is an error. Try again.");
  //   // } else {
  //     component.set("v.recaptchaValidated", true);
  //     try {
  //       component.find("warrantyForm").handleSaveContactInformations();
  //     } catch (error) {
  //       console.error(error);
  //       // expected output: ReferenceError: nonExistentFunction is not defined
  //       // Note - error messages will vary depending on browser
  //     }
  //   // }
  // },

  updateIds: function(component, event, helper) {
    console.log('documentId', event.getParam("documentId"));
    component.set("v.documentId", event.getParam("documentId"));
    // component.set("v.caseId", event.getParam("recId"));
    try {
      component
        .find("warrantyForm")
        .handleDocumentId(event.getParam("documentId"));
      // component.find("warrantyForm").handleCaseId(event.getParam("recId"));
    } catch (error) {
      console.error(error);
      // expected output: ReferenceError: nonExistentFunction is not defined
      // Note - error messages will vary depending on browser
    }
  },

  handleReset: function(component, event, helper) {
    try {
      component.find("warrantyForm").handleResetInformations();
    } catch (error) {
      console.error(error);
      // expected output: ReferenceError: nonExistentFunction is not defined
      // Note - error messages will vary depending on browser
    }
  },

  handleSave: function(component, event, helper) {
    try {
      component.find("warrantyForm").handleSaveContactInformations();
    } catch (error) {
      console.error(error);
      // expected output: ReferenceError: nonExistentFunction is not defined
      // Note - error messages will vary depending on browser
    }
  },

  getRefreshView: function(component, event, helper) {
    component.set("v.refreshView", false);
    var theHelper = helper;
    setTimeout(() => {
      component.set("v.refreshView", true);
      theHelper.insertNewCase(component, event, helper);
    }, 100);
  }
});