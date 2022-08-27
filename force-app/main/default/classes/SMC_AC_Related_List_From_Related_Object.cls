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
public with sharing class SMC_AC_Related_List_From_Related_Object {

    
    @AuraEnabled
    public static List<sObject> getData(
        String recId,
        String relatedObjectAPIName,
        String relatedListAPIName,
        String relatedLookupAPIName,
        String listFieldsAPIName
    ){
        List<sObject> relatedListRecord  = new List<sObject>();
        Set<Id> setIdContentDocument = new Set<Id>();
        //Retrieve the lookup ID
        String idRelatedObject;
        String query = 'SELECT ' + relatedObjectAPIName + ' FROM ' + getTypeObject(recId) + ' WHERE Id = \'' + recId + '\'';
        idRelatedObject = String.valueOf(Database.query(query)[0].get(relatedObjectAPIName)) ; 

        //From the ID, we retrieve, the related List, with selected fields
        if(listFieldsAPIName != null && listFieldsAPIName != ''){
            listFieldsAPIName = ',' + listFieldsAPIName;
        } else {
            listFieldsAPIName = '';
        }
        System.debug('listFieldsAPIName +++++ ' + listFieldsAPIName);
        String queryRelatedList;
        if(relatedListAPIName == 'ContentDocument'){
            
            String queryFiles = 'SELECT ContentDocumentId FROM ContentDocumentLink WHERE ' + relatedLookupAPIName  + ' = \'' + idRelatedObject + '\'';
            //Select sur le content ID 
            for(ContentDocumentLink cdl : Database.query(queryFiles)){
                setIdContentDocument.add(cdl.ContentDocumentId);
            }

            if(setIdContentDocument.size()>0){
                String setIdToString = String.join(new List<Id>(setIdContentDocument), '\', \'');
                queryRelatedList = 'SELECT Id' + listFieldsAPIName + ' FROM ' + relatedListAPIName + ' WHERE Id IN (\'' + setIdToString + '\')';
            }
        }else {
            queryRelatedList = 'SELECT Id' + listFieldsAPIName + ' FROM ' + relatedListAPIName + ' WHERE ' + relatedLookupAPIName + ' = \'' + idRelatedObject + '\'';
        }
        System.debug('queryRelatedList +++++ ' + queryRelatedList);

        for(sObject so : Database.query(queryRelatedList)){
            listFieldsAPIName = 'Id' + listFieldsAPIName;
        }

        try {
            relatedListRecord = Database.query(queryRelatedList);
            System.debug('relatedListRecord +++++ ' + relatedListRecord);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return relatedListRecord;       
    }

    @AuraEnabled
    public static Map<String, String> getColumns(
        String relatedListAPIName,
        String listFieldsAPIName
    ){
        Map<String, String> mapColumnsAPItoLabel = new Map<String, String>();
        List<String> listFieldsToDisplay = new List<String>();
        
        if(listFieldsAPIName != null && listFieldsAPIName != ''){
            listFieldsToDisplay = listFieldsAPIName.split(',');
        }

        if(listFieldsToDisplay.size() > 0)
        {
            for(String col : listFieldsToDisplay){
                col = col.replace(' ', '');
                /*if(col.contains('.')){

                    //Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get(relatedListAPIName).getDescribe().fields.getMap().get(col).getDescribe();
                    mapColumnsAPItoLabel.put(col, Schema.getGlobalDescribe().get().getDescribe().fields.getMap().get(col.substringAfter('.')).getDescribe().getLabel());
                } else{*/
                    //mapColumnsAPItoLabel.put(col, Schema.getGlobalDescribe().get(relatedListAPIName).getDescribe().fields.getMap().get(col).getDescribe().getLabel());
                    mapColumnsAPItoLabel.put(col, col);
                //}
                
            }
        }

        return mapColumnsAPItoLabel;
    }

    @AuraEnabled
    public static string getTitle(
        String recId,
        String relatedObjectAPIName,
        String relatedListAPIName
    ){

        String typeObject = getTypeObject(recId);

        //Field Label Lookup
        Schema.DescribeSObjectResult describeSobjects = ((SObject) (Type.forName('Schema.' + typeObject).newInstance())).getSObjectType().getDescribe();
        String currentFieldLabel =  describeSobjects.fields.getMap().get(relatedObjectAPIName).getDescribe().getLabel();

        //Object Related List Name
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(relatedListAPIName);
        String relatedListName = objectSchema.getDescribe().getLabel();

        String title = currentFieldLabel + ' : ' + relatedListName;

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
}