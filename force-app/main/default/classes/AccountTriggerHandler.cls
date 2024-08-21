public with sharing class AccountTriggerHandler {
    public AccountTriggerHandler() {

    }

    public static void checkIfWithExistingLead(List<Account> newAccounts){
        Set<String> accountNames = new Set<String>();
        //pass account names in a set
        if(!trigger.new.IsEmpty()){
            for(Account account : newAccounts){
                accountNames.add(account.Name);
            }
        }

        //fetch all leads that has the same names in accountNames
        List<Lead> leads = [SELECT Id, Company, Status FROM Lead WHERE Company IN :accountNames];
        Map<String, Lead> mappedExistingLeads = new Map<String, Lead>();
        if(!leads.isEmpty()){
            for(Lead lead: leads){
                mappedExistingLeads.put(lead.Company, lead);
            }
        }

        String converted = 'Closed - Converted';
        if(!newAccounts.isEmpty() && !mappedExistingLeads.isEmpty()){
            for(Account account : newAccounts){
                Boolean isConverted = mappedExistingLeads.get(account.Name).Status == converted ? true: false;
                if(mappedExistingLeads.containsKey(account.Name) && isConverted){
                    account.addError('Lead with the same Company Name already exists');
                }
            }
        }else{
            return;
        }
        
    }


    /**public static void checkForAccountDuplicates(List<Account> newAccounts){
        Set<String> accountNames = new Set<String>();

        if(!trigger.new.IsEmpty()){
            for(Account account : newAccounts){
                accountNames.add(account.Name);
            }
        }

        //fetch all accounts that has the same names in accountNames
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :accountNames];
        Map<String, Account> mappedExistingAccounts = new Map<String, Account>();

        if(!accounts.isEmpty()){
            for(Account account: accounts){
                mappedExistingAccounts.put(account.Name, account);

            }
        }

        if(!newAccounts.isEmpty()){
            for(Account account : newAccounts){
                if(mappedExistingAccounts.containsKey(account.Name)){
                    account.addError('Account Name already exists');
                }
            }
        }

    }**/
}