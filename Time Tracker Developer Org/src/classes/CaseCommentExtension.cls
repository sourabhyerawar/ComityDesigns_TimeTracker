/*
*History: [TICK:37738] - Shivam Sahni - 12/18/13 - This class is the controller behind the PostCaseComment VF page which acts as a CaseFeed custom action
*                           to provide our staff the ability to add comments that exceed 1000 characters (upto 4000 Bytes)
*/

public class CaseCommentExtension {
  
  public Case caseRec {get; set;}  
    public CaseComment comment {get; set;}

    public CaseCommentExtension(ApexPages.StandardController controller) {
      if(!Test.isRunningTest())
        //controller.AddFields(new List<string>{ 'Time_Spent_Minutes__c' });
        caseRec = (Case)controller.getRecord();
        comment = new CaseComment();
        comment.parentid = caseRec.id;
    }

    public PageReference addComment() {
      update caseRec;
      //caseRec.Time_Spent_Minutes__c = null;
      
        insert comment;
        comment = new CaseComment();
        comment.parentid = caseRec.id;
        return null;
    }   
}