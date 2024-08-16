public with sharing class LeadConversionProcessHelper {
    public LeadConversionProcessHelper() {

    }


        public static String startLeadConversion(List<OpportunityLineItem> opportunityLineItems){
            List<Lead> leads = [SELECT Id, Name, Company FROM Lead];
            Map<Id, String> mappedLeads= new Map<Id, String>();
            for(Lead lead: leads){
                mappedLeads.put(lead.Id, lead.Company);
            }

            for(OpportunityLineItem opp: opportunityLineItems){

            }

            return 'message';
        }


}