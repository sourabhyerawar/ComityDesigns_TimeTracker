global class TimeTrackerScheduledLogCleanup implements Schedulable {

   global void execute(SchedulableContext sc) {
   	TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerScheduledLogCleanup.execute() method.',
   	    Datetime.now(), null, null, null, UserInfo.getUserId());
   	TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sc: ' + sc,
   	    Datetime.now(), null, null, null, UserInfo.getUserId());

      TimeTrackerCleanupLogs cleanup = new TimeTrackerCleanupLogs();

      database.executebatch(cleanup);
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerScheduledLogCleanup.execute() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());

   }

}