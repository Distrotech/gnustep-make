#   -*-makefile-*-
#   Instance/subproject.make
#
#   Instance Makefile rules to build subprojects in GNUstep projects.
#
#   Copyright (C) 1998, 2001 Free Software Foundation, Inc.
#
#   Author:  Jonathan Gapen <jagapen@whitewater.chem.wisc.edu>
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

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

.PHONY: internal-subproject-all_       \
        internal-subproject-install_   \
        internal-subproject-uninstall_

#
# Compilation targets
#
internal-subproject-all_:: $(GNUSTEP_OBJ_DIR) \
                           $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT)

ifeq ($(BUILD_DLL),yes)

DLL_DEF_FILES = $(SUBPROJECT_DEF_FILES) $($(GNUSTEP_INSTANCE)_DLL_DEF)

ifneq ($(strip $(DLL_DEF_FILES)),)
DLL_DEF_INP = $(GNUSTEP_INSTANCE).inp

$(DLL_DEF_INP): $(DLL_DEF_FILES)
	cat $< > $@

DLL_DEF_FLAG = --input-def $(DLL_DEF_INP)
endif

internal-subproject-all_:: subproject.def

subproject.def: $(OBJ_FILES_TO_LINK) $(DLL_DEF)
	$(DLLTOOL) $(DLL_DEF_FLAG) --output-def subproject.def $(OBJ_FILES_TO_LINK)

endif

# We need to depend on SUBPROJECT_OBJ_FILES to account for sub-subprojects.
$(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT): $(OBJ_FILES_TO_LINK)
	$(ECHO_LINKING)$(OBJ_MERGE_CMD)$(END_ECHO)

#
# Build-header target for framework subprojects
#
# If we are called with OWNING_PROJECT_HEADER_DIR which is not empty,
# we need to copy our headers into that directory during the
# build-headers stage, and to disable installation/uninstallation of
# headers.
#
ifneq ($(OWNING_PROJECT_HEADER_DIR),)
.PHONY: internal-subproject-build-headers

HEADER_FILES = $($(GNUSTEP_INSTANCE)_HEADER_FILES)
OWNING_PROJECT_HEADER_FILES = $(patsubst %.h,$(OWNING_PROJECT_HEADER_DIR)/%.h,$(HEADER_FILES))

internal-subproject-build-headers:: $(OWNING_PROJECT_HEADER_FILES)

# We need to build the OWNING_PROJECT_HEADER_DIR directory here
# because this rule could be executed before the top-level framework
# has built his dirs
$(OWNING_PROJECT_HEADER_FILES):: $(HEADER_FILES) $(OWNING_PROJECT_HEADER_DIR)
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) ./$$file $(OWNING_PROJECT_HEADER_DIR)/$$file ; \
	  fi; \
	done
endif # we got HEADER_FILES

$(OWNING_PROJECT_HEADER_DIR):
	$(MKDIRS) $@

# End FRAMEWORK code
else
# Start no FRAMEWORK code

#
# Installation targets - we only need to install headers and only 
# if this is not in a framework
#

include $(GNUSTEP_MAKEFILES)/Instance/Shared/headers.make

internal-subproject-install_:: shared-instance-headers-install

internal-subproject-uninstall_:: shared-instance-headers-uninstall

endif # no FRAMEWORK


#
# A subproject can have resources, which it stores into the
# Resources/Subproject directory.  If you want your subproject
# to have resources, you need to put
# xxx_HAS_RESOURCE_BUNDLE = yes
# in your GNUmakefile.  The project which owns us can then
# copy recursively this directory into its own Resources directory
# (that is done automatically if the project uses
# Instance/Shared/bundle.make to manage its own resource bundle)
#
ifeq ($($(GNUSTEP_INSTANCE)_HAS_RESOURCE_BUNDLE), yes)

GNUSTEP_SHARED_BUNDLE_RESOURCE_PATH = Resources/Subproject
include $(GNUSTEP_MAKEFILES)/Instance/Shared/bundle.make

# Only build, not install
internal-subproject-all_:: shared-instance-bundle-all

endif

include $(GNUSTEP_MAKEFILES)/Instance/Shared/strings.make
