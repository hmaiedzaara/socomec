({
  getAmountPipe: function(component) {
    // Load report data
    var action = component.get("c.getAmountPipe");
    var self = this;
    action.setCallback(this, function(a) {
      component.set("v.amount", a.getReturnValue());
    });
    $A.enqueueAction(action);
  },
  getProjectNumberPipe: function(component) {
    // Load report data
    var action = component.get("c.getProjectNumberPipe");
    var self = this;
    action.setCallback(this, function(a) {
      component.set("v.projectNbs", a.getReturnValue());
    });
    $A.enqueueAction(action);
  },
  getUserDefaultCurrency: function(component) {
    // Load report data
    var action = component.get("c.getUserDefaultCurrency");
    var self = this;
    action.setCallback(this, function(a) {
      component.set("v.userDefaultCurrency", a.getReturnValue());
    });
    $A.enqueueAction(action);
  }
});