class Chat {
    constructor({ chatKey = null} = {}) {
        this.chatKey = chatKey;
		this.objectId = null;
        this.action = 'Start Chat';
        this.endAction = 'End Chat';
        this.activeTimestamps = [];
        this.inActiveTimestamps = [];
    }

    createEvent() {
        const obj = {
            Duration__c: this.calculateDuration(),
            Object_Id__c: this.to18DigitId(this.objectId),
            Source__c: 'Console Toolkit',
            Action__c: this.endAction,
            Opening_Action__c: this.action,
            DocumentId__c: this.chatKey,
            Opening_Activity_Time__c: this.activeTimestamps && this.activeTimestamps.length > 0 ? this.activeTimestamps[0] : null,
            Activity_Time__c: this.inActiveTimestamps && this.inActiveTimestamps.length > 0 ? this.inActiveTimestamps[this.inActiveTimestamps.length - 1] : null
        }
        console.log('Create End Chat Time Tracker Obj', obj);
    	pushTimeTracker(obj);
        return obj;
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
}
