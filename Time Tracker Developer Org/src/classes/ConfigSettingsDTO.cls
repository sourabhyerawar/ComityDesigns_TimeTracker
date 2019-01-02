/**
    @ Purpose : Wraps the data of the Config Settings Table Configuration.
//*/

public class ConfigSettingsDTO {
    
    public String apiName;
    
    public String labelName;
    
    public String description;
    
    public Boolean isBoolean;
    
    public String width;
    
    public Boolean used;
    
    public Boolean display;
    
    public Integer displayOrder;
    
    public ConfigSettingsDTO() {
        
        this.apiName = '';
        this.labelName = '';
        this.description = '';
        this.isBoolean = FALSE;
        this.width = '';
        this.used = FALSE;
        this.display = FALSE;
        this.displayOrder = 0;
    }
    
    public ConfigSettingsDTO( Config_Settings_Table_Configuration__c ObjConfig ) {
        
        this();
        if( ObjConfig != NULL ) {
            this.apiName = ObjConfig.API_Name__c;
            this.labelName = ObjConfig.Label__c;
            this.description = ObjConfig.Description__c;
            this.isBoolean = ObjConfig.Checkbox_Field__c;
            this.width = ObjConfig.Width__c;
            this.used = ObjConfig.Used__c;
            this.display = ObjConfig.Display__c;
            this.displayOrder = ( Integer ) ObjConfig.Column_Number__c;
        }
    } 
}