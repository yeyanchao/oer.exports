"""
Initialize RhaptosPrint Product

Author: Ed Woodward and J. Cameron Cooper
Copyright (C) 2009 Rice University. All Rights Reserved.

This software is subject to the provisions of the GNU Lesser General
Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
"""

import sys
from Products.CMFCore import utils
import RhaptosPrintTool

from config import GLOBALS, PROJECTNAME

this_module = sys.modules[ __name__ ]
tools = ( RhaptosPrintTool.RhaptosPrintTool,)

def initialize(context):
    utils.ToolInit('Print Tool',
                    tools = tools,
                    icon='tool.gif' 
                    ).initialize( context )