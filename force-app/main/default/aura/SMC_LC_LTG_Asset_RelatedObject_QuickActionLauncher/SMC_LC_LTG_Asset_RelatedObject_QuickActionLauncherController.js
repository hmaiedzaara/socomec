({
  newFirmawareAction: function(cmp, event, helper) {
    var actionAPI = cmp.find("quickActionAPI");
    actionAPI.getAvailableActions().then(function(result) {
      console.log("manu promise + result " + JSON.stringify(result));
    });
    var args = { actionName: "Asset.SMC_New_firmware" };
    actionAPI
      .selectAction(args)
      .then(function(result) {
        //Action selected; show data and set field values
      })
      .catch(function(e) {
        if (e.errors) {
          //If the specified action isn't found on the page, show an error message in the my component
        }
      });
  },

  createGroupLevelAction: function(cmp, event, helper) {
    var actionAPI = cmp.find("quickActionAPI");
    //var fields = {Status: {value: "Closed"}, Subject: {value: "Sets by lightning:quickActionAPI component"}, accountName: {Id: accountId}};
    var args = { actionName: "Asset.SMC_Create_Related_Objects" };
    actionAPI
      .selectAction(args)
      .then(function() {})
      .catch(function(e) {
        console.error(e.errors);
      });
  }
});