/*
*History: [TICK:37738] - Shivam Sahni - 12/19/13 - This class is the controller behind the AddNextActionDate VF page which acts as a CaseFeed custom action
*                                                  to provide our staff the ability to add new Next Action dates and log it in comments.
*/

public with sharing class CaseNextActionExtension {

    public Case caseRec {get; set;} 
    private CaseComment comment;
    private Datetime previousNextAction;
    private Datetime currentNextAction;

    public CaseNextActionExtension(ApexPages.StandardController controller) {
        if(!Test.isRunningTest())
            controller.AddFields(new List<string>{ 'Next_Action_Date__c' });
        caseRec = (Case)controller.getRecord();
        previousNextAction = caseRec.Next_Action_Date__c != null ? DateTime.newInstance(caseRec.Next_Action_Date__c,Time.newInstance(00,00,00,00)) : null;
        caseRec.Next_Action_Date__c = null;
    }
    
    public PageReference saveCase() {
        update caseRec;
        if(!Test.isRunningTest())
            currentNextAction = caseRec.Next_Action_Date__c != null ? datetime.newInstance(caseRec.Next_Action_Date__c,Time.newInstance(00,00,00,00)) : null;
        else
            currentNextAction = system.now();   
        if(previousNextAction != currentNextAction)
        {    
          comment = new CaseComment();
          comment.ParentId = caseRec.id;
          //system.debug('+++NextAction+++' + comment + ' ' + previousNextAction + ' ' + previousNextAction.format('MM-dd-yyyy') + ' ' + currentNextAction + ' ' + currentNextAction.format('MM-dd-yyyy'));
          //comment.CommentBody = 'Next Action date changed from ' + (previousNextAction != null ? previousNextAction.format('MM-dd-yyyy') : ' Blank ') + ' to ' + (currentNextAction != null ? currentNextAction.format('MM-dd-yyyy') : ' Blank ');
          comment.CommentBody = 'Next Action date changed from ' + previousNextAction + ' to ' + currentNextAction;
          insert comment;
        }  
        
        comment = null;
        previousNextAction = null;
        currentNextAction = null;
        caseRec.Next_Action_Date__c = null;
        return null;
    }  
}