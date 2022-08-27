trigger SMC_TGR_SkillRequirementTrigger on SkillRequirement (after insert) {
     new TH_SKR_SkillRequirementTriggerHandler().run();
}