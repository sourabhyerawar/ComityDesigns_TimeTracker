public class TimeTrackerTimesheetApproval {
  public static Map<String, Object> bulkApproveOrReject(Set<Id> recordIds, String action, String comments) {
		Map<String, Object> response = new Map<String, Object>();
		try {
			List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

			List<ProcessInstanceWorkitem> workItems = [ SELECT Id, ProcessInstanceId
														FROM ProcessInstanceWorkitem
														WHERE ActorId = :UserInfo.getUserId() 
														AND IsDeleted = false
														AND ProcessInstance.TargetObjectId IN :recordIds  ];
			for(ProcessInstanceWorkitem workItem : workItems) {
			 Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			 req.setWorkitemId(workItem.Id);
			 //Valid values are: Approve, Reject, or Removed.
			 //Only system administrators can specify Removed.
			 req.setAction(action);
			 req.setComments(comments);
			 requests.add(req);
		 }
		 Approval.ProcessResult[] processResults = Approval.process(requests);
	 } catch ( Exception ex ) {
		 response.put('status', '500');
		 response.put('error', ex.getMessage());
		 return response;
	 }
	 response.put('status', '200');
	 return response;
	}
}