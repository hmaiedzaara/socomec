({
  checkDoubleInteger: function(component, event, helper, isInit) {
    var theLine = component.get("v.line");
    //Check if discount is empty
    if (theLine.discount.toString().length == 0) {
      theLine.discount = 0;
    }
    //Check if discount is integer
    var isDoubleInteger =
      Math.floor(theLine.discount) == Math.ceil(theLine.discount);
    if (isDoubleInteger && !theLine.discount.toString().includes(".")) {
      theLine.discount = theLine.discount + ".0";
    }

    component.set("v.toggleIconValidity", true);

    if (!isInit) {
      var newDateStr = new Date().toDateString();
      theLine.createDate =
        newDateStr.substring(8, 10) +
        " " +
        newDateStr.substring(4, 7) +
        " " +
        newDateStr.substring(11, 16);
    }

    component.set("v.line", theLine);
  }
});