// In functions/.eslintrc.js

module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  parserOptions: {
    // ⭐️ FIXES: "Parsing error: Unexpected token"
    ecmaVersion: 2020,
  },
  rules: {
    "quotes": ["error", "double"],
    // ⭐️ FIXES: "Expected linebreaks to be 'LF' but found 'CRLF'"
    "linebreak-style": 0,
  },
};