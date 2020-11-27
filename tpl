#!/usr/bin/env python


import argparse
import glob
import yaml
import os
from jinja2 import Template
import readline
import subprocess 
CONFIG_DIR = os.path.expanduser("~/.tpl/data/configs")
TEMPLATE_DIR = os.path.expanduser("~/.tpl/data/templates")

## Parser Config
parser = argparse.ArgumentParser()
subparser = parser.add_subparsers(dest='action')
parser_new = subparser.add_parser('new', help='create new thing')
parser_new.add_argument('template', metavar='template', type=str, nargs=1, help='the template to create')
parser_list = subparser.add_parser('list', help='list templates')

def apply_config(config_name):
    config = get_configs(config_name)[0]
    config_vars = {}

    # loop through all the variables and figure out what to do with them
    # TODO : pass var overrides in from command line -e var=sdf
    for var in config['vars']:
        if var['ask']:
            line = input("{}({}):".format( var['description'], var['default']))
            if line == "":
                config_vars[ var['name'] ] = var['default']
            else:
                config_vars[ var['name'] ] = line.strip()
        else:
            config_vars[ var['name'] ] = var['default']

    # print(config['vars'])
    # process all the directives in the steps section serialy in order
    for directives in config['steps']:
        dtype = directives['type']
        dname = directives['name']

        if "when" in directives:
            when_value = Template(directives['when']).render( **config_vars )  == "True" 
            # print( "when:", when_value , type(when_value) , when_value == False)
            # if this is False, then skip this directive
            if when_value == False:
                continue

        if dtype == 'directory':
            directory = Template(directives['directory']).render( **config_vars) 
            if not os.path.exists(directory):
                print("Creating Directory:{}".format(directory))
                os.mkdir(directory)
        elif dtype == 'template':
            file_name = Template(directives['file']).render( **config_vars )  
            print("Creating file:{}".format(file_name))
            template = Template(directives['template']).render( **config_vars) 
            template_path = "{}/{}".format(TEMPLATE_DIR, template)
            rendered_content = Template( open(template_path).read()).render( **config_vars )
            with open(file_name,"w") as f:
                f.write(rendered_content)
        elif dtype == 'sh':
            command = Template(directives['command']).render( **config_vars )  
            print("Running:", command )
            output = subprocess.check_output(command, shell=True, text=True)
            output = output.strip()
            if "register" in directives:
                config_vars[ directives['register'].strip() ] = output

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
