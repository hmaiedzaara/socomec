/**
 * @File Name          : SMC_UTIL_ScoringMockJSONs.cls
 * @Description        : 
 * @Author             : Vincent RECASENS (Modis)
 * @Group              : 
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 11:47:18
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    ??/02/2018   Vincent RECASENS (Modis)     Initial Version
**/

public with sharing class SMC_UTIL_ScoringMockJSONs {
    

    public static String BAD_JSON = 'Bad JSON';
    public static String PUT_SAVE_FAIL = '{"message":"Save fail"}';
    public static String POST_FAIL = '{"message":"Creation fail"}';
    public static String PUT_UPDATE_FAIL = '{"message":"Update fail"}';
    public static String GET_ALL_FAIL = '{"message":"No entry Found"}';

    public static String PUT_SAVE_SUCCESS = '{"message":"Save success"}';
    public static String POST_SUCCESS = '{"message":"Creation success"}';
    public static String PUT_UPDATE_SUCCESS = '{"message":"Update success"}';
    public static String GET_ALL_BODY = '{"account":"..."}';

    public static String DISCOUNT_TOKEN = '{"refreshToken":"refreshToken"}';
    public static String GET_DISCOUNT_TOKEN_APPLICATION = 'SFDC';
    public static String GET_DISCOUNT_TOKEN_SECRET = 'U2ExZXNGMHJjZQ==';
    public static String ARE_SCORED_BODY = '[{"account":"0010D000006MZjhQAG"}]';
    public static String ARE_SCORED = '[' +
                                        '{' +
                                            '"account": "0010D000006MZjhQAG",' +
                                            '"country": null,' +
                                            '"category": null,' +
                                            '"business": null,' +
                                            '"acc": null,' +
                                            '"tier": "TIER1",' +
                                            '"user": null,' +
                                            '"baIds": null,' +
                                            '"bas":[' +
                                                    '{' +
                                                    '"id": 1,' +
                                                '"ba": "PCO",' +
                                                '"expiryDate": null,' +
                                                '"valid": false,' +
                                                '"answerRequired": false' +
                                                '}' +
                                            ']' +
                                        '}' +
                                    ']';
    public static String ARE_SCORED_WITHOUT_BA = '[' +
                                                    '{' +
                                                        '"account": "0010D000006MZjhQAG",' +
                                                        '"country": null,' +
                                                        '"category": null,' +
                                                        '"business": null,' +
                                                        '"acc": null,' +
                                                        '"tier": "TIER1",' +
                                                        '"user": null,' +
                                                        '"baIds": null,' +
                                                        '"bas":[]' +
                                                    '}' +
                                                ']';
    public static String UPSERT_SCORING = '[' +
                                            '{' +
                                                '"account": "0010D000006MZjhQAG",' +
                                                '"country": null,' +
                                                '"category": null,' +
                                                '"business": null,' +
                                                '"acc": null,' +
                                                '"tier": "TIER1",' +
                                                '"user": null,' +
                                                '"baIds": null,' +
                                                '"bas":[1]' +
                                            '}' +
                                        ']';
    public static String GET_ALL_SCORING_MOCK = '[  ' + 
                                                    '{  ' + 
                                                        '"account":"0010D000008VxkyQAC",' + 
                                                        '"country":null,' + 
                                                        '"category":null,' + 
                                                        '"business":null,' + 
                                                        '"acc":null,' + 
                                                        '"tier":"TIER1",' + 
                                                        '"user":null,' + 
                                                        '"baIds":null,' + 
                                                        '"bas":null,' + 
                                                        '"scorings":[  ' + 
                                                            '{  ' + 
                                                                '"ba":{  ' + 
                                                                '"id":1,' + 
                                                                '"ba":"PCO"' + 
                                                                '},' + 
                                                                '"scoringLines":[  ' + 
                                                                '{  ' + 
                                                                    '"id":4015,' + 
                                                                    '"priceGroup":{  ' + 
                                                                        '"id":15,' + 
                                                                        '"label":"D01",' + 
                                                                        '"description":"NETYS PL"' + 
                                                                    '},' + 
                                                                    '"min":0.00,' + 
                                                                    '"max":22.00,' + 
                                                                    '"discount":17.00' + 
                                                                '},' + 
                                                                '{  ' + 
                                                                    '"id":3954,' + 
                                                                    '"priceGroup":{  ' + 
                                                                        '"id":15,' + 
                                                                        '"label":"D01",' + 
                                                                        '"description":"NETYS PL"' + 
                                                                    '},' + 
                                                                    '"min":0.00,' + 
                                                                    '"max":22.00,' + 
                                                                    '"discount":0.00' + 
                                                                '},' + 
                                                                '{  ' + 
                                                                    '"id":4022,' + 
                                                                    '"priceGroup":{  ' + 
                                                                        '"id":15,' + 
                                                                        '"label":"D01",' + 
                                                                        '"description":"NETYS PL"' + 
                                                                    '},' + 
                                                                    '"min":0.00,' + 
                                                                    '"max":22.00,' + 
                                                                    '"discount":14.00' + 
                                                                '}' + 
                                                                ']' + 
                                                            '}' + 
                                                        ']' + 
                                                    '}' + 
                                                    ']';
    public static String PUT_SAVE_BODY = '{  ' +
                                            '"ba":{  ' +
                                                '"ba":"PCO",' +
                                                '"id":1' +
                                            '},' +
                                            '"scoringLines":[  ' +
                                                '{' +
                                                    '"discount":"14.0",' +
                                                    '"id":4015,' +
                                                    '"max":22,' +
                                                    '"min":0,' +
                                                    '"priceGroup":{  ' +
                                                        '"id":"15",' +
                                                        '"label":"D01"' +
                                                    '},' +
                                                    '"isModified":true' +
                                                '}' +
                                            '],' +
                                            '"userSeeMaxSuggested":false' +
                                            '}';

    public static String GET_SCORING_MOCK = '{ ' +
                                            '"id": 299, ' +
                                            '"sfdcAccountId": "0013N00000udD5iQAE", ' +
                                            '"scoringLines": [ ' +
                                            '    { ' +
                                            '        "id": 22644, ' +
                                            '        "priceGroup": { ' +
                                            '            "id": 2, ' +
                                            '            "code": "D54", ' +
                                            '            "descr": "ASYS-STATYS XS" ' +
                                            '        }, ' +
                                            '        "discount": 24.00, ' +
                                            '        "min": 24.00, ' +
                                            '        "max": 33.00, ' +
                                            '        "lastModifiedDate": "2022-06-17T14:46:11.32064" ' +
                                            '    }, ' +
                                            '    { ' +
                                            '        "id": 22645, ' +
                                            '        "priceGroup": { ' +
                                            '            "id": 3, ' +
                                            '            "code": "D55", ' +
                                            '            "descr": "OPTION TRANSFER SYSTEMS" ' +
                                            '        }, ' +
                                            '        "discount": 24.00, ' +
                                            '        "min": 24.00, ' +
                                            '        "max": 33.00, ' +
                                            '        "lastModifiedDate": "2022-06-17T14:46:11.32064" ' +
                                            '    } ' +
                                            '], ' +
                                            '"baId": 1 ' +
                                            '}';
    
}