/**
* @description unit test class for TimeTrackerRollupUtil.cls
* @created 09/02/15
*/
@isTest
private class TimeTrackerRollupUtil_Test {
    static Datetime dtNow = Datetime.now();
    
    @isTest static void testRollup() {

        Database.SaveResult sr = null;
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
                + 'TimeTrackerConfigSettings__c', 'TimeTrackerConfigSettings_Records');

        try {

            // create test user
            User usr = TimeTrackerTestHelper.createUser();
            Case caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
            insert caseObj;

            system.runAs(usr) {
                Integer rand = Crypto.getRandomInteger();
                rand = (rand < 0 ? rand * -1 : rand);
                String randomId = String.valueOf(rand);

                Test.startTest();
                    for(Integer i = 0; i < 2; i++)
                    {
                        // create TimeTracker records
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
                    }
                Test.stopTest();

                List<Timesheet_Entry__c> tseList = [ Select  Id, Name, Timesheet__c, Tracked_Duration__c
                                                    From Timesheet_Entry__c
                                                    Limit 10];
                System.debug(LoggingLevel.ERROR, '--++--tseList : ' + tseList);
                System.assert(!tseList.isEmpty());
                System.assertEquals(1, tseList.size());
                System.assertEquals(480, tseList[0].Tracked_Duration__c, tseList[0].Tracked_Duration__c);
            }
        } catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'Exception in running unit test TimeTrackerRollupUtil_Test. Error is: ' + ex.getMessage());
        }
    }

    @isTest static void testRollup_2() {

        Database.SaveResult sr = null;
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
                + 'TimeTrackerConfigSettings__c', 'TimeTrackerConfigSettings_Records');

        try {

            // create test user
            User usr = TimeTrackerTestHelper.createUser();
            Case caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
            insert caseObj;

            TimeTrackerConfigSettings__c conSet = TimeTrackerConfigSettings__c.getValues('Strategy_New_Case');
            System.assertNotEquals(null, conSet);
            conSet.Text3__c = TimeTrackerConstants.CASE_REVIEW_STR;
            update conSet;

            system.runAs(usr) {
                Integer rand = Crypto.getRandomInteger();
                rand = (rand < 0 ? rand * -1 : rand);
                String randomId = String.valueOf(rand);

                Test.startTest();
                    // delete / comment createNewTimesheetEntry & createNewTimeTracker methods from utility create

                    // create TimeTracker records
                    Time_Tracker__c caseCreationStart = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR, String.valueOf(dtNow.addMinutes(1).getTime()), String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                                '', '', '',
                                                                                caseObj.Id, caseObj.Id,  
                                                                                null, usr.Id);
                    insert caseCreationStart;
                    system.assert(caseCreationStart.Id != null);

                    Time_Tracker__c caseCreationend = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.NEW_CASE_STR + ' Save', String.valueOf(dtNow.addMinutes(3).getTime()), String.valueOf(dtNow.addMinutes(3).getTime()),
                                                                                TimeTrackerConstants.NEW_CASE_STR,String.valueOf(dtNow.addMinutes(1).getTime()) , String.valueOf(dtNow.addMinutes(1).getTime()),
                                                                                caseObj.Id, caseObj.Id,  
                                                                                null, usr.Id);
                    caseCreationend.Parent_Object_Id__c = caseObj.Id;
                    // This will execute GenericTimeTrackerImpl
                    insert caseCreationend;
                    system.assert(caseCreationend.Id != null);

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
                Test.stopTest();

                List<Timesheet_Entry__c> tseList = [ Select  Id, Name, Timesheet__c, Tracked_Duration__c
                                                    From Timesheet_Entry__c
                                                    Limit 10];
                System.debug(LoggingLevel.ERROR, '--++--tseList : ' + tseList);
                System.assert(!tseList.isEmpty());
                System.assertEquals(1, tseList.size());
                System.assertEquals(600, tseList[0].Tracked_Duration__c, tseList[0].Tracked_Duration__c);
            }
        } catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'Exception in running unit test TimeTrackerRollupUtil_Test. Error is: ' + ex.getMessage());
        }
    }
}