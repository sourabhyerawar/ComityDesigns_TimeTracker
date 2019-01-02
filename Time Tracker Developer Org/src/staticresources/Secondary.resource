class SecondaryTab {
    constructor(result) {
        this.tabId = result && result.id ? result.id : null;
        this.objectId = result && result.objectId ? result.objectId : null;
        this.activeTimestamps = [];
        this.inActiveTimestamps = [];
        this.active = false;
        this.action = null;
        this.info = null;
        this.newRecordDocumentIds = [];
    }

    getAction(callback) {
        if(!this.action && !this.objectId ){
            sforce.console.getTabLink(sforce.console.TabLink.TAB_ONLY, this.tabId, (result) => {
                if(!result.success) return;
                const typeFieldName = consoleState.Settings.Namespace ? consoleState.Settings.Namespace + '__' + 'Type__c' : 'Type__c';
                const typeObj = {};
                typeObj[typeFieldName] = 'URLPattern';
                const urls = _.filter(consoleState.Settings.ConfigSettings, typeObj);
                const tabLink = decodeURIComponent(result.tabLink);
                const code1 = consoleState.Settings.Namespace ? consoleState.Settings.Namespace + '__' + 'Code1__c' : 'Code1__c';
                const text1 = consoleState.Settings.Namespace ? consoleState.Settings.Namespace + '__' + 'Text1__c' : 'Text1__c';
                urls.some((url) => {
                    if(tabLink.indexOf(url[code1]) >= 0) {
                        this.action = url[text1];
                        result.tabLink = tabLink;
                        this.info = JSON.stringify(result);
                        console.log('Action', this.action);
                        callback();
                        return true;
                    }
                });
            });
        }
        if(!this.action && this.objectId ) {

            sforce.console.getTabLink(sforce.console.TabLink.TAB_ONLY, this.tabId, (result) => {
                if(!result.success) return;
                const tabLink = decodeURIComponent(result.tabLink);
                if(tabLink.indexOf('_ui/core/email/author/EmailAuthor?') < 0 ){
                    console.log('consoleState', consoleState);
                    console.log('this.objectId.substring(0, 3)', this.objectId.substring(0, 3));
                    this.action = consoleState.Settings.ObjectSettings[this.objectId.substring(0, 3)] + ' Review';
                    callback();
                }
            });
        }
    }

    createEvent() {
        this.getAction(() => {
            const obj = {
                Duration__c: this.calculateDuration(),
                Object_Id__c: this.to18DigitId(this.objectId),
                Source__c: 'Console Toolkit',
                TabInfo__c: this.info,
                Action__c: this.action,
                Opening_Action__c: this.action,
                New_Record_Document_Id__c : this.newRecordDocumentIds ? this.newRecordDocumentIds.toString() : null,
                Opening_Activity_Time__c: this.activeTimestamps && this.activeTimestamps.length > 0 ? this.activeTimestamps[0] : null,
                Activity_Time__c: this.inActiveTimestamps && this.inActiveTimestamps.length > 0 ? this.inActiveTimestamps[this.inActiveTimestamps.length - 1] : null,
            }
            console.log('create Event Time Tracker Obj', obj);

            pushTimeTracker(obj);
        });
    }

    to18DigitId(id) {
        if (!id || id.length != 15) return id;

        let s = "";
        for (let i = 0; i < 3; i++) {
            let f = 0;
            for (let j = 0; j < 5; j++) {
                let c = id.charAt(i * 5 + j);
                if (c >= "A" && c <= "Z") f += 1 << j;
            }
            s += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(f);
        }
        return id + s;
    }

    calculateDuration() {
        let duration = 0;
        console.log('this.activeTimestamps', this.activeTimestamps);
        console.log('this.inActiveTimestamps', this.inActiveTimestamps);
        if (this.activeTimestamps.length == 0) return duration;

        // If the activeTimestamps array length is less than 1 of the inActiveTimestamps array length
        if (this.activeTimestamps.length - 1 == this.inActiveTimestamps.length) this.inActiveTimestamps.push(_.now());

        // Loop thru the activeTimestamps and inActiveTumestamps to calculate the duration.
        this.activeTimestamps.map((startTime, i) => {
            const endTime = this.inActiveTimestamps[i];
            duration += (endTime - startTime);
        });

        console.log('Duration in seconds', duration * 0.001);
        return duration * 0.001;
    }

    startTimer() {
        this.activeTimestamps.push(_.now());
    }

    stopTimer() {
        this.inActiveTimestamps.push(_.now());
    }
}
