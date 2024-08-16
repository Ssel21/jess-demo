public with sharing class OrderWrapper {
    @AuraEnabled
    public String companyName {get; set;}
    @AuraEnabled
    public String email {get; set;}
    @AuraEnabled
    public String phone {get; set;}
    @AuraEnabled
    public String productUuid {get; set;}
    @AuraEnabled
    public Integer productQuantity {get; set;}
    @AuraEnabled
    public String address {get; set;}
    @AuraEnabled
    public String personalFirstName {get; set;} 
    @AuraEnabled
    public String personalLastName {get; set;} 


    public OrderWrapper(String companyName, String email, String phone, String productUuid, Integer productQuantity,
    String address, String personalFirstName, String personalLastName ) {
        this.companyName = companyName;
        this.email = email;
        this.phone = phone;
        this.productUuid = productUuid;
        this.productQuantity = productQuantity;
        this.address = address;
        this.personalFirstName = personalFirstName;
        this.personalLastName = personalLastName;
    }
}