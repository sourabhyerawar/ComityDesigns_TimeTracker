global class TimeTrackerScheduledStagingLineItem implements Schedulable {

   global void execute(SchedulableContext sc) {
		TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerScheduledStagingLineItem.execute() method.',
		    Datetime.now(), null, null, null, UserInfo.getUserId());
		TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sc: ' + sc,
		    Datetime.now(), null, null, null, UserInfo.getUserId());

      TimeTrackerStagingLineItem processAndInsert_TTRecords = new TimeTrackerStagingLineItem();

      database.executebatch(processAndInsert_TTRecords,50);
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerScheduledStagingLineItem.execute() method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
   }

}