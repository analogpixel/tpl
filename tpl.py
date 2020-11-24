#!/usr/bin/env python

CONFIG_DIR = "./data/configs"
TEMPLATE_DIR = "./data/templates"

import argparse
import glob
import yaml
from jinja2 import Template

## Parser Config
parser = argparse.ArgumentParser()
subparser = parser.add_subparsers(dest='action')
parser_new = subparser.add_parser('new', help='create new thing')
parser_new.add_argument('template', metavar='template', type=str, nargs=1, help='the template to create')
parser_list = subparser.add_parser('list', help='list templates')

def apply_config(config_name):
    config = get_configs(config_name)[0]
    print(config['vars'])
    for directives in config['files']:
        file_name = Template(directives['file']).render( **config['vars'])  )

def get_configs(file_name=None):
    """
    return a list of all the config
    """
    ret = []
    if file_name:
        search_string = "{}/{}.yml".format(CONFIG_DIR, file_name)
    else:
        search_string = "{}/*.yml".format(CONFIG_DIR)

    for fileList in glob.glob( search_string ):
        d = yaml.load( open(fileList), Loader=yaml.FullLoader )
        ret.append(d)
    return ret


args = parser.parse_args()

if args.action == "new":
    apply_config(args.template[0])

elif args.action == "list":
    print( "\n".join([x['name'] for x in get_configs()]) )


#print(args.action)
