/**
 * @File Name          : SMC_AC_Tile_Button.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-01-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    15/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public class SMC_AC_Tile_Button {
  public class ParentInfo {
    String title { get; set; }
    List<ButtonInfo> listButtons { get; set; }

    public ParentInfo(String title, List<ButtonInfo> listButtons) {
      this.title = title;
      this.listButtons = listButtons;
    }
  }
  public class ButtonInfo {
    String title { get; set; }
    String icon { get; set; }
    String pageType { get; set; }
    String pageReference { get; set; }
    Boolean needZoom { get; set; }

    public ButtonInfo(
      String title,
      String icon,
      String pageType,
      String pageReference,
      Boolean needZoom
    ) {
      this.title = title;
      this.icon = icon;
      this.pageType = pageType;
      this.pageReference = pageReference;
      this.needZoom = needZoom;
    }
  }

  /**
   * @description : get tile button informations from metadata Tile_Button_Informations__mdt
   * @author Vincent RECASENS (Modis) | 07-16-2020
   * @param selection
   * @return String
   **/
  @AuraEnabled
  public static String getButtonInfo(String selection) {
    if (
      selection == 'My Products and Connectivity' ||
      selection == 'Connectivity and Activation'
    ) {
      selection = 'Connectivity & Activation';
    }
    if (selection == 'Maintenance Services') {
      selection = 'Services';
    }

    List<ButtonInfo> listButtons = new List<ButtonInfo>();
    for (
      Tile_Button_Informations__mdt oneInfo : [
        SELECT
          ParentInfo__c,
          ButtonTitle__c,
          ButtonIcon__c,
          ButtonPageType__c,
          ButtonPageReference__c,
          Need_Zoom__c
        FROM Tile_Button_Informations__mdt
        WHERE
          ParentInfo__c = :selection
          AND DeveloperName != 'Tile_Product_Connectivity_Products' //Correctif
          AND DeveloperName != 'Tile_Maintenance_Services_Contracts' //Correctif
          AND DeveloperName != 'Tile_Maintenance_Service_Activities' //Correctif
      ]
    ) {
      listButtons.add(
        new ButtonInfo(
          oneInfo.ButtonTitle__c,
          oneInfo.ButtonIcon__c,
          oneInfo.ButtonPageType__c,
          oneInfo.ButtonPageReference__c,
          oneInfo.Need_Zoom__c
        )
      );
    }

    return JSON.serialize(new ParentInfo(selection, listButtons));
  }
}