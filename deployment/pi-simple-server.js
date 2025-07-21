const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS for development
app.use(cors());

// Serve static files from dist/public
const staticPath = path.join(process.cwd(), 'dist', 'public');
app.use(express.static(staticPath));

// Serve index.html for all routes (SPA routing)
app.get('*', (req, res) => {
  res.sendFile(path.join(staticPath, 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Kiosk server running on http://localhost:${PORT}`);
  console.log(`📁 Serving static files from: ${staticPath}`);
});