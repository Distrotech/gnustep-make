#
#   application.make
#
#   Makefile rules to build GNUstep-based applications.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
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

#
# Include in the common makefile rules
#
include $(GNUSTEP_ROOT)/Makefiles/rules.make

LINK_CMD = $(CC) $(ALL_CFLAGS) $@$(OEXT) -o $@ $(ALL_LDFLAGS)

#
# The name of the library is in the LIBRARY_NAME variable.
#

APP_DIR_NAME := $(foreach app,$(APP_NAME),$(app).app)
APP_FILE = $(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(APP_NAME)$(EXEEXT)

#
# Internal targets
#

stamp-% : $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$(APP_FILE) \
		$(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_GUI_LIBS)
	touch $@

#
# Compilation targets
#
internal-all:: $(APP_DIR_NAME)

internal-app-all:: build-app-dir build-app

build-app-dir::
	$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(APP_DIR_NAME) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_CPU) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR) \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)

build-app:: stamp-$(APP_NAME)

#
# Cleaning targets
#
internal-clean::
	for f in $(APP_DIR_NAME); do \
	  rm -rf $$f ; \
	done

internal-distclean:: clean
