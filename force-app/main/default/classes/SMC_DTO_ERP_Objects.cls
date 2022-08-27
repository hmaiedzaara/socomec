/**
 * @File Name          : SMC_DTO_ERP_Objects.cls
 * @Description        : 
 * @Author             : Vincent RECASENS (Modis)
 * @Group              : 
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:53:07
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    06/11/2018   Vincent RECASENS (Modis)     Initial Version
**/

public with sharing class SMC_DTO_ERP_Objects {
    public String id;
    public String company;
    public String invoiceCode;
    public String quoteCode;
    public String orderCode;
    public String accountCode;
    public String productCode;
    public String productDescription;
    public String businessApplication;
    public String productFamily;
    public Double amount;
    public Long quantity;
    public Datetime invoiceDate;
    public Datetime closingDate;
    public Datetime quotationDate;
    public Datetime reminderDate;
    public Datetime orderDate;
    public Datetime deliveryDate;
    public String initials;
    public String status;
    public String warehouse;
    public String customerOrder;
}