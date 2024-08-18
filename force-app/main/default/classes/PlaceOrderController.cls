public with sharing class PlaceOrderController {
    public PlaceOrderController() {

    }
    public static final String SUCCESS = 'Success';
    public static final String FAILED = 'Failed';


   


    public static void placeOrder(List<OrderWrapper> orders){
        
                Boolean matched = false;
                String message = '';
                Set<String> companies = new Set<String>();
                Map<String, OrderWrapper> mappedOrders  = new Map<String, OrderWrapper>();
                for(OrderWrapper ordr : orders){
                    companies.add(ordr.companyName);
                    mappedOrders.put(ordr.companyName, ordr);
                }


            List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Company IN :companies]; 
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :companies];

            /**If they find any Account that matches the Company Name, then do not take any
            action.  **/ 
            if(!accounts.isEmpty()){
                System.debug('accounts : ' + accounts);
                System.debug('an account with the same company name exists');
                return;
            }else if(!leads.isEmpty()){
                /**1.  a. If they find any Lead that matches the Company Name, then convert this Lead into:
                Account, Opportunity and Contact**/
                  for(Lead lead: leads){
                    OrderWrapper getOrder =  mappedOrders.get(lead.Company);
                    if(getOrder!= null){
                         message = convertLead(lead, getOrder);
                    }
                    
                }    

            }else{
                System.debug('No existing Lead and Account ');
                for(OrderWrapper ordr : orders){
                     message = convertToLeadContactAccount(ordr);
                }
               

            }
          
             



    }


    public static String convertLead(Lead lead, OrderWrapper order){
        System.debug('convert Lead process');
        String statusMessage = '';
        Product2 product = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c = :order.productUuid];
        PricebookEntry productEntry = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id = :product.Id];
        Account account = new Account(Name= lead.Company);
        insert account;

        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        Opportunity opportunity =  new Opportunity(Name=lead.Company, StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id = priceBooks[1].Id, AccountId=account.Id);
        insert opportunity;

        Contact contact = new Contact(FirstName = order.personalFirstName, LastName = order.personalLastName, AccountId = account.Id);
        insert contact;

        lead.Status = 'Closed - Converted';
        update lead;

        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
  
        oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=product.Id, Quantity= order.productQuantity, TotalPrice=product.Price__c, PricebookEntryId = productEntry.Id));
        
       
        insert oppProducts;
        
        opportunity.StageName = 'Closed Won';
        update opportunity;

        return SUCCESS;
    }


    public static String convertToLeadContactAccount(OrderWrapper order){
        String statusMessage = '';

        Product2 product = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c = :order.productUuid];
        PricebookEntry productEntry = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id = :product.Id];
        Account account = new Account(Name= order.companyName);
        try{
            insert account;
        } catch (DmlException e){
            Logger.logError('Insert failed in insert Account : ' + e.getMessage());
        
            
        }
        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        Opportunity opportunity =  new Opportunity(Name=order.companyName, StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id = priceBooks[1].Id, AccountId=account.Id);
        try{
         
          insert opportunity;
        }catch(DmlException e){
          Logger.logError('Insert failed in insert Opprtunity : ' + e.getMessage());
          
        
        }

     


        Contact contact = new Contact(FirstName = order.personalFirstName, LastName = order.personalLastName, AccountId = account.Id);
        insert contact;

        
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
  
        oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=product.Id, Quantity= order.productQuantity, TotalPrice=product.Price__c, PricebookEntryId = productEntry.Id));
        
       
        insert oppProducts;

        opportunity.StageName = 'Closed Won';
        update opportunity;

        return SUCCESS;
    }
}