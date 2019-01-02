global class GenericTimeTrackerImpl implements ITimeTrackerService {
    
    /**
* @description method to associate Start and End Action
* @param Time_Tracker__c: closingRecord
* @param List<Time_Tracker__c>: associatedList
*/
    public static void associateStartAndEndAction(Time_Tracker__c closingRecord, Time_Tracker__c openingRecord) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started GenericTimeTrackerImpl.associateStartAndEndAction method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingRecord: ' + closingRecord + '; openingRecord: ' + openingRecord,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        
        //1
        Decimal timeSpentInSeconds = TimeTrackerUtility.getDecimalTimeDifference(closingRecord, openingRecord);

        Integer elapsedTimeInMin = (Integer)(math.abs(timeSpentInSeconds) / 60);
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Original closingRecord Duration: ' + closingRecord.Duration__c,
          Datetime.now(), null, null, null, UserInfo.getUserId());
        //closingRecord.Duration__c = elapsedTimeInMin < TimeTrackerConfigSettings.getMaxAllowedMinutesDifference() ? timeSpentInSeconds : TimeTrackerConfigSettings.getMaxAllowedMinutesDifference()*60; 
        Integer MaxtimeInMin = TimeTrackerUserSettings.getMaxAllowedMinutesDifference();
        closingRecord.Duration__c = elapsedTimeInMin < MaxtimeInMin? timeSpentInSeconds : MaxtimeInMin*60;        
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ClosingRecord Duration Neutrlized against Max-allowed-time: ' + closingRecord.Duration__c + ' vs Max-time' + TimeTrackerConfigSettings.getMaxAllowedMinutesDifference(),
          Datetime.now(), null, null, null, UserInfo.getUserId());

        try {
            
            //2
            closingRecord.Opening_Activity_Date__c = openingRecord.Activity_Date__c;
            closingRecord.Opening_Activity_Time__c = openingRecord.Activity_Time__c;

            //Exclude Activities-time
            TimeTrackerTriggerUtility.excludeTime(closingRecord);
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'After excludeTime()- closingRecord duration: ' + closingRecord.Duration__c,
                Datetime.now(), null, null, null, UserInfo.getUserId());
            
            // Exclude Manual Line Items Time
            closingRecord.Duration__c = TimeTrackerUtility.excludeManualLineItemTime(closingRecord, closingRecord.Opening_Activity_Date__c);
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'After excludeManualLineItemTime()- closingRecord duration: ' + closingRecord.Duration__c,
                Datetime.now(), null, null, null, UserInfo.getUserId());

            closingRecord.Time_Spent__c = TimeTrackerUtility.calculateTimeSpent(closingRecord.Duration__c);
            closingRecord.Action_Closed__c = true;
        } catch(Exception e) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
            Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of GenericTimeTrackerImpl.associateStartAndEndAction method',
                  Datetime.now(), null, null, null, UserInfo.getUserId());
    }


}