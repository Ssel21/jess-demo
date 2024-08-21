public with sharing class LeadConversionQueueable implements Queueable {

    private Lead lead;
    private OrderWrapper order;
    public static final String CLOSED_WON = 'Closed Won';

    public LeadConversionQueueable(Lead lead, OrderWrapper order) {
        this.lead = lead;
        this.order = order;
    }


    public void execute(QueueableContext context){
        System.debug('convert Lead process');
        String statusMessage = '';
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);

        LeadStatus convertStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.ApiName);
        lc.setOpportunityName(lead.Name);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug('convert success');
        if(lcr.isSuccess()){
            System.debug('is succeeeesss');
            Opportunity opportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :lcr.getOpportunityId()];
            Product2 product = [SELECT Id, Name, Product_UUID__c, Price__c  FROM Product2 WHERE Product_UUID__c = :order.productUuid];
            PricebookEntry productEntry = [SELECT Id, Product2Id  FROM PricebookEntry WHERE Product2Id = :product.Id];
            List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
            oppProducts.add(new OpportunityLineItem(OpportunityId = opportunity.Id, Product2Id=product.Id, Quantity= order.productQuantity, TotalPrice=product.Price__c, PricebookEntryId = productEntry.Id));
            insert oppProducts;
    
         
            opportunity.StageName = CLOSED_WON;
            update opportunity;
            
            //return true;
    
        }else{
            System.debug('Lead conversion failed: ' + lcr.getErrors());
          
            //return false;
    
        }
    }
    
}