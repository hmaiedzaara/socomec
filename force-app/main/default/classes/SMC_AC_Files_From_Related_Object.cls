/**
 * @description       :
 * @author            : Denis PHAM (Modis)
 * @group             : Modis
 * @last modified on  : 08-JUL-2022
 * @last modified by  : Denis PHAM (Modis)
 * Modifications Log
 * Ver   Date          Author                   Modification
 * 1.0   08-JUL-2022   Denis PHAM (Modis)       Initial Version
 **/

 public with sharing class SMC_AC_Files_From_Related_Object {

    public class WrapperClass{
        @AuraEnabled 
        public String title;
        @AuraEnabled
        public String owner;
        @AuraEnabled
        public String lastModifiedDate;
        @AuraEnabled
        public String contentSize;
        @AuraEnabled
        public String documentId;
    }

    @AuraEnabled
    public static List<WrapperClass> getData(
        String recId,
        String relatedObjectAPIName,
        String communityName
    ){
        
        List<WrapperClass> relatedListRecord  = new List<WrapperClass>();
        Set<Id> setIdContentDocument = new Set<Id>();
        //Retrieve the lookup ID
        String idRelatedObject;
        String query = 'SELECT ' + relatedObjectAPIName + ' FROM ' + getTypeObject(recId) + ' WHERE Id = \'' + recId + '\'';
        idRelatedObject = String.valueOf(Database.query(query)[0].get(relatedObjectAPIName)) ; 

        //From the ID, we retrieve, the related List, with selected fields

        String queryRelatedList;

            
        String queryFiles = 'SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize FROM ContentDocumentLink WHERE  LinkedEntityId  = \'' + idRelatedObject + '\'';
        
        //Select sur le content ID 
        for(ContentDocumentLink cdl : Database.query(queryFiles)){
            WrapperClass wrapItem = new WrapperClass();
            wrapItem.documentId = '/' + communityName + '/s/detail/' + cdl.ContentDocumentId;
            wrapItem.title = cdl.ContentDocument.Title;
            wrapItem.owner = cdl.ContentDocument.Owner.Name;
            wrapItem.lastModifiedDate = (cdl.ContentDocument.LastModifiedDate).format('dd/MM/yyyy HH:mm', String.valueOf(UserInfo.getTimeZone()));
            wrapItem.contentSize = fileSizeToString(cdl.ContentDocument.ContentSize);
            relatedListRecord.add(wrapItem);
        }
        
        return relatedListRecord;       
    }

    @AuraEnabled
    public static string getTitle(
        String recId,
        String relatedObjectAPIName
    ){

        String typeObject = getTypeObject(recId);

        //Field Label Lookup
        Schema.DescribeSObjectResult describeSobjects = ((SObject) (Type.forName('Schema.' + typeObject).newInstance())).getSObjectType().getDescribe();
        String currentFieldLabel =  describeSobjects.fields.getMap().get(relatedObjectAPIName).getDescribe().getLabel();

        String title = currentFieldLabel + ' : Files';
        System.debug(title);
        return title;
    }

    public static string getTypeObject(
        String recId
    ){
        String typeObject;

        Map<String,String> keys = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset())
        keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);
        typeObject = keys.get(String.valueOf(recId).substring(0,3));

        return typeObject;
    }


    public static string fileSizeToString(Integer size)
        {
            /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
            if (size < 1024){
                return string.valueOf(size) + ' Bytes';
            }
            else if (size >= 1024 && size < (1024*1024))
            {
              //KB
              Decimal kb = Decimal.valueOf(size);
              kb = kb.divide(1024,2);
              return string.valueOf(kb) + ' KB';
            }
            else if (size >= (1024*1024) && size < (1024*1024*1024))
            {
              //MB
              Decimal mb = Decimal.valueOf(size);
              mb = mb.divide((1024*1024),2);
              return string.valueOf(mb) + ' MB';
            }
            else
            {
              //GB
              Decimal gb = Decimal.valueOf(size);
              gb = gb.divide((1024*1024*1024),2);
             
              return string.valueOf(gb) + ' GB';
            }    
        }
}