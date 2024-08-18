trigger LeadDuplicateTrigger on Lead (before insert) {

  if(Trigger.isBefore && Trigger.isInsert ){
    LeadTriggerHandler.checkIfWithExistingAccount(Trigger.new);
    }
}