/**
 * @File Name          : SMC_DTO_ML_Wrapper_Documents.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:55:26
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_ML_Wrapper_Documents {
  @AuraEnabled
  public List<SMC_DTO_ML_Document> documents;

  public with sharing class SMC_DTO_ML_Document {
    @AuraEnabled
    public Double averageRate;
    @AuraEnabled
    public String document_reference;
    @AuraEnabled
    public String docTreeLevel;
    @AuraEnabled
    public String publicPicturePath;
    @AuraEnabled
    public String documentType;
    @AuraEnabled
    public String dbid;
    @AuraEnabled
    public Integer userRate;
    @AuraEnabled
    public List<SMC_DTO_ML_File> files;
    @AuraEnabled
    public String documentId;
    @AuraEnabled
    public String documentTitle;
    @AuraEnabled
    public String thumbnail_url;
  }

  public with sharing class SMC_DTO_ML_File {
    @AuraEnabled
    public String fileName;
    @AuraEnabled
    public String audience;
    @AuraEnabled
    public Boolean canRead;
    @AuraEnabled
    public String last_version_date;
    @AuraEnabled
    public String author;
    @AuraEnabled
    public Boolean isNew;
    @AuraEnabled
    public String creation_date;
    @AuraEnabled
    public String publicPath;
    @AuraEnabled
    public List<SMC_DTO_ML_Target> targets;
    @AuraEnabled
    public String dbid;
    @AuraEnabled
    public Boolean isPublic;
    @AuraEnabled
    public String fileReference;
    @AuraEnabled
    public String lang;
    @AuraEnabled
    public String fileId;
  }

  public with sharing class SMC_DTO_ML_Target {
    @AuraEnabled
    public String target_name;
  }
}