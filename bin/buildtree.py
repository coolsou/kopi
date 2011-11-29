#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
A Script to build JavaScript dependency tree

@author     Brandon Wu
@version    0.1

"""

import re
import os
from optparse import OptionParser

class DepTree(object):

    RE_MODULE = re.compile(r'(kopi.module\([\'"]([a-z\.\_]+)[\'"]\)(?:\s*\.require\([\'"][a-z\.\_]+[\'"]\))*\s*\.define)', re.M)
    RE_REQUIRE = re.compile(r'\.require\([\'"]([a-z\.\_]+)[\'"]\)', re.M)

    SPROCKETS_HEADER = """// Generated by buildtree.py\n"""
    SPROCKETS_REQUIRE = "//= require %s\n"

    HTML_SCRIPT_TAG = '<script type="text/javascript" src="%s.js"></script>\n'

    def __init__(self, file, path, uri, extensions):
        self._file = file
        self._path = path
        self._uri = uri
        self._extensions = extensions
        self.name = None
        self.requires = []

    def build(self):
        print("read content from file: %s" % self._file)
        content = open(self._file, "r").read()
        match = self.RE_MODULE.search(content)
        if match:
            string, name = match.groups()
            self.name = name
            print("module name: %s" % self.name)
            requires = self.RE_REQUIRE.findall(string)
            print("found %s required modules: %s" % (len(requires), ", ".join(requires)))
            for module in requires:
                path = self.find_module_path(module)
                tree = DepTree(path, self._path, self._uri, self._extensions)
                tree.build()
                self.requires.append(tree)

    def find_module_path(self, module):
        modules = module.split(".")
        path = os.path.join(self._path, *modules[:-1])
        files = ["%s.%s" % (modules[-1], ext) for ext in self._extensions]
        for dir_name in os.listdir(path):
            for file_name in files:
                if dir_name == file_name:
                    modules[-1] = file_name
                    return os.path.join(self._path, *modules)
        raise ValueError("Module not found. %s" % module)

    def output(self, file, format):
        if format == 'sprockets':
            self.output_sprockets_manifest(file)
        elif format == "html":
            self.output_html_scripts(file)
        else:
            raise ValueError("Unknown output format: %s" % format)

    def uri(self):
        return os.path.join(self._uri, *self.name.split("."))

    def module_list(self, mod_list):
        for module in self.requires:
            module.module_list(mod_list)
            uri = module.uri()
            try:
                mod_list.index(uri)
            except ValueError:
                mod_list.append(uri)
        if self.name:
            uri = self.uri()
            try:
                mod_list.index(uri)
            except ValueError:
                mod_list.append(uri)

    def output_sprockets_manifest(self, output_file):
        mod_list = []
        self.module_list(mod_list)
        lines = [self.SPROCKETS_REQUIRE % line for line in mod_list]
        output_file = open(output_file, "w")
        output_file.writelines(self.SPROCKETS_HEADER)
        output_file.writelines(lines)
        output_file.close()
        print("manifest:\n%s" % ("\n".join(mod_list),))

    def output_html_scripts(self, output_file):
        mod_list = []
        self.module_list(mod_list)
        lines = [self.HTML_SCRIPT_TAG % line for line in mod_list]
        output_file = open(output_file, "w")
        output_file.writelines(lines)
        output_file.close()
        print("manifest:\n%s" % ("\n".join(mod_list),))

if __name__ == '__main__':
    p = OptionParser()
    p.add_option('--base-path', '-p')
    p.add_option('--base-uri', '-u', default='')
    p.add_option('--output-format', '-o', default='sprockets')
    p.add_option('--output-file', '-O')
    p.add_option('--ext-names', '-e', default='js,coffee')
    opts, args = p.parse_args()

    kwargs = {
        'path': opts.base_path,
        'uri': opts.base_uri,
        'extensions': opts.ext_names.split(','),
    }
    root = DepTree(None, **kwargs)
    for script in args:
        tree = DepTree(script, **kwargs)
        tree.build()
        root.requires.append(tree)
    root.output(opts.output_file, opts.output_format)
