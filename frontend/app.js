const express = require("express");
const app = express();
const STATIC_FILE_DIRECTORY = "/dist";

// the static content directory
app.use(express.static(__dirname + STATIC_FILE_DIRECTORY));

app.get("*", (req, res) => {
  // all request to index.html
  res.sendFile(__dirname + STATIC_FILE_DIRECTORY + "/index.html");
});

module.exports = app;
