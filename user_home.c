/*
   user_home.c
   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: February 2002

   This file is part of the GNUstep Makefile Package.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

#include "config.h"

#ifdef __MINGW32__
#ifndef __MINGW__
#define __MINGW__
#endif
#ifndef __WIN32__
#define __WIN32__
#endif
#endif

#include <stdio.h>
#include <ctype.h>

#if defined(__MINGW__)
# include <windows.h>
#endif

#if HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#if HAVE_STDLIB_H
# include <stdlib.h>
#endif

#if HAVE_UNISTD_H
# include <unistd.h>
#endif

#if HAVE_STRING_H
# include <string.h>
#endif

#if HAVE_PWD_H
# include <pwd.h>
#endif

#define lowlevelstringify(X) #X
#define stringify(X) lowlevelstringify(X)

#if defined(__MINGW__)
# define SEP "\\"
#else
# define SEP "/"
#endif

/*
 * This tool is intended to produce a definitive form of the
 * user specific root directories for a GNUstep user.  It must
 * remain consistent with the code in the GNUstep base library
 * which provides path information for all GNUstep applications.
 *
 *
 * How to run this tool ...
 *
 * 1. With no arguments ... the tool should print the home directory of
 * the current user to stdout.
 *
 * 2. With a 'user' argument ... the tool should print the
 * GNUSTEP_USER_ROOT directory to stdout.
 *
 * 3. With a 'defaults' argument ... the tool should print the
 * GNUSTEP_DEFAULTS_ROOT directory to stdout.
 *
 * Any other arguments will be ignored.
 * On success the tool will terminate with an exit status of zero
 * On failure, the tool will terminate with an exit status of one
 * and will print an error message to stderr.
 */

/* NOTE FOR DEVELOPERS.
 * If you change the behavior of this method you must also change
 * NSUser.m in the base library package to match.
 */
int main (int argc, char** argv)
{
  char		buf0[1024];
  char		path[2048];
  char		home[2048];
  char		*loginName = 0;
  enum { NONE, DEFS, USER } type = NONE;
#if defined(__MINGW__)
  char		buf1[1024];
  int		len0;
  int		len1;
#else
  struct passwd *pw;
#endif

  if (argc > 1)
    {
      if (strcmp(argv[1], "defaults") == 0)
	{
#ifdef	FORCE_DEFAULTS_ROOT
	  printf("%s", stringify(FORCE_DEFAULTS_ROOT));
	  return 0;
#else
	  type = DEFS;
#endif
	}
      else if (strcmp(argv[1], "user") == 0)
	{
#ifdef	FORCE_USER_ROOT
	  printf("%s", stringify(FORCE_USER_ROOT));
	  return 0;
#else
	  type = USER;
#endif
	}
    }

  if (loginName == 0)
    {
#if defined(__WIN32__)
      /* The GetUserName function returns the current user name */
      DWORD	n = 1024;

      len0 = GetEnvironmentVariable("LOGNAME", buf0, 1024);
      if (len0 > 0 && len0 < 1024)
	{
	  loginName = buf0;
	  loginName[len0] = '\0';
	}
      else if (GetUserName(buf0, &n))
	{
	  loginName = buf0;
	}
#else
      loginName = getenv("LOGNAME");
#if	HAVE_GETPWNAM
      /*
       * Check that LOGNAME contained legal name.
       */
      if (loginName != 0 && getpwnam(loginName) == 0)
	{
	  loginName = 0;
	}
#endif	/* HAVE_GETPWNAM */
#if	HAVE_GETLOGIN
      /*
       * Try getlogin() if LOGNAME environmentm variable didn't work.
       */
      if (loginName == 0)
	{
	  loginName = getlogin();
	}
#endif	/* HAVE_GETLOGIN */
#if HAVE_GETPWUID
      /*
       * Try getting the name of the effective user as a last resort.
       */
      if (loginName == 0)
	{
#if HAVE_GETEUID
	  int uid = geteuid();
#else
	  int uid = getuid();
#endif /* HAVE_GETEUID */
	  struct passwd *pwent = getpwuid (uid);
	  loginName = pwent->pw_name;
	}
#endif /* HAVE_GETPWUID */
#endif
      if (loginName == 0)
	{
	  fprintf(stderr, "Unable to determine current user name.\n");
	  return 1;
	}
    }

#if !defined(__MINGW__)
  pw = getpwnam (loginName);
  if (pw == 0)
    {
      fprintf(stderr, "Unable to locate home directory for '%s'\n", loginName);
      return 1;
    }
  strncpy(home, pw->pw_dir, sizeof(home));
#else
  /* Then environment variable HOMEPATH holds the home directory
     for the user on Windows NT; Win95 has no concept of home. */
  len0 = GetEnvironmentVariable("HOMEDRIVE", buf0, 1024);
  if (len0 > 0 && len0 < 1024)
    {
      buf0[len0] = '\0';
      len1 = GetEnvironmentVariable("HOMEPATH", buf1, 128);
      if (len1 > 0 && len1 < 128)
	{
	  buf1[len1] = '\0';
	  sprintf(home, "%s%s", buf0, buf1);
	}
      else
	{
	  fprintf(stderr, "Unable to determine HOMEPATH\n");
	  return 1;
	}
    }
  else
    {
      fprintf(stderr, "Unable to determine HOMEDRIVE\n");
      return 1;
    }
#endif

  if (type == NONE)
    {
      strcpy(path, home);
    }
  else
    {
      FILE	*fptr;
      char	*user = "";
      char	*defs = "";

      strcpy(path, home);
      strcat(path, SEP);
      strcat(path, ".GNUsteprc");
      fptr = fopen(path, "r");
      path[0] = '\0';
      if (fptr != 0)
	{
	  while (fgets(buf0, sizeof(buf0), fptr) != 0)
	    {
	      char	*pos = strchr(buf0, '=');

	      if (pos != 0)
		{
		  char	*key = buf0;
		  char	*val = pos;

		  *val++ = '\0';
		  while (isspace(*key))
		    key++;
		  while (strlen(key) > 0 && isspace(key[strlen(key)-1]))
		    key[strlen(key)-1] = '\0';
		  while (isspace(*val))
		    val++;
		  while (strlen(val) > 0 && isspace(val[strlen(val)-1]))
		    val[strlen(val)-1] = '\0';

		  if (strcmp(key, "GNUSTEP_USER_ROOT") == 0)
		    {
		      user = malloc(strlen(val)+1);
		      strcpy(user, val);
		    }
		  else if (strcmp(key, "GNUSTEP_DEFAULTS_ROOT") == 0)
		    {
		      defs = malloc(strlen(val)+1);
		      strcpy(user, val);
		    }
		}
	    }
	  fclose(fptr);
	}
      if (type == DEFS)
	{
	  strcpy(path, defs);
	  if (*path == '\0')
	    {
	      strcpy(path, user);
	    }
	}
      else
	{
	  strcpy(path, user);
	}

      if (*path == '\0')
	{
	  strcpy(path, home);
	  strcat(path, SEP);
	  strcat(path, "GNUstep");
	}
    }
  printf("%s", path);
  return 0;
}

