({
    setDefaultValues : function(component) {
        var action = component.get("c.setDefaultValues");
        action.setParams({
          recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            if (state == "SUCCESS" && result !== undefined && result !== null) {
                let resultParsed = JSON.parse(result);
                console.log('resultParsed', resultParsed);
                component.set("v.kindCase", resultParsed.kindCase);
                component.set("v.predefinedValues", resultParsed);
                component.set("v.showCreateCase", true);
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
})