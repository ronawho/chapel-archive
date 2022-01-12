# -*- coding: utf-8 -*-
#
# LLVM documentation build configuration file.
#
# This file is execfile()d with the current directory set to its containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.
from __future__ import print_function

import sys, os, re
from datetime import date

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#sys.path.insert(0, os.path.abspath('.'))

# -- General configuration -----------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be extensions
# coming with Sphinx (named 'sphinx.ext.*') or your custom ones.
extensions = ['sphinx.ext.intersphinx', 'sphinx.ext.todo']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix of source filenames.
source_suffix = {
    '.rst': 'restructuredtext',
}

try:
  import recommonmark
except ImportError:
  # manpages do not use any .md sources
  if not tags.has('builder-man'):
    raise
else:
  import sphinx
  if sphinx.version_info >= (3, 0):
    # This requires 0.5 or later.
    extensions.append('recommonmark')
  else:
    source_parsers = {'.md': 'recommonmark.parser.CommonMarkParser'}
  source_suffix['.md'] = 'markdown'

# The encoding of source files.
#source_encoding = 'utf-8-sig'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'LLVM'
copyright = u'2003-%d, LLVM Project' % date.today().year

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short version.
version = '12'
# The full version, including alpha/beta/rc tags.
release = '12'

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#language = None

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
today_fmt = '%Y-%m-%d'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ['_build']

# The reST default role (used for this markup: `text`) to use for all documents.
#default_role = None

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
show_authors = True

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'friendly'

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []


# -- Options for HTML output ---------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'llvm-theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = { "nosidebar": False }

# Add any paths that contain custom themes here, relative to this directory.
html_theme_path = ["_themes"]

# The name for this set of Sphinx documents.  If None, it defaults to
# "<project> v<release> documentation".
#html_title = None

# A shorter title for the navigation bar.  Default is the same as html_title.
#html_short_title = None

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
#html_logo = None

# The name of an image file (within the static path) to use as favicon of the
# docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
#html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
html_last_updated_fmt = '%Y-%m-%d'

# If true, SmartyPants will be used to convert quotes and dashes to
# typographically correct entities.
#html_use_smartypants = True

# Custom sidebar templates, maps document names to template names.

html_sidebars = {
    '**': [
        'indexsidebar.html',
        'sourcelink.html',
        'searchbox.html',
    ]
}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = None

# Output file base name for HTML help builder.
htmlhelp_basename = 'LLVMdoc'


# -- Options for LaTeX output --------------------------------------------------

latex_elements = {
# The paper size ('letterpaper' or 'a4paper').
#'papersize': 'letterpaper',

# The font size ('10pt', '11pt' or '12pt').
#'pointsize': '10pt',

# Additional stuff for the LaTeX preamble.
#'preamble': '',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title, author, documentclass [howto/manual]).
latex_documents = [
  ('index', 'LLVM.tex', u'LLVM Documentation',
   u'LLVM project', 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#latex_use_parts = False

# If true, show page references after internal links.
#latex_show_pagerefs = False

# If true, show URL addresses after external links.
#latex_show_urls = False

# Documents to append as an appendix to all manuals.
#latex_appendices = []

# If false, no module index is generated.
#latex_domain_indices = True


# -- Options for manual page output --------------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = []

# Automatically derive the list of man pages from the contents of the command
# guide subdirectory.
basedir = os.path.dirname(__file__)
man_page_authors = "Maintained by the LLVM Team (https://llvm.org/)."
command_guide_subpath = 'CommandGuide'
command_guide_path = os.path.join(basedir, command_guide_subpath)


def process_md(name):
    file_subpath = os.path.join(command_guide_subpath, name)
    with open(os.path.join(command_guide_path, name)) as f:
        title = f.readline().rstrip('\n')

        m = re.match(r'^# (\S+) - (.+)$', title)
        if m is None:
            print("error: invalid title in %r "
                  "(expected '# <name> - <description>')" % file_subpath,
                  file=sys.stderr)
        else:
            man_pages.append((file_subpath.replace('.md',''), m.group(1),
                              m.group(2), man_page_authors, 1))


def process_rst(name):
    file_subpath = os.path.join(command_guide_subpath, name)
    with open(os.path.join(command_guide_path, name)) as f:
        title = f.readline().rstrip('\n')
        header = f.readline().rstrip('\n')

        if len(header) != len(title):
            print('error: invalid header in %r (does not match title)' %
                  file_subpath, file=sys.stderr)
        if ' - ' not in title:
            print("error: invalid title in %r "
                  "(expected '<name> - <description>')" % file_subpath,
                  file=sys.stderr)
        # Split the name out of the title.
        name,description = title.split(' - ', 1)
        man_pages.append((file_subpath.replace('.rst',''), name,
                          description, man_page_authors, 1))


for name in os.listdir(command_guide_path):
    # Process Markdown files
    if name.endswith('.md'):
        process_md(name)
    # Process ReST files apart from the index page.
    elif name.endswith('.rst') and name != 'index.rst':
        process_rst(name)

# If true, show URL addresses after external links.
#man_show_urls = False

# FIXME: Define intersphinx configuration.
intersphinx_mapping = {}

# Pygment lexer are sometimes out of date (when parsing LLVM for example) or
# wrong. Suppress the warning so the build doesn't abort.
suppress_warnings = [ 'misc.highlighting_failure' ]

# Direct html-ified man pages to llvm.org
manpages_url = 'https://llvm.org/docs/CommandGuide/{page}.html'
