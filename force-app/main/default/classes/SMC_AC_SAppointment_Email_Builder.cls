/**
 * @File Name          : SMC_AC_SAppointment_Email_Builder.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-24-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    24/04/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public with sharing class SMC_AC_SAppointment_Email_Builder {
  public String theServiceAppointmentId { get; set; }
  public String fieldToDisplay { get; set; }
  public List<WorkOrder> workOrders { get; set; }

  public SMC_AC_SAppointment_Email_Builder() {
  }

  //Constructor for Tests
  public SMC_AC_SAppointment_Email_Builder(
    String fieldToDisplay,
    Id theServiceAppointmentId
  ) {
    this.fieldToDisplay = fieldToDisplay;
    this.theServiceAppointmentId = (String) theServiceAppointmentId;
    this.workOrders = findWorkOrder();
  }

  /**
   * @description : get Service Appointment
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param objectName
   * @return List<Object>
   **/
  private List<Object> getParentRecord(String objectName) {
    if (objectName == null || this.theServiceAppointmentId == null) {
      return null;
    }
    //Get Service Appointment
    ServiceAppointment theServiceAppointment = [
      SELECT ParentRecordId
      FROM ServiceAppointment
      WHERE Id = :this.theServiceAppointmentId
    ];

    //Get fields and build query
    Map<String, Object> objectMap = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap();
    Schema.SObjectType objectMapBis = Schema.getGlobalDescribe()
      .get(objectName);
    String query = 'SELECT ';
    for (
      SObjectField sof : objectMapBis.getDescribe().fields.getMap().values()
    ) {
      query += String.valueOf(sof) + ', ';
    }
    query =
      query.substring(0, query.length() - 2) +
      ' FROM ' +
      objectName +
      ' WHERE Id = \'' +
      theServiceAppointment.ParentRecordId +
      '\'';

    //return Object
    return Database.query(query);
  }

  /**
   * @description : get List<WorkOrder>
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @return List<WorkOrder>
   **/
  public List<WorkOrder> findWorkOrder() {
    if (this.fieldToDisplay == null) {
      return new List<WorkOrder>();
    }
    List<WorkOrder> testList = (List<WorkOrder>) getParentRecord(
      String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
    );
    return testList != null ? testList : new List<WorkOrder>();
  }

  /** Not used at 30/04/2020 **/
  // public List<WorkOrderLineItem> getWorkOrderLineItem() {
  //   return (List<WorkOrderLineItem>) getParentRecord(
  //     String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
  //   );
  // }

  // public List<Account> getAccount() {
  //   return (List<Account>) getParentRecord(
  //     String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
  //   );
  // }

  // public List<Asset> getAsset() {
  //   return (List<Asset>) getParentRecord(
  //     String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
  //   );
  // }

  // public List<Opportunity> getOpportunity() {
  //   return (List<Opportunity>) getParentRecord(
  //     String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
  //   );
  // }

  // public List<Lead> getLead() {
  //   return (List<Lead>) getParentRecord(
  //     String.escapeSingleQuotes(this.fieldToDisplay.split('#')[0])
  //   );
  // }
}

