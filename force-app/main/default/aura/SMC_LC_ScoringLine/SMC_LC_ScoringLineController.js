({
  doInit: function(component, event, helper) {
    var isInit = true;
    helper.checkDoubleInteger(component, event, helper, isInit);
  },

  onDiscountBlur: function(component, event, helper) {
    component.set("v.toggleIconValidity", false);

    var line = component.get("v.line");

    //To limit discount in range (0 - 100)
    var discount = component.find("discount");
    line.discount = discount.getElement().value;
    if (line.discount > 100) {
      line.discount = 100;
    }
    if (line.discount < 0) {
      line.discount = 0;
    }
    line.discount = Math.round(10 * line.discount) / 10; //To limit discount with one decimal

    var isInit = false;
    helper.checkDoubleInteger(component, event, helper, isInit);
  },

  onMaxSuggestedBlur: function(component, event, helper) {
    var line = component.get("v.line");

    //Max Suggested
    var maxSuggested = component.find("maxSuggested");
    line.maxSuggested = maxSuggested.getElement().value;
    if (line.maxSuggested > line.max) {
      line.maxSuggested = line.max;
    }
    if (line.maxSuggested < line.min) {
      line.maxSuggested = line.min;
    }

    component.set("v.line", line);
  },

  toggleDisplayOnFilter: function(component, event, helper) {
    component.set("v.isShowingOnFilter", false);

    var lineId = component.get("v.line.id");
    var linesToDisplay = event.getParam("linesToDisplay");
    for (var i = 0; i < linesToDisplay.length; i++) {
      if (linesToDisplay[i] == lineId) {
        component.set("v.isShowingOnFilter", true);
      }
    }
  }
});