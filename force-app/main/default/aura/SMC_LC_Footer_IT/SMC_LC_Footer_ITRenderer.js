({
  afterRender: function(component, helper) {
    //Facebook
    var svgDivFacebook = component.find("svg_content_facebook").getElement();
    var valFacebook = svgDivFacebook.innerText;
    if (typeof valFacebook !== "undefined") {
      valFacebook = valFacebook.replace("<![CDATA[", "").replace("]]>", "");
      svgDivFacebook.innerHTML = valFacebook;
    }
    //Twitter
    var svgDivTwitter = component.find("svg_content_twitter").getElement();
    var valTwitter = svgDivTwitter.innerText;
    if (typeof valTwitter !== "undefined") {
      valTwitter = valTwitter.replace("<![CDATA[", "").replace("]]>", "");
      svgDivTwitter.innerHTML = valTwitter;
    }
    //Youtube
    var svgDivYoutube = component.find("svg_content_youtube").getElement();
    var valYoutube = svgDivYoutube.innerText;
    if (typeof valYoutube !== "undefined") {
      valYoutube = valYoutube.replace("<![CDATA[", "").replace("]]>", "");
      svgDivYoutube.innerHTML = valYoutube;
    }
    //Linkedin
    var svgDivLinkedin = component.find("svg_content_linkedin").getElement();
    var valLinkedin = svgDivLinkedin.innerText;
    if (typeof valLinkedin !== "undefined") {
      valLinkedin = valLinkedin.replace("<![CDATA[", "").replace("]]>", "");
      svgDivLinkedin.innerHTML = valLinkedin;
    }
    //Contact Email
    if (
      component.find("svg_content_contactemail") !== undefined &&
      component.find("svg_content_contactemail") !== null
    ) {
      var svgDivCtcEmail = component
        .find("svg_content_contactemail")
        .getElement();
      var valCtcEmail = svgDivCtcEmail.innerText;
      if (typeof valCtcEmail !== "undefined") {
        valCtcEmail = valCtcEmail.replace("<![CDATA[", "").replace("]]>", "");
        svgDivCtcEmail.innerHTML = valCtcEmail;
      }
    }
  }
});