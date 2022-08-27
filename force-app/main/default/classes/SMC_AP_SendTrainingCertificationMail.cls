/**
 * @File Name          : SMC_AP_SendTrainingCertificationMail.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 24/02/2022
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    24/02/2022   Vincent RECASENS (Modis)     Initial Version
 **/
public without sharing class SMC_AP_SendTrainingCertificationMail {
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public Id participantId;
        @InvocableVariable
        public String participantName;
        @InvocableVariable
        public String participantEmail;
        @InvocableVariable
        public Id sessionId;
        @InvocableVariable
        public String certificationName;
    }
    
    /*** GENERER PDF + ENVOIE EMAIL ***/
    @InvocableMethod(label='Training certification email & PDF')
    public static void sendEmailWithPDF(List<FlowInputs> request){
        System.enqueueJob(new GeneratePDFAndSendEmail(request));
    }
   
    public class GeneratePDFAndSendEmail implements Queueable, Database.AllowsCallouts {
    // public class GeneratePDFAndSendEmail implements Queueable {
        List<FlowInputs> request;
        public GeneratePDFAndSendEmail(List<FlowInputs> request) {
            this.request = request;
        }

        public void execute(QueueableContext context){
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
            //EmailTemplate
            EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :STA_UtilsStatic.TRAINING_CERTIFICATION_ET];
            //FromAddress
            String orgNoReplyId = [SELECT Id FROM OrgwideEmailAddress WHERE DisplayName = :STA_UtilsStatic.NOREPLY_NAME].Id;
            //Check sandbox
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            for(FlowInputs oneInput: this.request){
                //Set certificat
                PageReference ref = 
                    new PageReference('/apex/SMC_VFP_Training_Certification_Template?participantid=' + 
                                        oneInput.participantId + 
                                      '&sessionid=' + 
                                        oneInput.sessionId);
                Blob b;
                if(!Test.isRunningTest()){
                    b = ref.getContentAsPDF();
                }
                else {
                    b = Blob.valueOf('Test Blob');
                }
    
                //Prepare files to insert
                insertContentVersion.add(insertionFiles(oneInput, b));
    
                //Set emails to send
                emailToSend.add(buildMail(oneInput, b, orgNoReplyId, theEmailTemplate, isSandbox));
    
            }
            insert insertContentVersion;
            
            //Send email
            Messaging.SendEmailResult[] results;
            if (!Test.isRunningTest()) {
                results = Messaging.sendEmail(emailToSend);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug(
                    'The email failed to send: ' + results[0].errors[0].message
                    );
                }
            }
        }
    }

    /**
    * @description : insert pfd in files
    * @author Vincent RECASENS (Modis) | 02-24-2022 
    * @param newMap 
    * @param mapParticipantId_PDF 
    * @return List<ContentDocumentLink> 
    **/
    public static ContentVersion insertionFiles(FlowInputs oneInput, Blob b){
        //Set participant name
        String participantName;
        if(oneInput.participantName.split('_HL_').size() > 1){
            participantName = oneInput.participantName.split('_HL_')[2];
        }
        else if(oneInput.participantName.split('</a>').size() > 1){
            participantName = oneInput.participantName.split('</a>')[0].split('>')[1];
        }
        else{
            participantName = oneInput.participantName;
        }
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Certification ' + oneInput.certificationName + ' - ' + participantName;
        cv.PathOnClient = 'Certification ' + oneInput.certificationName + ' - ' + participantName + '.pdf';
        cv.VersionData = b;
        cv.FirstPublishLocationId = oneInput.participantId;
        return cv;
    }
    
    //Method to build an email
    public static Messaging.SingleEmailMessage buildMail(FlowInputs oneInput, Blob attchBody, Id orgNoReplyId, EmailTemplate theEmailTemplate, Boolean isSandbox){
        //Set participant name
        String participantName;
        if(oneInput.participantName.split('_HL_').size() > 1){
            participantName = oneInput.participantName.split('_HL_')[2];
        }
        else if(oneInput.participantName.split('</a>').size() > 1){
            participantName = oneInput.participantName.split('</a>')[0].split('>')[1];
        }
        else{
            participantName = oneInput.participantName;
        }
        
        //Attachment part
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Certification ' + oneInput.certificationName + ' - ' + participantName + '.pdf');
        efa.setbody(attchBody);
        //Create an email message object
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(theEmailTemplate.Id, UserInfo.getUserId(), null);
        mail.setSaveAsActivity(false);
        //Set body
        String body = mail.getHtmlBody();
        // String host = URL.getSalesforceBaseUrl().toExternalForm().split('\\.')[0] + '--c' + (isSandbox ? '.sandbox' : '');
        // body = body.replace('$$HOST$$', host);
        body = body.replace('$$PARTICIPANT_NAME$$', participantName);
        body = body.replace('$$TRAINING_CERTIFICATION$$', oneInput.certificationName);
        mail.setHtmlBody(body);
        //Set attachment
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        //Set addresses
        mail.setToAddresses(new List<String>{oneInput.participantEmail});
        mail.setOrgWideEmailAddressId(orgNoReplyId);
        //Set subject
        mail.setSubject('Certification ' + oneInput.certificationName + ' - ' + participantName);
        return mail;
    }
}