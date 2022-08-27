({
  doInit: function(component, event, helper) {
    component.set("v.isLoadingScoring", true);
    component.set("v.isSavingScoring", false);
    component.set("v.errors", "");

    //We need to have the Account id (present in the URL) to load informations
    // var url = decodeURIComponent(window.location.search.substring(1));
    // var strs = url.split("=");
    // var recId = strs[1];
    // var urlPageForIE = recId.substring(0, 18);
    helper.getScoring(component, helper, component.get("v.recordId"));
  },

  //Ne fonctionne pas pour le moment
  saveScoring: function(component, event, helper) {
    component.set("v.unsaved", false);
    component.set("v.isSavingScoring", true);
    var scoring = component.get("v.scoring");
    var scoringShow = component.get("v.scoringShow");

    var checkIfAtLeastOneLineIsChanged = false;
    // for (var i = 0; i < scoring.ba.length; ++i) {
    for (var j = 0; j < scoring.scoringLines.length; ++j) {
      if (
        scoringShow.scoringLines[j].discount != scoring.scoringLines[j].discount
      ) {
        scoringShow.scoringLines[j].isModified = true;
        checkIfAtLeastOneLineIsChanged = true;
      }
      scoringShow.scoringLines[j].createDate = null;
      // if (scoringShow.scoringLines[j].maxSuggested != scoring.scoringLines[j].maxSuggested) {
      //     scoringShow.scoringLines[j].isModified = true;
      // }
    }
    // }
    if (!checkIfAtLeastOneLineIsChanged) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "No change apply",
        message: "You tried to save the discount but there is no change.",
        type: "warning"
      });
      toastEvent.fire();
      component.set("v.isSavingScoring", false);
    } else if (component.get("v.unsaved") == false) {
      helper.saveNewScoring(component, scoringShow);
    } else {
      component.set("v.isSavingScoring", false);
    }
  },

  //Hide or show the column "Max Suggested"
  hiddeMaxSuggested: function(component) {
    var checking = component.find("hiddeMaxSuggested").get("v.value");
    component.set("v.userSeeMaxSuggested", checking);
  },

  // //It is the controlelr of the tab
  // selectBa: function (component, event, helper) {
  // 	var scoringShow = component.get("v.scoringShow");

  // 	//Remove class on all elements
  // 	for (var i = 0; i < scoringShow.ba.length; ++i) {
  // 		var tab = component.find("tab");
  // 		var rows = component.find("rows");
  // 		$A.util.removeClass(tab[i], "slds-is-active");
  // 		$A.util.removeClass(rows[i], "slds-show");
  // 		$A.util.addClass(rows[i], "slds-hide");

  // 		//Add class on focused elements
  // 		if (scoringShow.dpx.businessApplication.id == event.target.getAttribute("data-id")) {
  // 			$A.util.addClass(tab[i], "slds-is-active");
  // 			$A.util.addClass(rows[i], "slds-show");
  // 			$A.util.removeClass(rows[i], "slds-hide");

  // 			var numberOfVisibleLines = 0;
  // 			for (var j = 0; j < scoringShow.scoringLines.length; ++j) {
  // 				++numberOfVisibleLines;
  // 			}
  // 			component.set("v.numberOfVisibleLines", numberOfVisibleLines);
  // 		}
  // 	}
  // },

  timeoutFiltrage: function(component, event, helper) {
    var tellLinesToShowOrHideEvent = $A.get("e.c:SMC_LC_EVT_Scoring");
    var timer = component.get("v.timer");

    clearTimeout(timer);

    var timer = setTimeout(function() {
      clearTimeout(timer);
      helper.filtrage(component, event, helper, tellLinesToShowOrHideEvent);
      component.set("v.timer", null);
    }, 1000);

    component.set("v.timer", timer);
  }
});