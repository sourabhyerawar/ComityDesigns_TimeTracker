/**
* @description an interface class (the Strategy) for TimeTracker with methods that will be implemented by other classes
*/
global interface ITimeTrackerService {

	/**
	* @description method to associate Start and End Action, that will be implemented by other classes
	* @param Time_Tracker__c: newRecord
	* @param List<Time_Tracker__c>: associatedList
	*/
	//void associateStartAndEndAction(Time_Tracker__c closingActionRecord, Map<String, Map<String, Time_Tracker__c>> associatedMap);
    
    void associateStartAndEndAction(Time_Tracker__c closingActionRecord, Time_Tracker__c openingActionRecord);
}