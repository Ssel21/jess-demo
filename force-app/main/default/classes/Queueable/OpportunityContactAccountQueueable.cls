public with sharing class OpportunityContactAccountQueueable implements Queueable {
    private OrderWrapper order;
    public static final String CLOSED_WON = 'Closed Won';
    public OpportunityContactAccountQueueable(OrderWrapper order) {
        this.order = order;
    }

    public void execute(QueueableContext context){
        String statusMessage = '';

        Product2 product = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c = :order.productUuid];
        PricebookEntry productEntry = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id = :product.Id];
        List<Pricebook2> priceBooks = [SELECT Id, Name FROM Pricebook2];
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
try{
    Account account = new Account(Name= order.companyName);
    insert account;
    System.debug('inserted account : ' + account);
    Opportunity opportunity =  new Opportunity(Name=order.companyName, StageName='Prospecting', CloseDate=Date.today(),  AccountId = account.Id);
    if(Test.isRunningTest()){
        opportunity.Pricebook2Id = Test.getStandardPricebookId();
       
    }else{
        opportunity.Pricebook2Id =  priceBooks[0].Id;
       
    }
    insert opportunity;

    Contact contact = new Contact(FirstName = order.personalFirstName, LastName = order.personalLastName, AccountId = account.Id);
    insert contact;
    oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=product.Id, Quantity= order.productQuantity, TotalPrice=product.Price__c, PricebookEntryId = productEntry.Id));
    insert oppProducts;
    
    System.debug('opportunity Id : ' + opportunity.Id);
    System.debug('contact Id : ' + contact.Id);
    System.debug('account Id : ' + account.Id);

}catch (DmlException e) {
    // Handle DML exception
    System.debug('A DML error occurred: ' + e.getMessage());
} catch (Exception e) {
    // Handle other types of exceptions
    System.debug('An unexpected error occurred: ' + e.getMessage());
}
        

    }
}