public with sharing class OperationResult {
    @AuraEnabled
    public Boolean success { get; set; }
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public Integer statusCode { get; set; }
    public OperationResult() {
    // this.success = success;
    // this.message = message;
    // this.statusCode = statusCode;
    }
}