/*
  public String getFieldValue() {
    String[] strTab = this.fieldToDisplay.split('#');
    //Get Service Appointment
    ServiceAppointment theServiceAppointment = [
      SELECT ParentRecordId
      FROM ServiceAppointment
      WHERE Id = :theServiceAppointmentId
    ];
    //Request ParentRecord
    String objectName = String.escapeSingleQuotes(strTab[0]);
    Map<String, Object> objectMap = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap();
    Schema.SObjectType objectMapBis = Schema.getGlobalDescribe()
      .get(objectName);
    String query = 'SELECT ';
    for (
      SObjectField sof : objectMapBis.getDescribe().fields.getMap().values()
    ) {
      query += String.valueOf(sof) + ', ';
    }
    query =
      query.substring(0, query.length() - 2) +
      ' FROM ' +
      objectName +
      ' WHERE Id = \'' +
      theServiceAppointment.ParentRecordId +
      '\'';
    Object resultQuery = (Object) Database.query(query);

    //Build fields list to find values
    List<String> compundFields = findAllValueOfCompundField(strTab[1]);

    //Build serialization to get only value requested by email template
    String[] strTabObject = JSON.serialize(resultQuery).split('},');
    Integer i = 0;
    String tmpObjectValues = '';
    for (String str : strTabObject) {
      if (i == 1 && strTabObject.size() == 2) {
        tmpObjectValues += '{' + str.substring(0, str.length() - 1);
      } else if (i >= 1 && i < strTabObject.size() - 1) {
        String tmpStr1;
        String tmpStr2;
        if (strTabObject[i].contains('Address')) {
          Integer idx = strTabObject[i].indexOf('"Address":{');
          tmpStr1 = strTabObject[i].substring(0, idx);
          tmpStr2 = strTabObject[i].substring(idx + ('"Address":{').length());
        }
        // else if (strTabObject[i].contains('BillingAddress')) {
        //   tmpStr1 = strTabObject[i].split('"BillingAddress":{');
        // }
        if (i == 1) {
          tmpObjectValues += '{' + tmpStr1 + tmpStr2;
        } else if (i > 1) {
          tmpObjectValues += tmpStr1 + tmpStr2;
        }
      } else if (i == strTabObject.size() - 1) {
        tmpObjectValues += str.substring(0, str.length() - 1);
      }
      ++i;
    }

    if (tmpObjectValues.contains('""')) {
      tmpObjectValues =
        tmpObjectValues.substring(0, tmpObjectValues.indexOf('""')) +
        'null' +
        tmpObjectValues.substring(
          tmpObjectValues.indexOf('""') + 2,
          tmpObjectValues.length()
        );
    }
    // return tmpObjectValues;

    //Deserialization to Map<String, String>
    Map<String, String> mapObjectFieldsValue = (Map<String, String>) JSON.deserialize(
      (tmpObjectValues),
      Map<String, String>.class
    );
    //Get only values requested
    Map<String, String> resultBeforeConcat = new Map<String, String>();
    for (String keyStr : compundFields) {
      if (
        mapObjectFieldsValue.get(keyStr) != null &&
        resultBeforeConcat.get(keyStr) == null
      ) {
        // if (mapObjectFieldsValue.get(keyStrWithCamelCase).contains('{')) {
        //   String tmpUniqueValue = mapObjectFieldsValue.get(keyStrWithCamelCase)
        //     .substring(
        //       1,
        //       mapObjectFieldsValue.get(keyStrWithCamelCase).length() - 1
        //     );
        //   return tmpUniqueValue;
        // } else {
        resultBeforeConcat.put(keyStr, mapObjectFieldsValue.get(keyStr));
        // }
      }
    }

    //Concat result and return
    return concatResult(strTab[1], resultBeforeConcat);
  }

  private List<String> findAllValueOfCompundField(String fieldToDisplay) {
    List<String> compundFields;
    if (fieldToDisplay == 'Address') {
      compundFields = new List<String>{
        'Street',
        'PostalCode',
        'City',
        'State',
        'Country'
      };
    } else if (fieldToDisplay == 'BillingAddress') {
      compundFields = new List<String>{
        'BillingStreet',
        'BillingPostalCode',
        'BillingCity',
        'BillingState',
        'BillingCountry'
      };
    } else {
      //else if...
      compundFields = new List<String>{ fieldToDisplay };
    }

    return compundFields;
  }

  private String concatResult(
    String fieldToDisplay,
    Map<String, String> resultBeforeConcat
  ) {
    String result = '';
    if (fieldToDisplay == 'Address') {
      result =
        (resultBeforeConcat.get('Street') != null
          ? resultBeforeConcat.get('Street') + ', '
          : '') +
        (resultBeforeConcat.get('Street') != null
          ? resultBeforeConcat.get('PostalCode') + ' '
          : '') +
        (resultBeforeConcat.get('Street') != null
          ? resultBeforeConcat.get('City') + ' '
          : '') +
        (resultBeforeConcat.get('Street') != null
          ? resultBeforeConcat.get('State') + ' '
          : '') +
        (resultBeforeConcat.get('Street') != null
          ? resultBeforeConcat.get('Country')
          : '');
    } else {
      result = resultBeforeConcat.get(fieldToDisplay);
    }

    if (result.length() == 0) {
      result = 'No value';
    }
    return result;
  }
}
*/