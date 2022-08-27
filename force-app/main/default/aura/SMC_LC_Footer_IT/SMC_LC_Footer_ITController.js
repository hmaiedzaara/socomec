({
  doInit: function(component, event, helper) {
    component.set("v.yearOfToday", new Date().getFullYear());

    var getOnlineOrderingPortal = component.get("c.getOnlineOrderingPortalLink");
    getOnlineOrderingPortal.setParams({});
    getOnlineOrderingPortal.setCallback(this, function(response){
      var state = response.getState();
      if(state === 'SUCCESS'){
        component.set("v.onlineOrderingPortalLinks", response.getReturnValue());
      }
    });

    var getWarrantyRegistration = component.get("c.getWarrantyRegistrationLink");
    getWarrantyRegistration.setParams({});
    getWarrantyRegistration.setCallback(this, function(response){
      var state = response.getState();
      if(state === 'SUCCESS'){
        component.set("v.warrantyRegistrationLinks", response.getReturnValue());
      }
    });
    $A.enqueueAction(getOnlineOrderingPortal, getWarrantyRegistration);
  }
});