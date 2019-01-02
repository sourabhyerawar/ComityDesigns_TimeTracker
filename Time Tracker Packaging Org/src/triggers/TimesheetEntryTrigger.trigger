trigger TimesheetEntryTrigger on Timesheet_Entry__c (before update) {

	system.debug('Trigger::TimesheetEntryTrigger: before update entered');
	try {
		for(Timesheet_Entry__c tse : Trigger.new) {
			if(tse.Tracked_Duration__c > 0) {
				system.debug('Tracked_Duration__c before TSE update is:: ' + tse.Tracked_Duration__c);
					
				Integer hours = Integer.valueOf(Math.floor(tse.Tracked_Duration__c/3600));
		        Integer minutes = Integer.valueOf(Math.floor((tse.Tracked_Duration__c  - (hours * 3600))/60));
		        Integer seconds = Integer.valueOf(tse.Tracked_Duration__c  - (hours * 3600) - (minutes * 60));
		        
		        tse.Time_Spent__c = (hours < 10 ? '0' + String.valueOf(hours) : String.valueOf(hours)) + ':' +
		        					(minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes)) + ':' +
		            				(seconds < 10 ? '0' + String.valueOf(seconds) : String.valueOf(seconds));
		    } else {
		    	tse.Time_Spent__c = '00:00:00';
		    }

	        system.debug('Time_Spent__c in before TSE update is calculated as:: ' + tse.Time_Spent__c);
		}
	} catch(Exception ex) {
		system.debug(LoggingLevel.ERROR, 'Error in processing Timesheet_Entry__c record(s) in before update trigger: ' + ex.getMessage());
	}

	system.debug('Trigger::TimesheetEntryTrigger: before update returning');
}