public class TimeTrackerTriggerHandler {
    public static void OnBeforeInsert(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHandler.OnBeforeInsert method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        TimeTrackerTriggerHelper.dumpTimeTrackerDetails(newList);
        TimeTrackerTriggerHelper.validateManualTimeTrackerRecords(newList);
        TimeTrackerTriggerHelper.calculateDurationAndExcludeTime(newList);
        TimeTrackerTriggerHelper.populateLookupsFields(newList);
        TimeTrackerTriggerHelper.associateTimesheetEntriesAndCustomSettingDetails(newList);
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHandler.OnBeforeInsert method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    
    public static void OnAfterInsert(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHandler.OnAfterInsert method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        TimeTrackerTriggerHelper.rollUpNewTimesheetEntries(newList);
        //Create Staging records
        TimeTrackerTriggerHelper.createStagingRecords(newList);
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHandler.OnAfterInsert method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    
    public static void OnBeforeUpdate(List<Time_Tracker__c> oldList, List<Time_Tracker__c> newList, Map<Id, Time_Tracker__c> oldMap, Map<Id, Time_Tracker__c> newMap) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHandler.OnBeforeUpdate method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'oldList: ' + oldList + ';newList: ' + newList
                                         + 'oldMap: ' + oldMap + ';newMap: ' + newMap,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        TimeTrackerTriggerHelper.dumpTimeTrackerDetails(newList);
        TimeTrackerTriggerHelper.validateManualTimeTrackerRecords(newList);
        TimeTrackerTriggerHelper.populateLookupsFields(newList);
        TimeTrackerTriggerHelper.associateTimesheetEntriesAndCustomSettingDetails(newList);
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHandler.OnBeforeUpdate method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    
    public static void OnAfterUpdate(List<Time_Tracker__c> oldList, List<Time_Tracker__c> newList, Map<Id, Time_Tracker__c> oldMap, Map<Id, Time_Tracker__c> newMap) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHandler.OnAfterUpdate method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'oldList: ' + oldList + ';newList: ' + newList
                                         + 'oldMap: ' + oldMap + ';newMap: ' + newMap,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        TimeTrackerTriggerHelper.rollUpNewTimesheetEntries(newList);
        TimeTrackerTriggerHelper.rollUpOldTimesheetEntries(newList, oldMap);
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHandler.OnAfterUpdate method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
    }
}