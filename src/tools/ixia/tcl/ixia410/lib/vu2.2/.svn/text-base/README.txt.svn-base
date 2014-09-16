/*
 * Based on various older packages.  See CREDITS for more info.
 *
 * see ChangeLog file for details
 *
 * current maintainer: jeff(at)hobbs.org
 *
 * Changes 1998-2002 Copyright (c) Jeffrey Hobbs (jeff(at)hobbs.org)
 */

		*************************************
		  The vu Widget Set v2.1+
		*************************************

The newest version is most likely found at:
	http://tktable.sourceforge.net/
	http://www.purl.org/net/hobbs/tcl/capp/

INTRODUCTION
============

Based on the old vuw widgets from UCO-Lick, this package consists of:

  ::vu::dial	a "clock face" gauge with a rotating indicator hand
		which can be scaled as you wish to represent various
		integer values

  ::vu::pie	a pie chart with legend, shading, exploded segments, etc.

  ::vu::spinbox	a standard spinbox (<= 8.3)
		This is the same as the 8.4 core spinbox widget.

  ::vu::bargraph	a "gas gauge" (growing/shrinking bar) such as many
		mac applications use to indicate %age of file
		processed, count of bytes transferred etc.

The following widgets are also under development:

  ::vu::combo	a standard combobox

The following additional canvas items are also included:

  stripchart	taken from scotty (Schoenwaelder)
  barchart	taken from scotty (Schoenwaelder)
  sticker 	taken from tkSticker-1.2 (Heribert Dahms), Unix only

Under development (actually, just requires internal Tk headers that
aren't searched for by default):

  label		from tkgraph-2.0.4's tkCanvText.c (uses BLT text rotation)
		a dash-pached version of standard tkCanvText.c
		renamed to tkCanvLabel.c
		(The tkCanvLabel.c should be part of the CORE.)

BINARY DISTRIBUTIONS
====================

If this is a binary distribution, then the vu-<version> directory
just needs to be placed as a sibling directory next to $tk_library.
You can place it anywhere, as long as $auto_path has the name of
the directory.

BUILDING FROM SOURCE
====================

 * UNIX & WINDOWS (Using TEA -- Tcl Extension Architecture)

	unpack the source in a directory called VU or something like that.

	cd vu-<version>
		or whatever you called it, do not use the makefiles in the
		win/ subdirs since they are not TEA-compliant.  The
		toplevel makefile will build on any platform that is
		configured for TEA (on Windows you will need cygwin or a
		similar set of tools).

	./configure

		* you may want to add --prefix=/opt/tcl or whatever the
		correct path is at your site

		* you may need to use the --with-tcl and --with-tk flags to
		tell configure which version of Tcl and Tk to use.

	make install

 * WINDOWS (using nmake)

	unpack the source in a directory called VU or something like that.

	cd vu-<version>/win
		or whatever you called it

	nmake -f makefile.vc

		you may want to add --prefix=/opt/tcl
		or whatever the correct path is at your site

	nmake -f makefile.vc test
	nmake -f makefile.vc install

 * MAC

	requires CodeWarrior 5+.  I'm not quite sure what is necessary,
	because those are contributed project files.  Mac projects
	contributed by Daniel Steffen.


CREDITS
=======

The bargraph was originally written by a team of programmers and
researchers at the University of Victoria, Wellington, NZ.  The main
co-conspirators were Francis Gardner, Richard Dearden, and Julian Anderson.
These authors subsequently moved on to other projects and the VU widgets
were left orphaned.  Dial and pie were also part of that set, but the
current dial and pie represent a complete rewrite of the original code with
different feature set.

	  -------------

win/winUtil.c and the text rotation portions of generic/tkCanvLabel.c are
derived from BLT, Copyright Bell Labs Innovations for Lucent Technologies
(author George Howlett).

	  -------------
dial was inspired from tkTurndial v2.0, with copyright as follows:

 * (c) 1996, Pierre-Louis Bossart (bossart(at)redhook.llnl.gov)
 * Based on the tkTurndial-1.8 copyrighted as follows
 * (c) 1995, Marco Beijersbergen (beijersb(at)rulhm1.leidenuniv.nl)
