(() => {
    const container = document.getElementById('progress-bar-container');
    const textElement = container.querySelector('.progress-bar-text');
    const fillElement = container.querySelector('.progress-bar-fill');
    
    let currentAnimation = null;
    let currentCallback = null;
    
    function show(data) {
        if (currentAnimation) {
            clearInterval(currentAnimation);
            currentAnimation = null;
        }
        
        textElement.textContent = data.text;
        fillElement.style.width = '0%';
        
        container.classList.add('visible');
        
        const startTime = Date.now();
        const duration = data.duration;
        
        currentAnimation = setInterval(() => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min((elapsed / duration) * 100, 100);
            
            fillElement.style.width = `${progress}%`;
            
            if (progress >= 100) {
                clearInterval(currentAnimation);
                currentAnimation = null;
                
                setTimeout(() => {
                    hide();
                    if (currentCallback) {
                        fetch(`https://${GetParentResourceName()}/progressComplete`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({})
                        });
                        currentCallback = null;
                    }
                }, 200);
            }
        }, 50);
        
        currentCallback = true;
    }
    
    function hide() {
        container.classList.remove('visible');
        fillElement.style.width = '0%';
    }
    
    function cancel() {
        if (currentAnimation) {
            clearInterval(currentAnimation);
            currentAnimation = null;
        }
        hide();
        if (currentCallback) {
            fetch(`https://${GetParentResourceName()}/progressCancelled`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            currentCallback = null;
        }
    }
    
    NUIRouter.on('progressBar:show', (payload) => {
        show(payload);
    });
    
    NUIRouter.on('progressBar:hide', () => {
        hide();
    });
    
    NUIRouter.on('progressBar:cancel', () => {
        cancel();
    });
})();

