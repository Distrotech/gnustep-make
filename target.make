#
#   target.make
#
#   Determine target specific settings
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

#
# Determine the environment variable name used by the dynamic loader
#
LD_LIB_PATH := $(shell $(LD_LIB_PATH_SCRIPT) $(GNUSTEP_HOST_OS))

#
# Host and target specific settings
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
X_INCLUDES := $(X_INCLUDES)/X11
endif

#
# Target specific libraries
#
ifeq ($(findstring linux-gnu, $(GNUSTEP_TARGET_OS)), linux-gnu)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -ldl -lm
  else
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -ldl -lm
  endif
endif
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
  ifeq ("$(objc_threaded)","")
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lsocket -lnsl -ldl -lm -lposix4
  else
    INTERNAL_CFLAGS = -D_REENTRANT
    INTERNAL_OBJCFLAGS = -D_REENTRANT
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) $(objc_threaded) -lsocket -lnsl -ldl -lm
  endif
endif
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring hpux, $(GNUSTEP_TARGET_OS)), hpux)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring sysv4.2, $(GNUSTEP_TARGET_OS)), sysv4.2)
    TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lsocket -lnsl -ldl -lm
endif
ifeq ($(findstring aix4.1, $(GNUSTEP_TARGET_OS)), aix4.1)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring freebsd, $(GNUSTEP_TARGET_OS)), freebsd)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring netbsd, $(GNUSTEP_TARGET_OS)), netbsd)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif
ifeq ($(findstring osf, $(GNUSTEP_TARGET_OS)), osf)
TARGET_SYSTEM_LIBS := $(CONFIG_SYSTEM_LIBS) -lm
endif

#
# Specific settings for building shared libraries, static libraries,
# and bundles on various systems
#
HAVE_SHARED_LIBS = no
STATIC_LIB_LINK_CMD = \
	$(AR) $(ARFLAGS) $(AROUT)$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^;\
	$(RANLIB) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE)
AFTER_INSTALL_STATIC_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); $(RANLIB) $(VERSION_LIBRARY_FILE))
SHARED_LIB_LINK_CMD =
SHARED_CFLAGS =
SHARED_LIBEXT =
AFTER_INSTALL_SHARED_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); \
	 rm -f $(LIBRARY_FILE); \
	 $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
HAVE_BUNDLES = no

####################################################
#
# Start of system specific settings
#
####################################################

####################################################
#
# OpenStep 4.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep4)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES            = yes
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
	/bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE) -o $@ \
		-framework System \
		$(ALL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc -lgcc $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE) $(ALL_LDFLAGS) $@ \
		-framework System \
		$(ALL_LIB_DIRS) $(LIBRARIES_DEPEND_UPON) \
		$(LIBRARIES_FOUNDATION_DEPEND_UPON) $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool -static $(ARCH_FLAGS) -o $@ $^

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += $(CONFIG_SYSTEM_LIBS) -lgcc
endif

BUNDLE_LD	= ld
BUNDLE_CFLAGS   +=
BUNDLE_LDFLAGS  += -r $(ARCH_FLAGS)
endif
#
# end OpenStep 4.x
#
####################################################

####################################################
#
# NEXTSTEP 3.x
#
ifeq ($(GNUSTEP_TARGET_OS), nextstep3)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES            = yes
endif

