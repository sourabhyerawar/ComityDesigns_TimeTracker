global class GenericImpl implements ITimeTrackerService {

           /**
    * @description method to associate Start and End Action
    * @param Time_Tracker__c: closingActionRecord
    * @param List<Time_Tracker__c>: associatedList
    */
    public static void associateStartAndEndAction(Time_Tracker__c closingRecord, Time_Tracker__c openingRecord) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started GenericImpl.associateStartAndEndAction method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingRecord: ' + closingRecord + '; openingRecord: ' + openingRecord,
          Datetime.now(), null, null, null, UserInfo.getUserId());

        Integer elapsedTimeInMin = (Integer) (Math.abs( closingRecord.Duration__c ) / 60);
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Original closingRecord Duration: ' + closingRecord.Duration__c,
          Datetime.now(), null, null, null, UserInfo.getUserId());
        Integer MaxtimeInMin = TimeTrackerUserSettings.getMaxAllowedMinutesDifference();
        closingRecord.Duration__c = elapsedTimeInMin < MaxtimeInMin? closingRecord.Duration__c : MaxtimeInMin*60;

        try {          
          closingRecord.Time_Spent__c = TimeTrackerUtility.calculateTimeSpent(closingRecord.Duration__c);
          closingRecord.Action_Closed__c = true;
        } catch(Exception e) {
                TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of GenericImpl.associateStartAndEndAction method',
          Datetime.now(), null, null, null, UserInfo.getUserId());
    }

}