#   -*-makefile-*-
#   aggregate.make
#
#   Master Makefile rules to build a set of GNUstep-base subprojects.
#
#   Copyright (C) 1997-2010 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Author:  Nicola Pero <nicola.pero@meta-innovation.com>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 3
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.
#   If not, write to the Free Software Foundation,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The list of aggregate project directory names is in the makefile
# variable SUBPROJECTS.  The name is unforunate, because it is confusingly
# similar to xxx_SUBPROJECTS, which is used for subprojects.
#

# For this reason, long term we'd like to replace the variable
# SUBPROJECTS with the variable AGGREGATE_PROJECTS.  As of February
# 2010, we can't just do it without breaking all GNUmakefiles.  So in
# February 2010, we added AGGREGATE_PROJECTS, so that gnustep-make now
# recognizes AGGREGATE_PROJECTS as well as SUBPROJECTS.  In a few
# years, when everyone is using a version of gnustep-make that does
# this, we can deprecate SUBPROJECTS and tell everyone to switch to
# AGGREGATE_PROJECTS without breaking anything :-) In other words, the
# following three lines of code are for compatibility with future
# versions of gnustep-make where the variable will be named
# AGGREGATE_PROJECTS.
AGGREGATE_PROJECTS := $(strip $(AGGREGATE_PROJECTS))
ifneq ($(AGGREGATE_PROJECTS),)
  SUBPROJECTS := $(AGGREGATE_PROJECTS)
endif

# SUBPROJECTS - which is implemented in this file - are just a list of
# directories; we step in each directory in turn, and run a submake in
# there.  The project types in the directories can be anything -
# tools, documentation, libraries, bundles, applications, whatever.
# For example, if your package is composed by a library and then by
# some tools using the library, you could have the library in one
# directory, the tools in another directory, and have a top level
# GNUmakefile which has the two as SUBPROJECTS.
#
# xxx_SUBPROJECTS - which is *not* implemented in this file, I'm just
# explaining it here to make clear the difference - are again a list
# of directories, each of which should contain a *subproject* project
# type (as implemented by subproject.make), which builds stuff into a
# .o file, which is then automatically linked into the xxx instance by
# gnustep-make when the top-level xxx is built.  For example, a
# library might be broken into many separate subprojects, each of
# which implementing a logically separated part of the library; the
# top-level GNUmakefile will then build the library, specifying
# xxx_SUBPROJECTS for the library to be those directories.
# gnustep-make will step in all dirs, compile the subprojects, and
# then finally automatically link the subprojects into the main
# library.
SUBPROJECTS := $(strip $(SUBPROJECTS))

# Set this variable to yes to allow parallelizing the build of the
# different aggregate projects in your GNUmakefile.
ifeq ($(GNUSTEP_USE_PARALLEL_AGGREGATE), YES)
  GNUSTEP_USE_PARALLEL_AGGREGATE = yes
endif

ifeq ($(GNUSTEP_MAKE_PARALLEL_BUILDING), no)
  GNUSTEP_USE_PARALLEL_AGGREGATE = no
endif

ifneq ($(SUBPROJECTS),)

ifneq ($(GNUSTEP_USE_PARALLEL_AGGREGATE), yes)

# Standard, serialized build.  Use a subshell.
internal-all internal-install internal-uninstall internal-clean \
  internal-distclean internal-check internal-strings::
	@ operation=$(subst internal-,,$@); \
	  abs_build_dir="$(ABS_GNUSTEP_BUILD_DIR)"; \
	for f in $(SUBPROJECTS); do \
	  echo "Making $$operation in $$f..."; \
	  mf=$(MAKEFILE_NAME); \
	  if [ ! -f "$$f/$$mf" -a -f "$$f/Makefile" ]; then \
	    mf=Makefile; \
	    echo "WARNING: No $(MAKEFILE_NAME) found for aggregate project $$f; using 'Makefile'"; \
	  fi; \
	  if [ "$${abs_build_dir}" = "." ]; then \
	    gsbuild="."; \
	  else \
	    gsbuild="$${abs_build_dir}/$$f"; \
	  fi; \
	  if $(MAKE) -C $$f -f $$mf $(GNUSTEP_MAKE_NO_PRINT_DIRECTORY_FLAG) --no-keep-going $$operation \
	       GNUSTEP_BUILD_DIR="$$gsbuild"; then \
	    :; else exit $$?; \
	  fi; \
	done

else

# Parallel build.  Run a parallel submake and build all the projects
# in parallel!  Warning: this will massively parallelize your build.
internal-all internal-install internal-uninstall internal-clean \
  internal-distclean internal-check internal-strings::
	$(ECHO_NOTHING)operation=$(subst internal-,,$@); \
	  $(MAKE) -f $(MAKEFILE_NAME) --no-print-directory --no-keep-going \
	  internal-master-aggregate-$$operation \
	  GNUSTEP_BUILD_DIR="$(GNUSTEP_BUILD_DIR)" \
	  _GNUSTEP_MAKE_PARALLEL=yes$(END_ECHO)

.PHONY: \
  internal-master-aggregate-all \
  internal-master-aggregate-install \
  internal-master-aggregate-uninstall \
  internal-master-aggregate-clean \
  internal-master-aggregate-distclean \
  internal-master-aggregate-check \
  internal-master-aggregate-strings

internal-master-aggregate-all: $(SUBPROJECTS:=.all.aggregate)

internal-master-aggregate-install: $(SUBPROJECTS:=.install.aggregate)

internal-master-aggregate-uninstall: $(SUBPROJECTS:=.uninstall.aggregate)

internal-master-aggregate-clean: $(SUBPROJECTS:=.clean.aggregate)

internal-master-aggregate-distclean: $(SUBPROJECTS:=.distclean.aggregate)

internal-master-aggregate-check: $(SUBPROJECTS:=.check.aggregate)

internal-master-aggregate-strings: $(SUBPROJECTS:=.strings.aggregate)

# See Master/rules.make as to why we use .PRECIOUS instead of .PHONY
# here.
.PRECIOUS: %.aggregate

%.aggregate:
	$(ECHO_NOTHING)instance=$(basename $*); \
          operation=$(subst .,,$(suffix $*)); \
	  abs_build_dir="$(ABS_GNUSTEP_BUILD_DIR)"; \
	  echo "Making $$operation in $$instance..."; \
	  mf=$(MAKEFILE_NAME); \
	  if [ ! -f "$$instance/$$mf" -a -f "$$instance/Makefile" ]; then \
	    mf=Makefile; \
	    echo "WARNING: No $(MAKEFILE_NAME) found for aggregate project $$instance; using 'Makefile'"; \
	  fi; \
	  if [ "$${abs_build_dir}" = "." ]; then \
	    gsbuild="."; \
	  else \
	    gsbuild="$${abs_build_dir}/$$instance"; \
	  fi; \
	  if $(MAKE) -C $$instance -f $$mf $(GNUSTEP_MAKE_NO_PRINT_DIRECTORY_FLAG) --no-keep-going $$operation \
	       GNUSTEP_BUILD_DIR="$$gsbuild" _GNUSTEP_MAKE_PARALLEL=no; then \
	    :; else exit $$?; \
	  fi$(END_ECHO)

endif

endif
