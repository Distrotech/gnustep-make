#
#   common.make
#
#   Set all of the common environment variables.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
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

SHELL = /bin/sh

# Default version
VERSION = 1.0.0

#
# Scripts to run for parsing canonical names
#
CONFIG_GUESS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/config.guess
CONFIG_SUB_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/config.sub
CONFIG_CPU_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/cpu.sh
CONFIG_VENDOR_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/vendor.sh
CONFIG_OS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/os.sh
CLEAN_CPU_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_cpu.sh
CLEAN_VENDOR_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_vendor.sh
CLEAN_OS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/clean_os.sh
WHICH_LIB_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/$(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)/which_lib
LD_LIB_PATH_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/ld_lib_path.sh
TRANSFORM_PATHS_SCRIPT = $(GNUSTEP_SYSTEM_ROOT)/Makefiles/transform_paths.sh

#
# Determine the compilation host and target
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/names.make

GNUSTEP_HOST_DIR = $(GNUSTEP_HOST_CPU)/$(GNUSTEP_HOST_OS)

GNUSTEP_TARGET_DIR = $(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)

#
# Get the config information
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/$(GNUSTEP_TARGET_DIR)/config.make

#
# Determine the core libraries
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/brain.make

#
# Determine target specific settings
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/target.make

#
# GNUSTEP_INSTALLATION_DIR is the directory where all the things go. If you
# don't specify it defaults to GNUSTEP_LOCAL_ROOT, unless GNUSTEP_LOCAL_ROOT
# is empty in which case it defaults to GNUSTEP_SYSTEM_ROOT
#
ifeq ($(GNUSTEP_INSTALLATION_DIR),)
  ifeq ($(GNUSTEP_LOCAL_ROOT),)
    GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_SYSTEM_ROOT)
  else
    GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)
  endif
endif

#
# Variables specifying the installation directory paths
#
GNUSTEP_APPS = $(GNUSTEP_INSTALLATION_DIR)/Apps
GNUSTEP_TOOLS = $(GNUSTEP_INSTALLATION_DIR)/Tools
GNUSTEP_HEADERS = $(GNUSTEP_INSTALLATION_DIR)/Headers
GNUSTEP_LIBRARIES_ROOT = $(GNUSTEP_INSTALLATION_DIR)/Libraries
GNUSTEP_TARGET_LIBRARIES = $(GNUSTEP_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LIBRARIES = $(GNUSTEP_TARGET_LIBRARIES)/$(LIBRARY_COMBO)
GNUSTEP_RESOURCES = $(GNUSTEP_LIBRARIES_ROOT)/Resources

# Take the makefiles from the system root
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles

# In case we need to explicitly reference
# the system, local, and user library directories
GNUSTEP_SYSTEM_LIBRARIES_ROOT = $(GNUSTEP_SYSTEM_ROOT)/Libraries
GNUSTEP_SYSTEM_TARGET_LIBRARIES = \
	$(GNUSTEP_SYSTEM_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_SYSTEM_LIBRARIES = $(GNUSTEP_SYSTEM_TARGET_LIBRARIES)/$(LIBRARY_COMBO)
GNUSTEP_SYSTEM_HEADERS = $(GNUSTEP_SYSTEM_ROOT)/Headers

ifneq ($(GNUSTEP_LOCAL_ROOT),)
GNUSTEP_LOCAL_LIBRARIES_ROOT = $(GNUSTEP_LOCAL_ROOT)/Libraries
GNUSTEP_LOCAL_TARGET_LIBRARIES = \
	$(GNUSTEP_LOCAL_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG = -L$(GNUSTEP_LOCAL_TARGET_LIBRARIES)
GNUSTEP_LOCAL_LIBRARIES = $(GNUSTEP_LOCAL_TARGET_LIBRARIES)/$(LIBRARY_COMBO)
GNUSTEP_LOCAL_LIBRARIES_FLAG = -L$(GNUSTEP_LOCAL_LIBRARIES)
GNUSTEP_LOCAL_HEADERS = $(GNUSTEP_LOCAL_ROOT)/Headers
GNUSTEP_LOCAL_HEADERS_FLAG = -I$(GNUSTEP_LOCAL_HEADERS)
endif

ifneq ($(GNUSTEP_USER_ROOT),)
GNUSTEP_USER_LIBRARIES_ROOT = $(GNUSTEP_USER_ROOT)/Libraries
GNUSTEP_USER_TARGET_LIBRARIES = \
	$(GNUSTEP_USER_LIBRARIES_ROOT)/$(GNUSTEP_TARGET_DIR)
GNUSTEP_USER_TARGET_LIBRARIES_FLAG = -L$(GNUSTEP_USER_TARGET_LIBRARIES)
GNUSTEP_USER_LIBRARIES = $(GNUSTEP_USER_TARGET_LIBRARIES)/$(LIBRARY_COMBO)
GNUSTEP_USER_LIBRARIES_FLAG = -L$(GNUSTEP_USER_LIBRARIES)
GNUSTEP_USER_HEADERS = $(GNUSTEP_USER_ROOT)/Headers
GNUSTEP_USER_HEADERS_FLAG = -I$(GNUSTEP_USER_HEADERS)
endif

#
# Target specific header include directories
#
ifneq ($(GNUSTEP_USER_ROOT),)
GNUSTEP_HEADERS_TARGET_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_TARGET_DIR)
endif
ifneq ($(GNUSTEP_LOCAL_ROOT),)
GNUSTEP_HEADERS_TARGET_FLAG += -I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_TARGET_DIR)
endif
GNUSTEP_HEADERS_TARGET_FLAG += -I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_TARGET_DIR)

