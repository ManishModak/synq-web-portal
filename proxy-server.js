const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 8086;

// Enable CORS for all routes
app.use(cors());

// Proxy to Dashboard API (port 3000)
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:3000',
  changeOrigin: true,
  onProxyReq: (proxyReq, req, res) => {
    // Add basic auth header if needed
    const auth = Buffer.from(':1234567899').toString('base64');
    proxyReq.setHeader('Authorization', `Basic ${auth}`);
  },
  onError: (err, req, res) => {
    console.error('Dashboard proxy error:', err.message);
    res.status(500).json({ error: 'Dashboard API unavailable' });
  }
}));

// Proxy to Metrics API (port 3001)
app.use('/metrics', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  onError: (err, req, res) => {
    console.error('Metrics proxy error:', err.message);
    res.status(500).json({ error: 'Metrics API unavailable' });
  }
}));

app.use('/health', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  onError: (err, req, res) => {
    console.error('Health proxy error:', err.message);
    res.status(500).json({ error: 'Health API unavailable' });
  }
}));

// Basic health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'Proxy server running',
    dashboard: 'http://localhost:3000 -> /api/*',
    metrics: 'http://localhost:3001 -> /metrics, /health'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 CORS Proxy server running on http://localhost:${PORT}`);
  console.log(`📊 Dashboard API: http://localhost:${PORT}/api/*`);
  console.log(`📈 Metrics API: http://localhost:${PORT}/metrics`);
  console.log(`❤️  Health Check: http://localhost:${PORT}/health`);
}); 