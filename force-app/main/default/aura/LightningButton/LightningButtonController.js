({
	navTo : function(component, event, helper) {
        var allowBack = component.get('{!v.isRecord}');
        var recUrl = component.get('{!v.url}')
        
        var action = component.get("c.processURL");
        action.setParams({ "objectRecordID" : component.get("v.recordId"),
                            "urlStr":recUrl});

        //alert('==> 0 '+recUrl);
        action.setCallback(this, function(response) {

          var state = response.getState();
          if (state === "SUCCESS") {
            recUrl = response.getReturnValue();
          }
          //alert('==> '+recUrl);
          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            "url": recUrl,
            "isredirect" :allowBack
          });
          urlEvent.fire();

        });
        $A.enqueueAction(action);

	}
})