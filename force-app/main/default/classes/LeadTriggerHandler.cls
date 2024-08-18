public with sharing class LeadTriggerHandler {
    public LeadTriggerHandler() {

    }

    public static void checkForLeadDuplicates(List<Lead> newLeads){
        Set<String> leadCompanyNames = new Set<String>();

        if(!trigger.new.IsEmpty()){
            for(Lead lead : newLeads){
                leadCompanyNames.add(lead.Company);
            }
        }

        //fetch all Leads that has the same names in leadCompanyNames
        List<Lead> Leads = [SELECT Id, Company FROM Lead WHERE Company IN :leadCompanyNames];
        Map<String, Lead> mappedExistingLeads = new Map<String, Lead>();

        if(!Leads.isEmpty()){
            for(Lead lead: Leads){
                mappedExistingLeads.put(lead.Company, lead);

            }
        }

        if(!newLeads.isEmpty()){
            for(Lead lead : newLeads){
                if(mappedExistingLeads.containsKey(lead.Company)){
                    lead.addError('Lead with the same Company Name already exists');
                }
            }
        }

    }
}