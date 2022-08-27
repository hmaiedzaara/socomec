public class SMC_AC_VFP_Training_Template_Controller {
    public String backgroundPicture {get; set;}
    public String participant {get; set;}
    public String company {get; set;}
    public Date endValidity {get; set;}
    public String trainer {get; set;}
    
    public SMC_AC_VFP_Training_Template_Controller(){
        String recordParticipantId = ApexPages.currentPage().getParameters().get('participantid');
        String recordSessionId = ApexPages.currentPage().getParameters().get('sessionid');
        //String recordID = 'a4K9E000000DR9EUAW';
        SMC_TrainingCertification__c trainingCertification = [SELECT SMC_Participant_Name__c,
                                      		 						 SMC_End_Validity__c,
                                      		 						 SMC_Trainer__c,
                                      		 						 SMC_TrainingCertificate__r.SMC_Template__c,
                                                                     SMC_TrainingParticipant__r.SMC_Contact__c,
                                                                     SMC_TrainingParticipant__r.SMC_User__c
                                      						  FROM SMC_TrainingCertification__c 
                                      						  WHERE SMC_TrainingParticipant__c = :recordParticipantId AND 
                                                                    SMC_Training_Session__c = :recordSessionId
                                                                    ORDER BY CreatedDate DESC LIMIT 1];
        //Check contact or user and fill company
        if(trainingCertification.SMC_TrainingParticipant__r.SMC_Contact__c != null){
            this.company = 'from ' + [SELECT Account.Name FROM Contact WHERE Id = :trainingCertification.SMC_TrainingParticipant__r.SMC_Contact__c].Account.Name + ',';
        }
        else {
            this.company = 'from SOCOMEC,';
        }
        //Background picture
        if(trainingCertification.SMC_TrainingCertificate__r.SMC_Template__c != null && 
           trainingCertification.SMC_TrainingCertificate__r.SMC_Template__c != '')
            backgroundPicture = trainingCertification.SMC_TrainingCertificate__r.SMC_Template__c.split('"')[1];
        //Participant name
        if(trainingCertification.SMC_Participant_Name__c.split('>').size() > 1)
        	this.participant = trainingCertification.SMC_Participant_Name__c.split('>')[1].split('<')[0] + ',';
        else
            this.participant = trainingCertification.SMC_Participant_Name__c + ',';
        //Expiration date
        this.endValidity = trainingCertification.SMC_End_Validity__c;
        //Trainer name
        this.trainer = trainingCertification.SMC_Trainer__c;
    }
}