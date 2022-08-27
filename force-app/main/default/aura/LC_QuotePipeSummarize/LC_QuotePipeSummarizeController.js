({
  doInit: function(component, event, helper) {
    // Retrieve report rows during component initialization
    helper.getAmountPipe(component);
    helper.getQuoteNumberPipe(component);
    helper.getUserDefaultCurrency(component);
  }
});