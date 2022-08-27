/**
 * @File Name          : SMC_UTIL_MockHttpResponseGenerator.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/201?   		 ??????     			Initial Version
 **/

@isTest
public with sharing class SMC_UTIL_MockHttpResponseGenerator implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String bodyAsString;
  protected Blob bodyAsBlob;
  protected Map<String, String> responseHeaders;

  public SMC_UTIL_MockHttpResponseGenerator(
    Integer code,
    String status,
    String body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsString = body;
    this.bodyAsBlob = null;
    this.responseHeaders = responseHeaders;
  }

  public SMC_UTIL_MockHttpResponseGenerator(
    Integer code,
    String status,
    Blob body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsBlob = body;
    this.bodyAsString = null;
    this.responseHeaders = responseHeaders;
  }

  /**
   * @description : create reponse for http mock
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param req
   * @return HTTPResponse
   **/
  public HTTPResponse respond(HTTPRequest req) {
    req.setTimeout(30000);
    HttpResponse resp = new HttpResponse();
    resp.setStatusCode(code);
    resp.setStatus(status);
    if (bodyAsBlob != null) {
      resp.setBodyAsBlob(bodyAsBlob);
    } else {
      resp.setBody(bodyAsString);
    }
    if (responseHeaders != null) {
      for (String key : responseHeaders.keySet()) {
        resp.setHeader(key, responseHeaders.get(key));
      }
    }
    return resp;
  }
}