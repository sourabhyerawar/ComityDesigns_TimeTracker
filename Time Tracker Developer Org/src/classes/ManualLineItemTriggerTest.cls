@isTest(SeeAllData=false)
private class ManualLineItemTriggerTest {
  private static List<Time_Tracker__c> startEventList {get; set;}
  private static List<Time_Tracker__c> endEventList {get; set;}
  private static List<ManualLineItem__c> mItems {get; set;}
  private static String caseId;
  private static String tseId;
  private static DateTime dtNow = Datetime.now();
  private static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];

  private static void setup()
    {
        //Config-setting
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()+'TimeTrackerConfigSettings__c', 'TimeTrackerConfigSettings_Records');
        System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().size());
        
        //TimeTrackerTestHelper.createTimeStrategyRecords();
        Database.SaveResult sr = null;
        //create a Case record
        Case newCase = new Case(OwnerId = usr.Id);
        //insert the Case record
        sr = Database.Insert(newCase, true);
        caseId = sr.getId();

        // create Timesheet record
        Timesheet__c timesheet = TimeTrackerUtility.createNewTimesheet(system.today(), usr.Id, usr.LastName);
        // insert the Timesheet record
        sr = Database.insert(timesheet, true);

        // create Timesheet Entry record
        Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(
          TimeTrackerConstants.CASE_CREATION_STR, system.today()
          , TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE
          , sr.getId(), UserInfo.getUserId());
        // insert the Timesheet Entry record
        sr = Database.insert(tse, true);
        tseId = sr.getId();
    }

  private static void insertManualLineItem1(){
    /*
    ManualLineItem__c mli1 = new ManualLineItem__c(
      Engage_Time__c = dtNow.addMinutes(80)
      , Disengage_Time__c = dtNow.addMinutes(150));
    */
    ManualLineItem__c mli1 = new ManualLineItem__c(
      Engage_Time__c = dtNow.addMinutes(5)
      , Disengage_Time__c = dtNow.addMinutes(12));
    insert mli1;
  }

  private static void insertManualLineItem2(){
    /*
    ManualLineItem__c mli1 = new ManualLineItem__c(
      Engage_Time__c = dtNow.addMinutes(170)
      , Disengage_Time__c = dtNow.addMinutes(190));    
    */
    ManualLineItem__c mli1 = new ManualLineItem__c(
      Engage_Time__c = dtNow.addMinutes(20)
      , Disengage_Time__c = dtNow.addMinutes(25));
    insert mli1;
  }

 @isTest static void Test_excludeManualLineItemTime_Evt0() {
    setup();
    //createTimeTrackerRecords();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*
    Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '0', null, 'Event0', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);    
    */
    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    /*
    Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(10).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '0', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event0', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);    
    */
    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);
    insert endEvt;

    Test.startTest();
      insertManualLineItem1();
      insertManualLineItem2();
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = :caseId and Opening_Action__c != null];
    system.assertEquals(60, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt1() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(75).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '1', null, 'Event1', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/


    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(2).getTime()), String.valueOf(dtNow.addMinutes(2).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(32).getTime()), String.valueOf(dtNow.addMinutes(32).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(2).getTime()), String.valueOf(dtNow.addMinutes(2).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(195).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '1', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event1', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

      insertManualLineItem1();
      insertManualLineItem2();
  
    Test.startTest();
      /*ttList.add(endEvt);
      Database.insert(ttList);*/
      insert endEvt;
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = : caseId and Opening_Action__c != null];
    system.assertEquals(1080, event.Duration__c);
  } 

   @isTest static void Test_excludeManualLineItemTime_Evt2() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(70).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '2', null, 'Event2', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(3).getTime()), String.valueOf(dtNow.addMinutes(3).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(90).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '2', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event2', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(6).getTime()), String.valueOf(dtNow.addMinutes(6).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(3).getTime()), String.valueOf(dtNow.addMinutes(3).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);



    Test.startTest();

      insert endEvt;

      insertManualLineItem1();
      insertManualLineItem2();
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = : caseId and Opening_Action__c != null];
    system.assertEquals(120, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt3() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(100).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '3', null, 'Event3', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(7).getTime()), String.valueOf(dtNow.addMinutes(7).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(110).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '3', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event3', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(8).getTime()), String.valueOf(dtNow.addMinutes(8).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(7).getTime()), String.valueOf(dtNow.addMinutes(7).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);


    Test.startTest();
      insert endEvt;

      insertManualLineItem1();
      insertManualLineItem2();
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = : caseId and Opening_Action__c != null];
    system.assertEquals(0, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt4() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

     /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(120).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '4', null, 'Event4', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(9).getTime()), String.valueOf(dtNow.addMinutes(9).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;      

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(200).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '4', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event4', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(26).getTime()), String.valueOf(dtNow.addMinutes(26).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(9).getTime()), String.valueOf(dtNow.addMinutes(9).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);

    insertManualLineItem1();
    insertManualLineItem2();

    Test.startTest();
      insert endEvt;
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = : caseId and Opening_Action__c != null];
    system.assertEquals(540, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt5() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(130).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '5', null, 'Event5', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt; 

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(180).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '5', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event5', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(21).getTime()), String.valueOf(dtNow.addMinutes(21).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);


    Test.startTest();
      insertManualLineItem1();

      insert endEvt;

      insertManualLineItem2();
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = : caseId and Opening_Action__c != null];
    system.assertEquals(480, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt6() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(140).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '6', null, 'Event6', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(11).getTime()), String.valueOf(dtNow.addMinutes(11).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(160).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '6', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event6', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(15).getTime()), String.valueOf(dtNow.addMinutes(15).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(11).getTime()), String.valueOf(dtNow.addMinutes(11).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);

    Test.startTest();
      insertManualLineItem1();

      insert endEvt;

      insertManualLineItem2();
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c =: caseId and Opening_Action__c != null];
    system.assertEquals(180, event.Duration__c);
  }

  @isTest static void Test_excludeManualLineItemTime_Evt7() {
    setup();
    List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();

    /*Time_Tracker__c startEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(220).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '7', null, 'Event7', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c startEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(27).getTime()), String.valueOf(dtNow.addMinutes(27).getTime()),
                                                                    '','','',
                                                                    caseId, caseId,  
                                                                    null, usr.Id);
    insert startEvt;

    /*Time_Tracker__c endEvt = TimeTrackerUtility.createNewTimeTracker(
      String.valueOf(dtNow.addMinutes(230).getTime()), null,
      TimeTrackerConstants.CHATTER_TEXT_POST_STP, TimeTrackerConstants.CASE_WORK_STR,
      caseId, '7', TimeTrackerConstants.CHATTER_TEXT_POST, 'Event7', TimeTrackerConstants.SYSTEM_STR, tseId, usr.Id);*/

    Time_Tracker__c endEvt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST_STP, String.valueOf(dtNow.addMinutes(29).getTime()), String.valueOf(dtNow.addMinutes(29).getTime()),
                                                                  TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.addMinutes(27).getTime()), String.valueOf(dtNow.addMinutes(27).getTime()),
                                                                  caseId, caseId,  
                                                                  null, usr.Id);

    insertManualLineItem1();
    insertManualLineItem2();

    Test.startTest();
      insert endEvt;
    Test.stopTest();

    Time_Tracker__c event = [SELECT Duration__c FROM Time_Tracker__c WHERE DocumentId__c = :caseId and Opening_Action__c != null];
    system.assertEquals(120, event.Duration__c);
  }
}