#
# Determine Foundation header subdirectory based upon library combo
#
ifeq ($(FOUNDATION_LIB),gnu)
GNUSTEP_FND_DIR = gnustep
FOUNDATION_LIBRARY_NAME = gnustep-base
FOUNDATION_LIBRARY_DEFINE = -DGNUSTEP_BASE_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),fd)
GNUSTEP_FND_DIR = libFoundation
FOUNDATION_LIBRARY_NAME = Foundation
FOUNDATION_LIBRARY_DEFINE = -DLIB_FOUNDATION_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),nx)
GNUSTEP_FND_DIR = NeXT
FOUNDATION_LIBRARY_NAME =
FOUNDATION_LIBRARY_DEFINE = -DNeXT_Foundation_LIBRARY=1
endif

ifeq ($(FOUNDATION_LIB),sun)
GNUSTEP_FND_DIR = sun
FOUNDATION_LIBRARY_DEFINE = -DSun_Foundation_LIBRARY=1
endif

ifneq ($(GNUSTEP_USER_ROOT),)
GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_FND_DIR)
endif
ifneq ($(GNUSTEP_LOCAL_ROOT),)
GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_FND_DIR)
endif
GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_FND_DIR)

ifeq ($(FOUNDATION_LIB), fd)
GNUSTEP_HEADERS_FND_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME) \
	-I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME) \
	-I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_FND_DIR)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(OBJC_RUNTIME)
endif

#
# Determine AppKit header subdirectory based upon library combo
#
ifeq ($(GUI_LIB),gnu)
GNUSTEP_GUI_DIR = gnustep/gui
ifneq ($(GNUSTEP_USER_ROOT),)
GNUSTEP_HEADERS_GUI_FLAG += -I$(GNUSTEP_USER_HEADERS)/$(GNUSTEP_GUI_DIR)
endif
ifneq ($(GNUSTEP_LOCAL_ROOT),)
GNUSTEP_HEADERS_GUI_FLAG += -I$(GNUSTEP_LOCAL_HEADERS)/$(GNUSTEP_GUI_DIR)
endif
GNUSTEP_HEADERS_GUI_FLAG += -I$(GNUSTEP_SYSTEM_HEADERS)/$(GNUSTEP_GUI_DIR)
endif

