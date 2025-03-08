(() => {
    const darkThemes = ['ayu', 'navy', 'coal'];
    const lightThemes = ['light', 'rust'];

    const classList = document.getElementsByTagName('html')[0].classList;

    let lastThemeWasLight = true;
    for (const cssClass of classList) {
        if (darkThemes.includes(cssClass)) {
            lastThemeWasLight = false;
            break;
        }
    }

    // Enhanced mermaid configuration with better defaults
    const theme = lastThemeWasLight ? 'neutral' : 'dark';
    mermaid.initialize({ 
        startOnLoad: true, 
        theme,
        flowchart: {
            useMaxWidth: true,
            htmlLabels: true,
            curve: 'basis'
        },
        themeVariables: {
            primaryColor: '#5D8AA8',
            primaryTextColor: '#fff',
            primaryBorderColor: '#1F456E',
            lineColor: '#1F456E',
            secondaryColor: '#006400',
            tertiaryColor: '#fff'
        },
        securityLevel: 'loose'
    });

    // Simplest way to make mermaid re-render the diagrams in the new theme is via refreshing the page
    for (const darkTheme of darkThemes) {
        const element = document.getElementById(darkTheme);
        if (element) {
            element.addEventListener('click', () => {
                if (lastThemeWasLight) {
                    window.location.reload();
                }
            });
        }
    }

    for (const lightTheme of lightThemes) {
        const element = document.getElementById(lightTheme);
        if (element) {
            element.addEventListener('click', () => {
                if (!lastThemeWasLight) {
                    window.location.reload();
                }
            });
        }
    }
})();
