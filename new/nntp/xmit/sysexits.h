/*
 * Copyright (c) 1987 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that this notice is preserved and that due credit is given
 * to the University of California at Berkeley. The name of the University
 * may not be used to endorse or promote products derived from this
 * software without specific prior written permission. This software
 * is provided ``as is'' without express or implied warranty.
 *
 *	@(#)sysexits.h	4.3.1 (2.11BSD) 1996/11/29
 */

/*
**  SYSEXITS.H -- Exit status codes for system programs.
**
**	This include file attempts to categorize possible error
**	exit statuses for system programs, notably delivermail
**	and the Berkeley network.
**
**	Error numbers begin at EX__BASE to reduce the possibility of
**	clashing with other exit statuses that random programs may
**	already return.  The meaning of the codes is approximately
**	as follows:
**
**	EX_USAGE -- The command was used incorrectly, e.g., with
**		the wrong number of arguments, a bad flag, a bad
**		syntax in a parameter, or whatever.
**	EX_DATAERR -- The input data was incorrect in some way.
**		This should only be used for user's data & not
**		system files.
**	EX_NOINPUT -- An input file (not a system file) did not
**		exist or was not readable.  This could also include
**		errors like "No message" to a mailer (if it cared
**		to catch it).
**	EX_NOUSER -- The user specified did not exist.  This might
**		be used for mail addresses or remote logins.
**	EX_NOHOST -- The host specified did not exist.  This is used
**		in mail addresses or network requests.
**	EX_UNAVAILABLE -- A service is unavailable.  This can occur
**		if a support program or file does not exist.  This
**		can also be used as a catchall message when something
**		you wanted to do doesn't work, but you don't know
**		why.
**	EX_SOFTWARE -- An internal software error has been detected.
**		This should be limited to non-operating system related
**		errors as possible.
**	EX_OSERR -- An operating system error has been detected.
**		This is intended to be used for such things as "cannot
**		fork", "cannot create pipe", or the like.  It includes
**		things like getuid returning a user that does not
**		exist in the passwd file.
**	EX_OSFILE -- Some system file (e.g., /etc/passwd, /var/run/utmp,
**		etc.) does not exist, cannot be opened, or has some
**		sort of error (e.g., syntax error).
**	EX_CANTCREAT -- A (user specified) output file cannot be
**		created.
**	EX_IOERR -- An error occurred while doing I/O on some file.
**	EX_TEMPFAIL -- temporary failure, indicating something that
**		is not really an error.  In sendmail, this means
**		that a mailer (e.g.) could not create a connection,
**		and the request should be reattempted later.
**	EX_PROTOCOL -- the remote system returned something that
**		was "not possible" during a protocol exchange.
**	EX_NOPERM -- You did not have sufficient permission to
**		perform the operation.  This is not intended for
**		file system problems, which should use NOINPUT or
**		CANTCREAT, but rather for higher level permissions.
**		For example, kre uses this to restrict who students
**		can send mail to.
**
**	Maintained by Eric Allman (eric@berkeley, ucbvax!eric) --
**		please mail changes to me.
**
**			@(#)sysexits.h	4.3		12/15/87
*/

# define EX_OK		0	/* successful termination */

# define EX__BASE	64	/* base value for error messages */

# define EX_USAGE	64	/* command line usage error */
# define EX_DATAERR	65	/* data format error */
# define EX_NOINPUT	66	/* cannot open input */
# define EX_NOUSER	67	/* addressee unknown */
# define EX_NOHOST	68	/* host name unknown */
# define EX_UNAVAILABLE	69	/* service unavailable */
# define EX_SOFTWARE	70	/* internal software error */
# define EX_OSERR	71	/* system error (e.g., can't fork) */
# define EX_OSFILE	72	/* critical OS file missing */
# define EX_CANTCREAT	73	/* can't create (user) output file */
# define EX_IOERR	74	/* input/output error */
# define EX_TEMPFAIL	75	/* temp failure; user is invited to retry */
# define EX_PROTOCOL	76	/* remote error in protocol */
# define EX_NOPERM	77	/* permission denied */