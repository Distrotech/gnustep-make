#
#   Instance/java-tool.make
#
#   Instance makefile rules to build Java command-line tools.
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Why using Java if you can use Objective-C ...
# Anyway if you really want it, here we go.

#
# The name of the tools is in the JAVA_TOOL_NAME variable.
# The main class (the one implementing main) is in the
# xxx_PRINCIPAL_CLASS variable.
#

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

.PHONY: internal-java_tool-all \
        internal-java_tool-clean \
        internal-java_tool-distclean \
        internal-java_tool-install \
        internal-java_tool-uninstall \
        _FORCE

# This is the directory where the tools get installed. If you don't specify a
# directory they will get installed in $(GNUSTEP_LOCAL_ROOT)/Tools/.
ifeq ($(JAVA_TOOL_INSTALLATION_DIR),)
JAVA_TOOL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)
endif

GNUSTEP_SHARED_JAVA_INSTALLATION_DIR = $(JAVA_TOOL_INSTALLATION_DIR)/Java
include $(GNUSTEP_MAKEFILES)/Instance/Shared/java.make

internal-java_tool-all:: before-$(GNUSTEP_INSTANCE)-all \
                           shared-instance-java-all \
                           after-$(GNUSTEP_INSTANCE)-all

internal-java_tool-install:: shared-instance-java-install \
                        $(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE)

ifeq ($(PRINCIPAL_CLASS),)
  $(warning You must specify PRINCIPAL_CLASS)
  # But then, we are good, and try guessing
  PRINCIPAL_CLASS = $(word 1 $(JAVA_OBJ_FILES))
endif

# Remove an eventual extension (.class or .java) from PRINCIPAL_CLASS;
# only take the first word of it
NORMALIZED_PRINCIPAL_CLASS = $(basename $(word 1 $(PRINCIPAL_CLASS)))

# Escape '/' so it can be passes to sed
ESCAPED_PRINCIPAL_CLASS = $(subst /,\/,$(PRINCIPAL_CLASS))

# Always rebuild this because if the PRINCIPAL_CLASS changes...
$(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE): _FORCE
	sed -e 's/JAVA_OBJ_FILE/$(ESCAPED_PRINCIPAL_CLASS)/g' \
	    $(GNUSTEP_MAKEFILES)/java-executable.template \
	    > $(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE); \
	chmod a+x $(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE);
ifneq ($(CHOWN_TO),)
	$(CHOWN) $(CHOWN_TO) \
	         $(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE)
endif

_FORCE::


internal-java_tool-uninstall:: shared-instance-java-uninstall
	rm -f $(JAVA_TOOL_INSTALLATION_DIR)/$(GNUSTEP_INSTANCE)

internal-java_tool-clean:: shared-instance-java-clean

internal-java_tool-distclean::

## Local variables:
## mode: makefile
## End:
