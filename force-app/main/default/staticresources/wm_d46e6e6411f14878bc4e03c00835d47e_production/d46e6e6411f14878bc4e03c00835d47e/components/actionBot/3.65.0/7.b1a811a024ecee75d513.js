(window._walkmeABWebpackJP_latest=window._walkmeABWebpackJP_latest||[]).push([[7],{457:function(e,t,n){"use strict";n.r(t),function(e,r){var a,i,u,s,o=n(178),c=n.n(o),g=n(9),d=c()(),l=g.a.deps.consts,S=g.a.deps.userGuidContainer,p=g.a.getCommonUtils(),v=g.a.getGuidGenerator(),m=g.a.getLogger(),f=g.a.getLibInitializer(),E=g.a.getAuditingEnabledIndicator();function P(e){return"walkme-"+e.type()+"-"+e.id()}function h(e,t,n){return function(){"walkthru"===t&&p.sendMenuEvent("WalkthruSelected",e),function(e){e({type:g.a.deps.classWalkMeAPI.getPlayInitiatorEnum().API})}(n)}}s=new d.SearchEventSender({logger:m,consts:l,eventSender:g.a.deps.eventSender}),u=new d.SearchClickReporter(function(e){return{commonUtils:p,userGuid:S.getUserGuid(),serverName:f.getPlayerServer(),wmAjax:g.a.deps.wmAjax,dataSenderManager:g.a.getServerDataSenderManager(),logger:m,isAuditDisabledFunc:function(){return!E.isEnabled()},getPlayerServerFunc:f.getPlayerServer,getABPermutationIdFunc:g.a.getAbPermutationManager().getPermutation,getEndUserGuidFunc:g.a.deps.endUsersManager.getEndUserGuid,getEnvIdFunc:g.a.deps.auditSourceManager.get,generateNewGuidFunc:v.generateGuid,searchEventSender:e}}(s)),a=[],g.a.getUiDataProvider().uiObjectsTree().reduce((function(e,t){var n=t.properties();return n.hasProperty(l.UI_PROPERTIES.Search)&&n.hasProperty(l.UI_PROPERTIES.Visible)?[].concat(e,[t]):e}),[]).forEach((function(e){var t=new d.SearchDeployablesEngine({commonEvents:g.a.deps.commonEvents,commonUtils:p,consts:l,logger:m,configSettings:g.a.getSiteConfig().Settings,createAction:h,reporter:u,getUniqueClassFunc:P,isFeatureActiveFunc:g.a.getFeaturesManager().isFeatureEnabled,getHostDataFunc:g.a.getHostData,clientStorageManager:g.a.deps.clientStorageManager,toJSON:g.a.getJsonUtils().toJSON,getCommonUtilsFunc:function(){return p}});t.init(e),a.push(t)})),i=new d.SearchTermSaver({reporter:u,logger:m,userGuid:S.getUserGuid()}),t.default={searchDeployables:function(t){i.saveSearch(t,v.generateGuid());var n,u=a.reduce((function(e,n){return e.concat(n.search(t))}),[]).filter((function(e){return e&&"tab"!==e.type}));return n=u.reduce((function(t,n){var r;return n.properties().indexOf("visible")>=0?e(t,((r={})[n.uniqueClass]=n,r)):t}),{}),r(n)}}}.call(this,n(14).assign,n(14).values)}}]);