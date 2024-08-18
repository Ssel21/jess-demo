trigger LeadDuplicateTrigger on Lead (before insert, before update) {

  if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
    LeadTriggerHandler.checkForLeadDuplicates(Trigger.new);
    }
}