trigger SMC_TGR_ServiceAppointmentTrigger on ServiceAppointment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new TH_SERVICEAPPOINTMENT_TriggerHandler().run();
}