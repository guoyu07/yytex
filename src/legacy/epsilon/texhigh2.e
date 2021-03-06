/*******************************************************************

Copyright 2007 TeX Users Group.
You may freely use, modify and/or distribute this file.

This is a demonstration of highlighting techniques in Epsilon, based
on Gary Smith's TeX package.  That extension added a feature like
show-matching-delimiter for TeX's $ and $$ characters.  The current
extension simply extends that to highlight the indicated region.  It
doesn't have the features of more recent TeX modes for Epsilon like
Herb Schulz's; it's simply a demonstration of highlighting.

This version highlights via Epsilon 7.0's code coloring features.  It
now dynamically rehighlights as needed.

*******************************************************************/

/********** Documentation to be inserted in file "edoc" ***********

~show-matching-dollar	Insert $ and show matching $ or $$ in TeX mode.

Calls normal-character to insert the key $, then shows the matching $
that delimits math-mode or displayed material.  Now it optionally
highlights math/displayed material too, using a user-specified color
class (set with set-color).

~tex-mode	Show delimiters for TeX code and fill.

This command puts the current buffer in TeX mode and is invoked
automatically for a file with extension .tex .  ([{ are flashed using
show-matching-delimiter().  Dollar signs $ or $$ invoke
show-matching-dollar().  fill-mode is set on, and fill-column is set
to 72.  The mode line says TeX Fill.  Also optionally highlights
math/displayed material too, using a user-specified color class (set
with set-color).

***********             End of documentation            **********/

/* -----  Gary R. Smith  (smith#gary@b.mfenet@nmfecc.arpa) */

/****************** Beginning of file "texhigh2.e" ******************/

#include "eel.h"
#include "colcode.h"

/*
Show delimiters for TeX code and fill.
Written by Gary R. Smith in Oct. 1986.
            
Fill mode is enabled automatically and the fill column set to 72.

When one of )]} is typed, the matching ([{ is flashed, by binding the
former keys to show-matching-delimiter().

Matching dollar signs, which indicate math-mode and displayed
material, are searched for using show-matching-dollar().  That
function performs searches that are limited to a small portion of
text by these assumptions about the TeX code:  (a) new paragraphs do
not begin in $...$ or $$...$$, and (b) $...$ is not nested within
$$...$$, or vice versa.  The following searches are made:

(1) If the $ just typed is preceded by another $, search backwards,
    counting occurrences of $$, until a solitary $ or the beginning of
    the buffer or the beginning of a paragraph is found (\n\n, i.e., a
    blank line, or TeX command \par).  If the $$ just typed is the
    first, third, fifth, etc., occurrence, then flash the first of the
    matching $$.

(2) A solitary $ causes a search backwards, counting occurrences of
    solitary $, until $$ or the beginning of the buffer or the
    beginning of a paragraph is found.  If the $ just typed is the
    first, third, fifth, etc., occurrence, then flash the first of the
    matching $.

Highlighting added by Steven Doerfler, Lugaru Software, Ltd.  1/20/94
as a demonstration of highlighting principles.  A more sophisticated
version might attempt to rehighlight correctly as the buffer changes;
this doesn't, and some types of editing will leave the wrong
highlighting.  Also updated for Epsilon 6.5.
Fixed bug in creating spots around region. 1/26/94
Now uses code coloring extension to rehighlight as the buffer changes. 10/8/94
*/

keytable tex_tab;               /* Key table for TeX mode */

color_class tex_math_mode;	// the colors to use, set via set-color
color_class tex_display;	// color for "displayed" text

command show_matching_dollar() on tex_tab['$']
{
        normal_character();
        iter = 0;
        say("");
	save_var point;
        if (dollar_match())	// is this the second $ or $$ of a set?
		show_line();        /* Function from prog.e */
}

dollar_match()  /* Return 1 if backwards search finds matching $,
                   return 0 otherwise */
{
        int double = 0;
        int count = 0;
        int loc;        /* Will hold location of match, if found */
        
        if (point < 3) return 0;
        point -= 2;
        if (curchar() == '$') double = 1;       /* $$ just typed */
        else point++;
        
/*        while (re_search(-1, "%$|\n\n|\\par")) {*//* To beginning or break */
        while (re_search(-1, "%$|\n\n")) { /* To beginning or break */
                if (curchar() == '$') { /* Found $ */
                        if (double) {   /* Trying to match $$ */
                                if (point > 0 && character(point-1) == '$') {
                                        /* Yes $$ */
                                        point--;
                                        if (!count++) loc = point;
                                        /* Count, and save loc if first */
                                }
                                else break;     /* Found solitary $ */
                        }
                        else {          /* Trying to match solitary $ */
                                if (!point) {
                                        if (!count++) loc = 0;
                                }
                                else if (character(point-1) != '$') {
                                        /* Found $ */
                                        if (!count++) loc = point;
                                        /* Count, and save loc if first */
                                }
                                else break;     /* Found $$ */
                        }
                }
                else break;     /* Found beginning of paragraph */
        }
        
        point = loc;
        return count % 2;
}

add_tex_highlight(p1, p2)		// highlight between p1 and p2
{
	int cclass;

	if (character(p1) == '$' && character(p1 + 1) == '$')
		cclass = color_class tex_display;
	else					// pick a color class
		cclass = color_class tex_math_mode;
	set_character_color(p1, p2, cclass);
}

color_tex_range(from, to)	// recolor in this range
{
	int inside = 0, double = 0, last = 0;

	point = from;		// first, narrow to work on entire paragraphs
/*	re_search(-1, "\n\n|\\par"); */
	re_search(-1, "\n\n");
	save_var narrow_start = point;
	point = to;
/*	re_search(1, "\n\n|\\par"); */
	re_search(1, "\n\n");
	save_var narrow_end = size() - point;
	point = 0;

	set_character_color(0, size(), -1);	// remove existing highlighting
/*        while (re_search(1, "%$|\n\n|\\par")) { */
        while (re_search(1, "%$|\n\n")) {
		if (character(point - 1) == '$') {
			if (double = (curchar() == '$'))
				point++;	// is this displayed text?
			inside = !inside;	// flip this variable
			if (inside)	// remember start of region
				last = point - 1 - double;
			else		// just ended, color it
				add_tex_highlight(last, point);
		} else			// starting new paragraph
			inside = 0;
	}
	return point;
}

color_tex_from_here(safe) // Move backward to the nearest line guaranteed
{			// to start outside any colored region, return pos.
	save_var narrow_start = safe;
/*	re_search(-1, "\n\n|\\par"); */
	re_search(-1, "\n\n");
	return point;
}

command tex_mode()
{
        mode_keys = tex_tab;            /* Use these keys */
        tex_tab[')'] = (short) show_matching_delimiter;
        tex_tab[']'] = (short) show_matching_delimiter;
        tex_tab['}'] = (short) show_matching_delimiter;
        fill_mode = 1;
        margin_right = 72;
        major_mode = strsave("TeX");
        make_mode();
	recolor_range = color_tex_range;	// set up coloring rules
	recolor_from_here = color_tex_from_here;
	if (want_code_coloring)		// maybe turn on coloring
		when_setting_want_code_coloring();
}

/* Make this the default mode for .tex files */
suffix_tex()    { tex_mode(); }

/****************** End of file "texhigh2.e" ******************/
