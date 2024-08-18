public with sharing class LeadTriggerHandler {
    public LeadTriggerHandler() {

    }

    public static void checkIfWithExistingAccount(List<Lead> newLeads){
        Set<String> leadCompanyNames = new Set<String>();
        //pass Company names in a set
        if(!trigger.new.IsEmpty()){
            for(Lead lead : newLeads){
                leadCompanyNames.add(lead.Company);
            }
        }

        //fetch all accounts that has the same names in leadCompanyNames
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :leadCompanyNames];
        Map<String, Account> mappedExistingAccounts = new Map<String, Account>();
        if(!accounts.isEmpty()){
            for(Account account: accounts){
                mappedExistingAccounts.put(account.Name, account);
            }
        }


        if(!newLeads.isEmpty()){
            for(Lead lead : newLeads){
                if(mappedExistingAccounts.containsKey(lead.Company)){
                    lead.addError('Account with the same  Name already exists');
                }
            }
        }
    }

    /**public static void checkForLeadDuplicates(List<Lead> newLeads){
        Set<String> leadCompanyNames = new Set<String>();

        if(!trigger.new.IsEmpty()){
            for(Lead lead : newLeads){
                leadCompanyNames.add(lead.Company);
            }
        }

        //fetch all Leads that has the same names in leadCompanyNames
        List<Lead> Leads = [SELECT Id, Company FROM Lead WHERE Company IN :leadCompanyNames];
        Map<String, Lead> mappedExistingAccounts = new Map<String, Lead>();

        if(!Leads.isEmpty()){
            for(Lead lead: Leads){
                mappedExistingAccounts.put(lead.Company, lead);

            }
        }

        if(!newLeads.isEmpty()){
            for(Lead lead : newLeads){
                if(mappedExistingAccounts.containsKey(lead.Company)){
                    lead.addError('Lead with the same Company Name already exists');
                }
            }
        }

    }**/
}