tpl is a tool to create projects based on a templated config, because I got sick of writing boilerplate code over
and over, and all the other tools I've found that do something like this seem huge and bloated.  

## Features
* templated configs
* user input for variables
* ability to set defaults for variables
* yaml config syntax
* create templated files using jinja2, directories, and run commands

## Installation 
```
git clone git@github.com:analogpixel/tpl.git ~/.tpl
ln -s ~/.tpl/tpl /usr/local/bin/tpl
```

## Usage
### list out available templates
```
tpl list  
```
### Apply a template
```
tpl new processing
```


