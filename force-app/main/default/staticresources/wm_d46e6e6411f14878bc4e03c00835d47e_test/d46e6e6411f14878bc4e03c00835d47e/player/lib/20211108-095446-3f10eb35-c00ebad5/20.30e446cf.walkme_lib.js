window,(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[20],{1264:function(e,t,n){"use strict";n.r(t),n.d(t,"SurveyQuestionAndAnswerText",function(){return s});var t=n(54),s=(r.prototype.getQuestionAndAnswerTextFromSurvey=function(e,t,n){var s=wmjQuery.grep(e.Questions,function(e){return e.Id==t})[0];switch(s.QuestionType){case this.consts.QUESTION_TYPES.NPS:return this.getAnswerAndQuestionTextForNPS(s,n);case this.consts.QUESTION_TYPES.FreeText:return this.getAnswerAndQuestionTextForFreeText(s);case this.consts.QUESTION_TYPES.RadioButton:case this.consts.QUESTION_TYPES.CheckBox:return this.getAnswerAndQuestionTextForMultipleAnswersQuestion(s,n)}},r.prototype.getAnswerAndQuestionTextForNPS=function(e,t){return{questionText:e.Title,answerText:t}},r.prototype.getAnswerAndQuestionTextForFreeText=function(e){return{questionText:e.Title}},r.prototype.getAnswerAndQuestionTextForMultipleAnswersQuestion=function(e,t){var n=wmjQuery.grep(e.Answers,function(e){return e.Id==t})[0];return{questionText:e.Title,answerText:n.Title}},r);function r(e){this.consts=e}t.register("SurveyQuestionAndAnswerText").asCtor(s).dependencies("Consts")}}]);