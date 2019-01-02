class ListNavigationEvent {
    constructor({ navId = null, label = null, url = null } = {}) {
        this.navId = navId;
        this.documentId = this.getUUID();
        this.label = label;
        this.url = url;
        this.action = label + ' List View';
        this.endAction = this.action + ' End';
    }

    startEvent() {
        const obj = {
            Source__c: 'Console Toolkit',
            Action__c: this.action,
            Activity_Time__c: _.now(),
            DocumentId__c: this.documentId
        }
        console.log('create Event Time Tracker Obj', obj);
        return obj;
    }

    endEvent() {
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


  getUUID() {
    var d = (new Date()).getTime();

    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = (d + Math.random()*16)%16 | 0;
      d = Math.floor(d/16);
      return (c=='x' ? r : (r&0x3|0x8)).toString(16);
    });

    return uuid;
  }
}

function endListNavigation() {
    if(!consoleState.navigation) return;

    pushTimeTracker(consoleState.navigation.endEvent());

    consoleState.navigation = null;
}

function trackListNavigation() {
    if(consoleState.navigation) {
        endListNavigation();
    }
    if(consoleState.primaryTabs.length != 0) return;

    sforce.console.getSelectedNavigationTab(getSelectedNavigationTabHandler);
}

function getSelectedNavigationTabHandler(result) {
    if (!result.success) return;

    consoleState.navigation = new ListNavigationEvent({ navId: result.navigationTabId, url: result.listViewUrl, label: result.label });

    pushTimeTracker(consoleState.navigation.startEvent());
}
