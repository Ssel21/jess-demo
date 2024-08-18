trigger AccountDuplicateTrigger on Account (before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        AccountTriggerHandler.checkIfWithExistingLead(Trigger.new);
    }

}