!function(){window;(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[1],{1305:function(n,e,o){"use strict";o.r(e);var s="page_key",d="page_name",c="page_tree",l="page_views_list",a=[{key:"AtkFlatHomePage",name:"Home Page"},{key:"ContactInformation",name:"Personal Info - Contact Information"},{key:"FamilyAndEmergencyContacts",name:"Personal Info - Family and Emergency Contacts Page"},{key:"QuickCreateCommunication",name:"Personal Info - Family and Emergency Contacts Page - New Contact Page"},{key:"AddExistingContact",name:"Personal Info - Family and Emergency Contacts Page - Select a Coworker as a Contact"},{key:"PersonalDetails",name:"Personal Info - Personal Details Page"},{key:"RespMainDocumentsOfRecordFlow/RespDor",name:"Personal Info - Document Records Page"},{key:"MyDocumentsFlow/MyDocuments",name:"Personal Info - Identification Info Page"},{key:"EmploymentCard",name:"Personal Info - Employment Info Page"},{key:"EssCompensation",name:"Personal Info - Compensation Page"},{key:"EmploymentInformation",name:"Employment Details Page"},{key:"RatesWorkerCompensationMaxCard",name:"Compensation "},{key:"PersonalPaymentMethodManage",name:"Pay - Payment Methods"},{key:"TaxSummaryPage",name:"Pay - Tax Withholding"},{key:"PersonSkills",name:"Skills and Qualifications"},{key:"MyTeamOverview",name:"My Team Landing Page"},{key:"MyTeamCompTF",name:"My Team Compensation"},{key:"GuidedProcessCustomizationPage",name:"My Team - Promote - Customization"},{key:"PromotionContainer",name:"My Team - Promote Page"},{key:"TerminationContainer",name:"My Team - Terminate Page"},{key:"ChangeLocationContainer",name:"My Team - Borrow Associate Page"},{key:"HcmCommonPersonSearchFlow/HcmPersonSearchPage",name:"Person Search Page"}],y=function(n){for(var e=0;e<a.length;e++){var o=a[e];if(-1<n.indexOf(o.key))return o}},t=o(2502);function i(){}var r=new(i.prototype.start=function(){var n,e,o;return n=wmjQuery('img[src*="personId"]:visible'),e=n.attr("src"),o=n.attr("title"),window.personId=e&&e.substring(e.indexOf("=")+1,e.indexOf("&")),window.personName=o,window[l]="",window[d]="",window[s]="",window[c]="",Object(t.a)().then(function(n){return function(n){var e,o,a;if(void 0!==n){for(var t in n._clientIdToComponentMap)if(n._clientIdToComponentMap.hasOwnProperty(t)){var i=n._clientIdToComponentMap[t],r=null===(e=null==i?void 0:i._props)||void 0===e?void 0:e.viewId;r&&(window[l]+=r+", "+t+", ")}var m=y(window[l]);m&&(window[d]=m.name,window[s]=m.key),window[c]=null===(a=null===(o=null==n?void 0:n._clientIdToComponentMap[null==n?void 0:n._documentClientId])||void 0===o?void 0:o._props)||void 0===a?void 0:a.title}}(n)})},i);o.d(e,"init",function(){return m});var m=function(n){return r.start()}},2502:function(n,o,a){"use strict";(function(t,n){a.d(o,"a",function(){return e});var i=function(n,e,o){void 0===e&&(e=20),void 0===o&&(o=150);var a=window.page||window.AdfPage&&window.AdfPage.PAGE;a?n(a):0<e?t.get("TimerManager").libSetTimeout(function(){i(n,--e)},o):n()},e=function(){return new n(function(n){i(n)})}}).call(this,a(2),a(11))}}])}();