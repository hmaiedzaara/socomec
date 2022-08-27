({
  //Get Scoring
  getScoring: function(component, helper) {
    var account = component.get("v.account");
    var action = component.get("c.getTheScoring");
    action.setParams({
      accountSerialize: JSON.stringify(account),
      token: component.get("v.token"),
      baIds: component.get("v.baIds")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      var result = response.getReturnValue();
      if (state == "SUCCESS") {
        /*There is 2 list :
                    - scoring = memory list
                    - scoringShow = list for manipulation. It is this list whom will be display
                */
        var memoryList = result[0];
        component.set("v.scoring", memoryList);
        component.set(
          "v.isAuthorizeToSeeMaxSuggested",
          memoryList.userSeeMaxSuggested
        );

        var manipulatedList = result[1];
        component.set("v.scoringShow", manipulatedList);

        //The number of line is used to determinate if the scroll bar is display or not
        var numberOfVisibleLines = 0;
        // for (var j = 0; j < result[1].ba.length; ++j) {
        for (var i = 0; i < result[1].scoringLines.length; ++i) {
          ++numberOfVisibleLines;
        }
        // }
        component.set("v.numberOfVisibleLines", numberOfVisibleLines);
        // this.sortTab(component, helper, result[1]);
      } else {
        var errors = response.getError();
        if (errors) {
          if (errors && Array.isArray(errors) && errors.length > 0) {
            component.set(
              "v.errors",
              $A.get("$Label.c.SMC_AccessScoring_Error")
            );
          }
        } else {
          component.set("v.errors", "Unknown error");
        }
        component.set("v.isOpen", true);
      }
      component.set("v.isLoadingScoring", false);
    });
    $A.enqueueAction(action);
  },

  //Save the new Scoring and refresh view
  saveNewScoring: function(component, scoringShow) {
    var action = component.get("c.saveTheScoring");
    action.setParams({
      scoring: JSON.stringify(scoringShow),
      token: component.get("v.token"),
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      var toastEvent = $A.get("e.force:showToast");
      if (state == "SUCCESS") {
        //Close discount
        toastEvent.setParams({
          title: "Saved",
          message: "Your changes are saved.",
          type: "success"
        });
        $A.get("e.c:SMC_LC_EVT_CloseScoring").fire();
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
        toastEvent.setParams({
          title: "Error",
          message: errors,
          type: "error"
        });
        component.set("v.isOpen", true);
      }
      component.set("v.isSavingScoring", false);
      toastEvent.fire();
    });
    $A.enqueueAction(action);
  },

  //It is the controller of checkbox filters
  filtrage: function(component, event, helper, tellLinesToShowOrHideEvent) {
    var scoringShow = component.get("v.scoringShow");
    var wantedLinesId = [];

    var checkingDiscountMax = component
      .find("showOnlyDiscountMax")
      .get("v.value");
    // for (var i = 0; i < scoringShow.ba.length; ++i) {
    for (var j = 0; j < scoringShow.scoringLines.length; ++j) {
      //No filter
      if (!checkingDiscountMax) {
        wantedLinesId.push(scoringShow.scoringLines[j].id);
      }
      //Lines with discountTemp
      else if (checkingDiscountMax) {
        if (
          scoringShow.scoringLines[j].discount > scoringShow.scoringLines[j].max
        ) {
          wantedLinesId.push(scoringShow.scoringLines[j].id);
        }
      }
    }

    // }

    // Search filters
    var search = component.get("v.userinputPriceGroup");
    if (search == undefined || search == null) {
      search = "";
    }
    var searchDescription = component.get("v.userinputDescription");
    if (searchDescription == undefined || searchDescription == null) {
      searchDescription = "";
    }
    // for (var i = 0; i < scoringShow.ba.length; ++i) {
    for (var j = 0; j < scoringShow.scoringLines.length; ++j) {
      var strPriceGroup = scoringShow.scoringLines[
        j
      ].priceGroup.label.toLowerCase(); //Price group - pricegroup.id
      var strDescription = scoringShow.scoringLines[
        j
      ].priceGroup.description.toLowerCase(); //Description - pricegroup.label
      // if (!strPriceGroup.includes(search.toLowerCase())) {
      //     wantedLinesId.splice(wantedLinesId.indexOf(scoringShow.scoringLines[j].id), 1);
      // }
      if (
        !strPriceGroup.includes(search.toLowerCase()) ||
        !strDescription.includes(searchDescription.toLowerCase())
      ) {
        wantedLinesId.splice(
          wantedLinesId.indexOf(scoringShow.scoringLines[j].id),
          1
        );
      }
    }

    // }

    var numberOfVisibleLines = 0;
    for (var i = 0; i < wantedLinesId.length; ++i) {
      ++numberOfVisibleLines;
    }

    component.set("v.numberOfVisibleLines", numberOfVisibleLines);

    tellLinesToShowOrHideEvent.setParams({
      linesToDisplay: wantedLinesId
    });
    tellLinesToShowOrHideEvent.fire();
  }
});