HAVE_SHARED_LIBS        = yes

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
    Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress
		 $(ARCH_FLAGS) -o $@ -framework System \
		$(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
		$(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
		-L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
		$(ADDITIONAL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) -lobjc -lgcc -undefined warning $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else
SHARED_LIB_LINK_CMD     = \
        /bin/libtool -dynamic -read_only_relocs suppress $(ARCH_FLAGS) -o $@ \
		-framework System \
		$(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
		$(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
		-L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
		$(ADDITIONAL_LIB_DIRS) $(LIBRARIES_DEPEND_UPON) $^; \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif

STATIC_LIB_LINK_CMD	= \
	/bin/libtool -static $(ARCH_FLAGS) -o $@ $^

ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .a

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += $(CONFIG_SYSTEM_LIBS) -lgcc
endif

BUNDLE_LD	= ld
BUNDLE_CFLAGS   +=
BUNDLE_LDFLAGS  += -r $(ARCH_FLAGS)
endif
#
# end NEXTSTEP 3.x
#
####################################################

####################################################
#
# Linux ELF
#
ifeq ($(findstring linux-gnu, $(GNUSTEP_TARGET_OS)), linux-gnu)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -Wl,-soname,$(SONAME_LIBRARY_FILE) \
           -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ \
	   $(GNUSTEP_USER_TARGET_LIBRARIES_FLAG) \
	   $(GNUSTEP_LOCAL_TARGET_LIBRARIES_FLAG) \
	   -L$(GNUSTEP_SYSTEM_LIBRARIES) \
	   -L$(GNUSTEP_SYSTEM_TARGET_LIBRARIES) \
	   $(SYSTEM_LIB_DIR) \
	   $(ADDITIONAL_LIB_DIRS) \
	   $(LIBRARIES_DEPEND_UPON) \
	   $(TARGET_SYSTEM_LIBS); \
	(cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(SONAME_LIBRARY_FILE) $(LIBRARY_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); \
          rm -f $(LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(SONAME_LIBRARY_FILE) $(LIBRARY_FILE); \
	)
OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS   += -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -shared
ADDITIONAL_LDFLAGS += -rdynamic
endif
#
# end Linux ELF
#
####################################################

####################################################
#
# FreeBSD a.out (2.2.x)
#
ifeq ($(findstring freebsd2, $(GNUSTEP_TARGET_OS)), freebsd2)
HAVE_SHARED_LIBS	= no
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(VERSION_LIBRARY_FILE) \
	   -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ /usr/lib/c++rt0.o;\
	(cd $(GNUSTEP_OBJ_DIR); \
	  rm -f $(LIBRARY_FILE); \
	  $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_CFLAGS	+= -fPIC
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic
endif
#
# end FreeBSD A.out
#
####################################################

####################################################
#
# FreeBSD ELF
#
ifeq ($(findstring freebsd, $(GNUSTEP_TARGET_OS)), freebsd)
HAVE_SHARED_LIBS	= yes
SHARED_LIB_LINK_CMD = \
	$(CC) -shared -Wl,-soname,$(VERSION_LIBRARY_FILE) \
	   -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ ;\
	(cd $(GNUSTEP_OBJ_DIR); \
	  rm -f $(LIBRARY_FILE); \
	  $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
OBJ_MERGE_CMD		= \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS	+= -fPIC
SHARED_LIBEXT	= .so

HAVE_BUNDLES	= yes
BUNDLE_LD	= $(CC)
BUNDLE_CFLAGS	+= -fPIC
BUNDLE_LDFLAGS	+= -shared
ADDITIONAL_LDFLAGS += -rdynamic
endif
#
# end FreeBSD
#
####################################################

####################################################
#
# NetBSD
#
ifeq ($(findstring netbsd, $(GNUSTEP_TARGET_OS)), netbsd)
# This is disabled temporarily, because I don't know exactly how
# to link shared libs. Everything seems to link correctly now but
# constructor functions in the shared lib failed to get called
# when the lib is loaded in. I don't know why. ASF.
HAVE_SHARED_LIBS        = no
SHARED_LD		= ld
SHARED_LIB_LINK_CMD     = \
        $(SHARED_LD) -x -Bshareable -Bforcearchive \
           -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ /usr/lib/c++rt0.o;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS   += -shared
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
#BUNDLE_CFLAGS   += 
BUNDLE_LDFLAGS  += -shared
#ADDITIONAL_LDFLAGS += -rdynamic
endif
#
# end NetBSD
#
####################################################

####################################################
#
# OpenBSD 2.x (though set for 2.4)
#
ifeq ($(findstring openbsd, $(GNUSTEP_TARGET_OS)), openbsd)
# This is disabled temporarily, because I don't know exactly how
# to link shared libs. Everything seems to link correctly now but
# constructor functions in the shared lib failed to get called
# when the lib is loaded in. I don't know why. ASF.
HAVE_SHARED_LIBS        = no
SHARED_LD		= ld
SHARED_LIB_LINK_CMD     = \
        $(SHARED_LD) -x -Bshareable -Bforcearchive \
           -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ /usr/lib/c++rt0.o;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS   += -shared
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = no
BUNDLE_LD	= $(CC)
#BUNDLE_CFLAGS   += 
BUNDLE_LDFLAGS  += -shared
#ADDITIONAL_LDFLAGS += -rdynamic
endif
#
# end OpenBSD 2.x
#
####################################################

####################################################
#
# IRIX
#
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
#HAVE_SHARED_LIBS        = yes
STATIC_LIB_LINK_CMD = \
        (cd $(GNUSTEP_OBJ_DIR); $(AR) $(ARFLAGS) \
        $(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o`);\
        $(RANLIB) $(VERSION_LIBRARY_FILE)
SHARED_LIB_LINK_CMD     = \
        (cd $(GNUSTEP_OBJ_DIR); $(CC) -v $(SHARED_CFLAGS) -shared -o \
	  $(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o` ;\
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fPIC
SHARED_LIBEXT   = .sl

HAVE_BUNDLES    = yes
BUNDLE_LD       = $(CC)
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end IRIX
#
####################################################

####################################################
#
# Solaris
#
ifeq ($(findstring solaris, $(GNUSTEP_TARGET_OS)), solaris)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
	$(CC) -G -Wl,-h,$(SONAME_LIBRARY_FILE) \
	   -o $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) $^ ;\
	(cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(SONAME_LIBRARY_FILE) $(LIBRARY_FILE); \
	)
AFTER_INSTALL_SHARED_LIB_COMMAND = \
	(cd $(GNUSTEP_LIBRARIES); \
          rm -f $(LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(SONAME_LIBRARY_FILE); \
          $(LN_S) $(SONAME_LIBRARY_FILE) $(LIBRARY_FILE); \
	)

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_CFLAGS   += -fPIC
#BUNDLE_LDFLAGS  += -shared -mimpure-text
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end Solaris
#
####################################################


####################################################
#
# Unixware
#
ifeq ($(findstring sysv4.2, $(GNUSTEP_TARGET_OS)), sysv4.2)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        $(CC) -shared -o $(VERSION_LIBRARY_FILE) $^ ;\
        mv $(VERSION_LIBRARY_FILE) $(GNUSTEP_OBJ_DIR) ;\
        (cd $(GNUSTEP_OBJ_DIR); \
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fpic -fPIC
SHARED_LIBEXT   = .so

HAVE_BUNDLES    = yes
BUNDLE_LD       = $(CC)
BUNDLE_CFLAGS   += -fPIC
#BUNDLE_LDFLAGS  += -shared -mimpure-text
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end Unixware
#
####################################################


####################################################
#
# HP-UX 
#
ifeq ($(findstring hpux, $(GNUSTEP_TARGET_OS)), hpux)
HAVE_SHARED_LIBS        = yes
SHARED_LIB_LINK_CMD     = \
        (cd $(GNUSTEP_OBJ_DIR); $(CC) -v $(SHARED_CFLAGS) -shared -o $(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o` ;\
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

ifeq ($(CC), cc)
SHARED_CFLAGS   += +z
BUNDLE_CFLAGS   += +z
else
SHARED_CFLAGS   += -fPIC
BUNDLE_CFLAGS   += -fPIC
endif
SHARED_LIBEXT   = .sl

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end HP-UX
#
####################################################

####################################################
#
# IRIX
#
ifeq ($(findstring irix, $(GNUSTEP_TARGET_OS)), irix)
#HAVE_SHARED_LIBS        = yes
STATIC_LIB_LINK_CMD = \
	(cd $(GNUSTEP_OBJ_DIR); $(AR) $(ARFLAGS) \
	$(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o`);\
	$(RANLIB) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE)
SHARED_LIB_LINK_CMD     = \
        (cd $(GNUSTEP_OBJ_DIR); $(CC) -v $(SHARED_CFLAGS) -shared -o $(VERSION_LIBRARY_FILE) `ls -1 *\.o */*\.o` ;\
          rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))

SHARED_CFLAGS     += -fPIC
SHARED_LIBEXT   = .sl

HAVE_BUNDLES    = yes
BUNDLE_LD	= $(CC)
BUNDLE_CFLAGS   += -fPIC
BUNDLE_LDFLAGS  += -nodefaultlibs -Xlinker -r
endif

# end IRIX
#
####################################################

####################################################
#
# MacOSX-Server 1.0
#
ifeq ($(findstring rhapsody5, $(GNUSTEP_TARGET_OS)), rhapsody5)
ifeq ($(OBJC_RUNTIME), NeXT)
HAVE_BUNDLES     = yes
endif

HAVE_SHARED_LIBS = yes
SHARED_LIBEXT    = .dylib

ifeq ($(FOUNDATION_LIB),nx)
  # Use the NeXT compiler
  CC = cc
  OBJC_COMPILER = NeXT
  ifneq ($(arch),)
    ARCH_FLAGS = $(foreach a, $(arch), -arch $(a))
    INTERNAL_OBJCFLAGS += $(ARCH_FLAGS)
    INTERNAL_CFLAGS    += $(ARCH_FLAGS)
    INTERNAL_LDFLAGS   += $(ARCH_FLAGS)
  endif
endif

TARGET_LIB_DIR = \
   
Libraries/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)

ifneq ($(OBJC_COMPILER), NeXT)
SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic \
		-compatibility_version 1 -current_version 1 \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE)
\
		-o $@ \
		-framework Foundation \
		-framework System \
		$(ALL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-lobjc -lgcc $^ $(SHARED_LD_POSTFLAGS); \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
else # OBJC_COMPILER=NeXT
SHARED_LIB_LINK_CMD     = \
	$(CC) $(SHARED_LD_PREFLAGS) \
		-dynamiclib $(ARCH_FLAGS) -dynamic \
		-compatibility_version 1 -current_version 1 \
		-read_only_relocs suppress \
		-undefined suppress \
		-install_name $(GNUSTEP_SYSTEM_ROOT)/$(TARGET_LIB_DIR)/$(LIBRARY_FILE)
\
		-o $@ \
		$(ALL_LIB_DIRS) \
		$(LIBRARIES_DEPEND_UPON) $(LIBRARIES_FOUNDATION_DEPEND_UPON) \
		-framework Foundation \
		$^ $(SHARED_LD_POSTFLAGS); \
	(cd $(GNUSTEP_OBJ_DIR); rm -f $(LIBRARY_FILE); \
          $(LN_S) $(VERSION_LIBRARY_FILE) $(LIBRARY_FILE))
endif # OBJC_COMPILER

OBJ_MERGE_CMD = \
	$(CC) -nostdlib -r -d -o $(GNUSTEP_OBJ_DIR)/$(SUBPROJECT_PRODUCT) $^ ;

STATIC_LIB_LINK_CMD	= \
	/usr/bin/libtool $(STATIC_LD_PREFLAGS) -static $(ARCH_FLAGS) -o $@ $^ \
	$(STATIC_LD_POSTFLAGS)

# This doesn't work with 4.1, what about others?
#ADDITIONAL_LDFLAGS += -Wl,-read_only_relocs,suppress

AFTER_INSTALL_STATIC_LIB_COMMAND =

SHARED_CFLAGS   += -dynamic
SHARED_LIBEXT   = .dylib

ifneq ($(OBJC_COMPILER), NeXT)
TARGET_SYSTEM_LIBS += $(CONFIG_SYSTEM_LIBS) -lgcc
endif

BUNDLE_LD	=  $(CC)
BUNDLE_CFLAGS   += 
BUNDLE_LDFLAGS  += -bundle -undefined suppress $(ARCH_FLAGS)
endif
#
# end MacOSX-Server 1.0
#
####################################################

## Local variables:
## mode: makefile
## End:

