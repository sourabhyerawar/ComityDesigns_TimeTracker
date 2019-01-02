/**
* @description a context class where decision will be taken at run-time to identify the strategy 
* to associate the TimeTracker Opening and Closing action
*/
public class TimeTracker {

    public class TimeTrackerException extends Exception {}

    private static final Map<String, ITimeTrackerService> strategies;

    static {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Initiating TimeTracker.setup.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        // retrieve list of strategies from TimeTrackerConfig Custom Setting
        Map<String, List<TimeTrackerConfigSettings__c>> ttsMap = TimeTrackerConfigSettings.getSettingsByType(TimeTrackerConstants.STRATEGY_TYPE,
                                                                TimeTrackerConstants.TEXT1_FIELD);
        
        // populate a map of strategy names to concrete implementations
        // using Type.forName for each strategy string
        strategies = new Map<String, ITimeTrackerService>();
        if(ttsMap != null && !ttsMap.isEmpty()) {
            for(String action : ttsMap.keySet()) {
                if(ttsMap.get(action) == null || ttsMap.get(action).isEmpty()) { continue; }
                try {
                    if(String.isNotBlank(ttsMap.get(action)[0].Code1__c)) {
                        String className = ttsMap.get(action)[0].Code1__c;
                        strategies.put(action.trim(), (ITimeTrackerService) Type.forName(className).newInstance() );
                    }
                } catch(Exception ex) {
                    //skip bad name silently
                    TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                    continue;
                } 
            }
            //system.debug('Registered Strategies are:: ' + strategies);
        } else {
            //system.debug('TimeTrackerStrategy Custom Settings is empty');
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTracker.setup',
        Datetime.now(), null, null, null, UserInfo.getUserId());
    } 

    private ITimeTrackerService strategy;

    public TimeTracker(String name) {
        //System.debug(LoggingLevel.ERROR, '--++--name : ' + name);
        //System.debug(LoggingLevel.ERROR, '--++--strategies.keySet() : ' + strategies.keySet());
        if(!strategies.containsKey(name) ) {
            throw new TimeTrackerException(name);
        }
        strategy = strategies.get(name);
    }
    
    public void processStrategy(Time_Tracker__c closingRecord, Time_Tracker__c openingRecord) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTracker.processStrategy method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingRecord: ' + closingRecord + '; openingRecord:' + openingRecord,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        strategy.associateStartAndEndAction(closingRecord, openingRecord);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTracker.processStrategy method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }
}