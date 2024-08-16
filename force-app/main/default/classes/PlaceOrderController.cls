public with sharing class PlaceOrderController {
    public PlaceOrderController() {

    }
    public static final String SUCCESS = 'Success';
    public static final String FAILED = 'Failed';


   


    public static void placeOrder(List<OrderWrapper> orders){
        
                Boolean matched = false;
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
                    String message = convertLead(lead, getOrder);
                }    

            }else{
                System.debug('No existing Lead and Account ');
                for(OrderWrapper ordr : orders){
                    String message = convertToLeadContactAccount(ordr);
                }
               

            }
          
             



        /**Set<String> productUuIds = new Set<String>();
        Set<Id> product2Ids = new Set<Id>();
        for(OrderWrapper order: orders){
            productUuIds.add(order.productUuid);
        }

        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        Opportunity opportunity =  new Opportunity(Name = 'Opp Test 4',  StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id = priceBooks[1].Id);
        insert opportunity; 
        
        
        List<Product2> products = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c IN :productUuIds];
        //map to get product ids easily
        Map<Id, Product2> mappedProdIds = new Map<Id, Product2>(products);
        //map to get product UUIDS easily
        Map<String, Product2> mappedProducts = new Map<String, Product2>(products);
        //get all product ids
        product2Ids = mappedProdIds.keySet();
        //map products and its UUIDS
        for(Product2 prod: products){
            mappedProducts.put(prod.Product_UUID__c, prod);
        }

        List<PricebookEntry> productEntries = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id IN :product2Ids];
        Map<Id, Id> mappedPricebookEntries = new Map<Id, Id>();
        for(PricebookEntry entry: productEntries){
            mappedPricebookEntries.put(entry.Product2Id, entry.Id);
        }

        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
        for(OrderWrapper order: orders){
            Product2 filteredProduct = mappedProducts.get(order.productUuid);
            Id filteredPricebookEntry = mappedPricebookEntries.get(filteredProduct.Id);
            oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=filteredProduct.Id, Quantity= order.productQuantity, TotalPrice=filteredProduct.Price__c, PricebookEntryId = filteredPricebookEntry));
        }
       
        insert oppProducts;**/
    }


    public static String convertLead(Lead lead, OrderWrapper order){
        String statusMessage = '';
        Account account = new Account(Name= lead.Company);
        insert account;

        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        Opportunity opportunity =  new Opportunity(Name=lead.Company, StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id = priceBooks[1].Id, AccountId=account.Id);
        insert opportunity;

        Contact contact = new Contact(FirstName = order.personalFirstName, LastName = order.personalLastName, AccountId = account.Id);
        insert contact;

        return SUCCESS;
    }
    public static String convertToLeadContactAccount(OrderWrapper order){
        String statusMessage = '';

        Product2 product = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c = :order.productUuid];
        PricebookEntry productEntry = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id = :product.Id];
        Account account = new Account(Name= order.companyName);
        insert account;

        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        Opportunity opportunity =  new Opportunity(Name=order.companyName, StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id = priceBooks[1].Id, AccountId=account.Id);
        insert opportunity;


        Contact contact = new Contact(FirstName = order.personalFirstName, LastName = order.personalLastName, AccountId = account.Id);
        insert contact;

        
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
  
        oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=product.Id, Quantity= order.productQuantity, TotalPrice=product.Price__c, PricebookEntryId = productEntry.Id));
        
       
        insert oppProducts;

        return SUCCESS;
    }
}