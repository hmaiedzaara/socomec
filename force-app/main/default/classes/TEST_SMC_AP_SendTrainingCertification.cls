@IsTest
public without sharing class TEST_SMC_AP_SendTrainingCertification {
    
    @isTest
    public static void testSendEmailWithPDF(){
        // Generate users
        Profile profileStandard = [
          SELECT Id
          FROM Profile
          WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        ];
        User user = SMC_UTIL_TestUtils.createUser(
          STA_UtilsStatic.TEST_DIESE,
          STA_UtilsStatic.EMAIL_TEST,
          profileStandard.Id,
          STA_UtilsStatic.USERNAME_TEST,
          STA_UtilsStatic.USER_NICKNAME
        );
        insert user;
        
        //Training
        SMC_Training__c training = SMC_UTIL_TestUtils.createTraining(STA_UtilsStatic.TEST, 
                                                                    STA_UtilsStatic.TEST, 
                                                                    1);
        insert training;
        // Training Certificate
        SMC_TrainingCertificate__c trainingCertificate = 
                                        SMC_UTIL_TestUtils.createTrainingCertificate(STA_UtilsStatic.TEST, 
                                                                                    STA_UtilsStatic.TEST, 
                                                                                    STA_UtilsStatic.TEST);
        insert trainingCertificate;
        // Training Session
        SMC_TrainingSession__c trainingSession = 
                                    SMC_UTIL_TestUtils.createTrainingSession(STA_UtilsStatic.TEST, 
                                                                            'Open Registration',
                                                                            training.Id,
                                                                            UserInfo.getUserId());
        insert trainingSession;
        // Training Participant
        SMC_TrainingParticipant__c trainingParticipant = 
                                        SMC_UTIL_TestUtils.createTrainingParticipant(UserInfo.getUserId(), 
                                                                                    trainingSession.Id);
        insert trainingParticipant;
        trainingParticipant = [SELECT Id, SMC_Name__c, SMC_Email__c FROM SMC_TrainingParticipant__c WHERE Id = :trainingParticipant.Id];

        //Flow Input
        SMC_AP_SendTrainingCertificationMail.FlowInputs inputs = new SMC_AP_SendTrainingCertificationMail.FlowInputs();
        inputs.participantId = trainingParticipant.Id;
        inputs.participantName = trainingParticipant.SMC_Name__c;
        inputs.participantEmail = trainingParticipant.SMC_Email__c;
        inputs.sessionId = trainingSession.Id;
        inputs.certificationName = trainingCertificate.Name;

        System.runAs(user){
            Test.startTest();
                SMC_AP_SendTrainingCertificationMail.sendEmailWithPDF(new List<SMC_AP_SendTrainingCertificationMail.FlowInputs>{inputs});
            Test.stopTest();

            String participantName;
            if(trainingParticipant.SMC_Name__c.split('_HL_').size() > 1){
                participantName = trainingParticipant.SMC_Name__c.split('_HL_')[2];
            }
            else if(trainingParticipant.SMC_Name__c.split('</a>').size() > 1){
                participantName = trainingParticipant.SMC_Name__c.split('</a>')[0].split('>')[1];
            }
            else{
                participantName = trainingParticipant.SMC_Name__c;
            }
            ContentDocumentLink cdl = [SELECT Id, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :UserInfo.getUserId()];
            System.assertNotEquals('Certification ' + trainingCertificate.Name + ' - ' + participantName, cdl.ContentDocument.Title);
        }
    }
}