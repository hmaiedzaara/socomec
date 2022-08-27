({
    doInit: function(component, event, helper) {
        //Open a new tab to access to QliSense
        helper.openNewTab(component);
    
        //Redirect to the current Salesforce page
        var url = window.location.href;
        var value = url.substr(0, url.lastIndexOf("/") + 1);
        window.history.back();
      }
})