class ChatEvent {
    constructor({ documentId = null, action = null, endAction = null } = {}) {
        this.documentId = documentId;
        this.action = action;
        this.endAction = endAction;
    }

    getStartEvent() {
        const obj = {
            Source__c: 'Console Toolkit',
            Action__c: this.action,
            Activity_Time__c: _.now(),
            DocumentId__c: this.documentId
        }
        console.log('create Event Time Tracker Obj', obj);
        return obj;
    }

    getEndEvent() {
        const obj = {
            Source__c: 'Console Toolkit',
            Action__c: this.endAction,
            Opening_Action__c: this.action,
            Activity_Time__c: _.now(),
            DocumentId__c: this.documentId
        }
        console.log('create Event Time Tracker Obj', obj);
        return obj;
    }
}