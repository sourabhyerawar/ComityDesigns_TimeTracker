/**
* @description unit test class for TimeTrackerRollupUtil.cls
* @created 09/02/15
*/
@isTest
private class TimeTrackerRollupUtil_Test {
    
    @isTest static void testRollup() {

        Database.SaveResult sr = null;

        try {

            // create test user
            User usr = TimeTrackerTestHelper.createUser();

            system.runAs(usr) {
                Integer rand = Crypto.getRandomInteger();
                rand = (rand < 0 ? rand * -1 : rand);
                String randomId = String.valueOf(rand);

                Test.startTest();

                //******************* Commented the following, as TimeTrackerConfigSettings are being used insted
                //******************* of Manual and Strategy
                // create settings for TimeTrackerStrategy
                //List<TimeTrackerStrategy__c> ttsList = new List<TimeTrackerStrategy__c>();
                //ttsList.add(new TimeTrackerStrategy__c(Name = TimeTrackerConstants.NEW_CASE_STR, 
                //                                       Impl_Class_Name__c = TimeTrackerUtility.getStringWithoutWhiteSpaces(TimeTrackerConstants.NEW_CASE_STR) + 
                //                                                            TimeTrackerConstants.IMPLEMENATION_CLASS_NAME_SUFFIX));
                //// TODO: need to be removed
                //ttsList.add(new TimeTrackerStrategy__c(Name = TimeTrackerConstants.TIME_TRACKER_MAX_TIME_CONSIDER_IN_MIN, 
                //                                       Value__c = '5'));
                //// insert the TimeTrackerStrategy record
                //List<Database.SaveResult> srs = Database.insert(ttsList, true);
                //// ensure the TimeTrackerStrategy records has Id
                //for(Database.SaveResult result : srs) {
                //    system.assertNotEquals(null, result.getId());
                //}

                // create Timesheet record
                Timesheet__c timesheet = TimeTrackerUtility.createNewTimesheet(system.today(), usr.Id, usr.LastName);
                
                // insert the Timesheet record
                sr = Database.insert(timesheet, true);
                // ensure the Timesheet record has an Id
                system.assertNotEquals(null, sr.getId());

                // create Timesheet Entry record
                Timesheet_Entry__c tse = TimeTrackerUtility.createNewTimesheetEntry(TimeTrackerConstants.CASE_CREATION_STR, 
                                                                                    system.today(), TimeTrackerConstants.TIME_SPENT_DEFAULT_VALUE, 
                                                                                    sr.getId(), usr.Id);
                // insert the Timesheet Entry record
                sr = Database.insert(tse, true);
                // ensure the Timesheet Entry record has an Id
                system.assertNotEquals(null, sr.getId());

                // create TimeTracker records
                Time_Tracker__c tt1 = TimeTrackerUtility.createNewTimeTracker(String.valueOf(DateTime.now().getTime()), null, 
                                                                              TimeTrackerConstants.NEW_CASE_STR, 
                                                                              TimeTrackerConstants.CASE_WORK_STR, null, null, null, 
                                                                              randomId, TimeTrackerConstants.SYSTEM_STR, null, usr.Id);
                // insert the TimeTracker record with start action
                sr = Database.insert(tt1, true);
                // ensure the TimeTracker record has an Id
                system.assertNotEquals(null, sr.getId());
                
                Time_Tracker__c tt2 = TimeTrackerUtility.createNewTimeTracker(String.valueOf((DateTime.now().addMinutes(10)).getTime()) , 
                                                                              null, TimeTrackerConstants.CASE_DETAIL_STR, 
                                                                              TimeTrackerConstants.CASE_WORK_STR, 
                                                                              null, null, TimeTrackerConstants.NEW_CASE_STR, 
                                                                              randomId, TimeTrackerConstants.SYSTEM_STR, null, usr.Id);
                // insert the TimeTracker record with end action
                sr = Database.insert(tt2, true);
                // ensure the TimeTracker record has an Id
                system.assertNotEquals(null, sr.getId());

                // ensure the roll-up is successful
                List<Time_Tracker__c> testTT = [Select Id, Duration__c, Timesheet_Entry__c, Timesheet_Entry__r.Tracked_Duration__c
                                                From Time_Tracker__c
                                                Where Timesheet_Entry__c = :tse.Id
                                                Limit 1];

                Test.stopTest();

                system.assertNotEquals(null, testTT);
                system.assertNotEquals(null, testTT[0].Timesheet_Entry__c);
                system.assertEquals(testTT[0].Duration__c, testTT[0].Timesheet_Entry__r.Tracked_Duration__c);
            }
        } catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'Exception in running unit test TimeTrackerRollupUtil_Test. Error is: ' + ex.getMessage());
        }
    }
}