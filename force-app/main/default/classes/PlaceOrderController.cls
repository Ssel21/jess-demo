public with sharing class PlaceOrderController {
    public PlaceOrderController() {

    }
    
    public static final String SUCCESS = 'Success';
    public static final String FAILED = 'Failed';
    public static final String CLOSED_WON = 'Closed Won';


   


    public static OperationResult placeOrder(List<OrderWrapper> orders){
                OperationResult result = new OperationResult();
                Boolean matched = false;
                Boolean isLeadConverted;
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
                result.message = 'No action';
                result.statusCode = 200;
                result.success = true;
                System.debug('Code :  ' + result.statusCode);
                return result;
            }else if(!leads.isEmpty()){
                /**1.  a. If they find any Lead that matches the Company Name, then convert this Lead into:
                Account, Opportunity and Contact**/
                  for(Lead lead: leads){
                    OrderWrapper getOrder =  mappedOrders.get(lead.Company);
                    if(getOrder!= null){
                        
                            LeadConversionQueueable leadConversionJob = new LeadConversionQueueable(lead, getOrder);
                            Id jobId = System.enqueueJob(leadConversionJob);
                            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate, CompletedDate 
                            FROM AsyncApexJob WHERE Id = :jobId];
                        if(job.Status == 'Completed'){
                            System.debug('Lead conversion completed successfully!');
                            result.message = 'Success';
                            result.success = true;
                            result.statusCode = 200;
                        }else if(job.Status == 'Failed'){
                            System.debug('Job failed');
                            result.message = 'Failed';
                            result.success = false;
                            result.statusCode = 500;
                        }else{
                            System.debug('Job Status : ' + job.Status);
                            result.message = 'Failed';
                            result.success = false;
                            result.statusCode = 500;
                        }
                       
                    }
                    
                }    
                System.debug('Code :  ' + result.statusCode);
                return result;

            }else{
                System.debug('No existing Lead and Account ');
                for(OrderWrapper ordr : orders){
                    OpportunityContactAccountQueueable oppQue = new OpportunityContactAccountQueueable(ordr);
                    Id jobId = System.enqueueJob(oppQue);
                    AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate, CompletedDate 
                            FROM AsyncApexJob WHERE Id = :jobId];
                        if(job.Status == 'Completed'){
                            System.debug('Job completed successfully!');
                            result.message = 'Success';
                            result.success = true;
                            result.statusCode = 200;
                        }else if(job.Status == 'Failed'){
                            System.debug('Job failed');
                            result.message = 'Failed';
                            result.success = false;
                            result.statusCode = 500;
                        }else{
                            System.debug('Job Status : ' + job.Status);
                            result.message = 'Failed';
                            result.success = false;
                            result.statusCode = 500;
                        }
                }
               
                // result.message = 'Account, Opportunity and Contact created successfully!';
                // result.statusCode = 200;
                // result.success = true;
                System.debug('Code :  ' + result.statusCode);
                System.debug('success :  ' + result.success);
                System.debug('message :  ' + result.message);
                return result;
            }

           
          
             



    }
 
}