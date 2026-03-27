const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello from Node.js inside Docker! 🚀");
});

app.get("/health", (req, res) => {
  res.status(500).json({ status: "KO", timestamp: Date.now() });
});

app.listen(3000, () => console.log("Server running on port 3000"));
