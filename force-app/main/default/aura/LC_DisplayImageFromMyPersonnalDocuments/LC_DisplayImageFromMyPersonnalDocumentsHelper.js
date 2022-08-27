({
  getIdDocumentFromImageName: function(component) {
    // Load report data
    var action = component.get("c.getIdDocumentFromImageName");
    action.setParams({
      Name: component.get("v.name"),
      prefixInterfaceName: component.get("v.prefixInterfaceName"),
      isPrefixByUserAlias: component.get("v.isPrefixByUserAlias"),
      isPrefixByTodayDate: component.get("v.isPrefixByTodayDate")
    });
    var self = this;
    action.setCallback(this, function(a) {
      var state = a.getState();
      if (state == "SUCCESS") {
        component.set("v.IdDocument", a.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  }
});