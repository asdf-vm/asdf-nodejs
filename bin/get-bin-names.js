#!/usr/bin/env node

var fs = require('fs');

if (process.env['npm_config_global'] != 'true') {
  process.exit();
}

var package_json_path=process.env['PWD'] + '/package.json';
var node_modules_occurance = (package_json_path.match(/node_modules/g) || []).length;

// create shims only for globally installed pkg
if (node_modules_occurance > 1) {
  process.exit();
}

var package_json = JSON.parse(fs.readFileSync(package_json_path, 'utf8'));

if (!('bin' in package_json)) {
  process.exit();
}

if (typeof package_json['bin'] === "object") {
  var bin_names = Object.keys(package_json['bin']);
  console.log(bin_names.join(" "));
}
else
{
  console.log(package_json["name"]);
}
