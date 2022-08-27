({
  doInit: function(component, event, helper) {
    // var id = component.get("v.oneProcessInstance.processInstanceId");
    var divId = component.find(
      component.get("v.oneProcessInstance.processInstanceId")
    );
    divId.getElement().addEventListener("click", function() {
      toggleMenu();
    });

    divId.getElement().addEventListener("blur", function() {
      setTimeout(function() {
        hideMenu();
      }, 100);
    });
  },

  toggleMenu: function(component, event, helper) {
    document
      .getElementsByClassName(component.get("v.idxIteration"))
      .classList.toggle("hide");
  },

  hideMenu: function(component, event, helper) {
    document
      .getElementsByClassName(component.get("v.idxIteration"))
      .classList.add("hide");
  },

  redirection: function(component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/" + event.target.getAttribute("data-id")
    });
    urlEvent.fire();
  }
});