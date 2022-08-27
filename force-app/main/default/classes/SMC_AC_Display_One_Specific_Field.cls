/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 01-15-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   01-15-2021   Vincent RECASENS (Modis)   Initial Version
 **/
public with sharing class SMC_AC_Display_One_Specific_Field {
  public class Wrapper {
    @AuraEnabled
    public String title;
    // public String fieldLabel;
    @AuraEnabled
    public String fieldValue;
    @AuraEnabled
    public String fieldType;

    public Wrapper(String title, String fieldValue, String fieldType) {
      this.title = title;
      this.fieldValue = fieldValue;
      this.fieldType = fieldType;
    }
  }

  @AuraEnabled
  public static Wrapper getField(
    String recId,
    String objectAPIName,
    String fieldAPIName
  ) {
    // Set and execute query
    String query =
      'SELECT Id, ' +
      fieldAPIName +
      ' FROM ' +
      objectAPIName +
      ' WHERE Id = \'' +
      recId +
      '\'';
    sObject sobj = Database.query(query);
    // Search field
    SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
    Map<String, Schema.SObjectField> mfields = objectType.getDescribe()
      .fields.getMap();
    String type = mfields.get(fieldAPIName.toLowerCase())
      .getDescribe()
      .getType()
      .name();
    String fieldType;
    String fieldValue;
    if (type == 'STRING' && type.startsWith('<img')) {
      fieldType = 'IMAGE';
      fieldValue = String.valueOf(sobj.get(fieldAPIName)).split('alt="')[0]
          .split('src="')[1]
        .substring(0, ('/resource/SMC_IOT_Apps/ewire.jpg"').length() - 1);
    } else if (type == 'TEXTAREA') {
      fieldType = 'TEXT';
      fieldValue = String.valueOf(sobj.get(fieldAPIName));
    }
    //Set return wrapper
    Wrapper returnWrapper = new Wrapper(
      mfields.get(fieldAPIName.toLowerCase()).getDescribe().getLabel(),
      fieldValue,
      fieldType
    );
    //Return
    return returnWrapper;
  }
}