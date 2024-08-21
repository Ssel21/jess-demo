/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PlaceOrderControllerTest {

    @testSetup
    static void setupData() {
        Product2 orderManager = new Product2(Name = 'Order Manager', Product_UUID__c='d7836b3f-2880-47b3-af05-23917941d32c', Price__c=20, IsActive=true);
        Product2 businessManager = new Product2(Name = 'Business Manager', Product_UUID__c='c1a0a951-4eaf-4f81-8252-0335e9a3a509', Price__c=20, IsActive=true);
        List<Product2> products = new List<Product2>();
        products.addAll(new List<Product2>{orderManager, businessManager});
        insert products;
        List<Product2> insertedProducts = [SELECT Id FROM Product2];
        Pricebook2 pricebook = new Pricebook2(Name='Test Price Book', IsActive=true);
        insert pricebook;
        PricebookEntry pricebookEntry1 = new PricebookEntry(UnitPrice=28.99, Pricebook2Id=Test.getStandardPricebookId(), Product2Id=insertedProducts[0].Id, IsActive=true);
        PricebookEntry pricebookEntry2 = new PricebookEntry(UnitPrice=68.99, Pricebook2Id=Test.getStandardPricebookId(), Product2Id=insertedProducts[1].Id, IsActive=true);
        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.addAll(new List<PricebookEntry>{pricebookEntry1, pricebookEntry2});
        insert entries;
        Lead lead = new Lead(FirstName='Jane', LastName='Doe', Company='Earth', Status='Open - Not Contacted');
        insert lead;
        Account account = new Account(Name= 'Venus');
        insert account;
      

        // TO DO: implement unit test
    }


    @isTest
    private static void testLeadConversionQueueable(){
        List<Product2> products = [SELECT Id, Name, Product_UUID__c FROM Product2];
        OrderWrapper orderWrapper1 = new OrderWrapper('Earth', 'testcompany8@gmail.com', '985678122', products[0].Product_UUID__c, 39, 'Test 8 address', 'Lyka', 'Dutton');
        OrderWrapper orderWrapper2 = new OrderWrapper('Mars', 'testcompany9@gmail.com', '985678155', products[1].Product_UUID__c, 55, 'Test 7 address', 'Lindsey', 'Dutton');
        OrderWrapper orderWrapper3 = new OrderWrapper('Saturn', 'testcompany10@gmail.com', '985678144', products[1].Product_UUID__c, 29, 'Test 7 address', 'Cally', 'Dutton');
        List<OrderWrapper> orders = new List<OrderWrapper>();
        orders.add(orderWrapper1);
        orders.add(orderWrapper2);
        orders.add(orderWrapper3);
        Lead lead = [SELECT Id, Name, FirstName, LastName, Company, Status FROM Lead][0];
        System.debug('lead result: ' + lead.Name );
        Test.startTest();
        LeadConversionQueueable leadq = new LeadConversionQueueable(lead, orderWrapper1);
        System.enqueueJob(leadq);
        //System.debug('test result : ' + result );
        
        Test.stopTest();
        Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name =:lead.Name AND StageName = 'Closed Won'];
        System.assertEquals(lead.Name, opp.Name, 'Should have the same name');
        System.assertEquals(opp.StageName, 'Closed Won', 'Should have the same stage name');

    }
    @isTest
    private static void testOpportunityContactAccountQueueable(){
        List<Product2> products = [SELECT Id, Name, Product_UUID__c FROM Product2];
      
        OrderWrapper orderWrapper2 = new OrderWrapper('Jupiter', 'testcompany9@gmail.com', '985678155', products[1].Product_UUID__c, 55, 'Test 7 address', 'Lindsey', 'Dutton');
        Test.startTest();
        OpportunityContactAccountQueueable leadq = new OpportunityContactAccountQueueable(orderWrapper2);
        Id jobId = System.enqueueJob(leadq);
        System.debug('test jobId : ' + jobId );
        
        Test.stopTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = :orderWrapper2.companyName];
        System.assertEquals(orderWrapper2.companyName, acc.Name, 'Should have the same name');


    }
    @isTest
    private static void testWithExistingLead(){
        List<Product2> products = [SELECT Id, Name, Product_UUID__c FROM Product2];
        OrderWrapper orderWrapper1 = new OrderWrapper('Earth', 'testcompany8@gmail.com', '985678122', products[0].Product_UUID__c, 39, 'Test 8 address', 'Lyka', 'Dutton');
        OrderWrapper orderWrapper2 = new OrderWrapper('Mars', 'testcompany9@gmail.com', '985678155', products[1].Product_UUID__c, 55, 'Test 7 address', 'Lindsey', 'Dutton');
        OrderWrapper orderWrapper3 = new OrderWrapper('Saturn', 'testcompany10@gmail.com', '985678144', products[1].Product_UUID__c, 29, 'Test 7 address', 'Cally', 'Dutton');
        List<OrderWrapper> orders = new List<OrderWrapper>();
        orders.add(orderWrapper1);
        orders.add(orderWrapper2);
        orders.add(orderWrapper3);
        Test.startTest();
        PlaceOrderController.placeOrder(orders);
        
        
        Test.stopTest();
        Lead lead = [SELECT Id, Status, Company FROM Lead WHERE Company = 'Earth'];
        System.debug('Lead Company : ' + lead.Company);
      
        System.assertEquals(lead.Status, 'Closed - Converted', 'Should be the same Stage');
     


    }
    @isTest
    private static void testWithNoExistingLead(){
        List<Product2> products = [SELECT Id, Name, Product_UUID__c FROM Product2];
        OrderWrapper orderWrapper1 = new OrderWrapper('Mars', 'testcompany9@gmail.com', '985678155', products[1].Product_UUID__c, 55, 'Test 7 address', 'Lindsey', 'Dutton');
        OrderWrapper orderWrapper2 = new OrderWrapper('Saturn', 'testcompany10@gmail.com', '985678144', products[1].Product_UUID__c, 29, 'Test 7 address', 'Cally', 'Dutton');
        List<OrderWrapper> orders = new List<OrderWrapper>();
        orders.add(orderWrapper1);
        orders.add(orderWrapper2);
        Test.startTest();
        PlaceOrderController.placeOrder(orders);
        
        
        Test.stopTest();
        Lead lead = [SELECT Id, Company FROM Lead WHERE Company = 'Earth'];
        System.assertEquals(true, lead.Company !=orderWrapper2.companyName, 'Should not have the same name');


    }
    @isTest
    private static void testWithExistingAccount(){
        List<Product2> products = [SELECT Id, Name, Product_UUID__c FROM Product2];
        //OrderWrapper orderWrapper1 = new OrderWrapper('Earth', 'testcompany8@gmail.com', '985678122', products[0].Product_UUID__c, 39, 'Test 8 address', 'Lyka', 'Dutton');
        OrderWrapper orderWrapper2 = new OrderWrapper('Venus', 'testcompany9@gmail.com', '985678155', products[1].Product_UUID__c, 55, 'Test 7 address', 'Lindsey', 'Dutton');
        OrderWrapper orderWrapper3 = new OrderWrapper('Saturn', 'testcompany10@gmail.com', '985678144', products[1].Product_UUID__c, 29, 'Test 7 address', 'Cally', 'Dutton');
        List<OrderWrapper> orders = new List<OrderWrapper>();
        //orders.add(orderWrapper1);
        orders.add(orderWrapper2);
        orders.add(orderWrapper3);
        Test.startTest();
        PlaceOrderController.placeOrder(orders);
        
        
        Test.stopTest();
         Account acc = [SELECT Id, Name FROM Account WHERE Name = :orderWrapper2.companyName];
        System.assertEquals(orderWrapper2.companyName, acc.Name, 'Should have the same name');


    }
}