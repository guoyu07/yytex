@echo off
if "%1" == "" goto end
echo adding glyphs to cmsl%1

if exist cmti%1.afm addchars -x cmsl%1 138 cmti%1 sterling
if not exist cmti%1.afm echo cmti%1 does not exist
rem if exist cmsl%1.afm addchars -x cmti%1 139 cmsl%1 dollar
rem if not exist cmsl%1.afm echo cmsl%1 does not exist

if exist cmmi%1.afm addchars -s=0.1666667 -x cmsl%1 140 cmmi%1 less
if exist cmmi%1.afm addchars -s=0.1666667 -x cmsl%1 141 cmmi%1 greater
if not exist cmmi%1.afm echo cmmi%1 does not exist

if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 142 cmsy%1 braceleft
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 143 cmsy%1 braceright
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 144 cmsy%1 backslash
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 145 cmsy%1 bar
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 146 cmsy%1 dagger
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 147 cmsy%1 daggerdbl
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 148 cmsy%1 section
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 149 cmsy%1 paragraph
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 150 cmsy%1 multiply
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 151 cmsy%1 divide
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 152 cmsy%1 minus
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 153 cmsy%1 bullet
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 154 cmsy%1 periodcentered
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 155 cmsy%1 logicalnot
if exist cmsy%1.afm addchars -s=0.1666667 -x cmsl%1 156 cmsy%1 plusminus

if not exist cmsy%1.afm echo cmsy%1 does not exist

rem NOTE in Times-Italic, 
rem less, greater, backslash, bar, bullet, logicalnot, 
rem plusminus, periodcentered, multiply and divide are NOT skewed

:end
