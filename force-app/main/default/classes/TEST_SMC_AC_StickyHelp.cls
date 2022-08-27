/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 07-16-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   07-16-2020   Vincent RECASENS (Modis)   Initial Version
**/
@IsTest
public class TEST_SMC_AC_StickyHelp {
    
    @isTest
    public static void testGetStickyInfos(){
        System.assertNotEquals(null, SMC_AC_StickyHelp.getStickyInfos(), 'Metadata has changed or does not exist');
    }

}