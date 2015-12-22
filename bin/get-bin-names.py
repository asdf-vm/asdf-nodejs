#/usr/bin/env python
import os, json;

if os.environ['npm_config_global'] == 'true':
    exit(0)

package_json_path=os.environ['PWD'] + '/package.json'

# create shims only for globally installed pkg
if package_json_path.count('node_modules') > 1:
    exit(0)

with open(package_json_path, 'r') as package_json_file:
	package_json = json.load(package_json_file)

if 'bin' in package_json:
    if isinstance(package_json['bin'], dict):
        bin_list = " ".join(package_json['bin'].keys())
        print(bin_list)
    else:
        print(package_json["name"])
