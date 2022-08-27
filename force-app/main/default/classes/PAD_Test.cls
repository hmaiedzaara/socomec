@isTest
private class PAD_Test {
  static testMethod void PAD_Main_TestMethod() {
    Test.startTest();
    PAD.startTimer();
    PAD.log('', '');
    PAD.log('', 1);
    PAD.log(1, '');
    PAD.log(1, 1);
    PAD.log(1);
    PAD.log('');
    PAD.stopTimer();
    PAD.limits();
    PAD.myColor(0, 0);
    PAD.myColor(0, 3);
    PAD.myColor(2, 3);
    PAD.myColor(3, 3);
    PAD myPAD = new PAD();
    myPAD.getPAD_logs();
    PAD.canTrigger('AP123');
    Test.stopTest();
    System.assertEquals(PAD.PAD_logs.isEmpty(), false);
    System.assertEquals(PAD.canTrigger('testPad'), true);
  }
}