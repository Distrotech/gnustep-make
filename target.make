#
#   target.make
#
#   Determine the compilation target.
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

# Run config.guess to guess the host

GNUSTEP_HOST := $(shell $(CONFIG_GUESS_SCRIPT))
GNUSTEP_HOST_CPU := $(shell $(CONFIG_CPU_SCRIPT) $(GNUSTEP_HOST))
GNUSTEP_HOST_VENDOR := $(shell $(CONFIG_VENDOR_SCRIPT) $(GNUSTEP_HOST))
GNUSTEP_HOST_OS := $(shell $(CONFIG_OS_SCRIPT) $(GNUSTEP_HOST))

#
# The user can specify a `target' variable when running make
#

ifeq ($(strip $(target)),)

# The host is the default target
GNUSTEP_TARGET := $(GNUSTEP_HOST)
GNUSTEP_TARGET_CPU := $(GNUSTEP_HOST_CPU)
GNUSTEP_TARGET_VENDOR := $(GNUSTEP_HOST_VENDOR)
GNUSTEP_TARGET_OS := $(GNUSTEP_HOST_OS)

else

#
# Parse the target variable
#

GNUSTEP_TARGET := $(shell $(CONFIG_SUB_SCRIPT) $(target))
GNUSTEP_TARGET_CPU := $(shell $(CONFIG_CPU_SCRIPT) $(GNUSTEP_TARGET))
GNUSTEP_TARGET_VENDOR := $(shell $(CONFIG_VENDOR_SCRIPT) $(GNUSTEP_TARGET))
GNUSTEP_TARGET_OS := $(shell $(CONFIG_OS_SCRIPT) $(GNUSTEP_TARGET))

endif

#
# Clean up the host and target names
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean.make

#
# Host and target specific settings
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
X_INCLUDES := $(X_INCLUDES)/X11
endif

#
# Target specific libraries
#
ifeq ($(GNUSTEP_TARGET_OS),linux-gnu)
TARGET_SYSTEM_LIBS := -lpcthread -ldl -lm
endif
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
TARGET_SYSTEM_LIBS := -lsocket -lnsl -ldl -lm
endif

#
# Specific settings for building shared libraries
#
HAVE_SHARED_LIBS = no
SHARED_LIB_LINK_CMD =
SHARED_CFLAGS =
SHARE_LIBEXT =

#
# OpenStep 4.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep4)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        libtool -dynamic -o $@ \
                /NextLibrary/Frameworks/System.framework/System \
                $(GNUSTEP_LIBRARIES)/libobjc$(SHARED_LIBEXT) \
                $(GNUSTEP_LIBRARIES)/libgcc$(SHARED_LIBEXT) $^ \
                >/dev/null

SHARED_CFLAGS     += -dynamic
SHARED_LIBEXT   = .a
endif

#
# Linux ELF
#
ifeq ($(GNUSTEP_TARGET_OS), linux-gnu)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -W,l,soname=$(SHARED_LIBRARY_FILE) \
           -o $(GNUSTEP_OBJ_DIR)/$(SHARED_LIBRARY_FILE) $^ ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(SHARED_LIBRARY_NAME); \
          $(LN_S) $(SHARED_LIBRARY_FILE) $(SHARED_LIBRARY_NAME))

SHARED_CFLAGS     += -fPIC
SHARED_LIBEXT   = .so
endif


#
# Solaris
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -G -o $(SHARED_LIBRARY_FILE) $^ ;\
        mv $(SHARED_LIBRARY_FILE) $(GNUSTEP_OBJ_DIR) ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(SHARED_LIBRARY_NAME); \
          $(LN_S) $(SHARED_LIBRARY_FILE) $(SHARED_LIBRARY_NAME))

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so
endif
