window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[20],{1268:function(r,e,n){(function(n,e){(function(){n.register("DeepUiInitializer").asCtor(function(o,l,s,c,d,u,g,p,m,w,f,S,C,F){this.start=function(a){return new e(function(e,n){try{var r=o.getSettingsFile(),t=o.getCdnServerName();if(p.isSelfHosted){if(!d.isFeatureEnabled(I))return e();t=r.PlayerApiServer&&r.PlayerApiServer.replace("papi","cdn")}var i=F&&F.getItem("wm-deepui-snippet-link")||t+"/deepui/0/main.js";l.addScriptWithCallback(i,"onDeepUIReadyCb",function(){return{resolve:e,reject:n,wmDependencies:{datafile:a,settingsFile:o,commonUtils:l,consts:s,wmjQuery:c,elementFinder:u,jQueryElementFinder:g,wmInternals:p,wmLogger:m,clientStorageManager:w,localStorageService:F,endUsersManager:f,userGuidContainer:S,isInEditor:C}}},function(){n(new Error("Failed to addScriptWithCallback for: "+i))})}catch(e){n(e)}})},function(){}.apply(null,arguments)}).dependencies("SettingsFile, CommonUtils, Consts, wmjQuery, FeaturesManager,ElementFinder, JQueryElementFinder, WmInternals, Logger, ClientStorageManager, EndUsersManager, UserGuidContainer, IsInEditor, LocalStorageService");var I="DeepUiAllowedInSelfHosted";r.exports={init:function(e){return n.get("DeepUiInitializer").start(e).catch(function(e){n.get("Logger").error(e)})}}}).call(window)}).call(this,n(3),n(2))}}]);