@isTest (seeAllData=False)
private class TimeTrackerTriggerTest
{
    static Account acc;
    static Contact con;
    static Case caseObj;
    static opportunity oppObj;
    static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
    static DateTime dtNow = Datetime.now();
    private static void init()
    {
        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
            + 'TimeTrackerConfigSettings__c',
            'TimeTrackerConfigSettings_Records');
        System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());

        TimeTrackerUserSettings__c userSet = new TimeTrackerUserSettings__c();
        userSet.Server_Debug_Level__c = 'Debug';
        insert userSet;
        System.assert(userSet.Id != null);
        
        acc = new Account(Name = 'Account Test Name');
        caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
        oppObj = new opportunity(StageName= 'Qualification', CloseDate = Date.today(), Name = 'Test opportunity' );
        con = new Contact(LastName = 'Test Lastname');
        insert acc;
        insert con;
        insert caseObj;
        insert oppObj;
        System.assert(acc.Id != null && caseObj.id != null && con.id != null && oppObj.id != null);
    }
     
    @isTest static void test_Default_MaxAllowedTime()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        System.debug(LoggingLevel.ERROR, '--++--confSetting : ' + confSetting);
        confSetting.Text5__c = '';
        upsert confSetting;
        /*TimeTrackerConfigSettings__c maxTimeSetting = TimeTrackerConfigSettings__c.getValues('Miscellaneous_maxTimeConsiderInMin');
        maxTimeSetting.code1__c = String.valueof(2);
        upsert maxTimeSetting;*/
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        ttSettings.Max_Duration_In_Minutes__c = 2;
        upsert ttSettings;
            
        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        //System.assertEquals(240, caseCreationRecord.Duration__c);
        System.assertEquals(120, caseCreationRecord.Duration__c); //Due to max time neutralized

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Action__c, Opening_Action__c,Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        //System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(120, excludedTT.Duration__c); //Due to max time neutralized
		system.debug('@@@@'+excludedTT);
        
        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        //System.assertEquals(600,tse.Tracked_Duration__c);
        System.assertEquals(120,tse.Tracked_Duration__c); //Due to max time neutralized
    }
    @isTest static void test_GenericExcludeImpl_URLPattern_GetBothFields()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        confSetting.Text5__c = '';
        upsert confSetting;

        /*TimeTrackerConfigSettings__c maxTimeSetting = TimeTrackerConfigSettings__c.getValues('Miscellaneous_maxTimeConsiderInMin');
        maxTimeSetting.code1__c = String.valueof(2);
        upsert maxTimeSetting;*/
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        ttSettings.Max_Duration_In_Minutes__c = 2;
        upsert ttSettings;
        
        TimeTrackerConfigSettings__c urlPatternEntry = new TimeTrackerConfigSettings__c();
        urlPatternEntry.Type__c = 'URLPattern';
        urlPatternEntry.Name = 'forTest';
        urlPatternEntry.Text1__c = TimeTrackerConstants.CASE_REVIEW_STR;
        urlPatternEntry.Text2__c = 'objId';
        urlPatternEntry.Text3__c = 'parentId';
        insert urlPatternEntry;
            
        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        //System.assertEquals(240, caseCreationRecord.Duration__c);
        System.assertEquals(120, caseCreationRecord.Duration__c); //Due to max time neutralized

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        //reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        //reviewtt.Parent_Object_Id__c = caseObj.Id;
        reviewtt.TabInfo__c = ' {"success":true,"tabLink":"https://na30.salesforce.com/console#/p/attach/NoteAttach?objId=500360000036Wbz&parentId=500360000036Aby"}';

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        //System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(120, excludedTT.Duration__c); //Due to max time neutralized

        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        //System.assertEquals(600,tse.Tracked_Duration__c);
        System.assertEquals(120,tse.Tracked_Duration__c); //Due to max time neutralized

        Time_Tracker__c updatedTTRec = [SELECT Id,Object_Id__c, Parent_Object_Id__c FROM Time_Tracker__c 
                                        WHERE Id=:reviewtt.Id];
        system.assertEquals('500360000036Wbz',updatedTTRec.Object_Id__c);
        system.assertEquals('500360000036Aby',updatedTTRec.Parent_Object_Id__c);                                
    }

    @isTest static void test_GenericExcludeImpl_URLPattern_GetObjectIDField()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        confSetting.Text5__c = '';
        upsert confSetting;

        /*TimeTrackerConfigSettings__c maxTimeSetting = TimeTrackerConfigSettings__c.getValues('Miscellaneous_maxTimeConsiderInMin');
        maxTimeSetting.code1__c = String.valueof(2);
        upsert maxTimeSetting;*/
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        ttSettings.Max_Duration_In_Minutes__c = 2;
        upsert ttSettings;
        
        TimeTrackerConfigSettings__c urlPatternEntry = new TimeTrackerConfigSettings__c();
        urlPatternEntry.Type__c = 'URLPattern';
        urlPatternEntry.Name = 'forTest';
        urlPatternEntry.Text1__c = TimeTrackerConstants.CASE_REVIEW_STR;
        urlPatternEntry.Text2__c = 'objId';
        insert urlPatternEntry;
            
        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        //System.assertEquals(240, caseCreationRecord.Duration__c);
        System.assertEquals(120, caseCreationRecord.Duration__c); //Due to max time neutralized

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        //reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        //reviewtt.Parent_Object_Id__c = caseObj.Id;
        reviewtt.TabInfo__c = ' {"success":true,"tabLink":"https://na30.salesforce.com/console#/p/attach/NoteAttach?objId=500360000036Wbz&parentId=00001009"}';

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        //System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(120, excludedTT.Duration__c); //Due to max time neutralized

        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        //System.assertEquals(600,tse.Tracked_Duration__c);
        System.assertEquals(120,tse.Tracked_Duration__c); //Due to max time neutralized

        Time_Tracker__c updatedTTRec = [SELECT Id,Object_Id__c, Parent_Object_Id__c FROM Time_Tracker__c 
                                        WHERE Id=:reviewtt.Id];
        system.assertEquals('500360000036Wbz',updatedTTRec.Object_Id__c);
        system.assertEquals(null,updatedTTRec.Parent_Object_Id__c);                                
    }
    @isTest static void test_GenericExcludeImpl_URLPattern_GetParentObjectIDField()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        confSetting.Text5__c = '';
        upsert confSetting;

        /*TimeTrackerConfigSettings__c maxTimeSetting = TimeTrackerConfigSettings__c.getValues('Miscellaneous_maxTimeConsiderInMin');
        maxTimeSetting.code1__c = String.valueof(2);
        upsert maxTimeSetting;*/
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        ttSettings.Max_Duration_In_Minutes__c = 2;
        upsert ttSettings;
        
        TimeTrackerConfigSettings__c urlPatternEntry = new TimeTrackerConfigSettings__c();
        urlPatternEntry.Type__c = 'URLPattern';
        urlPatternEntry.Name = 'forTest';
        urlPatternEntry.Text1__c = TimeTrackerConstants.CASE_REVIEW_STR;
        urlPatternEntry.Text3__c = 'parentId';
        insert urlPatternEntry;
            
        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        //System.assertEquals(240, caseCreationRecord.Duration__c);
        System.assertEquals(120, caseCreationRecord.Duration__c); //Due to max time neutralized

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        //reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        //reviewtt.Parent_Object_Id__c = caseObj.Id;
        reviewtt.TabInfo__c = ' {"success":true,"tabLink":"https://na30.salesforce.com/console#/p/attach/NoteAttach?objId=500360000036Wbz&parentId=500360000036Aby"}';

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        //System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(120, excludedTT.Duration__c); //Due to max time neutralized

        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        //System.assertEquals(600,tse.Tracked_Duration__c);
        System.assertEquals(120,tse.Tracked_Duration__c); //Due to max time neutralized

        Time_Tracker__c updatedTTRec = [SELECT Id,Object_Id__c, Parent_Object_Id__c FROM Time_Tracker__c 
                                        WHERE Id=:reviewtt.Id];
        system.assertEquals(null,updatedTTRec.Object_Id__c);
        system.assertEquals('500360000036Aby',updatedTTRec.Parent_Object_Id__c);                                
    }
    
    @isTest static void test_GenericExcludeImpl_DontExcludeActivity_Reportable()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        System.debug(LoggingLevel.ERROR, '--++--confSetting : ' + confSetting);
        confSetting.Text5__c = '';
        upsert confSetting;

        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        System.assertEquals(240, caseCreationRecord.Duration__c);

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);

        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        System.assertEquals(600,tse.Tracked_Duration__c);
    }

    @isTest static void test_GenericExcludeImpl_DontExcludeActivity_NonReportable()
    {
        init();

        // get config custom setting for Strategy_CASE_OPENED_FOR_REVIEW
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        System.debug(LoggingLevel.ERROR, '--++--confSetting : ' + confSetting);
        confSetting.Text5__c = '';
        //Non-reportable field
        confSetting.Flag3__c = true;
        upsert confSetting;

        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        System.assertEquals(240, caseCreationRecord.Duration__c);

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c, Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);

        //Should be 0 due to Non-reportable field
        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        System.assertEquals(0,tse.Tracked_Duration__c);
    }

    @isTest static void test_GenericExcludeImpl_ExcludeActivity_Reportable()
    {
        init();
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        System.debug(LoggingLevel.ERROR, '--++--confSetting : ' + confSetting);
        confSetting.Text5__c = '';
        confSetting.Text6__c = TimeTrackerConstants.NEW_CASE_STR;
        upsert confSetting;

        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        System.assertEquals(240, caseCreationRecord.Duration__c);

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(360, excludedTT.Duration__c);

        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        System.assertEquals(360,tse.Tracked_Duration__c);
    }

    @isTest static void test_GenericExcludeImpl_ExcludeActivity_NonReportable()
    {
        init();
        TimeTrackerConfigSettings__c confSetting = TimeTrackerConfigSettings__c.getValues('Strategy_Case_Review');
        System.assert(confSetting != null);
        System.debug(LoggingLevel.ERROR, '--++--confSetting : ' + confSetting);
        confSetting.Text5__c = '';
        confSetting.Text6__c = TimeTrackerConstants.NEW_CASE_STR;
        confSetting.Flag3__c = true;
        upsert confSetting;

        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;
        system.assert(caseCreationend.Id != null);

        //Verify correct time is calculated For Case-creation
        Time_Tracker__c caseCreationRecord = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationend.Id];
        System.assertEquals(240, caseCreationRecord.Duration__c);

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(360, excludedTT.Duration__c);

        //Should be 0 due to Non-reportable field
        Timesheet_Entry__c tse = [SELECT Tracked_Duration__c FROM Timesheet_Entry__c WHERE Id=: excludedTT.Timesheet_Entry__c]; 
        System.assertEquals(0,tse.Tracked_Duration__c);
    }

    @isTest static void test_GenericTimeTrackerImpl()
    {
        init();

        Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    '', '', '',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        insert caseCreationStart;
        system.assert(caseCreationStart.Id != null);

        ManualLineItem__c mli1 = new ManualLineItem__c(Engage_Time__c = dtNow.addMinutes(2), Disengage_Time__c = dtNow.addMinutes(3));
        insert mli1;
        
        Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(5).getTime()), String.valueOf(dtNow.addMinutes(5).getTime()),
                                                                    TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        caseCreationend.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericTimeTrackerImpl
        insert caseCreationend;        

        Time_Tracker__c updated = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: caseCreationEnd.Id];
        system.assertEquals(180, updated.Duration__c);        
    }
    @isTest static void test_populateLookupsFieldsAndSubMethods_Old()
    {
        init();
        
        //Opportunity-object
        Time_Tracker__c forOpp1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forOpp1.Object_Id__c = oppObj.Id;
        forOpp1.Parent_Object_Id__c = oppObj.Id;

        Time_Tracker__c forOpp2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forOpp2.Parent_Object_Id__c = oppObj.Id;        
        
        
        //Case-object
        Time_Tracker__c forCase1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    '', caseObj.Id,  
                                                                    null, usr.Id);
        forCase1.Object_Id__c = caseObj.Id;
        forCase1.Parent_Object_Id__c = caseObj.Id;
        
        Time_Tracker__c forCase2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forCase2.Parent_Object_Id__c = caseObj.Id;
        
        
        //Account-object
        Time_Tracker__c forAct1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forAct1.Object_Id__c = acc.Id;
        forAct1.Parent_Object_Id__c = acc.Id;
        
        Time_Tracker__c forAct2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forAct2.Parent_Object_Id__c = acc.Id;
        
        //Contact-object
        Time_Tracker__c forcon1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forcon1.Object_Id__c = con.Id;
        forcon1.Parent_Object_Id__c = con.Id;
        
        Time_Tracker__c forcon2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CHATTER_TEXT_POST, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '','','',
                                                                    caseObj.Id, caseObj.Id,  
                                                                    null, usr.Id);
        forcon2.Parent_Object_Id__c = con.Id;
        
        
        List<Time_Tracker__c> ttList = new List<Time_Tracker__c>{forAct1, forAct2, forcon1, forcon2, forCase1,  forCase2, forOpp1, forOpp2};
        insert ttList;
        system.debug('##'+ttList);
        //System.assert(evnt.Id != null);
    }

    @isTest static void test_populateLookupsFields_HasNoConfiguration()
    {
        init();

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        upsert caseObjConfig;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);
    }
    @isTest 
    static void test_populateLookupsFields_HasConfiguration_ObjectDontHaveRelatedObjectsDetails()
    {
        init();

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Id:Case__c;Contact.AccountId:Account__c;ContactId:Contact__c;';
        upsert caseObjConfig;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(caseObj.Id,excludedTT.Case__c);
    }
    @isTest 
    static void test_populateLookupsFields_HasConfiguration_ObjectHasRelatedObjectsDetails()
    {
        init();
        List<sobject> toUpd = new List<sobject>();
        con.AccountId = acc.Id;
        toUpd.add(con);
        caseObj.ContactId = con.Id;
        toUpd.add(caseObj);
        update toUpd;

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Id:Case__c;Contact.AccountId:Account__c;ContactId:Contact__c;';
        upsert caseObjConfig;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(caseObj.Id,excludedTT.Case__c);
        System.assertEquals(con.Id,excludedTT.Contact__c);
        System.assertEquals(acc.Id,excludedTT.Account__c);
    }
    @isTest 
    static void test_populateLookupsFields_HasConfigurationWithIncorrectTTField_ObjectHasRelatedObjectsDetails()
    {
        init();
        List<sobject> toUpd = new List<sobject>();
        con.AccountId = acc.Id;
        toUpd.add(con);
        caseObj.ContactId = con.Id;
        toUpd.add(caseObj);
        update toUpd;

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Id:Case__c;Contact.AccountId:Acnt_c;ContactId:Contact__c;';
        upsert caseObjConfig;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(caseObj.Id,excludedTT.Case__c);
        System.assertEquals(con.Id,excludedTT.Contact__c);
        System.assertEquals(null,excludedTT.Account__c);
    }
    @isTest 
    static void test_populateLookupsFields_HasConfigurationWithIncorrectObjectField_ObjectHasRelatedObjectsDetails()
    {
        init();
        List<sobject> toUpd = new List<sobject>();
        con.AccountId = acc.Id;
        toUpd.add(con);
        caseObj.ContactId = con.Id;
        toUpd.add(caseObj);
        update toUpd;

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Id:Case__c;Cntct.AccountId:Account__c;ContactId:Contact__c;';
        upsert caseObjConfig;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        Time_Tracker__c excludedTT = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: reviewtt.Id];
        System.assertEquals(600, excludedTT.Duration__c);
        System.assertEquals(null,excludedTT.Case__c);
        System.assertEquals(null,excludedTT.Contact__c);
        System.assertEquals(null,excludedTT.Account__c);
    }
    @isTest 
    static void test_populateLookupsFields_PartialFromObjectId_PartialFromParentId()
    {
        init();
        List<sobject> toUpd = new List<sobject>();
        con.AccountId = acc.Id;
        toUpd.add(con);
        caseObj.ContactId = con.Id;
        toUpd.add(caseObj);
        update toUpd;

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Contact.AccountId:Account__c;';
        upsert caseObjConfig;
        TimeTrackerConfigSettings__c taskObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Task');
        taskObjConfig.Code1__c = '00T';
        taskObjConfig.Text4__c = 'WhatId:Case__c;';
        upsert taskObjConfig;

        Task tsk = new Task(ActivityDate = Date.today().addDays(0),Subject='Sample Task', Status='In Progress',
                            WhatId = caseObj.Id,
                            OwnerId = UserInfo.getUserId());
        insert tsk;
        System.assert(tsk.Id != null);

        Time_Tracker__c taskReview = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.TASK_SAVE, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.TASK, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        taskReview.Object_Id__c = tsk.Id;
        taskReview.Duration__c = 600;
        taskReview.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert taskReview;
        System.assert(taskReview.Id != null);

        Time_Tracker__c updtaskReview = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: taskReview.Id];
        System.assertEquals(600, updtaskReview.Duration__c);
        System.assertEquals(caseObj.Id,updtaskReview.Case__c);
        System.assertEquals(null,updtaskReview.Contact__c);
        System.assertEquals(acc.Id,updtaskReview.Account__c);
    }
    @isTest 
    static void test_populateLookupsFields_NoneFromObjectId_AllFromParentId()
    {
        init();
        List<sobject> toUpd = new List<sobject>();
        con.AccountId = acc.Id;
        toUpd.add(con);
        caseObj.ContactId = con.Id;
        toUpd.add(caseObj);
        update toUpd;

        TimeTrackerConfigSettings__c caseObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Case');
        caseObjConfig.Code1__c = '500';
        caseObjConfig.Text4__c = 'Id:Case__c;Contact.AccountId:Account__c;ContactId:Contact__c';
        upsert caseObjConfig;
        TimeTrackerConfigSettings__c taskObjConfig = TimeTrackerConfigSettings__c.getValues('Object_Settings_Task');
        taskObjConfig.Code1__c = '00T';
        taskObjConfig.Text4__c = '';
        taskObjConfig.Text5__c = '';
        upsert taskObjConfig;

        Task tsk = new Task(ActivityDate = Date.today().addDays(0),Subject='Sample Task', Status='In Progress',
                            WhatId = caseObj.Id,
                            OwnerId = UserInfo.getUserId());
        insert tsk;
        System.assert(tsk.Id != null);

        Time_Tracker__c taskReview = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.TASK_SAVE, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.TASK, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    '', '',  
                                                                    null, usr.Id);
        taskReview.Object_Id__c = tsk.Id;
        taskReview.Duration__c = 600;
        taskReview.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert taskReview;
        System.assert(taskReview.Id != null);

        Time_Tracker__c updtaskReview = [SELECT Case__c,Account__c,Contact__c,Duration__c,Timesheet_Entry__c FROM Time_Tracker__c WHERE Id=: taskReview.Id];
        System.assertEquals(600, updtaskReview.Duration__c);
        System.assertEquals(caseObj.Id,updtaskReview.Case__c);
        System.assertEquals(con.Id,updtaskReview.Contact__c);
        System.assertEquals(acc.Id,updtaskReview.Account__c);
    }                
}