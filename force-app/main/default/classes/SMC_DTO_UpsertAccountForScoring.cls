/**
 * @File Name          : SMC_DTO_UpsertAccountForScoring.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_UpsertAccountForScoring {
  public Id account { get; set; } //AccountId
  public String acc { get; set; } //Tier code
  public String business { get; set; } //Business code
  public String country { get; set; } //Country code
  public String category { get; set; } //Category code
  public String user { get; set; } //Username
  public String tier { get; set; } //Tier code
  public Integer baIds { get; set; } //BA id
  public List<SMC_DTO_Scoring_BAs> bas { get; set; } //BA informations

  public SMC_DTO_UpsertAccountForScoring() {
  }

  public SMC_DTO_UpsertAccountForScoring(
    Id account,
    String category,
    String country
  ) {
    this.account = account;
    this.category = category;
    this.country = country;
  }

  public SMC_DTO_UpsertAccountForScoring(
    Id account,
    String acc,
    String country,
    String category,
    String business,
    String tier,
    String user,
    List<SMC_DTO_Scoring_BAs> bas
  ) {
    this.account = account;
    //Acc
    this.acc = acc != null ? acc : '';
    //Business
    this.business = business != null ? business : '';
    //Category
    this.category = category != null ? category : '';
    //Tier
    this.tier = tier != null ? tier : '';
    //Country
    this.country = country != null ? country : '';
    //User
    this.user = user != null ? user : '';
    //Bas
    this.bas = bas != null ? bas : new List<SMC_DTO_Scoring_BAs>();
  }
}