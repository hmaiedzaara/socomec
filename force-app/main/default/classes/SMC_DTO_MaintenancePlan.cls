public with sharing class SMC_DTO_MaintenancePlan {
    public with sharing class SMC_DTO_MaintenancePlan_Routes {
        @AuraEnabled
        public List<SMC_DTO_MaintenancePlan_Route> routes;

        public SMC_DTO_MaintenancePlan_Routes() {
            this.routes = new List<SMC_DTO_MaintenancePlan_Route>();
        }
    }

    public with sharing class SMC_DTO_MaintenancePlan_Route {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public List<SMC_DTO_MaintenancePlan_Section> sections;
        
        public SMC_DTO_MaintenancePlan_Route() {
            this.sections = new List<SMC_DTO_MaintenancePlan_Section>();
        }
    }


    public with sharing class SMC_DTO_MaintenancePlan_Section {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_DepartureArrival departure;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_DepartureArrival arrival;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_Summary summary;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_Transport transport;

        public SMC_DTO_MaintenancePlan_Section(){
            this.departure = new SMC_DTO_MaintenancePlan_DepartureArrival();
            this.arrival = new SMC_DTO_MaintenancePlan_DepartureArrival();
            this.summary = new SMC_DTO_MaintenancePlan_Summary();
            this.transport = new SMC_DTO_MaintenancePlan_Transport();
        }
    }

    public with sharing class SMC_DTO_MaintenancePlan_DepartureArrival {
        @AuraEnabled
        public String timeDA;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_DepartureArrival_Place place;

        public SMC_DTO_MaintenancePlan_DepartureArrival(){
            this.place = new SMC_DTO_MaintenancePlan_DepartureArrival_Place();
        }
    }

    public with sharing class SMC_DTO_MaintenancePlan_DepartureArrival_Place {
        @AuraEnabled
        public String type;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_DepartureArrival_Location location;
        @AuraEnabled
        public SMC_DTO_MaintenancePlan_DepartureArrival_Location originalLocation;
        
        public SMC_DTO_MaintenancePlan_DepartureArrival_Place(){
            this.location = new SMC_DTO_MaintenancePlan_DepartureArrival_Location();
            this.originalLocation = new SMC_DTO_MaintenancePlan_DepartureArrival_Location();
        }
    }

    public with sharing class SMC_DTO_MaintenancePlan_DepartureArrival_Location {
        @AuraEnabled
        public Decimal lat;
        @AuraEnabled 
        public Decimal lng;
    }

    public with sharing class SMC_DTO_MaintenancePlan_Summary {
        @AuraEnabled
        public Integer duration;
        @AuraEnabled
        public Integer lenght;
        @AuraEnabled
        public Integer baseDuration;
    }

    public with sharing class SMC_DTO_MaintenancePlan_Transport {
        @AuraEnabled
        public String mode;
    }


}