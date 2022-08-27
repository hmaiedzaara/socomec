({
  doInit: function(component, event, helper) {
    // Retrieve report rows during component initialization
    helper.getAmountPipe(component);
    helper.getProjectNumberPipe(component);
    helper.getUserDefaultCurrency(component);
  }
});