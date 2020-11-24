#!/usr/bin/env python

CONFIG_DIR = "./data/configs"
TEMPLATE_DIR = "./data/templates"

import argparse
import glob
import yaml
import os
from jinja2 import Template
import readline

## Parser Config
parser = argparse.ArgumentParser()
subparser = parser.add_subparsers(dest='action')
parser_new = subparser.add_parser('new', help='create new thing')
parser_new.add_argument('template', metavar='template', type=str, nargs=1, help='the template to create')
parser_list = subparser.add_parser('list', help='list templates')

def apply_config(config_name):
    config = get_configs(config_name)[0]

    # loop through all the variables we need to ask about
    for ask in config['ask']:
        if ask['name'] in config['vars']:
            line = input("{}({}):".format( ask['description'], config['vars'][ask['name']] ))
            if line != "":
                config['vars'][ ask['name'] ] = line.strip()
        else:
            line = input("{}():".format( ask['description'] ))
            if line == "":
                print("No input given, and no default; exiting.")
                quit()

    # print(config['vars'])
    for directives in config['files']:
        file_name = Template(directives['file']).render( **config['vars'])  
        dtype = directives['type']
        dname = directives['name']

        if "when" in directives:
            when_value = Template(directives['when']).render( **config['vars'])  == "True" 
            # print( "when:", when_value , type(when_value) , when_value == False)
            # if this is False, then skip this directive
            if when_value == False:
                continue

        if dtype == 'directory':
            if not os.path.exists(file_name):
                os.mkdir(file_name)
        elif dtype == 'template':
            template = Template(directives['template']).render( **config['vars']) 
            template_path = "{}/{}".format(TEMPLATE_DIR, template)
            rendered_content = Template( open(template_path).read()).render( **config['vars'])
            with open(file_name,"w") as f:
                f.write(rendered_content)


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
