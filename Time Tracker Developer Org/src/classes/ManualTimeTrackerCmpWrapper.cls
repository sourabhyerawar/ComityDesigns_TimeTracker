/**
    @ PURPOSE : HOLDS THE RESPONSE TO BE SENT TO LIGHTNING COMPONENT --> ManualTimeTrackerCmp.cmp
*/
public class ManualTimeTrackerCmpWrapper {
    
    // HOLDS TRUE IF OPERATION SUCCEEDS OTHERWISE FALSE.
    public Boolean isSucceeded;
    
    // HOLDS MESSAGE TO BE DISPLAYED TO AN END USER.
    public String strMessage;
    
    // HOLDS NAMESPACE OF THE PACKAGE INCLUDING '__'
    public String strNamespace;
    
    // HOLDS THE USER SETTINGS OF LOGGED-IN USER.
    public TimeTrackerUserSettings__c loggedInUserSettings;
    
    // HOLDS THE LIST OF MISCELLANEOUS SETTINGS TO DISPLAY CONSOLE LOGS.
    public List<TimeTrackerConfigSettings__c> listOfMiscellaneousSettings;
    
    // HOLDS THE LIST OF MANUAL SETTINGS.
    public List<ManualActivityWrapper> listOfManualActivityWrappers;
    
    // HOLDS THE TIME TRACKER RECORD TO BE CREATED.
    public Time_Tracker__c ttRecord;
    
	// HOLDS THE MAP OF LABEL API NAME WITH ITS VALUE.
	public Map<String,String> labelApiNameToValue;
	
    public ManualTimeTrackerCmpWrapper() {
        
        this.isSucceeded = FALSE;
        this.strMessage = '';
        this.strNamespace = '';
        
        this.loggedInUserSettings = TimeTrackerUserSettings__c.getInstance( UserInfo.getUserId() );
        this.listOfMiscellaneousSettings = new List<TimeTrackerConfigSettings__c>();
        this.listOfManualActivityWrappers = new List<ManualActivityWrapper>();
        
        this.ttRecord = new Time_Tracker__c();
		this.setLabelsAndValues();
    }
    
    /*
        @ PURPOSE : SETS THE STATUS OF THE OPERATION.
    */
    public void setStatus( Boolean isSucceeded, String strMessage ) {
        
        if( isSucceeded != NULL ) {
            this.isSucceeded = isSucceeded;
        }
        
        if( strMessage != NULL ) {
            this.strMessage = strMessage;
        }
    }
    
    /*
        @ PURPOSE : SETS THE NAMESPACE IF AVAILABLE.
    */
    public void setNamespace() {
        
        this.strNamespace = TimeTrackerComponentController.class.getName().substringBefore( 'TimeTrackerComponentController' );
        if( String.isNotBlank( this.strNamespace ) ) {
            this.strNamespace = this.strNamespace.subString( 0, this.strNamespace.length() - 1 ) + '__';
        }
        this.setStatus( TRUE, this.strNamespace + ' ' + System.Label.SUCCESS_Namespace_Set_Successfully );
    }
    
    /*
    	@ PURPOSE : SETS CUSTOM LABELS VALUES.
	*/
	public void setLabelsAndValues() {
		
		this.labelApiNameToValue = new Map<String,String>
								   {
									'LBL_Activity_Date' => System.Label.LBL_Activity_Date,
									
									'LBL_TT_Widget_Start' => System.Label.LBL_TT_Widget_Start,
									'LBL_TT_Widget_Pause' => System.Label.LBL_TT_Widget_Pause,
									'LBL_TT_Widget_Stop' => System.Label.LBL_TT_Widget_Stop,
									
									'LBL_Activity' => System.Label.LBL_Activity,
									'LBL_Select_DropDown' => System.Label.LBL_Select_DropDown,
									
									'LBL_Get_from_Active_Tab' => System.Label.LBL_Get_from_Active_Tab,
									'LBL_Clear_Search_Keyword' => System.Label.LBL_Clear_Search_Keyword,
									
									'LBL_Comment' => System.Label.LBL_Comment,
									'LBL_Comment_Placeholder' => System.Label.LBL_Comment_Placeholder,
									
									'LBL_Submit' => System.Label.LBL_Submit,
									
									'ERR_Invalid_Activity_Date' => System.Label.ERR_Invalid_Activity_Date,
									'ERR_Invalid_duration' => System.Label.ERR_Invalid_duration,
									'ERR_Activity_Required' => System.Label.ERR_Activity_Required,
									'ERR_Invalid_SObject' => System.Label.ERR_Invalid_SObject,
									'ERR_Get_From_Active_Tab' => System.Label.ERR_Get_From_Active_Tab,
									'ERR_Lex_Component_Unhandled_Message' => System.Label.ERR_Lex_Component_Unhandled_Message
								   };
	}
    
