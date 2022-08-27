window,window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[4],{1258:function(t,e,i){"use strict";i.r(e),i.d(e,"AttentionGrabber",function(){return o});var r=i(167);function o(t){var e;t.agData?i=t.agData.ClassType:(e=t.config.Settings.AG)&&(i=e.type);var i=i||0;return r.create({0:"ImageAttentionGrabber",1:"OldSwooshAttentionGrabber",2:"SwooshAttentionGrabber",3:"MenuOverviewAttentionGrabber",4:"TickerAttentionGrabber",5:"CustomTextAttentionGrabber",6:"CustomImageAttentionGrabber","3.sub":"MenuOverviewSubAttentionGrabber"}[i],t)}i(1331),i(1362),i(1462),i(1405),i(1463),i(1464),i(1465),i(1466),i(1467),i(1340),i(1468),i(1469),r.register("AttentionGrabber").asFunction(o).asProto()},1331:function(t,e,i){"use strict";i.r(e),i.d(e,"AttentionGrabberBase",function(){return r});var l=i(167),r=(o.prototype.drawAttentionGrabber=function(){var t;this._logger.customerLog("Start drawing attention grabber",5),this._replayTimeoutHandler&&this._replayTimeoutHandler.clear(),this._attentionGrabber=this.getHtml(),this._attentionGrabber&&(this._attentionGrabberWrapper=this._domManager.parseElementAsJquery("<div id='walkme-attengrab' class='walkme-to-destroy' style='display: none;'/>"),this._attentionGrabberWrapper.append(this._attentionGrabber),this._topContainer.append(this._attentionGrabberWrapper),this._lib.getUiUtils().setLangAttribute(this._attentionGrabberWrapper),this.updateEvent(),t=wmjQuery.proxy(function(){this.postDrawing(),this.hideAfterTimeout(),this._commonUtils.handleAccessibleElement(this._attentionGrabberWrapper,"button")},this),this._timerManager.libSetTimeout(t,100))},o.prototype.getHtml=function(){},o.prototype.postDrawing=function(){},o.prototype.hideAfterTimeout=function(){var t,e=parseInt(this._settings.duration);e&&(t=wmjQuery.proxy(function(){this.hide(),this._stopAnimation=!0},this),this._hideTimeoutHandler=this._timerManager.libSetTimeout(t,1e3*e))},o.prototype.isSupportedByBrowser=function(){return!0},o.prototype.setupAttenGrab=function(){if(this.isSupportedByBrowser()&&this._settings&&!wmjQuery.isEmptyObject(this._settings)&&!1!==this.innerSetup()){if(this._settings.repeat){var t=this._storageKeysConfigurations.attentionGrabber.repeat.key;if(!(t=l.get("AutoStartManager").checkRepeatCookie(t,this._settings.repeat)).shouldStart)return;t.store()}t=wmjQuery.proxy(function(){this.drawAttentionGrabber()},this),this._delayTimeoutHandler=this._timerManager.libSetTimeout(t,1e3*parseFloat(this._settings.delay))}},o.prototype.innerSetup=function(){return!0},o.prototype.remove=function(e){try{this._logger.customerLog("Remove attention grabber",5),this._attentionGrabberWrapper&&this._attentionGrabberWrapper.remove(),this.clearTimers(),this.updateEvent(),e&&e()}catch(t){e&&e()}},o.prototype.hide=function(){this.remove(),this.replay()},o.prototype.updateEvent=function(){this._dataManager&&this._dataManager.updateEvent()},o.prototype.replay=function(){var t,e=parseInt(this._settings.replay);e&&(this._logger.customerLog("Replay attention grabber",5),t=wmjQuery.proxy(function(){this.drawAttentionGrabber()},this),this._replayTimeoutHandler=this._timerManager.libSetTimeout(t,1e3*e*60))},o.prototype.getDirection=function(){return this._config.Direction},o.prototype.getDefaultOrFirstTab=function(){for(var t=l.get("UiDataProvider").uiObjectsTree(),e=0;e<t.length;e++)if(t[e].properties().hasProperty("default"))return t[e];for(e=0;e<t.length;e++)if(t[e].properties().hasProperty("visible"))return t[e]},o.prototype.clearTimers=function(){this._delayTimeoutHandler&&this._delayTimeoutHandler.clear(),this._replayTimeoutHandler&&this._replayTimeoutHandler.clear(),this._hideTimeoutHandler&&this._hideTimeoutHandler.clear()},o);function o(t,e,i,r,o,a,n,s,p,h){this._stopAnimation=!1,this.POSITION="TrianglePosition",this._lib=t,this._commonUtils=e,this._timerManager=i,this._endUsersManager=r,this._auditSourceManager=o,this._hostData=a,this._wmAjax=n,this._safeFullUrlProvider=s,this._domManager=p,this._storageKeysConfigurations=l.get("StorageKeysConfigurations"),this._config=h.config,this._player=h.player,this._menu=h.menu,this._logger=l.get("Logger"),this._topContainer=l.get("TopContainerProvider").getTopContainer(),h.agData?(this._data=h.agData,this._settings=h.agData.Settings,this._agId=this._data.Id,this._dataManager=l.get("AttentionGrabberDataManager")):(this._oldAG=!0,this._oldAGData=this._commonUtils.getSettingsValue(this._config.Settings,"AG",!1),this._oldAGData&&(this._settings={},this._oldAGData.delay&&(this._settings.delay=this._oldAGData.delay),this._oldAGData.timeout&&(this._settings.duration=this._oldAGData.timeout),this._oldAGData.repeat&&(this._settings.repeat=this._oldAGData.repeat)))}l.register("AttentionGrabberBase").asCtor(r).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")},1340:function(t,e,i){"use strict";i.r(e),i.d(e,"TemplateAttentionGrabber",function(){return r});var c,e=i(0),g=i(167),i=i(1331),r=(c=i.AttentionGrabberBase,Object(e.__extends)(o,c),o.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(7)},o.prototype.getHtml=function(){return g.get("TemplatesFactory").get(this._templateId,this._templateVersion,this._templateVariations,this.getTemplateData())},o.prototype.getTemplateData=function(){return{}},o.prototype.getHorizontalOffset=function(){return 0},o.prototype.getVerticalOffset=function(){return 0},o.prototype.animate=function(){},o.prototype.postDrawing=function(){this.addMainClass(),this._attentionGrabber.show(),this._attentionGrabberWrapper.show(),this.setPosition(),this.bindEvents(),this.animate()},o.prototype.addMainClass=function(){this._attentionGrabber.addClass("wm-ag-"+this._mainClass)},o.prototype.copyCssProperties=function(){for(var t=0;t<this.positions.length;t++)this._attentionGrabberWrapper.css(this.positions[t],this.getCssPosition(this._player,this.positions[t])),this._attentionGrabberWrapper.css("margin-"+this.positions[t],this._player.css("margin-"+this.positions[t]))},o.prototype.fixCssMargins=function(t,e){var i=parseFloat(this._attentionGrabberWrapper.css("margin-left"))||0,r=parseFloat(this._attentionGrabberWrapper.css("margin-right"))||0,o=parseFloat(this._attentionGrabberWrapper.css("margin-top"))||0,a=parseFloat(this._attentionGrabberWrapper.css("margin-bottom"))||0;this._attentionGrabberWrapper.css("margin-left",i+t+"px").css("margin-right",r+t+"px"),this._attentionGrabberWrapper.css("margin-top",o+e+"px").css("margin-bottom",a+e+"px")},o.prototype.getCssPosition=function(t,e){var i=t[0].style[e],r=this.hostData.isIE(8)?t[0].currentStyle[e]:t.css(e);t.important(e,"auto");var o=t.css(e);return t.important(e,""),i&&(t[0].style[e]=i),r!=o?r:"auto"},o.prototype.setLogicCss=function(){this._attentionGrabberWrapper.css("z-index"," 2147483647"),this._attentionGrabberWrapper.css("cursor","pointer")},o.prototype.bindEvents=function(){wmjQuery(window).resize(this._setPositionProxy);var t=wmjQuery.proxy(function(){var t={type:this._agPlayInitiator};this._menu.toggle({initiator:t})},this);this._attentionGrabberWrapper.click(t)},o.prototype.unbindEvents=function(){wmjQuery(window).off("resize",this._setPositionProxy)},o.prototype.setPosition=function(){var t,e;this._attentionGrabberWrapper.css("position","fixed"),this.setLogicCss(),"left"==this._playerMajorPosition||"right"==this._playerMajorPosition?(t=this._player.outerWidth()+this.getHorizontalOffset(),e=(this._player.outerHeight()-this._attentionGrabber.outerHeight())/2):"top"!=this._playerMajorPosition&&"bottom"!=this._playerMajorPosition||(t=(this._player.outerWidth()-this._attentionGrabber.outerWidth())/2,e=this._player.outerHeight()+this.getVerticalOffset()),this.copyCssProperties(),this.fixCssMargins(t,e)},o.prototype.remove=function(e){try{this.unbindEvents(),c.prototype.remove.call(this,e)}catch(t){c.prototype.remove.call(this,e)}},o);function o(t,e,i,r,o,a,n,s,p,h){var l,u=c.call(this,t,e,i,r,o,a,n,s,p,h)||this;for(l in u.hostData=a,u.positions=["left","right","top","bottom"],u._templateId=u._data.UITemplateId,u._templateVersion=u._data.UITemplateVersion,u._templateVariations=[],u._data.UIVariationsIds)u._templateVariations.push(g.get("UIVariations").get(u._data.UIVariationsIds[l]));return u._data.Settings.customVariation&&u._templateVariations.push(u._data.Settings.customVariation),u._setPositionProxy=wmjQuery.proxy(function(){this.setPosition()},u),u._playerMajorPosition=u._config[u.POSITION].slice(0,u._config[u.POSITION].indexOf("-")),u._agPlayInitiator=g.get("Consts").STEP_PLAY_INITIATOR_ENUM.ATTENTION_GRABBER,u}g.register("TemplateAttentionGrabber").asCtor(r).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1362:function(t,e,i){"use strict";i.r(e),i.d(e,"BalloonAttentionGrabber",function(){return o});var l,e=i(0),r=i(167),i=i(1340),o=(l=i.TemplateAttentionGrabber,Object(e.__extends)(a,l),a.prototype.getTemplateData=function(){var t=r.get("LanguageManager");return{title:this.getBalloonTitle(),text:this.getBalloonText(),position:this.getOppositeDirection(this._playerMajorPosition),buttons:this._settings.buttons,direction:this.getDirection(),language:t.getCurrentLanguage()}},a.prototype.getBalloonText=function(){return""},a.prototype.getBalloonTitle=function(){},a.prototype.setLogicCss=function(){l.prototype.setLogicCss.call(this),this._attentionGrabberWrapper.css("direction",this.getDirection())},a.prototype.bindEvents=function(){l.prototype.bindEvents.call(this);var t=wmjQuery.proxy(this.remove,this);this._xBtn=wmjQuery(".wm-x-button",this._attentionGrabberWrapper),this._xBtn.click(function(){t()})},a.prototype.getHorizontalOffset=function(){return wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper).outerWidth()},a.prototype.getVerticalOffset=function(){return wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper).outerHeight()},a.prototype.animate=function(){var i=this._attentionGrabberWrapper,r=this._playerMajorPosition,o=parseInt(i.css(r)),a=o+30+"px",n=this._stopAnimation,s=0,p=this._timerManager.libSetTimeout;!function e(){if(1==s)return s=0,p(function(){e()},3e3),0;s++;var t={};t[r]=a,i.animate(t,{easing:"swing",duration:700,complete:function(){p(function(){var t={};t[r]=o+5+"px",i.animate(t,{easing:"easeOutBounce",duration:700,complete:function(){n||p(function(){e()},100)}})},100)}})}()},a.prototype.getOppositeDirection=function(t){return this._oppositeDirections[t]},a.prototype.remove=function(e){try{var t;this._attentionGrabberWrapper?(this._attentionGrabberWrapper.off("click"),this._xBtn&&this._xBtn.off("click"),t=wmjQuery.proxy(l.prototype.remove,this),this._attentionGrabberWrapper.stop(!0,!0),this._hostData.isIE(8)?l.prototype.remove.call(this,e):this._attentionGrabberWrapper.animate({opacity:0},{duration:300,complete:function(){t(e)}})):l.prototype.remove.call(this,e)}catch(t){l.prototype.remove.call(this,e)}},a);function a(t,e,i,r,o,a,n,s,p,h){return(h=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._oppositeDirections={left:"right",right:"left",bottom:"top",top:"bottom"},h}r.register("BalloonAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1405:function(t,e,i){"use strict";i.r(e),i.d(e,"CustomTextAttentionGrabber",function(){return o});var l,r=i(0),e=i(167),i=i(1362),o=(l=i.BalloonAttentionGrabber,Object(r.__extends)(a,l),a.prototype.getBalloonText=function(){return this._settings.text||""},a.prototype.setLogicCss=function(){l.prototype.setLogicCss.call(this),wmjQuery(".wm-title",this._attentionGrabber).css("width","auto")},a);function a(t,e,i,r,o,a,n,s,p,h){return(h=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._mainClass="custom-text",h}e.register("CustomTextAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1462:function(t,e,i){"use strict";i.r(e),i.d(e,"CustomImageAttentionGrabber",function(){return o});var g,e=i(0),r=i(167),i=i(1340),o=(g=i.TemplateAttentionGrabber,Object(e.__extends)(a,g),a.prototype.getHtml=function(){var t=this._resourceManager.getResourcePath(this._settings.image.url);return this.isHttpOverHttps(t)?(this._logger.customerLog("Attention Grabber - Could not load Custom Image because source is http over https",3),this.commonEvents.raiseEvent(this.consts.EVENTS.AttentionGrabberInsecure,{name:"Custom Image"}),null):((t=r.get("TemplatesFactory").get(this._templateId,this._templateVersion,this._templateVariations,{src:t})).height(this._settings.image.height).width(this._settings.image.width),t)},a.prototype.setLogicCss=function(){g.prototype.setLogicCss.call(this),this._attentionGrabberWrapper.height(this._settings.image.height).width(this._settings.image.width)},a.prototype.isHttpOverHttps=function(t){return!!t&&0==window.location.href.indexOf("https://")&&-1==t.indexOf("https://")},a);function a(t,e,i,r,o,a,n,s,p,h,l,u,c){return(c=g.call(this,t,e,i,r,o,a,n,s,p,c)||this).commonEvents=l,c.consts=u,c._mainClass="custom-image",c._resourceManager=h,c}r.register("CustomImageAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager, ResourceManager, CommonEvents, Consts")},1463:function(t,e,i){"use strict";i.r(e),i.d(e,"ImageAttentionGrabber",function(){return o});var l,r=i(0),e=i(167),i=i(1331),o=(l=i.AttentionGrabberBase,Object(r.__extends)(a,l),a.prototype.getHtml=function(){return wmjQuery("<img src='"+this._settings.filename+"' />")},a.prototype.innerSetup=function(){return this._settings.filename&&(this._settings.filename=this._lib.ResourceManager.getResourcePath(this._settings.filename)),-1!=parseInt(this._settings.id)},a.prototype.postDrawing=function(){this.drawAGWaitForImages()},a.prototype.drawAGWaitForImages=function(){var t,e=wmjQuery.proxy(this.imageNotLoadedCases,this),i=this._player,e=e();i="1"==i.attr("data-inanimation"),e||i?(this._drawAGWaitForImagesFailCount++,10<this._drawAGWaitForImagesFailCount||(t=wmjQuery.proxy(this.drawAGWaitForImages,this),this._timerManager.libSetTimeout(function(){t()},500))):this.drawAGPostLoad()},a.prototype.drawAGPostLoad=function(){var t="0px",e="0px",i="auto",r="auto",o=parseInt(this._settings.hOffset),a=parseInt(this._settings.vOffset),n=(this._player.width()-this._attentionGrabberWrapper.width())/2,s=(this._player.height()-this._attentionGrabberWrapper.height())/2,p=this.handlePosition("auto","bottom",s,a),i=this.handlePosition(i,"top",s,a),h=this.handlePosition("auto","right",n,o),r=this.handlePosition(r,"left",n,o);-1<this._config[this.POSITION].indexOf("center")&&(r="50%",e=this.buildPosition(e,"margin-left",n,o),e=this.dynamicSizeHandler("width",e)),-1<this._config[this.POSITION].indexOf("middle")&&(i="50%",t=this.buildPosition(t,"margin-top",s,a),t=this.dynamicSizeHandler("height",t)),this._attentionGrabberWrapper.css({position:"fixed",top:i,right:h,bottom:p,left:r,"margin-top":t,"margin-right":"0px","margin-bottom":"0px","margin-left":e}),this._attentionGrabberWrapper.show()},a.prototype.handlePosition=function(t,e,i,r){return-1<this._config[this.POSITION].indexOf(e)?this.buildPosition(t,e,i,r):t},a.prototype.buildPosition=function(t,e,i,r){return t=parseFloat(this._player.css(e).replace("px","")),t+=i,(t+=r)+"px"},a.prototype.dynamicSizeHandler=function(t,e){return this._player.hasClass("walkme-dynamic-size")?parseFloat(e.replace("px",""))+this._player.css(t).replace("px","")/2*-1:e},a.prototype.imageNotLoadedCases=function(){return 0==this._player.width()||28==this._player.width()||0==this._attentionGrabberWrapper.width()||28==this._attentionGrabberWrapper.width()||24==this._attentionGrabberWrapper.width()&&24==this._attentionGrabberWrapper.width()},a);function a(t,e,i,r,o,a,n,s,p,h){return(h=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._drawAGWaitForImagesFailCount=0,h._oldAG&&(h._oldAGData.id&&(h._settings.id=h._oldAGData.id),h._oldAGData.filename&&(h._settings.filename=h._oldAGData.filename),h._oldAGData.hOffset&&(h._settings.hOffset=h._oldAGData.hOffset),h._oldAGData.vOffset&&(h._settings.vOffset=h._oldAGData.vOffset)),h}e.register("ImageAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1464:function(t,e,i){"use strict";i.r(e),i.d(e,"MenuOverviewAttentionGrabber",function(){return r});var u,e=i(0),c=i(167),i=i(1331),r=(u=i.AttentionGrabberBase,Object(e.__extends)(o,u),o.prototype.updateJqueryMenu=function(t){this._jQueryMenu=t},o.prototype.createAg=function(t,e){var i=wmjQuery.proxy(this.showNextBalloon,this),r=wmjQuery.proxy(function(){var t=wmjQuery.proxy(function(){var t;i(),1==this._stepIndex&&(t={type:this._agPlayInitiator},WalkMePlayerAPI.toggleMenu(t))},this);o.remove(t)},this);(r={config:{Direction:this._config.Direction},player:t,menu:this._menu,onClickFunc:r,agData:{Id:e.firstBalloon?this._agId:null,ClassType:e.classType,UITemplateId:this._data.UITemplateId,UITemplateVersion:this._data.UITemplateVersion,UIVariationsIds:[this._themeVariation,this._data.ExtraUIVariationsIds[this._stepIndex+1]],Settings:{delay:e.delay,text:e.text,title:e.title,boldText:e.boldText,buttons:[{text:e.buttonText}],firstBalloon:e.firstBalloon,attachedToElementSelector:e.attachedToElementSelector,jQueryMenu:this._jQueryMenu,moveArrow:e.moveArrow,marginRight:e.marginRight,marginBottom:e.marginBottom}}}).config[this.POSITION]=e.position;var o=c.create("AttentionGrabber",r);(this._currentAg=o).setupAttenGrab()},o.prototype.showNextBalloon=function(){var i;this._stopPlaying||(this._stepIndex++,this._balloonsData[this._stepIndex]&&(this.shouldPlay()?this._jQueryMenu?this.createAg(this._jQueryMenu,this._balloonsData[this._stepIndex]):(i=wmjQuery.proxy(function(t){this._jQueryMenu=t,this.createAg(t,this._balloonsData[this._stepIndex])},this),this._menu.bind("on-open-end",function(t,e){t.target.unbind("on-open-end"),i(e.menu)})):this.showNextBalloon()))},o.prototype.shouldPlay=function(){var t=this._balloonsData[this._stepIndex].attachedToElementSelector;return!t||0<wmjQuery(t+":visible",this._jQueryMenu).length},o.prototype.setupAttenGrab=function(){var t;this.isWalkthrusTab()&&"iOS"!=this._hostData.os().name&&"Android"!=this._hostData.os().name&&(t=wmjQuery.proxy(this.stopAll,this),this._menu.bind("on-close-begin",function(){t()}),this.createAg(this._player,this._balloonsData[0]))},o.prototype.isWalkthrusTab=function(){var t=this.getDefaultOrFirstTab().properties().getAll();return-1<wmjQuery.inArray(c.get("Consts").PROPERTY_CONTAINS_PREFIX+"walkthru",t)},o.prototype.stopAll=function(){this._stopPlaying=!0,this._currentAg.remove()},o.prototype.remove=function(t){this._currentAg&&this._currentAg.remove(),u.prototype.remove.call(this,t)},o);function o(t,e,i,r,o,a,n,s,p,h){(h=u.call(this,t,e,i,r,o,a,n,s,p,h)||this)._balloonsData={0:{classType:"3.sub",title:"Meet WalkMe!",text:"Your New Personal Assistant.",buttonText:"Start",position:"bottom-center",firstBalloon:!0},1:{classType:"3.sub",text:"The WalkMe menu is the place to get all the help you might need.",boldText:'Click "Next" and take a look...',buttonText:"Next",position:"bottom-center",delay:1,marginBottom:3},2:{classType:"3.sub",text:"Here you can select your preferred language.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"bottom-center",attachedToElementSelector:"#walkme-languages",moveArrow:!0},3:{classType:"3.sub",text:"Quickly find answers to your support issue by using the search bar.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"right-middle",attachedToElementSelector:".walkme-search-box-container",marginRight:12},4:{classType:"3.sub",text:"All the Walk-Thrus and help resources are located here, click them to start your online guidance.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"right-middle",attachedToElementSelector:".walkme-deployables-list .walkme-tab .walkme-deployable",marginRight:14},5:{classType:"3.sub",text:"Couldn't find what you want? this link takes you to the support page.",boldText:"To learn more about WalkMe, click here.",buttonText:"Next",position:"bottom-center",attachedToElementSelector:".walkme-open-ticket",moveArrow:!0},6:{classType:"3.sub",title:"Thank You!",text:"We're here to help.",buttonText:"Done",position:"bottom-center",marginBottom:3}},h._stepIndex=0,h._themeVariation=h._data.ExtraUIVariationsIds[0],h._balloonsData[0].position=h._config[h.POSITION],h._balloonsData[0].delay=h._settings.delay,h._agPlayInitiator=c.get("Consts").STEP_PLAY_INITIATOR_ENUM.ATTENTION_GRABBER;var l=wmjQuery.proxy(h.updateJqueryMenu,h);return h._menu.bind("build-menu-end",function(t,e){l(e.menu)}),h}c.register("MenuOverviewAttentionGrabber").asCtor(r).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1465:function(t,e,i){"use strict";i.r(e);var l,r=i(0),e=i(167),i=i(1405),r=(l=i.CustomTextAttentionGrabber,Object(r.__extends)(o,l),o.prototype.getTemplateData=function(){return{title:this._settings.title,"bold-text":this._settings.boldText,text:this._settings.text,position:this.getOppositeDirection(this._playerMajorPosition),buttons:this._settings.buttons}},o.prototype.setLogicCss=function(){l.prototype.setLogicCss.call(this),this.moveArrow(),this._data.Settings.firstBalloon||this._attentionGrabberWrapper.css("cursor","auto")},o.prototype.moveArrow=function(){var t,e,i;this._data.Settings.moveArrow&&(i=wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper),t=wmjQuery(".wm-inner-arrow",this._attentionGrabberWrapper),e=i.offset().left,i.css("left","85%"),t.css("left","85%"),i=i.offset().left,this._arrowOffset=i-e,this._data.Settings.moveArrow=!1)},o.prototype.bindEvents=function(){l.prototype.bindEvents.call(this),this._attentionGrabberWrapper.off("click"),wmjQuery(".wm-button",this._attentionGrabberWrapper).click(this._onClickFunc),this._fixPositionProxy=wmjQuery.proxy(this.fixPosition,this),wmjQuery(window).resize(this._fixPositionProxy),this._data.Settings.firstBalloon&&this._attentionGrabberWrapper.click(this._onClickFunc)},o.prototype.unbindEvents=function(){l.prototype.unbindEvents.call(this),wmjQuery(window).off("resize",this._fixPositionProxy)},o.prototype.animate=function(){this.fixPosition(),this._data.Settings.firstBalloon&&l.prototype.animate.call(this)},o.prototype.fixPosition=function(){var t,e,i,r,o,a,n,s=this._attentionGrabberWrapper.css("margin-bottom"),p=this._attentionGrabberWrapper.css("margin-right"),h=this._data.Settings.marginRight||0,l=this._data.Settings.marginBottom||0;this._data.Settings.attachedToElementSelector?(o=this._data.Settings.jQueryMenu,t=(a=wmjQuery(this._data.Settings.attachedToElementSelector,o)).offset().left-o.offset().left,e=a.offset().top-o.offset().top,"bottom"==this._playerMajorPosition?(i=o.width(),r=this._attentionGrabberWrapper.css("margin-bottom"),n=a.width(),n=parseFloat(p)+i/2-t-n/2+this._arrowOffset+h,this._attentionGrabberWrapper.css("margin-right",n+"px").css("margin-bottom",parseFloat(r)-e+l+"px")):(o=o.height(),a=a.height(),n=parseFloat(s)+o/2-e-a/2+l,this._attentionGrabberWrapper.css("margin-right",parseFloat(p)-t+h+"px").css("margin-bottom",n+"px"))):this._attentionGrabberWrapper.css("margin-right",parseFloat(p)+h+"px").css("margin-bottom",parseFloat(s)+l+"px")},o);function o(t,e,i,r,o,a,n,s,p,h){return(p=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._mainClass="menu-overview",p._arrowOffset=0,p._onClickFunc=h.onClickFunc,p}e.register("MenuOverviewSubAttentionGrabber").asCtor(r).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1466:function(t,e,i){"use strict";i.r(e),i.d(e,"OldSwooshAttentionGrabber",function(){return o});var l,r=i(0),e=i(167),i=i(1331),o=(l=i.AttentionGrabberBase,Object(r.__extends)(a,l),a.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(9,"lte")},a.prototype.getHtml=function(){var t,e;this.isHorizental()?(t=this._settings.width+"px",e="130%"):(e=this._settings.width+"px",t="130%");var i=this._settings.opacity,r=this._settings.deg;return this._domManager.parseElementAsJquery("<div class='wm-ag-swoosh' style='width: "+t+"; height:"+e+"; position: absolute; top:-6px; right: -6px; background-color: transparent !important; "+this.getRotateCss(r)+this.getBackgoundCss(i)+"'/>")},a.prototype.postDrawing=function(){var t=this._settings.right;this._attentionGrabberWrapper.detach().appendTo(this._player);var e=this.isHorizental()?"width":"height",i=this._player.css(e);this._attentionGrabberWrapper.css({position:"absolute",overflow:"hidden",width:"100%",height:"100%","z-index":this._player.css("z-index"),right:"0",bottom:"auto",top:"0"}).important("background","none"),this._attentionGrabber.show(),this._attentionGrabberWrapper.show(),e=this.getProperty("animationDuration"),this.animate(i,t,e)},a.prototype.animate=function(t,i,r){var o=this._attentionGrabber,a=this.isHorizental()?"right":"top",n=this._timerManager;o.css(a,i+"px");var s=1.3*parseFloat(t)+"px";!function t(){var e={};e[a]=s,o.animate(e,r),e=this._stopAnimation,n.setWalkmeTimeout(function(){var t={};t[a]=i+"px",o.animate(t,r)},1e3),e||n.setWalkmeTimeout(t,4e3)}()},a.prototype.isHorizental=function(){return"hoz"==this._direction},a.prototype.getProperty=function(t){return this._settings[t]||this._defaultValues[t]},a.prototype.getBackgoundCss=function(t){return"background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIwIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjUwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIwLjkxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNmZmZmZmYiIHN0b3Atb3BhY2l0eT0iMCIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);background: -moz-linear-gradient(left,  rgba(255,255,255,0) 0%, rgba(255,255,255,"+t+") 50%, rgba(255,255,255,0) 100%);background: -webkit-gradient(linear, left top, right top, color-stop(0%,rgba(255,255,255,0)), color-stop(50%,rgba(255,255,255,"+t+")), color-stop(100%,rgba(255,255,255,0)));background: -webkit-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: -o-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: -ms-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: linear-gradient(to right,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);"},a.prototype.getRotateCss=function(t){return"transform: rotate("+t+"deg); -moz-transform:rotate("+t+"deg); -webkit-transform:rotate("+t+"deg); -o-transform:rotate("+t+"deg);  -ms-transform:rotate("+t+"deg);"},a);function a(t,e,i,r,o,a,n,s,p,h){return(h=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._defaultValues={animationDuration:700},h._oldAG&&h._oldAGData.settings&&(h._oldAGData.settings.width&&(h._settings.width=h._oldAGData.settings.width),h._oldAGData.settings.right&&(h._settings.right=h._oldAGData.settings.right),h._oldAGData.settings.deg&&(h._settings.deg=h._oldAGData.settings.deg),h._oldAGData.settings.dir&&(h._settings.dir=h._oldAGData.settings.dir,h._direction=h._oldAGData.settings.dir),h._oldAGData.settings.opacity&&(h._settings.opacity=h._oldAGData.settings.opacity)),h}e.register("OldSwooshAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1467:function(t,e,i){"use strict";i.r(e),i.d(e,"SwooshAttentionGrabber",function(){return o});var l,r=i(0),e=i(167),i=i(1340),o=(l=i.TemplateAttentionGrabber,Object(r.__extends)(a,l),a.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(9,"lte")},a.prototype.postDrawing=function(){this._attentionGrabberWrapper.detach().appendTo(this._player),this._attentionGrabberWrapper.css({position:"absolute",overflow:"hidden",width:"100%",height:"100%","z-index":this._player.css("z-index"),right:"0",bottom:"auto",top:"0"}).important("background","none"),this._attentionGrabber.show(),this._attentionGrabberWrapper.show(),this.animate()},a.prototype.animate=function(){var i=this._attentionGrabber,r=this._animationDuration,o=this._timerManager,t=this.isHorizental(),a=t?"right":"top";i.css(a,"-60px");var n=1.3*parseFloat(this._player.css(t?"width":"height"))+"px",s=this._stopAnimation;this.initAnimationProperties(t),function t(){var e={};e[a]=n,i.animate(e,r),o.setWalkmeTimeout(function(){var t={};t[a]="-60px",i.animate(t,r)},1e3),s||o.setWalkmeTimeout(t,4e3)}()},a.prototype.initAnimationProperties=function(t){t?this.setInitCss("15deg","50px","130%"):this.setInitCss("105deg","130%","50px")},a.prototype.setInitCss=function(t,e,i){this._attentionGrabber.css({height:i,width:e,transform:"rotate("+t+")","-moz - transform":"rotate("+t+")","-webkit - transform":"rotate("+t+")","-o - transform":"rotate("+t+")","-ms - transform":"rotate("+t+")"})},a.prototype.isHorizental=function(){return this._player.width()>this._player.height()},a);function a(t,e,i,r,o,a,n,s,p,h){return(h=l.call(this,t,e,i,r,o,a,n,s,p,h)||this)._mainClass="ag",h._animationDuration=h._settings.animationDuration||700,h}e.register("SwooshAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager")},1468:function(t,e,i){"use strict";i.r(e),i.d(e,"TickerAttentionGrabber",function(){return o});var b,r=i(0),e=i(167),i=i(1362),o=(b=i.BalloonAttentionGrabber,Object(r.__extends)(a,b),a.prototype.setupAttenGrab=function(){0!==this._textItems.length&&b.prototype.setupAttenGrab.call(this)},a.prototype.getBalloonTitle=function(){return"Help me with..."},a.prototype.getBalloonText=function(){return this._textItems[this._currentDeployableIndex]},a.prototype.getDeployableText=function(){var t=this._textItems[this._currentDeployableIndex];return this._currentDeployableIndex<Math.min(this.MAX_DEPLOYABLES_TO_SHOW,this._textItems.length)-1?this._currentDeployableIndex++:this._currentDeployableIndex=0,t},a.prototype.animate=function(){var t;this._hostData.isIE(8)?this.innerAnimate():(this._attentionGrabberWrapper.css({opacity:0}),t=wmjQuery.proxy(this.innerAnimate,this),this._attentionGrabberWrapper.animate({opacity:1},{duration:300,complete:t}))},a.prototype.innerAnimate=function(){var t=wmjQuery(".wm-title",this._attentionGrabber),e={opacity:1};this.fixOpacityForIe8(e),t.css(e);var i=this._stopAnimation;t.text(this.htmlDecoder.decodeHtml(this.getDeployableText(),["&",'"',"'",">","<"]));var r=wmjQuery.proxy(this.innerAnimate,this),o=this._timerManager.libSetTimeout;t.animate(e,{duration:700,complete:function(){o(function(){t.animate({opacity:0},{duration:700,complete:function(){i||r()}})},2e3)}})},a.prototype.getDirection=function(){return"ltr"},a.prototype.fixOpacityForIe8=function(t){this._hostData.isIE(8)&&(t.opacity=.99)},a);function a(t,e,i,r,o,a,n,s,p,h,l){var u=b.call(this,t,e,i,r,o,a,n,s,p,l)||this;if(u.htmlDecoder=h,u._mainClass="ticker",u._textItems=[],u.MAX_DEPLOYABLES_TO_SHOW=5,h=u.getDefaultOrFirstTab())for(var c=h.children(),g=0,m=0;m<c.length;m++){var d=c[m];if(d.properties().hasProperty("visible")&&(u._textItems.push(d.name()),g++),g==u.MAX_DEPLOYABLES_TO_SHOW)break}return u._currentDeployableIndex=0,u}e.register("TickerAttentionGrabber").asCtor(o).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, DomManager, HtmlDecoder")},1469:function(t,e,i){i(167)}}]);