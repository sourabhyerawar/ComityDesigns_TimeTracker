Trigger TimeTrackerTrigger on Time_Tracker__c ( Before Insert, After Insert, Before Update, After Update ) {
    
    try
    {
        Boolean executeTrigger = TimeTrackerConfigSettings.getRunTimeTrackerTriggers();
        if( executeTrigger ) { 
            
            if( Trigger.isBefore ) {
                
                if ( Trigger.isInsert ) {
                    TimeTrackerTriggerHandler.OnBeforeInsert( Trigger.new );
                }
                else if ( Trigger.isUpdate ) {
                    TimeTrackerTriggerHandler.OnBeforeUpdate( Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap );
                }
            }
            else {
                if ( Trigger.isInsert ) {
                    TimeTrackerTriggerHandler.OnAfterInsert( Trigger.new );
                }
                else if ( Trigger.isUpdate ) {
                    TimeTrackerTriggerHandler.OnAfterUpdate( Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap );
                }
            }
        }
    }
    catch( Exception ex ) {
        TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString( ex ),
                                          Datetime.now(), null, null, null, UserInfo.getUserId()
                                        );
    }
    finally {
        TimeTrackerUtility.upsertLogRecord();
    }
}