/**
 * @File Name          : SMC_DTO_SDFCUser.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_SDFCUser {
  public String username { get; set; }
  public String firstname { get; set; }
  public String lastname { get; set; }
  public String alias { get; set; }
  public String email { get; set; }

  public SMC_DTO_SDFCUser() {
    Id userId = UserInfo.getUserId();
    User user = new User();
    user = [
      SELECT Name, FirstName, LastName, Alias, Email
      FROM User
      WHERE Id = :userId
    ];

    this.userName = user.Name;
    this.firstName = user.FirstName;
    this.lastName = user.LastName;
    this.alias = user.Alias;
    this.email = user.Email;
  }
}