@IsTest
public class TEST_SMC_AC_Tile_Button {
    
    @isTest
    public static void testGetButtonInfo(){
        System.assertNotEquals(null, SMC_AC_Tile_Button.getButtonInfo('Help'), 'The selection has changed.');
    }

}