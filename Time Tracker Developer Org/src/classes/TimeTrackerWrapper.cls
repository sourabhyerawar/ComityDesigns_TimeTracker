public class TimeTrackerWrapper {

	public class Activity {
		public String objectType;
		public String activityDate;
		public String clientId;
		public String action;
		public String actionCategory;
		public String caseId;
		public String tabId;
        public String documentId;
		public String openingAction;
		public String level;
		public String logData;
        public String source;
        public String user;
	}

	public List<Activity> activity;

	public static TimeTrackerWrapper parse(String json) {
		return (TimeTrackerWrapper) System.JSON.deserialize(json, TimeTrackerWrapper.class);
	}
}