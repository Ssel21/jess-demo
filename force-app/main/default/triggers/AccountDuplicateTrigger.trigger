trigger AccountDuplicateTrigger on Account (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        AccountTriggerHandler.checkIfWithExistingLead(Trigger.new);
    }

}