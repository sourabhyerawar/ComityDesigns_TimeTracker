global class TimeTrackerScheduledCleanup implements Schedulable {

   global void execute(SchedulableContext sc) {
		TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerScheduledCleanup.execute() method.',
		    Datetime.now(), null, null, null, UserInfo.getUserId());
		TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sc: ' + sc,
		    Datetime.now(), null, null, null, UserInfo.getUserId());

      TimeTrackerCleanupOrphans cleanup = new TimeTrackerCleanupOrphans();

      database.executebatch(cleanup);
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerScheduledCleanup.execute() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
   }

}