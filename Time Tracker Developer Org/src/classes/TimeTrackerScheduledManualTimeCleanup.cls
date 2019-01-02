/**
* An apex class used to schedule TimeTrackerScheduledManualTimeCleanup Batch process
*/
global class TimeTrackerScheduledManualTimeCleanup implements Schedulable {
	global void execute(SchedulableContext sc) {
		TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerScheduledManualTimeCleanup.execute method.',
		    Datetime.now(), null, null, null, UserInfo.getUserId());
		TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sc: ' + sc,
		    Datetime.now(), null, null, null, UserInfo.getUserId());
		TimeTrackerCleanupManualTime b = new TimeTrackerCleanupManualTime();
		database.executebatch(b);
	}
}