const express = require('express');
const cors = require('cors');
const path = require('path');
const fetch = require('node-fetch');

const app = express();
const PORT = 3001;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static(path.join(__dirname)));

// Proxy endpoint for Jina Reader
app.post('/api/jina/extract', async (req, res) => {
    const { url } = req.body;
    
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }

    try {
        
        // Call Jina Reader API
        const jinaUrl = `https://r.jina.ai/${url}`;
        const response = await fetch(jinaUrl, {
            method: 'GET',
            headers: {
                'Accept': 'text/plain',
                'X-Return-Format': 'markdown'
            }
        });

        if (!response.ok) {
            throw new Error(`Jina API error: ${response.status} ${response.statusText}`);
        }

        const markdown = await response.text();
        res.json({ success: true, content: markdown });
        
    } catch (error) {
        console.error('Jina Reader proxy error:', error);
        res.status(500).json({ 
            error: 'Failed to extract article', 
            details: error.message 
        });
    }
});

// Alternative: Handle hash-based routing for SPAs
app.post('/api/jina/extract-spa', async (req, res) => {
    const { url } = req.body;
    
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }

    try {
        
        // Use POST method for SPAs with hash routing
        const response = await fetch('https://r.jina.ai/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'text/plain'
            },
            body: `url=${encodeURIComponent(url)}`
        });

        if (!response.ok) {
            throw new Error(`Jina API error: ${response.status} ${response.statusText}`);
        }

        const markdown = await response.text();
        res.json({ success: true, content: markdown });
        
    } catch (error) {
        console.error('Jina Reader SPA proxy error:', error);
        res.status(500).json({ 
            error: 'Failed to extract SPA content', 
            details: error.message 
        });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', service: 'QED Jina Reader Proxy' });
});

app.listen(PORT, () => {
    console.log(`QED Jina Reader proxy server running at http://localhost:${PORT}`);
    console.log(`Open http://localhost:${PORT}/qed-evaluator-prototype.html to use the evaluator`);
});