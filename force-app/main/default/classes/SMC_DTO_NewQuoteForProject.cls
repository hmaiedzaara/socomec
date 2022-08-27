public class SMC_DTO_NewQuoteForProject {

    @AuraEnabled
    public Opportunity opportunity {get; set;}

    @AuraEnabled
    public Quote newQuote {get; set;}

    @AuraEnabled
    public Boolean isPartnerUser {get; set;}

    @AuraEnabled
    public List<Account> accounts {get; set;}

    @AuraEnabled
    public String defaultAccount {get; set;}
    
    @AuraEnabled
    public List<Contact> contacts {get; set;}

    @AuraEnabled
    public String defaultContact {get; set;}

    @AuraEnabled
    public List<User> users {get; set;}

    @AuraEnabled
    public String defaultOwner {get; set;}

    @AuraEnabled
    public String defaultReminderPilot {get; set;}
    
    @AuraEnabled
    public String defaultUser {get; set;}
    
    @AuraEnabled
    public Boolean hasSyncQuote {get; set;}
    
    @AuraEnabled
    public SMC_DTO_QuotationTool_MissingFields dtoMissingFields {get; set;}

    public SMC_DTO_NewQuoteForProject(){}

    public SMC_DTO_NewQuoteForProject(Opportunity opportunity, List<Account> accounts, List<Contact> contacts, SMC_DTO_QuotationTool_MissingFields dtoMissingFields, Boolean hasSyncQuote, List<User> users){
        this.opportunity = opportunity;
        
        this.accounts = accounts;
        this.defaultAccount = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
        this.contacts = contacts;
        this.defaultContact = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;

        this.dtoMissingFields = dtoMissingFields;
        this.hasSyncQuote = hasSyncQuote;
        
        this.users = users;
        this.defaultOwner = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
        this.defaultReminderPilot = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;

        //Set the new Quote
        this.newQuote = new Quote();
        newQuote.SMC_Closing_Date__c = Date.today().addMonths(1); //CloseDate -> today + 1 month
        newQuote.SMC_Probability__c = 5;
    }

    public SMC_DTO_NewQuoteForProject(Boolean currentUserIsPrimaryContact, Opportunity opportunity, List<Account> accounts, List<Contact> contacts, SMC_DTO_QuotationTool_MissingFields dtoMissingFields, Boolean hasSyncQuote, List<User> users){
        this.isPartnerUser = currentUserIsPrimaryContact;
        
        this.opportunity = opportunity;
        
        this.accounts = accounts;
        this.defaultAccount = currentUserIsPrimaryContact ? accounts[0].Name  : STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
        this.contacts = contacts;
        this.defaultContact = currentUserIsPrimaryContact ? contacts[0].Name  : STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;

        this.dtoMissingFields = dtoMissingFields;
        this.hasSyncQuote = hasSyncQuote;
        
        this.users = users;
        this.defaultOwner = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;
        this.defaultReminderPilot = STA_UtilsStatic.DEFAULT_PICKLIST_VALUE;

        //Set the new Quote
        this.newQuote = new Quote();
        newQuote.SMC_Closing_Date__c = Date.today().addMonths(1); //CloseDate -> today + 1 month
        newQuote.SMC_Probability__c = 5;
    }
}