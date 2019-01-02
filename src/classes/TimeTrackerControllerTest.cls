@isTest (SeeAllData = false)
/**
* @description unit test class for TimeTrackerController.cls
*/
public class TimeTrackerControllerTest {
    private static final String STANDARD_PROFILE_NAME = 'Standard User';
    
    static Account acc;
    static CaseComment caseComment;
    static Contact con;
    static Case caseObj;
    static opportunity oppObj;
    static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
    static DateTime dtNow = Datetime.now();
    private static void setup()
    {
        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
                                                              + 'TimeTrackerConfigSettings__c',
                                                              'TimeTrackerConfigSettings_Records');
        System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());
        
        acc = new Account(Name = 'Account Test Name');
        caseObj = new Case(Type = 'Other',  Status = 'New', Origin = 'Phone');
        oppObj = new opportunity(StageName= 'Qualification', CloseDate = Date.today(), Name	= 'Test opportunity' );
        con = new Contact(LastName = 'Test Lastname');
        insert acc;
        insert con;
        insert caseObj;
        insert oppObj;
        caseComment = new CaseComment(ParentId = caseObj.Id, CommentBody = 'Test Body');
        insert caseComment;
        
        System.assert(acc.Id != null && caseObj.id != null);
    }
    
    private static void init()
    {
        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
                                                              + 'TimeTrackerConfigSettings__c',
                                                              'TimeTrackerConfigSettings_Records');
        System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());
    }
    
    /**
* Test TimeTracker record creation using Console Component Timer with all information supplied
*/
    @isTest static void testManualTimeTracker() {
        init();
        Database.SaveResult sr = null;
        User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
        system.runAs(stdUsr) {
            Test.startTest();
            Account acct = new Account(Name='Test Account');
            //insert the Account record
            sr = Database.Insert(acct, true);
            // ensure the Case record has an Id
            system.assertNotEquals(null, sr.getId());
            String acctid = sr.getId();
            
            //create a Case record
            Case newCase = new Case(OwnerId = stdUsr.Id);
            newCase.AccountId = acctid;
            
            //insert the Case record
            sr = Database.Insert(newCase, true);
            // ensure the Case record has an Id
            system.assertNotEquals(null, sr.getId());
            String sObjectId = sr.getId();
            
            // all information supplied
            String isSuccessful = TimeTrackerController.doCreateTimesheetEntry('00:01:15', '5',
                                                                               DateTime.now().format(),	TimeTrackerConstants.GENERAL_OTHER,
                                                                               null, null, 'TrackerComment');
            system.assertEquals('true', isSuccessful);
            Test.stopTest();
        }
    }
    
    @isTest static void testManualTimeTrackerNoAccountId() {
        init();
        Database.SaveResult sr = null;
        User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
        //system.runAs(stdUsr) {
        Test.startTest();
        Account acct = new Account(Name='Test Account');
        //insert the Account record
        sr = Database.Insert(acct, true);
        // ensure the Case record has an Id
        system.assertNotEquals(null, sr.getId());
        String acctid = sr.getId();
        
        //create a Case record
        Case newCase = new Case(OwnerId = stdUsr.Id);
        newCase.AccountId = acctid;
        
        //insert the Case record
        sr = Database.Insert(newCase, true);
        // ensure the Case record has an Id
        system.assertNotEquals(null, sr.getId());
        String caseId = sr.getId();
        
        // no account id, no case number
        String isSuccessful = TimeTrackerController.doCreateTimesheetEntry
            (
                '00:01:15', '5', DateTime.now().format(),
                TimeTrackerConstants.EMAIL_STR, caseId, null, 'TrackerComment'
            );
        system.assertEquals('true', isSuccessful);
        Test.stopTest();
        //}
    }
    
    @isTest static void testManualTimeTrackerCaseNumber() {
        init();
        Database.SaveResult sr = null;
        User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
        system.runAs(stdUsr) {
            Test.startTest();
            Account acct = new Account(Name='Test Account');
            //insert the Account record
            sr = Database.Insert(acct, true);
            // ensure the Case record has an Id
            system.assertNotEquals(null, sr.getId());
            String acctid = sr.getId();
            
            //create a Case record
            Case newCase = new Case(OwnerId = stdUsr.Id);
            
            //insert the Case record
            sr = Database.Insert(newCase, true);
            // ensure the Case record has an Id
            system.assertNotEquals(null, sr.getId());
            String caseId = sr.getId();
            
            // case number but no account id, no case id
            Case givenCase = [Select Id, CaseNumber From Case Where Id = :caseId];
            system.assertEquals(caseId, givenCase.Id);
            
            String isSuccessful = TimeTrackerController.doCreateTimesheetEntry('00:01:15', '5',
                                                                               DateTime.now().format(),	TimeTrackerConstants.GENERAL_OTHER,
                                                                               null, null,  'TrackerComment');
            system.assertEquals('true', isSuccessful);
            Test.stopTest();
        }
    }
    
    @isTest static void test_InsertTimeTracker(){
        setup();
        Time_Tracker__c tt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseObj.Id, Source__c = 'Console Toolkit',
                                                 Parent_Object_Id__c= caseObj.Id, Action__c='Case Review', Opening_Action__c = 'Case Review', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
        tt.DocumentId__c = caseObj.Id;
        String jtt = JSON.serialize(tt);
        TimeTrackerController.insertTimeTracker(jtt);
        
        List<Time_Tracker__c> confirmInsertlist = [	SELECT Id FROM Time_Tracker__c
                                                   WHERE Duration__c=: 50 AND Object_Id__c =: caseObj.Id
                                                   AND Source__c =: 'Console Toolkit' AND Parent_Object_Id__c=: caseObj.Id
                                                   AND Action__c=:'Case Review' AND Opening_Action__c =: 'Case Review'
                                                   AND Opening_Activity_Time__c =: 1469099914781L AND Activity_Time__c =: 1469099946909L
                                                  ];
        System.assertNotEquals(null, confirmInsertlist);
        
        Time_Tracker__c updt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseObj.Id, Source__c = 'Console Toolkit',
                                                   Parent_Object_Id__c= caseObj.Id, Action__c='Case Review', Opening_Action__c = 'Case Review', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
        updt.DocumentId__c = caseObj.Id;
        updt.New_Record_Document_Id__c = ''+caseObj.Id;
        String updtjson = JSON.serialize(updt);
        TimeTrackerController.insertTimeTracker(updtjson);
        
        tt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseComment.Id, Source__c = 'Extension', Action__c='Case Comment Save', Opening_Action__c = 'New Case Comment', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
        tt.DocumentId__c = caseObj.Id;
        tt.New_Record_Document_Id__c = ''+caseObj.Id;
        updtjson = JSON.serialize(tt);
        TimeTrackerController.insertTimeTracker(updtjson);
        
        Integer totalRecordsAfterUpdate = [ SELECT COUNT() FROM Time_Tracker__c ];
        //	System.assertEquals(totalRecordsAfterUpdate, confirmInsertlist.size()+2);
    }
    @isTest static void test_getactivityLst(){
        setup();
        String actLst = TimeTrackerController.getactivityLst(null);
        system.assertNotEquals(null, actLst);
    }
    @isTest static void test_saveManualLineItems_CheckNotEmpty(){
        String data = '[{"Engage_Time__c":1469517643133,"Disengage_Time__c":1469517648643},{"Engage_Time__c":1469517654395,"Disengage_Time__c":1469517662156}]';
        List<ManualLineItem__c> mli = TimeTrackerController.saveManualLineItems(data);
        system.assertEquals(2, mli.size());
    }
    @isTest static void test_saveManualLineItems_CheckEmpty(){
        String data = '[{"Engage_Time__":1469517643133,"Disengage_Time__c":1469517648643},{"Engage_Time__c":1469517654395,"Disengage_Time__c":1469517662156}]';
        List<ManualLineItem__c> manualLineItems = TimeTrackerController.saveManualLineItems('data');
        system.assertEquals(0, manualLineItems.size());
    }
    
    @isTest static void test_getObjectMap(){
        setup();
        List<Database.SaveResult> sr = null;
        
        List<TimeTrackerConfigSettings__c> listManualConfigSettings = new List<TimeTrackerConfigSettings__c>();
        
        TimeTrackerConfigSettings__c ttcsManualErollment = [ SELECT Id, Code1__c, Text1__c FROM TimeTrackerConfigSettings__c WHERE Type__c=:TimeTrackerConstants.MANUAL_TYPE AND Text1__c=:TimeTrackerConstants.OUT_OF_OFFICE];
        ttcsManualErollment.Code1__c = 'Account';
        //ttcsManualErollment.Text1__c = 'Enrollment';
        System.debug(ttcsManualErollment);
        listManualConfigSettings.add(ttcsManualErollment);
        
        TimeTrackerConfigSettings__c ttcsManualProjectWork = [ SELECT Id, Code1__c, Text1__c FROM TimeTrackerConfigSettings__c WHERE Type__c=:TimeTrackerConstants.MANUAL_TYPE AND Text1__c=:TimeTrackerConstants.WORK_STOPPAGE];
        ttcsManualProjectWork.Code1__c = 'Account*';
        //ttcsManualProjectWork.Text1__c = 'Project Work';
        System.debug(ttcsManualProjectWork);
        listManualConfigSettings.add(ttcsManualProjectWork);
        
        Test.startTest();
        sr = Database.Update(listManualConfigSettings, true);
        
        String objmap = JSON.serialize((TimeTrackerController.getObjectMap(null)));
        
        List<Object> oblst = (List<Object>)JSON.deserializeUntyped(objMap);
        
        Integer passCount = 0;
        //Manual Config settings with code1 as case and text1 as General - Other
        for(Object ob : oblst){
            Map<String, Object> tt = (Map<String, Object>) ob;
            if(tt.get('activityName') == TimeTrackerConstants.GENERAL_OTHER){
                System.assertEquals('Case', tt.get('displaySObjectLable'));
                passCount++;
            } else if(tt.get('activityName')==TimeTrackerConstants.MEETING){
                System.assertEquals('Case', tt.get('displaySObjectLable'));
                passCount++;
            } else if(tt.get('activityName')==TimeTrackerConstants.OUT_OF_OFFICE){
                System.assertEquals('Account', tt.get('displaySObjectLable'));
                passCount++;
            } else if(tt.get('activityName')==TimeTrackerConstants.WORK_STOPPAGE){
                System.assertEquals('Account', tt.get('displaySObjectLable'));
                passCount++;
            }
        }
        System.assertEquals(4,passCount);
        Test.stopTest();
    }
    
    @isTest static void test_getCaseNoFromCaseId(){
        setup();
        String caseNo = TimeTrackerController.getCaseNoFromCaseId(caseObj.Id);
        system.assertNotEquals(null, caseNo);
    }
    
    @isTest static void test_getSettings(){
        init();
        String settings = TimeTrackerController.getSettings('Dummy');
        system.assert(String.isNotBlank(settings));
    }
    
    @isTest static void test_getSObjectFieldsFromId() {
        Account acct = new Account(Name = 'Acme');
        List<String> listShowFields = new List<String>();
        listShowFields.add('Name');
        insert acct;
        
        sObject sObj = TimeTrackerController.getSObjectFieldsFromId(acct.Id, 'Account', listShowFields);				
        String objStr = JSON.serialize(sObj);
        System.debug('objStr : '+objStr);
        System.assertNotEquals(objStr, 'Acme');
    }
    
    @isTest static void test_getSObjectDetailsFromActivityAndSObjectValue() {
        Account acct = new Account(Name = 'Acme');
        TimeTrackerConfigSettings__c ttcfg = new TimeTrackerConfigSettings__c();
        ttcfg.Text1__c = 'Break';
        ttcfg.Name = 'MANUAL_Break';
        ttcfg.Text3__c = 'Break';
        ttcfg.Code1__c = 'Account';
        ttcfg.Code2__c = '{"fields":[{"field":"Name"; "search": true ; "show" : true}]}';
        ttcfg.Type__c = 'Manual';
        
        insert acct;
        insert ttcfg;
        
        sObject sObj = TimeTrackerController.getSObjectDetailsFromActivityAndSObjectValue('Break', 'Acme');
        String objStr = JSON.serialize(sObj);
        System.debug('objStr : '+objStr);
        System.assertNotEquals(objStr, null);
    }
}