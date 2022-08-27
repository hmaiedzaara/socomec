({
  doInit: function(component, event, helper) {
    component.set("v.yearOfToday", new Date().getFullYear());

    var getCustomers = component.get("c.getCustomersLink");
    getCustomers.setParams({});
    getCustomers.setCallback(this, function(response){
      var state = response.getState();
      if(state === 'SUCCESS'){
        component.set("v.customersLinks", response.getReturnValue());
      }
    });

    var getCustomerPortal = component.get("c.getCustomerPortalLink");
    getCustomerPortal.setParams({});
    getCustomerPortal.setCallback(this, function(response){
      var state = response.getState();
      if(state === 'SUCCESS'){
        component.set("v.customerPortalLinks", response.getReturnValue());
      }
    });

    var getSupplierPortal = component.get("c.getSupplierPortalLink");
    getSupplierPortal.setParams({});
    getSupplierPortal.setCallback(this, function(response){
      var state = response.getState();
      if(state === 'SUCCESS'){
        component.set("v.supplierPortalLinks", response.getReturnValue());
      }
    });
    $A.enqueueAction(getCustomers, getCustomerPortal, getSupplierPortal);
    
  }
});