    /**
        @ PURPOSE : WRAPS THE DETAILS OF THE MANUAL SETTING.
    */
    public class ManualActivityWrapper {
        
        // HOLDS THE TEXT1 VALUE OF THE MANUAL SETTING [ BREAK, EMAIL, ETC ].
        public String manualActivityType;
        
        // HOLDS THE LIST OF FIELDS TO BE DISPLAYED WHEN USER TYPES IN SEARCH RECORD FIELD [ TYPE AHEAD FEATURE ].
        public List<String> listOfShowFields;
        
        // HOLDS THE LABEL OF THE OBJECT.
        public String sObjectLabel;
        
        // HOLDS THE API NAME OF THE OBJECT.
        public String sObjectApiName;
        
        // HOLDS THE PREFIX OF THE OBJECT.
        public String sObjectKeyPrefix;
        
        // HOLDS THE API NAME OF THE FIELD IN WHICH A KEYWORD SHOULD BE SEARCHED/MATCHED.
        public String sObjectSearchField;
        
        // HOLDS THE LABEL OF THE FIELD IN WHICH A KEYWORD SHOULD BE SEARCHED/MATCHED.
        public String sObjectSearchFieldLabel;
        
        // HOLDS TRUE IF RECORD SELECTION IS MANDATORY OTHERWISE FALSE.
        public Boolean isSobjectRequired;
        
        // HOLDS TRUE IF COMMENT IS MANDATORY OTHERWISE FALSE.
        public Boolean isCommentRequired;
        
        public ManualActivityWrapper() {
            
            this.manualActivityType = '';
            this.listOfShowFields = new List<String>();
            this.sObjectLabel = '';
            this.sObjectApiName = '';
            this.sObjectKeyPrefix = '';
            this.sObjectSearchField = '';
			this.sObjectSearchFieldLabel = '';
            this.isSobjectRequired = FALSE;
            this.isCommentRequired = FALSE;
        }
    }
    
    /**
        @ PURPOSE : WRAPS THE DETAILS OF THE TIME TRACKER RECORD.
    */
    public class TimeTrackerWrapper {
        
        // HOLDS THE TRACKED TIME [ 00:10:27 ].
        public String strTrackedTime;
        
        // HOLDS THE TRACKED DURATION [ 627 ]
        public String strTrackedDuration;
        
        // HOLDS THE ACTIVITY DATE TIME [ 06/18/2018 02:35 PM ]
        public String strActivityDateTime;
        
        // HOLDS THE TEXT1 VALUE OF THE MANUAL SETTING [ BREAK, EMAIL, ETC ].
        public String strActivitySubType;
        
        // HOLDS THE ID OF THE RECORD.
        public String strObjectId;
        
        // HOLDS THE COMMENTS OF TIME TRACKER RECORD.
        public String strComments;
        
        // HOLDS THE LIST OF MANUAL LINE ITEMS WHICH CARRY THE ACTIVE AND INACTIVE TIME STAMPS.
        public List<ManualLineItem__c> listOfManualLineItems;
        
        public TimeTrackerWrapper() {
            
            this.strTrackedTime = '';
            this.strTrackedDuration = '';
            this.strActivityDateTime = '';
            this.strActivitySubType = '';
            this.strObjectId = '';
            this.strComments = '';
            this.listOfManualLineItems = new List<ManualLineItem__c>();
        }
    }
}