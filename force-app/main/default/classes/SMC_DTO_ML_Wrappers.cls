/**
 * @File Name          : SMC_DTO_ML_Wrappers.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-30-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    18/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_DTO_ML_Wrappers {
  public with sharing class SMC_DTO_ML_AllData {
    @AuraEnabled
    public SMC_DTO_ML_Documents docList;
    @AuraEnabled
    public Integer totalrecords;
    @AuraEnabled
    public Integer actualLimit;
    @AuraEnabled
    public SMC_DTO_ML_Others sortList;
    @AuraEnabled
    public SMC_DTO_ML_PF_Parent bas;
    // @AuraEnabled
    // public SMC_DTO_ML_PF_Parent basToDisplay;
    @AuraEnabled
    public SMC_DTO_ML_PF_Parent productFamily;
    // @AuraEnabled
    // public SMC_DTO_ML_Others docTypeToDisplay;
    @AuraEnabled
    public SMC_DTO_ML_Others docType;
    @AuraEnabled
    public SMC_DTO_ML_Others language;
    // @AuraEnabled
    // public SMC_DTO_ML_Others languageTodisplay;

    public SMC_DTO_ML_AllData() {
      this.docList = new SMC_DTO_ML_Documents();
      this.sortList = new SMC_DTO_ML_Others();
      this.actualLimit = 50;
    }
  }

  public with sharing class SMC_DTO_ML_Documents {
    @AuraEnabled
    public List<SMC_DTO_ML_Document> documents;
    @AuraEnabled
    public Integer nbDocuments;
    @AuraEnabled
    public String responseBody;

    public SMC_DTO_ML_Documents() {
      this.documents = new List<SMC_DTO_ML_Document>();
    }
  }

  public with sharing class SMC_DTO_ML_Document implements Comparable {
    @AuraEnabled
    public Double averageRate;
    @AuraEnabled
    public String document_reference;
    @AuraEnabled
    public String docTreeLevel;
    @AuraEnabled
    public String publicPicturePath;
    @AuraEnabled
    public String subfamily;
    @AuraEnabled
    public String family;
    @AuraEnabled
    public String publicPictureDefaultPath;
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

    public Integer compareTo(Object compareTo) {
      SMC_DTO_ML_Document compareToGoal = (SMC_DTO_ML_Document) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;

      if (this.documentTitle > compareToGoal.documentTitle) {
        return 1;
      } else if (this.documentTitle < compareToGoal.documentTitle) {
        return -1;
      }

      return returnValue;
    }
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

  public with sharing class SMC_DTO_ML_PF_Parent {
    @AuraEnabled
    public List<SMC_DTO_ML_PF_Children> children;

    public SMC_DTO_ML_PF_Parent() {
      this.children = new List<SMC_DTO_ML_PF_Children>();
    }
  }

  public with sharing class SMC_DTO_ML_PF_Children {
    @AuraEnabled
    public List<SMC_DTO_ML_PF_GrandChildren> grandChildren;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String id;

    public SMC_DTO_ML_PF_Children() {
      this.grandChildren = new List<SMC_DTO_ML_PF_GrandChildren>();
    }

    public SMC_DTO_ML_PF_Children(String label, String value) {
      this.grandChildren = new List<SMC_DTO_ML_PF_GrandChildren>();
      this.name = label;
      this.id = value;
    }
  }

  public with sharing class SMC_DTO_ML_PF_GrandChildren {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String id;

    public SMC_DTO_ML_PF_GrandChildren(String name, String id) {
      this.name = name;
      this.id = id;
    }
  }

  public with sharing class SMC_DTO_ML_Others {
    @AuraEnabled
    public List<SMC_DTO_ML_OthersDetails> objects;

    public SMC_DTO_ML_Others() {
      this.objects = new List<SMC_DTO_ML_OthersDetails>();
    }
  }

  public with sharing class SMC_DTO_ML_OthersDetails implements Comparable {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    public SMC_DTO_ML_OthersDetails() {
    }

    public SMC_DTO_ML_OthersDetails(String label, String value) {
      this.label = label;
      this.value = value;
    }

    public Integer compareTo(Object compareTo) {
      SMC_DTO_ML_OthersDetails compareToGoal = (SMC_DTO_ML_OthersDetails) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;

      if (this.label > compareToGoal.label) {
        return 1;
      } else if (this.label < compareToGoal.label) {
        return -1;
      }

      return returnValue;
    }
  }
}