ifeq ($(GUI_LIB),nx)
GNUSTEP_GUI_DIR =
#GNUSTEP_HEADERS_GUI_FLAG = -framework AppKit
endif

#
# Overridable compilation flags
#
OBJCFLAGS = -Wno-import
CFLAGS =
OBJ_DIR_PREFIX =

ifeq ($(OBJC_RUNTIME_LIB),gnu)
RUNTIME_FLAG = -fgnu-runtime
RUNTIME_DEFINE = -DGNU_RUNTIME=1
endif

ifeq ($(OBJC_RUNTIME_LIB),nx)
  ifneq ($(OBJC_COMPILER), NeXT)
    RUNTIME_FLAG = -fnext-runtime
  endif
RUNTIME_DEFINE = -DNeXT_RUNTIME=1
endif

ifneq ($(debug), yes)
OPTFLAG = -O2
endif

# Enable building shared libraries by default. If the user wants to build a
# static library, he/she has to specify shared=no explicitly.
ifeq ($(HAVE_SHARED_LIBS), yes)
  ifeq ($(shared), no)
    shared=no
  else
    shared=yes
  endif
endif

ifeq ($(shared), yes)
  LIB_LINK_CMD = $(SHARED_LIB_LINK_CMD)
  OBJ_DIR_PREFIX += shared_
  INTERNAL_OBJCFLAGS += $(SHARED_CFLAGS)
  INTERNAL_CFLAGS += $(SHARED_CFLAGS)
  AFTER_INSTALL_LIBRARY_CMD = $(AFTER_INSTALL_SHARED_LIB_COMMAND)
else
  LIB_LINK_CMD = $(STATIC_LIB_LINK_CMD)
  OBJ_DIR_PREFIX += static_
  AFTER_INSTALL_LIBRARY_CMD = $(AFTER_INSTALL_STATIC_LIB_COMMAND)
  LIBRARY_NAME_SUFFIX := s$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(profile), yes)
ADDITIONAL_FLAGS += -pg
OBJ_DIR_PREFIX += profile_
  LIBRARY_NAME_SUFFIX := p$(LIBRARY_NAME_SUFFIX)
endif

ifeq ($(debug), yes)
ADDITIONAL_FLAGS += -g
OBJ_DIR_PREFIX += debug_
  LIBRARY_NAME_SUFFIX := d$(LIBRARY_NAME_SUFFIX)
endif

OBJ_DIR_PREFIX += obj

ifneq ($(LIBRARY_NAME_SUFFIX),)
LIBRARY_NAME_SUFFIX := _$(LIBRARY_NAME_SUFFIX)
endif

INTERNAL_OBJCFLAGS += $(ADDITIONAL_FLAGS) $(OPTFLAG) $(OBJCFLAGS) \
			$(RUNTIME_FLAG)
INTERNAL_CFLAGS += $(ADDITIONAL_FLAGS) $(CFLAGS) $(OPTFLAG) $(RUNTIME_FLAG)
INTERNAL_LDFLAGS += $(LDFLAGS)

GNUSTEP_OBJ_PREFIX = $(shell echo $(OBJ_DIR_PREFIX) | sed 's/ //g')

#
# Support building of Multiple Architecture Binaries (MAB). The object files
# directory will be something like shared_obj/ix86_m68k_sun/
#
ifeq ($(arch),)
ARCH_OBJ_DIR = $(GNUSTEP_TARGET_DIR)
else
ARCH_OBJ_DIR = \
      $(shell echo $(CLEANED_ARCH) | sed -e 's/ /_/g')/$(GNUSTEP_TARGET_OS)
endif

GNUSTEP_OBJ_DIR = $(GNUSTEP_OBJ_PREFIX)/$(ARCH_OBJ_DIR)/$(LIBRARY_COMBO)
