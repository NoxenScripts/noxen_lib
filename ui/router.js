window.NUIRouter = {
    listeners: {},
    
    on(type, callback) {
        if (!this.listeners[type]) {
            this.listeners[type] = [];
        }
        this.listeners[type].push(callback);
    },
    
    emit(type, payload) {
        if (this.listeners[type]) {
            this.listeners[type].forEach(callback => callback(payload));
        }
    }
};

window.addEventListener('message', (event) => {
    const { type, payload } = event.data;
    if (type) {
        NUIRouter.emit(type, payload);
    }
});

