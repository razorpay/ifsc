// This file is generated from `bank.js.tpl` using constants
// from banknames.json. Run `make generate-constants` to update

module.exports = Object.freeze({ {{ range  .Value }}
  {{ . }}: '{{ . }}',{{ end }}
});
