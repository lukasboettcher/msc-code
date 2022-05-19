; ModuleID = 'nano.ll'
source_filename = "nano.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.openfilestruct = type { i8*, %struct.linestruct*, %struct.linestruct*, %struct.linestruct*, %struct.linestruct*, i64, i64, i64, i64, i64, %struct.stat*, %struct.linestruct*, %struct.linestruct*, i64, i8, i32, i8*, %struct.undostruct*, %struct.undostruct*, %struct.undostruct*, i32, i8, %struct.syntaxtype*, i8*, %struct.openfilestruct*, %struct.openfilestruct* }
%struct.stat = type { i64, i64, i64, i32, i32, i32, i32, i64, i64, i64, i64, %struct.timespec, %struct.timespec, %struct.timespec, [3 x i64] }
%struct.timespec = type { i64, i64 }
%struct.linestruct = type { i8*, i64, %struct.linestruct*, %struct.linestruct*, i16*, i8 }
%struct.undostruct = type { i32, i32, i64, i64, i8*, i64, i64, %struct.groupstruct*, %struct.linestruct*, i64, i64, %struct.undostruct* }
%struct.groupstruct = type { i64, i64, i8**, %struct.groupstruct* }
%struct.syntaxtype = type { i8*, i8*, i64, %struct.augmentstruct*, %struct.regexlisttype*, %struct.regexlisttype*, %struct.regexlisttype*, i8*, i8*, i8*, i8*, %struct.colortype*, i16, %struct.syntaxtype* }
%struct.augmentstruct = type { i8*, i64, i8*, %struct.augmentstruct* }
%struct.regexlisttype = type { %struct.re_pattern_buffer*, %struct.regexlisttype* }
%struct.re_pattern_buffer = type { %struct.re_dfa_t*, i64, i64, i64, i8*, i8*, i64, i8 }
%struct.re_dfa_t = type opaque
%struct.colortype = type { i16, i16, i16, i16, i32, %struct.re_pattern_buffer*, %struct.re_pattern_buffer*, %struct.colortype* }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, %struct._IO_codecvt*, %struct._IO_wide_data*, %struct._IO_FILE*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type opaque
%struct._IO_codecvt = type opaque
%struct._IO_wide_data = type opaque
%struct.termios = type { i32, i32, i32, i32, i8, [32 x i8], i32, i32 }
%struct._win_st = type { i16, i16, i16, i16, i16, i16, i16, i32, i32, i8, i8, i8, i8, i8, i8, i8, i8, i8, i32, %struct.ldat*, i16, i16, i32, i32, %struct._win_st*, %struct.pdat, i16, %struct.cchar_t, i32 }
%struct.ldat = type opaque
%struct.pdat = type { i16, i16, i16, i16, i16, i16 }
%struct.cchar_t = type { i32, [5 x i32], i32 }
%struct.sigaction = type { %union.anon, %struct.__sigset_t, i32, void ()* }
%union.anon = type { void (i32)* }
%struct.__sigset_t = type { [16 x i64] }
%struct.funcstruct = type { void ()*, i8*, i8*, i8, i8, i32, %struct.funcstruct* }
%struct.option = type { i8*, i32, i32*, i32 }
%struct.keystruct = type { i8*, i32, i32, void ()*, i32, i32, i8*, %struct.keystruct* }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }
%struct.vt_stat = type { i16, i16, i16 }

@openfile = external dso_local global %struct.openfilestruct*, align 8
@.str = private unnamed_addr constant [28 x i8] c"Key is invalid in view mode\00", align 1
@flags = external dso_local global [4 x i32], align 16
@.str.1 = private unnamed_addr constant [45 x i8] c"This function is disabled in restricted mode\00", align 1
@.str.2 = private unnamed_addr constant [22 x i8] c"To suspend, type ^T^Z\00", align 1
@.str.3 = private unnamed_addr constant [9 x i8] c"\1B[?2004l\00", align 1
@stdout = external dso_local global %struct._IO_FILE*, align 8
@original_state = internal global %struct.termios zeroinitializer, align 4
@footwin = external dso_local global %struct._win_st*, align 8
@topwin = external dso_local global %struct._win_st*, align 8
@midwin = external dso_local global %struct._win_st*, align 8
@.str.4 = private unnamed_addr constant [13 x i8] c"No file name\00", align 1
@.str.5 = private unnamed_addr constant [23 x i8] c"Save modified buffer? \00", align 1
@.str.6 = private unnamed_addr constant [10 x i8] c"Cancelled\00", align 1
@.str.7 = private unnamed_addr constant [8 x i8] c"nano.%u\00", align 1
@.str.8 = private unnamed_addr constant [6 x i8] c".save\00", align 1
@stderr = external dso_local global %struct._IO_FILE*, align 8
@.str.9 = private unnamed_addr constant [23 x i8] c"\0AToo many .save files\0A\00", align 1
@.str.10 = private unnamed_addr constant [23 x i8] c"\0ABuffer written to %s\0A\00", align 1
@die.stabs = internal global i32 0, align 4
@LINES = external dso_local global i32, align 4
@editwinrows = external dso_local global i32, align 4
@COLS = external dso_local global i32, align 4
@fill = external dso_local global i64, align 8
@wrap_at = external dso_local global i64, align 8
@oldinterval = internal global i32 -1, align 4
@.str.11 = private unnamed_addr constant [4 x i8] c" %s\00", align 1
@.str.12 = private unnamed_addr constant [4 x i8] c"%*s\00", align 1
@.str.13 = private unnamed_addr constant [2 x i8] c" \00", align 1
@.str.14 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@.str.15 = private unnamed_addr constant [51 x i8] c"Usage: nano [OPTIONS] [[+LINE[,COLUMN]] FILE]...\0A\0A\00", align 1
@.str.16 = private unnamed_addr constant [150 x i8] c"To place the cursor on a specific line of a file, put the line number with\0Aa '+' before the filename.  The column number can be added after a comma.\0A\00", align 1
@.str.17 = private unnamed_addr constant [63 x i8] c"When a filename is '-', nano reads data from standard input.\0A\0A\00", align 1
@.str.18 = private unnamed_addr constant [7 x i8] c"Option\00", align 1
@.str.19 = private unnamed_addr constant [12 x i8] c"Long option\00", align 1
@.str.20 = private unnamed_addr constant [8 x i8] c"Meaning\00", align 1
@.str.21 = private unnamed_addr constant [3 x i8] c"-A\00", align 1
@.str.22 = private unnamed_addr constant [12 x i8] c"--smarthome\00", align 1
@.str.23 = private unnamed_addr constant [22 x i8] c"Enable smart home key\00", align 1
@.str.24 = private unnamed_addr constant [3 x i8] c"-B\00", align 1
@.str.25 = private unnamed_addr constant [9 x i8] c"--backup\00", align 1
@.str.26 = private unnamed_addr constant [31 x i8] c"Save backups of existing files\00", align 1
@.str.27 = private unnamed_addr constant [9 x i8] c"-C <dir>\00", align 1
@.str.28 = private unnamed_addr constant [18 x i8] c"--backupdir=<dir>\00", align 1
@.str.29 = private unnamed_addr constant [41 x i8] c"Directory for saving unique backup files\00", align 1
@.str.30 = private unnamed_addr constant [3 x i8] c"-D\00", align 1
@.str.31 = private unnamed_addr constant [11 x i8] c"--boldtext\00", align 1
@.str.32 = private unnamed_addr constant [39 x i8] c"Use bold instead of reverse video text\00", align 1
@.str.33 = private unnamed_addr constant [3 x i8] c"-E\00", align 1
@.str.34 = private unnamed_addr constant [15 x i8] c"--tabstospaces\00", align 1
@.str.35 = private unnamed_addr constant [29 x i8] c"Convert typed tabs to spaces\00", align 1
@.str.36 = private unnamed_addr constant [3 x i8] c"-F\00", align 1
@.str.37 = private unnamed_addr constant [14 x i8] c"--multibuffer\00", align 1
@.str.38 = private unnamed_addr constant [41 x i8] c"Read a file into a new buffer by default\00", align 1
@.str.39 = private unnamed_addr constant [3 x i8] c"-G\00", align 1
@.str.40 = private unnamed_addr constant [10 x i8] c"--locking\00", align 1
@.str.41 = private unnamed_addr constant [27 x i8] c"Use (vim-style) lock files\00", align 1
@.str.42 = private unnamed_addr constant [3 x i8] c"-H\00", align 1
@.str.43 = private unnamed_addr constant [13 x i8] c"--historylog\00", align 1
@.str.44 = private unnamed_addr constant [41 x i8] c"Save & reload old search/replace strings\00", align 1
@.str.45 = private unnamed_addr constant [3 x i8] c"-I\00", align 1
@.str.46 = private unnamed_addr constant [16 x i8] c"--ignorercfiles\00", align 1
@.str.47 = private unnamed_addr constant [27 x i8] c"Don't look at nanorc files\00", align 1
@.str.48 = private unnamed_addr constant [12 x i8] c"-J <number>\00", align 1
@.str.49 = private unnamed_addr constant [23 x i8] c"--guidestripe=<number>\00", align 1
@.str.50 = private unnamed_addr constant [34 x i8] c"Show a guiding bar at this column\00", align 1
@.str.51 = private unnamed_addr constant [3 x i8] c"-K\00", align 1
@.str.52 = private unnamed_addr constant [15 x i8] c"--rawsequences\00", align 1
@.str.53 = private unnamed_addr constant [41 x i8] c"Fix numeric keypad key confusion problem\00", align 1
@.str.54 = private unnamed_addr constant [3 x i8] c"-L\00", align 1
@.str.55 = private unnamed_addr constant [13 x i8] c"--nonewlines\00", align 1
@.str.56 = private unnamed_addr constant [31 x i8] c"Don't add an automatic newline\00", align 1
@.str.57 = private unnamed_addr constant [3 x i8] c"-M\00", align 1
@.str.58 = private unnamed_addr constant [13 x i8] c"--trimblanks\00", align 1
@.str.59 = private unnamed_addr constant [36 x i8] c"Trim tail spaces when hard-wrapping\00", align 1
@.str.60 = private unnamed_addr constant [3 x i8] c"-N\00", align 1
@.str.61 = private unnamed_addr constant [12 x i8] c"--noconvert\00", align 1
@.str.62 = private unnamed_addr constant [40 x i8] c"Don't convert files from DOS/Mac format\00", align 1
@.str.63 = private unnamed_addr constant [3 x i8] c"-O\00", align 1
@.str.64 = private unnamed_addr constant [12 x i8] c"--bookstyle\00", align 1
@.str.65 = private unnamed_addr constant [39 x i8] c"Leading whitespace means new paragraph\00", align 1
@.str.66 = private unnamed_addr constant [3 x i8] c"-P\00", align 1
@.str.67 = private unnamed_addr constant [14 x i8] c"--positionlog\00", align 1
@.str.68 = private unnamed_addr constant [38 x i8] c"Save & restore position of the cursor\00", align 1
@.str.69 = private unnamed_addr constant [11 x i8] c"-Q <regex>\00", align 1
@.str.70 = private unnamed_addr constant [19 x i8] c"--quotestr=<regex>\00", align 1
@.str.71 = private unnamed_addr constant [36 x i8] c"Regular expression to match quoting\00", align 1
@.str.72 = private unnamed_addr constant [3 x i8] c"-R\00", align 1
@.str.73 = private unnamed_addr constant [13 x i8] c"--restricted\00", align 1
@.str.74 = private unnamed_addr constant [34 x i8] c"Restrict access to the filesystem\00", align 1
@.str.75 = private unnamed_addr constant [3 x i8] c"-S\00", align 1
@.str.76 = private unnamed_addr constant [11 x i8] c"--softwrap\00", align 1
@.str.77 = private unnamed_addr constant [40 x i8] c"Display overlong lines on multiple rows\00", align 1
@.str.78 = private unnamed_addr constant [12 x i8] c"-T <number>\00", align 1
@.str.79 = private unnamed_addr constant [19 x i8] c"--tabsize=<number>\00", align 1
@.str.80 = private unnamed_addr constant [39 x i8] c"Make a tab this number of columns wide\00", align 1
@.str.81 = private unnamed_addr constant [3 x i8] c"-U\00", align 1
@.str.82 = private unnamed_addr constant [13 x i8] c"--quickblank\00", align 1
@.str.83 = private unnamed_addr constant [36 x i8] c"Wipe status bar upon next keystroke\00", align 1
@.str.84 = private unnamed_addr constant [3 x i8] c"-V\00", align 1
@.str.85 = private unnamed_addr constant [10 x i8] c"--version\00", align 1
@.str.86 = private unnamed_addr constant [35 x i8] c"Print version information and exit\00", align 1
@.str.87 = private unnamed_addr constant [3 x i8] c"-W\00", align 1
@.str.88 = private unnamed_addr constant [13 x i8] c"--wordbounds\00", align 1
@.str.89 = private unnamed_addr constant [39 x i8] c"Detect word boundaries more accurately\00", align 1
@.str.90 = private unnamed_addr constant [12 x i8] c"-X <string>\00", align 1
@.str.91 = private unnamed_addr constant [21 x i8] c"--wordchars=<string>\00", align 1
@.str.92 = private unnamed_addr constant [38 x i8] c"Which other characters are word parts\00", align 1
@.str.93 = private unnamed_addr constant [10 x i8] c"-Y <name>\00", align 1
@.str.94 = private unnamed_addr constant [16 x i8] c"--syntax=<name>\00", align 1
@.str.95 = private unnamed_addr constant [38 x i8] c"Syntax definition to use for coloring\00", align 1
@.str.96 = private unnamed_addr constant [3 x i8] c"-Z\00", align 1
@.str.97 = private unnamed_addr constant [6 x i8] c"--zap\00", align 1
@.str.98 = private unnamed_addr constant [38 x i8] c"Let Bsp and Del erase a marked region\00", align 1
@.str.99 = private unnamed_addr constant [3 x i8] c"-a\00", align 1
@.str.100 = private unnamed_addr constant [11 x i8] c"--atblanks\00", align 1
@.str.101 = private unnamed_addr constant [40 x i8] c"When soft-wrapping, do it at whitespace\00", align 1
@.str.102 = private unnamed_addr constant [3 x i8] c"-b\00", align 1
@.str.103 = private unnamed_addr constant [17 x i8] c"--breaklonglines\00", align 1
@.str.104 = private unnamed_addr constant [39 x i8] c"Automatically hard-wrap overlong lines\00", align 1
@.str.105 = private unnamed_addr constant [3 x i8] c"-c\00", align 1
@.str.106 = private unnamed_addr constant [15 x i8] c"--constantshow\00", align 1
@.str.107 = private unnamed_addr constant [32 x i8] c"Constantly show cursor position\00", align 1
@.str.108 = private unnamed_addr constant [3 x i8] c"-d\00", align 1
@.str.109 = private unnamed_addr constant [15 x i8] c"--rebinddelete\00", align 1
@.str.110 = private unnamed_addr constant [39 x i8] c"Fix Backspace/Delete confusion problem\00", align 1
@.str.111 = private unnamed_addr constant [3 x i8] c"-e\00", align 1
@.str.112 = private unnamed_addr constant [12 x i8] c"--emptyline\00", align 1
@.str.113 = private unnamed_addr constant [40 x i8] c"Keep the line below the title bar empty\00", align 1
@.str.114 = private unnamed_addr constant [10 x i8] c"-f <file>\00", align 1
@.str.115 = private unnamed_addr constant [16 x i8] c"--rcfile=<file>\00", align 1
@.str.116 = private unnamed_addr constant [40 x i8] c"Use only this file for configuring nano\00", align 1
@.str.117 = private unnamed_addr constant [3 x i8] c"-g\00", align 1
@.str.118 = private unnamed_addr constant [13 x i8] c"--showcursor\00", align 1
@.str.119 = private unnamed_addr constant [40 x i8] c"Show cursor in file browser & help text\00", align 1
@.str.120 = private unnamed_addr constant [3 x i8] c"-h\00", align 1
@.str.121 = private unnamed_addr constant [7 x i8] c"--help\00", align 1
@.str.122 = private unnamed_addr constant [29 x i8] c"Show this help text and exit\00", align 1
@.str.123 = private unnamed_addr constant [3 x i8] c"-i\00", align 1
@.str.124 = private unnamed_addr constant [13 x i8] c"--autoindent\00", align 1
@.str.125 = private unnamed_addr constant [31 x i8] c"Automatically indent new lines\00", align 1
@.str.126 = private unnamed_addr constant [3 x i8] c"-j\00", align 1
@.str.127 = private unnamed_addr constant [17 x i8] c"--jumpyscrolling\00", align 1
@.str.128 = private unnamed_addr constant [37 x i8] c"Scroll per half-screen, not per line\00", align 1
@.str.129 = private unnamed_addr constant [3 x i8] c"-k\00", align 1
@.str.130 = private unnamed_addr constant [16 x i8] c"--cutfromcursor\00", align 1
@.str.131 = private unnamed_addr constant [31 x i8] c"Cut from cursor to end of line\00", align 1
@.str.132 = private unnamed_addr constant [3 x i8] c"-l\00", align 1
@.str.133 = private unnamed_addr constant [14 x i8] c"--linenumbers\00", align 1
@.str.134 = private unnamed_addr constant [39 x i8] c"Show line numbers in front of the text\00", align 1
@.str.135 = private unnamed_addr constant [3 x i8] c"-m\00", align 1
@.str.136 = private unnamed_addr constant [8 x i8] c"--mouse\00", align 1
@.str.137 = private unnamed_addr constant [28 x i8] c"Enable the use of the mouse\00", align 1
@.str.138 = private unnamed_addr constant [3 x i8] c"-n\00", align 1
@.str.139 = private unnamed_addr constant [9 x i8] c"--noread\00", align 1
@.str.140 = private unnamed_addr constant [37 x i8] c"Do not read the file (only write it)\00", align 1
@.str.141 = private unnamed_addr constant [9 x i8] c"-o <dir>\00", align 1
@.str.142 = private unnamed_addr constant [21 x i8] c"--operatingdir=<dir>\00", align 1
@.str.143 = private unnamed_addr constant [24 x i8] c"Set operating directory\00", align 1
@.str.144 = private unnamed_addr constant [3 x i8] c"-p\00", align 1
@.str.145 = private unnamed_addr constant [11 x i8] c"--preserve\00", align 1
@.str.146 = private unnamed_addr constant [37 x i8] c"Preserve XON (^Q) and XOFF (^S) keys\00", align 1
@.str.147 = private unnamed_addr constant [3 x i8] c"-q\00", align 1
@.str.148 = private unnamed_addr constant [12 x i8] c"--indicator\00", align 1
@.str.149 = private unnamed_addr constant [34 x i8] c"Show a position+portion indicator\00", align 1
@.str.150 = private unnamed_addr constant [12 x i8] c"-r <number>\00", align 1
@.str.151 = private unnamed_addr constant [16 x i8] c"--fill=<number>\00", align 1
@.str.152 = private unnamed_addr constant [36 x i8] c"Set width for hard-wrap and justify\00", align 1
@.str.153 = private unnamed_addr constant [13 x i8] c"-s <program>\00", align 1
@.str.154 = private unnamed_addr constant [20 x i8] c"--speller=<program>\00", align 1
@.str.155 = private unnamed_addr constant [35 x i8] c"Use this alternative spell checker\00", align 1
@.str.156 = private unnamed_addr constant [3 x i8] c"-t\00", align 1
@.str.157 = private unnamed_addr constant [13 x i8] c"--saveonexit\00", align 1
@.str.158 = private unnamed_addr constant [35 x i8] c"Save changes on exit, don't prompt\00", align 1
@.str.159 = private unnamed_addr constant [3 x i8] c"-u\00", align 1
@.str.160 = private unnamed_addr constant [7 x i8] c"--unix\00", align 1
@.str.161 = private unnamed_addr constant [38 x i8] c"Save a file by default in Unix format\00", align 1
@.str.162 = private unnamed_addr constant [3 x i8] c"-v\00", align 1
@.str.163 = private unnamed_addr constant [7 x i8] c"--view\00", align 1
@.str.164 = private unnamed_addr constant [22 x i8] c"View mode (read-only)\00", align 1
@.str.165 = private unnamed_addr constant [3 x i8] c"-w\00", align 1
@.str.166 = private unnamed_addr constant [9 x i8] c"--nowrap\00", align 1
@.str.167 = private unnamed_addr constant [37 x i8] c"Don't hard-wrap long lines [default]\00", align 1
@.str.168 = private unnamed_addr constant [3 x i8] c"-x\00", align 1
@.str.169 = private unnamed_addr constant [9 x i8] c"--nohelp\00", align 1
@.str.170 = private unnamed_addr constant [30 x i8] c"Don't show the two help lines\00", align 1
@.str.171 = private unnamed_addr constant [3 x i8] c"-y\00", align 1
@.str.172 = private unnamed_addr constant [12 x i8] c"--afterends\00", align 1
@.str.173 = private unnamed_addr constant [34 x i8] c"Make Ctrl+Right stop at word ends\00", align 1
@.str.174 = private unnamed_addr constant [3 x i8] c"-%\00", align 1
@.str.175 = private unnamed_addr constant [13 x i8] c"--stateflags\00", align 1
@.str.176 = private unnamed_addr constant [34 x i8] c"Show some states on the title bar\00", align 1
@.str.177 = private unnamed_addr constant [3 x i8] c"-_\00", align 1
@.str.178 = private unnamed_addr constant [10 x i8] c"--minibar\00", align 1
@.str.179 = private unnamed_addr constant [34 x i8] c"Show a feedback bar at the bottom\00", align 1
@.str.180 = private unnamed_addr constant [3 x i8] c"-0\00", align 1
@.str.181 = private unnamed_addr constant [7 x i8] c"--zero\00", align 1
@.str.182 = private unnamed_addr constant [34 x i8] c"Hide all bars, use whole terminal\00", align 1
@.str.183 = private unnamed_addr constant [24 x i8] c" GNU nano from git, %s\0A\00", align 1
@.str.184 = private unnamed_addr constant [18 x i8] c"v6.2-37-gc022c4cc\00", align 1
@.str.185 = private unnamed_addr constant [58 x i8] c" (C) 1999-2011, 2013-2022 Free Software Foundation, Inc.\0A\00", align 1
@.str.186 = private unnamed_addr constant [39 x i8] c" (C) 2014-%s the contributors to nano\0A\00", align 1
@.str.187 = private unnamed_addr constant [5 x i8] c"2022\00", align 1
@.str.188 = private unnamed_addr constant [19 x i8] c" Compiled options:\00", align 1
@.str.189 = private unnamed_addr constant [20 x i8] c" --disable-libmagic\00", align 1
@.str.190 = private unnamed_addr constant [15 x i8] c" --enable-utf8\00", align 1
@.str.191 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1
@control_C_was_pressed = external dso_local global i8, align 1
@newaction = internal global %struct.sigaction zeroinitializer, align 8
@oldaction = internal global %struct.sigaction zeroinitializer, align 8
@.str.192 = private unnamed_addr constant [9 x i8] c"/dev/tty\00", align 1
@.str.193 = private unnamed_addr constant [39 x i8] c"Could not reconnect stdin to keyboard\0A\00", align 1
@.str.194 = private unnamed_addr constant [56 x i8] c"Reading data from keyboard; type ^D or ^D^D to finish.\0A\00", align 1
@.str.195 = private unnamed_addr constant [11 x i8] c"/dev/stdin\00", align 1
@.str.196 = private unnamed_addr constant [3 x i8] c"rb\00", align 1
@.str.197 = private unnamed_addr constant [25 x i8] c"Failed to open stdin: %s\00", align 1
@.str.198 = private unnamed_addr constant [6 x i8] c"stdin\00", align 1
@.str.199 = private unnamed_addr constant [13 x i8] c"NANO_NOCATCH\00", align 1
@.str.200 = private unnamed_addr constant [28 x i8] c"Received SIGHUP or SIGTERM\0A\00", align 1
@.str.201 = private unnamed_addr constant [55 x i8] c"Sorry! Nano crashed!  Code: %d.  Please report a bug.\0A\00", align 1
@.str.202 = private unnamed_addr constant [3 x i8] c"\0A\0A\00", align 1
@.str.203 = private unnamed_addr constant [29 x i8] c"Use \22fg\22 to return to nano.\0A\00", align 1
@lastmessage = external dso_local global i32, align 4
@ran_a_tool = external dso_local global i8, align 1
@the_window_resized = external dso_local global i32, align 4
@stdscr = external dso_local global %struct._win_st*, align 8
@thebar = external dso_local global i32, align 4
@bardata = external dso_local global i32*, align 8
@margin = external dso_local global i32, align 4
@editwincols = external dso_local global i32, align 4
@focusing = external dso_local global i8, align 1
@.str.204 = private unnamed_addr constant [9 x i8] c"Too tiny\00", align 1
@.str.205 = private unnamed_addr constant [13 x i8] c"Not possible\00", align 1
@refresh_needed = external dso_local global i8, align 1
@.str.206 = private unnamed_addr constant [30 x i8] c"Current syntax determines Tab\00", align 1
@.str.207 = private unnamed_addr constant [6 x i8] c"%s %s\00", align 1
@.str.208 = private unnamed_addr constant [8 x i8] c"enabled\00", align 1
@.str.209 = private unnamed_addr constant [9 x i8] c"disabled\00", align 1
@.str.210 = private unnamed_addr constant [9 x i8] c"\1B[?2004h\00", align 1
@.str.211 = private unnamed_addr constant [17 x i8] c"Unknown sequence\00", align 1
@.str.212 = private unnamed_addr constant [17 x i8] c"Unbound key: F%i\00", align 1
@.str.213 = private unnamed_addr constant [12 x i8] c"Unbound key\00", align 1
@meta_key = external dso_local global i8, align 1
@.str.214 = private unnamed_addr constant [22 x i8] c"Unbindable key: M-^%c\00", align 1
@shifted_metas = external dso_local global i8, align 1
@.str.215 = private unnamed_addr constant [21 x i8] c"Unbound key: Sh-M-%c\00", align 1
@.str.216 = private unnamed_addr constant [18 x i8] c"Unbound key: M-%c\00", align 1
@.str.217 = private unnamed_addr constant [19 x i8] c"Unbindable key: ^[\00", align 1
@.str.218 = private unnamed_addr constant [17 x i8] c"Unbound key: ^%c\00", align 1
@.str.219 = private unnamed_addr constant [16 x i8] c"Unbound key: %c\00", align 1
@keep_cutbuffer = external dso_local global i8, align 1
@allfuncs = external dso_local global %struct.funcstruct*, align 8
@cutbuffer = external dso_local global %struct.linestruct*, align 8
@.str.220 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@bracketed_paste = external dso_local global i8, align 1
@process_a_keystroke.puddle = internal global i8* null, align 8
@process_a_keystroke.depth = internal global i64 0, align 8
@process_a_keystroke.give_a_hint = internal global i8 1, align 1
@pletion_line = external dso_local global %struct.linestruct*, align 8
@.str.221 = private unnamed_addr constant [27 x i8] c"^W = Ctrl+W    M-W = Alt+W\00", align 1
@shift_held = external dso_local global i8, align 1
@also_the_last = external dso_local global i8, align 1
@.str.222 = private unnamed_addr constant [9 x i8] c"boldtext\00", align 1
@.str.223 = private unnamed_addr constant [12 x i8] c"multibuffer\00", align 1
@.str.224 = private unnamed_addr constant [14 x i8] c"ignorercfiles\00", align 1
@.str.225 = private unnamed_addr constant [13 x i8] c"rawsequences\00", align 1
@.str.226 = private unnamed_addr constant [11 x i8] c"trimblanks\00", align 1
@.str.227 = private unnamed_addr constant [9 x i8] c"quotestr\00", align 1
@.str.228 = private unnamed_addr constant [11 x i8] c"restricted\00", align 1
@.str.229 = private unnamed_addr constant [11 x i8] c"quickblank\00", align 1
@.str.230 = private unnamed_addr constant [8 x i8] c"version\00", align 1
@.str.231 = private unnamed_addr constant [7 x i8] c"syntax\00", align 1
@.str.232 = private unnamed_addr constant [15 x i8] c"breaklonglines\00", align 1
@.str.233 = private unnamed_addr constant [13 x i8] c"constantshow\00", align 1
@.str.234 = private unnamed_addr constant [13 x i8] c"rebinddelete\00", align 1
@.str.235 = private unnamed_addr constant [7 x i8] c"rcfile\00", align 1
@.str.236 = private unnamed_addr constant [11 x i8] c"showcursor\00", align 1
@.str.237 = private unnamed_addr constant [5 x i8] c"help\00", align 1
@.str.238 = private unnamed_addr constant [12 x i8] c"linenumbers\00", align 1
@.str.239 = private unnamed_addr constant [6 x i8] c"mouse\00", align 1
@.str.240 = private unnamed_addr constant [13 x i8] c"operatingdir\00", align 1
@.str.241 = private unnamed_addr constant [9 x i8] c"preserve\00", align 1
@.str.242 = private unnamed_addr constant [5 x i8] c"fill\00", align 1
@.str.243 = private unnamed_addr constant [8 x i8] c"speller\00", align 1
@.str.244 = private unnamed_addr constant [11 x i8] c"saveonexit\00", align 1
@.str.245 = private unnamed_addr constant [9 x i8] c"tempfile\00", align 1
@.str.246 = private unnamed_addr constant [5 x i8] c"view\00", align 1
@.str.247 = private unnamed_addr constant [7 x i8] c"nowrap\00", align 1
@.str.248 = private unnamed_addr constant [7 x i8] c"nohelp\00", align 1
@.str.249 = private unnamed_addr constant [12 x i8] c"suspendable\00", align 1
@.str.250 = private unnamed_addr constant [10 x i8] c"smarthome\00", align 1
@.str.251 = private unnamed_addr constant [7 x i8] c"backup\00", align 1
@.str.252 = private unnamed_addr constant [10 x i8] c"backupdir\00", align 1
@.str.253 = private unnamed_addr constant [13 x i8] c"tabstospaces\00", align 1
@.str.254 = private unnamed_addr constant [8 x i8] c"locking\00", align 1
@.str.255 = private unnamed_addr constant [11 x i8] c"historylog\00", align 1
@.str.256 = private unnamed_addr constant [12 x i8] c"guidestripe\00", align 1
@.str.257 = private unnamed_addr constant [11 x i8] c"nonewlines\00", align 1
@.str.258 = private unnamed_addr constant [10 x i8] c"noconvert\00", align 1
@.str.259 = private unnamed_addr constant [10 x i8] c"bookstyle\00", align 1
@.str.260 = private unnamed_addr constant [12 x i8] c"positionlog\00", align 1
@.str.261 = private unnamed_addr constant [9 x i8] c"softwrap\00", align 1
@.str.262 = private unnamed_addr constant [8 x i8] c"tabsize\00", align 1
@.str.263 = private unnamed_addr constant [11 x i8] c"wordbounds\00", align 1
@.str.264 = private unnamed_addr constant [10 x i8] c"wordchars\00", align 1
@.str.265 = private unnamed_addr constant [4 x i8] c"zap\00", align 1
@.str.266 = private unnamed_addr constant [9 x i8] c"atblanks\00", align 1
@.str.267 = private unnamed_addr constant [10 x i8] c"emptyline\00", align 1
@.str.268 = private unnamed_addr constant [11 x i8] c"autoindent\00", align 1
@.str.269 = private unnamed_addr constant [15 x i8] c"jumpyscrolling\00", align 1
@.str.270 = private unnamed_addr constant [14 x i8] c"cutfromcursor\00", align 1
@.str.271 = private unnamed_addr constant [7 x i8] c"noread\00", align 1
@.str.272 = private unnamed_addr constant [10 x i8] c"indicator\00", align 1
@.str.273 = private unnamed_addr constant [5 x i8] c"unix\00", align 1
@.str.274 = private unnamed_addr constant [10 x i8] c"afterends\00", align 1
@.str.275 = private unnamed_addr constant [11 x i8] c"stateflags\00", align 1
@.str.276 = private unnamed_addr constant [8 x i8] c"minibar\00", align 1
@.str.277 = private unnamed_addr constant [5 x i8] c"zero\00", align 1
@__const.main.long_options = private unnamed_addr constant [57 x %struct.option] [%struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.222, i32 0, i32 0), i32 0, i32* null, i32 68 }, %struct.option { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.223, i32 0, i32 0), i32 0, i32* null, i32 70 }, %struct.option { i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.224, i32 0, i32 0), i32 0, i32* null, i32 73 }, %struct.option { i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.225, i32 0, i32 0), i32 0, i32* null, i32 75 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.226, i32 0, i32 0), i32 0, i32* null, i32 77 }, %struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.227, i32 0, i32 0), i32 1, i32* null, i32 81 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.228, i32 0, i32 0), i32 0, i32* null, i32 82 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.229, i32 0, i32 0), i32 0, i32* null, i32 85 }, %struct.option { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.230, i32 0, i32 0), i32 0, i32* null, i32 86 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.231, i32 0, i32 0), i32 1, i32* null, i32 89 }, %struct.option { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.232, i32 0, i32 0), i32 0, i32* null, i32 98 }, %struct.option { i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.233, i32 0, i32 0), i32 0, i32* null, i32 99 }, %struct.option { i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.234, i32 0, i32 0), i32 0, i32* null, i32 100 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.235, i32 0, i32 0), i32 1, i32* null, i32 102 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.236, i32 0, i32 0), i32 0, i32* null, i32 103 }, %struct.option { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.237, i32 0, i32 0), i32 0, i32* null, i32 104 }, %struct.option { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.238, i32 0, i32 0), i32 0, i32* null, i32 108 }, %struct.option { i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.239, i32 0, i32 0), i32 0, i32* null, i32 109 }, %struct.option { i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.240, i32 0, i32 0), i32 1, i32* null, i32 111 }, %struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.241, i32 0, i32 0), i32 0, i32* null, i32 112 }, %struct.option { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.242, i32 0, i32 0), i32 1, i32* null, i32 114 }, %struct.option { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.243, i32 0, i32 0), i32 1, i32* null, i32 115 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.244, i32 0, i32 0), i32 0, i32* null, i32 116 }, %struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.245, i32 0, i32 0), i32 0, i32* null, i32 116 }, %struct.option { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.246, i32 0, i32 0), i32 0, i32* null, i32 118 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.247, i32 0, i32 0), i32 0, i32* null, i32 119 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.248, i32 0, i32 0), i32 0, i32* null, i32 120 }, %struct.option { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.249, i32 0, i32 0), i32 0, i32* null, i32 122 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.250, i32 0, i32 0), i32 0, i32* null, i32 65 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.251, i32 0, i32 0), i32 0, i32* null, i32 66 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.252, i32 0, i32 0), i32 1, i32* null, i32 67 }, %struct.option { i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.253, i32 0, i32 0), i32 0, i32* null, i32 69 }, %struct.option { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.254, i32 0, i32 0), i32 0, i32* null, i32 71 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.255, i32 0, i32 0), i32 0, i32* null, i32 72 }, %struct.option { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.256, i32 0, i32 0), i32 1, i32* null, i32 74 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.257, i32 0, i32 0), i32 0, i32* null, i32 76 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.258, i32 0, i32 0), i32 0, i32* null, i32 78 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.259, i32 0, i32 0), i32 0, i32* null, i32 79 }, %struct.option { i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.260, i32 0, i32 0), i32 0, i32* null, i32 80 }, %struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.261, i32 0, i32 0), i32 0, i32* null, i32 83 }, %struct.option { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.262, i32 0, i32 0), i32 1, i32* null, i32 84 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.263, i32 0, i32 0), i32 0, i32* null, i32 87 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.264, i32 0, i32 0), i32 1, i32* null, i32 88 }, %struct.option { i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.265, i32 0, i32 0), i32 0, i32* null, i32 90 }, %struct.option { i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.266, i32 0, i32 0), i32 0, i32* null, i32 97 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.267, i32 0, i32 0), i32 0, i32* null, i32 101 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.268, i32 0, i32 0), i32 0, i32* null, i32 105 }, %struct.option { i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.269, i32 0, i32 0), i32 0, i32* null, i32 106 }, %struct.option { i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.270, i32 0, i32 0), i32 0, i32* null, i32 107 }, %struct.option { i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.271, i32 0, i32 0), i32 0, i32* null, i32 110 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.272, i32 0, i32 0), i32 0, i32* null, i32 113 }, %struct.option { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.273, i32 0, i32 0), i32 0, i32* null, i32 117 }, %struct.option { i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.274, i32 0, i32 0), i32 0, i32* null, i32 121 }, %struct.option { i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.275, i32 0, i32 0), i32 0, i32* null, i32 37 }, %struct.option { i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.276, i32 0, i32 0), i32 0, i32* null, i32 95 }, %struct.option { i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.277, i32 0, i32 0), i32 0, i32* null, i32 48 }, %struct.option zeroinitializer], align 16
@on_a_vt = external dso_local global i8, align 1
@.str.278 = private unnamed_addr constant [6 x i8] c"UTF-8\00", align 1
@.str.279 = private unnamed_addr constant [5 x i8] c"nano\00", align 1
@.str.280 = private unnamed_addr constant [24 x i8] c"/usr/local/share/locale\00", align 1
@.str.281 = private unnamed_addr constant [68 x i8] c"0ABC:DEFGHIJ:KLMNOPQ:RST:UVWX:Y:Zabcdef:ghijklmno:pqr:s:tuvwxyz$%_!\00", align 1
@backup_dir = external dso_local global i8*, align 8
@optarg = external dso_local global i8*, align 8
@stripe_column = external dso_local global i64, align 8
@.str.282 = private unnamed_addr constant [29 x i8] c"Guide column \22%s\22 is invalid\00", align 1
@quotestr = external dso_local global i8*, align 8
@tabsize = external dso_local global i64, align 8
@.str.283 = private unnamed_addr constant [35 x i8] c"Requested tab size \22%s\22 is invalid\00", align 1
@word_chars = external dso_local global i8*, align 8
@syntaxstr = external dso_local global i8*, align 8
@custom_nanorc = external dso_local global i8*, align 8
@operating_dir = external dso_local global i8*, align 8
@.str.284 = private unnamed_addr constant [36 x i8] c"Requested fill size \22%s\22 is invalid\00", align 1
@alt_speller = external dso_local global i8*, align 8
@.str.285 = private unnamed_addr constant [47 x i8] c"Type '%s -h' for a list of available options.\0A\00", align 1
@.str.286 = private unnamed_addr constant [5 x i8] c"TERM\00", align 1
@.str.287 = private unnamed_addr constant [11 x i8] c"TERM=vt220\00", align 1
@.str.288 = private unnamed_addr constant [9 x i8] c"NO_COLOR\00", align 1
@rescind_colors = external dso_local global i8, align 1
@hilite_attribute = external dso_local global i32, align 4
@punct = external dso_local global i8*, align 8
@.str.289 = private unnamed_addr constant [4 x i8] c"!.?\00", align 1
@brackets = external dso_local global i8*, align 8
@.str.290 = private unnamed_addr constant [7 x i8] c"\22')>]}\00", align 1
@.str.291 = private unnamed_addr constant [27 x i8] c"^([ \09]*([!#%:;>|}]|/{2}))+\00", align 1
@quotereg = external dso_local global %struct.re_pattern_buffer, align 8
@.str.292 = private unnamed_addr constant [28 x i8] c"Bad quoting regex \22%s\22: %s\0A\00", align 1
@.str.293 = private unnamed_addr constant [6 x i8] c"SPELL\00", align 1
@matchbrackets = external dso_local global i8*, align 8
@.str.294 = private unnamed_addr constant [9 x i8] c"(<[{)>]}\00", align 1
@whitespace = external dso_local global i8*, align 8
@.str.295 = private unnamed_addr constant [5 x i8] c"\C2\BB\C2\B7\00", align 1
@whitelen = external dso_local global [2 x i32], align 4
@.str.296 = private unnamed_addr constant [3 x i8] c">.\00", align 1
@last_search = external dso_local global i8*, align 8
@interface_color_pair = external dso_local global [12 x i32], align 16
@.str.297 = private unnamed_addr constant [6 x i8] c"kLFT5\00", align 1
@controlleft = external dso_local global i32, align 4
@.str.298 = private unnamed_addr constant [6 x i8] c"kRIT5\00", align 1
@controlright = external dso_local global i32, align 4
@.str.299 = private unnamed_addr constant [5 x i8] c"kUP5\00", align 1
@controlup = external dso_local global i32, align 4
@.str.300 = private unnamed_addr constant [5 x i8] c"kDN5\00", align 1
@controldown = external dso_local global i32, align 4
@.str.301 = private unnamed_addr constant [6 x i8] c"kHOM5\00", align 1
@controlhome = external dso_local global i32, align 4
@.str.302 = private unnamed_addr constant [6 x i8] c"kEND5\00", align 1
@controlend = external dso_local global i32, align 4
@.str.303 = private unnamed_addr constant [5 x i8] c"kDC5\00", align 1
@controldelete = external dso_local global i32, align 4
@.str.304 = private unnamed_addr constant [5 x i8] c"kDC6\00", align 1
@controlshiftdelete = external dso_local global i32, align 4
@.str.305 = private unnamed_addr constant [4 x i8] c"kUP\00", align 1
@shiftup = external dso_local global i32, align 4
@.str.306 = private unnamed_addr constant [4 x i8] c"kDN\00", align 1
@shiftdown = external dso_local global i32, align 4
@.str.307 = private unnamed_addr constant [6 x i8] c"kLFT6\00", align 1
@shiftcontrolleft = external dso_local global i32, align 4
@.str.308 = private unnamed_addr constant [6 x i8] c"kRIT6\00", align 1
@shiftcontrolright = external dso_local global i32, align 4
@.str.309 = private unnamed_addr constant [5 x i8] c"kUP6\00", align 1
@shiftcontrolup = external dso_local global i32, align 4
@.str.310 = private unnamed_addr constant [5 x i8] c"kDN6\00", align 1
@shiftcontroldown = external dso_local global i32, align 4
@.str.311 = private unnamed_addr constant [6 x i8] c"kHOM6\00", align 1
@shiftcontrolhome = external dso_local global i32, align 4
@.str.312 = private unnamed_addr constant [6 x i8] c"kEND6\00", align 1
@shiftcontrolend = external dso_local global i32, align 4
@.str.313 = private unnamed_addr constant [6 x i8] c"kLFT3\00", align 1
@altleft = external dso_local global i32, align 4
@.str.314 = private unnamed_addr constant [6 x i8] c"kRIT3\00", align 1
@altright = external dso_local global i32, align 4
@.str.315 = private unnamed_addr constant [5 x i8] c"kUP3\00", align 1
@altup = external dso_local global i32, align 4
@.str.316 = private unnamed_addr constant [5 x i8] c"kDN3\00", align 1
@altdown = external dso_local global i32, align 4
@.str.317 = private unnamed_addr constant [6 x i8] c"kPRV3\00", align 1
@altpageup = external dso_local global i32, align 4
@.str.318 = private unnamed_addr constant [6 x i8] c"kNXT3\00", align 1
@altpagedown = external dso_local global i32, align 4
@.str.319 = private unnamed_addr constant [5 x i8] c"kIC3\00", align 1
@altinsert = external dso_local global i32, align 4
@.str.320 = private unnamed_addr constant [5 x i8] c"kDC3\00", align 1
@altdelete = external dso_local global i32, align 4
@.str.321 = private unnamed_addr constant [6 x i8] c"kLFT4\00", align 1
@shiftaltleft = external dso_local global i32, align 4
@.str.322 = private unnamed_addr constant [6 x i8] c"kRIT4\00", align 1
@shiftaltright = external dso_local global i32, align 4
@.str.323 = private unnamed_addr constant [5 x i8] c"kUP4\00", align 1
@shiftaltup = external dso_local global i32, align 4
@.str.324 = private unnamed_addr constant [5 x i8] c"kDN4\00", align 1
@shiftaltdown = external dso_local global i32, align 4
@optind = external dso_local global i32, align 4
@.str.325 = private unnamed_addr constant [29 x i8] c"Invalid search modifier '%c'\00", align 1
@.str.326 = private unnamed_addr constant [20 x i8] c"Empty search string\00", align 1
@.str.327 = private unnamed_addr constant [30 x i8] c"Invalid line or column number\00", align 1
@.str.328 = private unnamed_addr constant [2 x i8] c"-\00", align 1
@more_than_one = external dso_local global i8, align 1
@startup_problem = external dso_local global i8*, align 8
@.str.329 = private unnamed_addr constant [47 x i8] c"Welcome to nano.  For basic help, type Ctrl+G.\00", align 1
@we_are_running = external dso_local global i8, align 1
@mute_modifiers = external dso_local global i8, align 1
@currmenu = external dso_local global i32, align 4
@as_an_at = external dso_local global i8, align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.linestruct* @make_new_node(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %4 = call i8* @nmalloc(i64 48)
  %5 = bitcast i8* %4 to %struct.linestruct*
  store %struct.linestruct* %5, %struct.linestruct** %3, align 8
  %6 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %7 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %8 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %7, i32 0, i32 3
  store %struct.linestruct* %6, %struct.linestruct** %8, align 8
  %9 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %10 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %9, i32 0, i32 2
  store %struct.linestruct* null, %struct.linestruct** %10, align 8
  %11 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %12 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %11, i32 0, i32 0
  store i8* null, i8** %12, align 8
  %13 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %14 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %13, i32 0, i32 4
  store i16* null, i16** %14, align 8
  %15 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %16 = icmp ne %struct.linestruct* %15, null
  br i1 %16, label %17, label %22

17:                                               ; preds = %1
  %18 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %19 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %18, i32 0, i32 1
  %20 = load i64, i64* %19, align 8
  %21 = add nsw i64 %20, 1
  br label %23

22:                                               ; preds = %1
  br label %23

23:                                               ; preds = %22, %17
  %24 = phi i64 [ %21, %17 ], [ 1, %22 ]
  %25 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %26 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %25, i32 0, i32 1
  store i64 %24, i64* %26, align 8
  %27 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %28 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %27, i32 0, i32 5
  store i8 0, i8* %28, align 8
  %29 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  ret %struct.linestruct* %29
}

declare dso_local i8* @nmalloc(i64) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @splice_node(%struct.linestruct* %0, %struct.linestruct* %1) #0 {
  %3 = alloca %struct.linestruct*, align 8
  %4 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %3, align 8
  store %struct.linestruct* %1, %struct.linestruct** %4, align 8
  %5 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %6 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %5, i32 0, i32 2
  %7 = load %struct.linestruct*, %struct.linestruct** %6, align 8
  %8 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %9 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %8, i32 0, i32 2
  store %struct.linestruct* %7, %struct.linestruct** %9, align 8
  %10 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %11 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %12 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %11, i32 0, i32 3
  store %struct.linestruct* %10, %struct.linestruct** %12, align 8
  %13 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %14 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %13, i32 0, i32 2
  %15 = load %struct.linestruct*, %struct.linestruct** %14, align 8
  %16 = icmp ne %struct.linestruct* %15, null
  br i1 %16, label %17, label %23

17:                                               ; preds = %2
  %18 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %19 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %20 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %19, i32 0, i32 2
  %21 = load %struct.linestruct*, %struct.linestruct** %20, align 8
  %22 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %21, i32 0, i32 3
  store %struct.linestruct* %18, %struct.linestruct** %22, align 8
  br label %23

23:                                               ; preds = %17, %2
  %24 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %25 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %26 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %25, i32 0, i32 2
  store %struct.linestruct* %24, %struct.linestruct** %26, align 8
  %27 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %28 = icmp ne %struct.openfilestruct* %27, null
  br i1 %28, label %29, label %39

29:                                               ; preds = %23
  %30 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %31 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %30, i32 0, i32 2
  %32 = load %struct.linestruct*, %struct.linestruct** %31, align 8
  %33 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %34 = icmp eq %struct.linestruct* %32, %33
  br i1 %34, label %35, label %39

35:                                               ; preds = %29
  %36 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %37 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %38 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %37, i32 0, i32 2
  store %struct.linestruct* %36, %struct.linestruct** %38, align 8
  br label %39

39:                                               ; preds = %35, %29, %23
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @delete_node(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %3 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %4 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %5 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %4, i32 0, i32 3
  %6 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %7 = icmp eq %struct.linestruct* %3, %6
  br i1 %7, label %8, label %14

8:                                                ; preds = %1
  %9 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %10 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %9, i32 0, i32 3
  %11 = load %struct.linestruct*, %struct.linestruct** %10, align 8
  %12 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %13 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %12, i32 0, i32 3
  store %struct.linestruct* %11, %struct.linestruct** %13, align 8
  br label %14

14:                                               ; preds = %8, %1
  %15 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %16 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %17 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %16, i32 0, i32 11
  %18 = load %struct.linestruct*, %struct.linestruct** %17, align 8
  %19 = icmp eq %struct.linestruct* %15, %18
  br i1 %19, label %20, label %23

20:                                               ; preds = %14
  %21 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %22 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %21, i32 0, i32 11
  store %struct.linestruct* null, %struct.linestruct** %22, align 8
  br label %23

23:                                               ; preds = %20, %14
  %24 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %25 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %24, i32 0, i32 0
  %26 = load i8*, i8** %25, align 8
  call void @rpl_free(i8* %26)
  %27 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %28 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %27, i32 0, i32 4
  %29 = load i16*, i16** %28, align 8
  %30 = bitcast i16* %29 to i8*
  call void @rpl_free(i8* %30)
  %31 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %32 = bitcast %struct.linestruct* %31 to i8*
  call void @rpl_free(i8* %32)
  ret void
}

declare dso_local void @rpl_free(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @unlink_node(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %3 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %4 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %3, i32 0, i32 3
  %5 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %6 = icmp ne %struct.linestruct* %5, null
  br i1 %6, label %7, label %15

7:                                                ; preds = %1
  %8 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %9 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %8, i32 0, i32 2
  %10 = load %struct.linestruct*, %struct.linestruct** %9, align 8
  %11 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %12 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %11, i32 0, i32 3
  %13 = load %struct.linestruct*, %struct.linestruct** %12, align 8
  %14 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %13, i32 0, i32 2
  store %struct.linestruct* %10, %struct.linestruct** %14, align 8
  br label %15

15:                                               ; preds = %7, %1
  %16 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %17 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %16, i32 0, i32 2
  %18 = load %struct.linestruct*, %struct.linestruct** %17, align 8
  %19 = icmp ne %struct.linestruct* %18, null
  br i1 %19, label %20, label %28

20:                                               ; preds = %15
  %21 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %22 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %21, i32 0, i32 3
  %23 = load %struct.linestruct*, %struct.linestruct** %22, align 8
  %24 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %25 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %24, i32 0, i32 2
  %26 = load %struct.linestruct*, %struct.linestruct** %25, align 8
  %27 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %26, i32 0, i32 3
  store %struct.linestruct* %23, %struct.linestruct** %27, align 8
  br label %28

28:                                               ; preds = %20, %15
  %29 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %30 = icmp ne %struct.openfilestruct* %29, null
  br i1 %30, label %31, label %43

31:                                               ; preds = %28
  %32 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %33 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %32, i32 0, i32 2
  %34 = load %struct.linestruct*, %struct.linestruct** %33, align 8
  %35 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %36 = icmp eq %struct.linestruct* %34, %35
  br i1 %36, label %37, label %43

37:                                               ; preds = %31
  %38 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %39 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %38, i32 0, i32 3
  %40 = load %struct.linestruct*, %struct.linestruct** %39, align 8
  %41 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %42 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %41, i32 0, i32 2
  store %struct.linestruct* %40, %struct.linestruct** %42, align 8
  br label %43

43:                                               ; preds = %37, %31, %28
  %44 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  call void @delete_node(%struct.linestruct* %44)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @free_lines(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %3 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %4 = icmp eq %struct.linestruct* %3, null
  br i1 %4, label %5, label %6

5:                                                ; preds = %1
  br label %21

6:                                                ; preds = %1
  br label %7

7:                                                ; preds = %12, %6
  %8 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %9 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %8, i32 0, i32 2
  %10 = load %struct.linestruct*, %struct.linestruct** %9, align 8
  %11 = icmp ne %struct.linestruct* %10, null
  br i1 %11, label %12, label %19

12:                                               ; preds = %7
  %13 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %14 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %13, i32 0, i32 2
  %15 = load %struct.linestruct*, %struct.linestruct** %14, align 8
  store %struct.linestruct* %15, %struct.linestruct** %2, align 8
  %16 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %17 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %16, i32 0, i32 3
  %18 = load %struct.linestruct*, %struct.linestruct** %17, align 8
  call void @delete_node(%struct.linestruct* %18)
  br label %7

19:                                               ; preds = %7
  %20 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  call void @delete_node(%struct.linestruct* %20)
  br label %21

21:                                               ; preds = %19, %5
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.linestruct* @copy_node(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %4 = call i8* @nmalloc(i64 48)
  %5 = bitcast i8* %4 to %struct.linestruct*
  store %struct.linestruct* %5, %struct.linestruct** %3, align 8
  %6 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %7 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %6, i32 0, i32 0
  %8 = load i8*, i8** %7, align 8
  %9 = call i8* @copy_of(i8* %8)
  %10 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %11 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %10, i32 0, i32 0
  store i8* %9, i8** %11, align 8
  %12 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %13 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %12, i32 0, i32 4
  store i16* null, i16** %13, align 8
  %14 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %15 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %14, i32 0, i32 1
  %16 = load i64, i64* %15, align 8
  %17 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %18 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %17, i32 0, i32 1
  store i64 %16, i64* %18, align 8
  %19 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %20 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %19, i32 0, i32 5
  %21 = load i8, i8* %20, align 8
  %22 = trunc i8 %21 to i1
  %23 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %24 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %23, i32 0, i32 5
  %25 = zext i1 %22 to i8
  store i8 %25, i8* %24, align 8
  %26 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  ret %struct.linestruct* %26
}

declare dso_local i8* @copy_of(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.linestruct* @copy_buffer(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca %struct.linestruct*, align 8
  %4 = alloca %struct.linestruct*, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %5 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %6 = call %struct.linestruct* @copy_node(%struct.linestruct* %5)
  store %struct.linestruct* %6, %struct.linestruct** %3, align 8
  %7 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  %8 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %7, i32 0, i32 3
  store %struct.linestruct* null, %struct.linestruct** %8, align 8
  %9 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  store %struct.linestruct* %9, %struct.linestruct** %4, align 8
  %10 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %11 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %10, i32 0, i32 2
  %12 = load %struct.linestruct*, %struct.linestruct** %11, align 8
  store %struct.linestruct* %12, %struct.linestruct** %2, align 8
  br label %13

13:                                               ; preds = %16, %1
  %14 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %15 = icmp ne %struct.linestruct* %14, null
  br i1 %15, label %16, label %32

16:                                               ; preds = %13
  %17 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %18 = call %struct.linestruct* @copy_node(%struct.linestruct* %17)
  %19 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %20 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %19, i32 0, i32 2
  store %struct.linestruct* %18, %struct.linestruct** %20, align 8
  %21 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %22 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %23 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %22, i32 0, i32 2
  %24 = load %struct.linestruct*, %struct.linestruct** %23, align 8
  %25 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %24, i32 0, i32 3
  store %struct.linestruct* %21, %struct.linestruct** %25, align 8
  %26 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %27 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %26, i32 0, i32 2
  %28 = load %struct.linestruct*, %struct.linestruct** %27, align 8
  store %struct.linestruct* %28, %struct.linestruct** %4, align 8
  %29 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %30 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %29, i32 0, i32 2
  %31 = load %struct.linestruct*, %struct.linestruct** %30, align 8
  store %struct.linestruct* %31, %struct.linestruct** %2, align 8
  br label %13

32:                                               ; preds = %13
  %33 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %34 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %33, i32 0, i32 2
  store %struct.linestruct* null, %struct.linestruct** %34, align 8
  %35 = load %struct.linestruct*, %struct.linestruct** %3, align 8
  ret %struct.linestruct* %35
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @renumber_from(%struct.linestruct* %0) #0 {
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca i64, align 8
  store %struct.linestruct* %0, %struct.linestruct** %2, align 8
  %4 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %5 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %4, i32 0, i32 3
  %6 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %7 = icmp eq %struct.linestruct* %6, null
  br i1 %7, label %8, label %9

8:                                                ; preds = %1
  br label %15

9:                                                ; preds = %1
  %10 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %11 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %10, i32 0, i32 3
  %12 = load %struct.linestruct*, %struct.linestruct** %11, align 8
  %13 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %12, i32 0, i32 1
  %14 = load i64, i64* %13, align 8
  br label %15

15:                                               ; preds = %9, %8
  %16 = phi i64 [ 0, %8 ], [ %14, %9 ]
  store i64 %16, i64* %3, align 8
  br label %17

17:                                               ; preds = %20, %15
  %18 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %19 = icmp ne %struct.linestruct* %18, null
  br i1 %19, label %20, label %28

20:                                               ; preds = %17
  %21 = load i64, i64* %3, align 8
  %22 = add nsw i64 %21, 1
  store i64 %22, i64* %3, align 8
  %23 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %24 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %23, i32 0, i32 1
  store i64 %22, i64* %24, align 8
  %25 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %26 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %25, i32 0, i32 2
  %27 = load %struct.linestruct*, %struct.linestruct** %26, align 8
  store %struct.linestruct* %27, %struct.linestruct** %2, align 8
  br label %17

28:                                               ; preds = %17
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @print_view_warning() #0 {
  %1 = call i8* @gettext(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %1)
  ret void
}

declare dso_local void @statusline(i32, i8*, ...) #1

; Function Attrs: nounwind
declare dso_local i8* @gettext(i8*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @in_restricted_mode() #0 {
  %1 = alloca i1, align 1
  %2 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %3 = and i32 %2, 4194304
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %5, label %8

5:                                                ; preds = %0
  %6 = call i8* @gettext(i8* getelementptr inbounds ([45 x i8], [45 x i8]* @.str.1, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %6)
  %7 = call i32 @beep()
  store i1 true, i1* %1, align 1
  br label %9

8:                                                ; preds = %0
  store i1 false, i1* %1, align 1
  br label %9

9:                                                ; preds = %8, %5
  %10 = load i1, i1* %1, align 1
  ret i1 %10
}

declare dso_local i32 @beep() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @suggest_ctrlT_ctrlZ() #0 {
  %1 = call %struct.keystruct* @first_sc_for(i32 1, void ()* @do_execute)
  %2 = icmp ne %struct.keystruct* %1, null
  br i1 %2, label %3, label %18

3:                                                ; preds = %0
  %4 = call %struct.keystruct* @first_sc_for(i32 1, void ()* @do_execute)
  %5 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %4, i32 0, i32 1
  %6 = load i32, i32* %5, align 8
  %7 = icmp eq i32 %6, 20
  br i1 %7, label %8, label %18

8:                                                ; preds = %3
  %9 = call %struct.keystruct* @first_sc_for(i32 128, void ()* @do_suspend)
  %10 = icmp ne %struct.keystruct* %9, null
  br i1 %10, label %11, label %18

11:                                               ; preds = %8
  %12 = call %struct.keystruct* @first_sc_for(i32 128, void ()* @do_suspend)
  %13 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %12, i32 0, i32 1
  %14 = load i32, i32* %13, align 8
  %15 = icmp eq i32 %14, 26
  br i1 %15, label %16, label %18

16:                                               ; preds = %11
  %17 = call i8* @gettext(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.2, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %17)
  br label %18

18:                                               ; preds = %16, %11, %8, %3, %0
  ret void
}

declare dso_local %struct.keystruct* @first_sc_for(i32, void ()*) #1

declare dso_local void @do_execute() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @do_suspend() #0 {
  %1 = call zeroext i1 @in_restricted_mode()
  br i1 %1, label %2, label %3

2:                                                ; preds = %0
  br label %4

3:                                                ; preds = %0
  call void @suspend_nano(i32 0)
  store i8 1, i8* @ran_a_tool, align 1
  br label %4

4:                                                ; preds = %3, %2
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @restore_terminal() #0 {
  %1 = call i32 @curs_set(i32 1)
  %2 = call i32 @endwin()
  %3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.3, i64 0, i64 0))
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %5 = call i32 @fflush(%struct._IO_FILE* %4)
  %6 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* @original_state) #9
  ret void
}

declare dso_local i32 @curs_set(i32) #1

declare dso_local i32 @endwin() #1

declare dso_local i32 @printf(i8*, ...) #1

declare dso_local i32 @fflush(%struct._IO_FILE*) #1

; Function Attrs: nounwind
declare dso_local i32 @tcsetattr(i32, i32, %struct.termios*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @finish() #0 {
  call void @blank_statusbar()
  call void @blank_bottombars()
  %1 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %2 = call i32 @wrefresh(%struct._win_st* %1)
  %3 = load %struct._win_st*, %struct._win_st** @topwin, align 8
  %4 = icmp ne %struct._win_st* %3, null
  br i1 %4, label %5, label %8

5:                                                ; preds = %0
  %6 = load %struct._win_st*, %struct._win_st** @topwin, align 8
  %7 = call i32 @delwin(%struct._win_st* %6)
  br label %8

8:                                                ; preds = %5, %0
  %9 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %10 = call i32 @delwin(%struct._win_st* %9)
  %11 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %12 = call i32 @delwin(%struct._win_st* %11)
  call void @restore_terminal()
  call void @display_rcfile_errors()
  call void @exit(i32 0) #10
  unreachable
}

declare dso_local void @blank_statusbar() #1

declare dso_local void @blank_bottombars() #1

declare dso_local i32 @wrefresh(%struct._win_st*) #1

declare dso_local i32 @delwin(%struct._win_st*) #1

declare dso_local void @display_rcfile_errors() #1

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) #3

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @close_and_go() #0 {
  %1 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %2 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %1, i32 0, i32 16
  %3 = load i8*, i8** %2, align 8
  %4 = icmp ne i8* %3, null
  br i1 %4, label %5, label %10

5:                                                ; preds = %0
  %6 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %7 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %6, i32 0, i32 16
  %8 = load i8*, i8** %7, align 8
  %9 = call zeroext i1 @delete_lockfile(i8* %8)
  br label %10

10:                                               ; preds = %5, %0
  %11 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %12 = and i32 %11, -2147483648
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %14, label %15

14:                                               ; preds = %10
  call void @update_poshistory()
  br label %15

15:                                               ; preds = %14, %10
  %16 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %17 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %18 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %17, i32 0, i32 24
  %19 = load %struct.openfilestruct*, %struct.openfilestruct** %18, align 8
  %20 = icmp ne %struct.openfilestruct* %16, %19
  br i1 %20, label %21, label %28

21:                                               ; preds = %15
  call void @switch_to_next_buffer()
  %22 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %23 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %22, i32 0, i32 25
  %24 = load %struct.openfilestruct*, %struct.openfilestruct** %23, align 8
  store %struct.openfilestruct* %24, %struct.openfilestruct** @openfile, align 8
  call void @close_buffer()
  %25 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %26 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %25, i32 0, i32 24
  %27 = load %struct.openfilestruct*, %struct.openfilestruct** %26, align 8
  store %struct.openfilestruct* %27, %struct.openfilestruct** @openfile, align 8
  call void @titlebar(i8* null)
  br label %34

28:                                               ; preds = %15
  %29 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %30 = and i32 %29, 2097152
  %31 = icmp ne i32 %30, 0
  br i1 %31, label %32, label %33

32:                                               ; preds = %28
  call void @save_history()
  br label %33

33:                                               ; preds = %32, %28
  call void @finish()
  br label %34

34:                                               ; preds = %33, %21
  ret void
}

declare dso_local zeroext i1 @delete_lockfile(i8*) #1

declare dso_local void @update_poshistory() #1

declare dso_local void @switch_to_next_buffer() #1

declare dso_local void @close_buffer() #1

declare dso_local void @titlebar(i8*) #1

declare dso_local void @save_history() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @do_exit() #0 {
  %1 = alloca i32, align 4
  %2 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %3 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %2, i32 0, i32 21
  %4 = load i8, i8* %3, align 4
  %5 = trunc i8 %4 to i1
  br i1 %5, label %7, label %6

6:                                                ; preds = %0
  store i32 0, i32* %1, align 4
  br label %30

7:                                                ; preds = %0
  %8 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %9 = and i32 %8, 1024
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %11, label %20

11:                                               ; preds = %7
  %12 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %13 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %12, i32 0, i32 0
  %14 = load i8*, i8** %13, align 8
  %15 = getelementptr inbounds i8, i8* %14, i64 0
  %16 = load i8, i8* %15, align 1
  %17 = sext i8 %16 to i32
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %19, label %20

19:                                               ; preds = %11
  store i32 1, i32* %1, align 4
  br label %29

20:                                               ; preds = %11, %7
  %21 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %22 = and i32 %21, 1024
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %24, label %26

24:                                               ; preds = %20
  %25 = call i8* @gettext(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.4, i64 0, i64 0)) #9
  call void @warn_and_briefly_pause(i8* %25)
  br label %26

26:                                               ; preds = %24, %20
  %27 = call i8* @gettext(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.5, i64 0, i64 0)) #9
  %28 = call i32 @ask_user(i1 zeroext false, i8* %27)
  store i32 %28, i32* %1, align 4
  br label %29

29:                                               ; preds = %26, %19
  br label %30

30:                                               ; preds = %29, %6
  %31 = load i32, i32* %1, align 4
  %32 = icmp eq i32 %31, 0
  br i1 %32, label %39, label %33

33:                                               ; preds = %30
  %34 = load i32, i32* %1, align 4
  %35 = icmp eq i32 %34, 1
  br i1 %35, label %36, label %40

36:                                               ; preds = %33
  %37 = call i32 @write_it_out(i1 zeroext true, i1 zeroext true)
  %38 = icmp sgt i32 %37, 0
  br i1 %38, label %39, label %40

39:                                               ; preds = %36, %30
  call void @close_and_go()
  br label %46

40:                                               ; preds = %36, %33
  %41 = load i32, i32* %1, align 4
  %42 = icmp ne i32 %41, 1
  br i1 %42, label %43, label %45

43:                                               ; preds = %40
  %44 = call i8* @gettext(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.6, i64 0, i64 0)) #9
  call void @statusbar(i8* %44)
  br label %45

45:                                               ; preds = %43, %40
  br label %46

46:                                               ; preds = %45, %39
  ret void
}

declare dso_local void @warn_and_briefly_pause(i8*) #1

declare dso_local i32 @ask_user(i1 zeroext, i8*) #1

declare dso_local i32 @write_it_out(i1 zeroext, i1 zeroext) #1

declare dso_local void @statusbar(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @emergency_save(i8* %0) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i8*, align 8
  %4 = alloca i8*, align 8
  store i8* %0, i8** %2, align 8
  %5 = load i8*, i8** %2, align 8
  %6 = load i8, i8* %5, align 1
  %7 = sext i8 %6 to i32
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %9, label %14

9:                                                ; preds = %1
  %10 = call i8* @nmalloc(i64 28)
  store i8* %10, i8** %3, align 8
  %11 = load i8*, i8** %3, align 8
  %12 = call i32 @getpid() #9
  %13 = call i32 (i8*, i8*, ...) @sprintf(i8* %11, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 %12) #9
  br label %17

14:                                               ; preds = %1
  %15 = load i8*, i8** %2, align 8
  %16 = call i8* @copy_of(i8* %15)
  store i8* %16, i8** %3, align 8
  br label %17

17:                                               ; preds = %14, %9
  %18 = load i8*, i8** %3, align 8
  %19 = call i8* @get_next_filename(i8* %18, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.8, i64 0, i64 0))
  store i8* %19, i8** %4, align 8
  %20 = load i8*, i8** %4, align 8
  %21 = load i8, i8* %20, align 1
  %22 = sext i8 %21 to i32
  %23 = icmp eq i32 %22, 0
  br i1 %23, label %24, label %28

24:                                               ; preds = %17
  %25 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %26 = call i8* @gettext(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.9, i64 0, i64 0)) #9
  %27 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %25, i8* %26)
  br label %72

28:                                               ; preds = %17
  %29 = load i8*, i8** %4, align 8
  %30 = call zeroext i1 @write_file(i8* %29, %struct._IO_FILE* null, i1 zeroext false, i32 0, i1 zeroext false)
  br i1 %30, label %31, label %71

31:                                               ; preds = %28
  %32 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %33 = call i8* @gettext(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.10, i64 0, i64 0)) #9
  %34 = load i8*, i8** %4, align 8
  %35 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %32, i8* %33, i8* %34)
  %36 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %37 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %36, i32 0, i32 10
  %38 = load %struct.stat*, %struct.stat** %37, align 8
  %39 = icmp ne %struct.stat* %38, null
  br i1 %39, label %40, label %70

40:                                               ; preds = %31
  br label %41

41:                                               ; preds = %40
  %42 = load i8*, i8** %4, align 8
  %43 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %44 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %43, i32 0, i32 10
  %45 = load %struct.stat*, %struct.stat** %44, align 8
  %46 = getelementptr inbounds %struct.stat, %struct.stat* %45, i32 0, i32 3
  %47 = load i32, i32* %46, align 8
  %48 = call i32 @chmod(i8* %42, i32 %47) #9
  %49 = icmp ne i32 %48, 0
  br i1 %49, label %50, label %51

50:                                               ; preds = %41
  br label %51

51:                                               ; preds = %50, %41
  br label %52

52:                                               ; preds = %51
  br label %53

53:                                               ; preds = %52
  %54 = load i8*, i8** %4, align 8
  %55 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %56 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %55, i32 0, i32 10
  %57 = load %struct.stat*, %struct.stat** %56, align 8
  %58 = getelementptr inbounds %struct.stat, %struct.stat* %57, i32 0, i32 4
  %59 = load i32, i32* %58, align 4
  %60 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %61 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %60, i32 0, i32 10
  %62 = load %struct.stat*, %struct.stat** %61, align 8
  %63 = getelementptr inbounds %struct.stat, %struct.stat* %62, i32 0, i32 5
  %64 = load i32, i32* %63, align 8
  %65 = call i32 @chown(i8* %54, i32 %59, i32 %64) #9
  %66 = icmp ne i32 %65, 0
  br i1 %66, label %67, label %68

67:                                               ; preds = %53
  br label %68

68:                                               ; preds = %67, %53
  br label %69

69:                                               ; preds = %68
  br label %70

70:                                               ; preds = %69, %31
  br label %71

71:                                               ; preds = %70, %28
  br label %72

72:                                               ; preds = %71, %24
  %73 = load i8*, i8** %4, align 8
  call void @rpl_free(i8* %73)
  %74 = load i8*, i8** %3, align 8
  call void @rpl_free(i8* %74)
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @sprintf(i8*, i8*, ...) #2

; Function Attrs: nounwind
declare dso_local i32 @getpid() #2

declare dso_local i8* @get_next_filename(i8*, i8*) #1

declare dso_local i32 @fprintf(%struct._IO_FILE*, i8*, ...) #1

declare dso_local zeroext i1 @write_file(i8*, %struct._IO_FILE*, i1 zeroext, i32, i1 zeroext) #1

; Function Attrs: nounwind
declare dso_local i32 @chmod(i8*, i32) #2

; Function Attrs: nounwind
declare dso_local i32 @chown(i8*, i32, i32) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @die(i8* %0, ...) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca [1 x %struct.__va_list_tag], align 16
  %4 = alloca %struct.openfilestruct*, align 8
  store i8* %0, i8** %2, align 8
  %5 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  store %struct.openfilestruct* %5, %struct.openfilestruct** %4, align 8
  %6 = load i32, i32* @die.stabs, align 4
  %7 = add nsw i32 %6, 1
  store i32 %7, i32* @die.stabs, align 4
  %8 = icmp sgt i32 %7, 1
  br i1 %8, label %9, label %10

9:                                                ; preds = %1
  call void @exit(i32 11) #10
  unreachable

10:                                               ; preds = %1
  call void @restore_terminal()
  call void @display_rcfile_errors()
  %11 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %3, i64 0, i64 0
  %12 = bitcast %struct.__va_list_tag* %11 to i8*
  call void @llvm.va_start(i8* %12)
  %13 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %14 = load i8*, i8** %2, align 8
  %15 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %3, i64 0, i64 0
  %16 = call i32 @vfprintf(%struct._IO_FILE* %13, i8* %14, %struct.__va_list_tag* %15)
  %17 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %3, i64 0, i64 0
  %18 = bitcast %struct.__va_list_tag* %17 to i8*
  call void @llvm.va_end(i8* %18)
  br label %19

19:                                               ; preds = %53, %10
  %20 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %21 = icmp ne %struct.openfilestruct* %20, null
  br i1 %21, label %22, label %54

22:                                               ; preds = %19
  %23 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %24 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %23, i32 0, i32 16
  %25 = load i8*, i8** %24, align 8
  %26 = icmp ne i8* %25, null
  br i1 %26, label %27, label %32

27:                                               ; preds = %22
  %28 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %29 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %28, i32 0, i32 16
  %30 = load i8*, i8** %29, align 8
  %31 = call zeroext i1 @delete_lockfile(i8* %30)
  br label %32

32:                                               ; preds = %27, %22
  %33 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %34 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %33, i32 0, i32 21
  %35 = load i8, i8* %34, align 4
  %36 = trunc i8 %35 to i1
  br i1 %36, label %37, label %45

37:                                               ; preds = %32
  %38 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %39 = and i32 %38, 4194304
  %40 = icmp ne i32 %39, 0
  br i1 %40, label %45, label %41

41:                                               ; preds = %37
  %42 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %43 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %42, i32 0, i32 0
  %44 = load i8*, i8** %43, align 8
  call void @emergency_save(i8* %44)
  br label %45

45:                                               ; preds = %41, %37, %32
  %46 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %47 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %46, i32 0, i32 24
  %48 = load %struct.openfilestruct*, %struct.openfilestruct** %47, align 8
  store %struct.openfilestruct* %48, %struct.openfilestruct** @openfile, align 8
  %49 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %50 = load %struct.openfilestruct*, %struct.openfilestruct** %4, align 8
  %51 = icmp eq %struct.openfilestruct* %49, %50
  br i1 %51, label %52, label %53

52:                                               ; preds = %45
  br label %54

53:                                               ; preds = %45
  br label %19

54:                                               ; preds = %52, %19
  call void @exit(i32 1) #10
  unreachable
}

; Function Attrs: nofree nosync nounwind willreturn
declare void @llvm.va_start(i8*) #4

declare dso_local i32 @vfprintf(%struct._IO_FILE*, i8*, %struct.__va_list_tag*) #1

; Function Attrs: nofree nosync nounwind willreturn
declare void @llvm.va_end(i8*) #4

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @window_init() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %4 = icmp ne %struct._win_st* %3, null
  br i1 %4, label %5, label %16

5:                                                ; preds = %0
  %6 = load %struct._win_st*, %struct._win_st** @topwin, align 8
  %7 = icmp ne %struct._win_st* %6, null
  br i1 %7, label %8, label %11

8:                                                ; preds = %5
  %9 = load %struct._win_st*, %struct._win_st** @topwin, align 8
  %10 = call i32 @delwin(%struct._win_st* %9)
  br label %11

11:                                               ; preds = %8, %5
  %12 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %13 = call i32 @delwin(%struct._win_st* %12)
  %14 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %15 = call i32 @delwin(%struct._win_st* %14)
  br label %16

16:                                               ; preds = %11, %0
  store %struct._win_st* null, %struct._win_st** @topwin, align 8
  %17 = load i32, i32* @LINES, align 4
  %18 = icmp slt i32 %17, 3
  br i1 %18, label %19, label %35

19:                                               ; preds = %16
  %20 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %21 = and i32 %20, 131072
  %22 = icmp ne i32 %21, 0
  br i1 %22, label %23, label %25

23:                                               ; preds = %19
  %24 = load i32, i32* @LINES, align 4
  br label %26

25:                                               ; preds = %19
  br label %26

26:                                               ; preds = %25, %23
  %27 = phi i32 [ %24, %23 ], [ 1, %25 ]
  store i32 %27, i32* @editwinrows, align 4
  %28 = load i32, i32* @editwinrows, align 4
  %29 = load i32, i32* @COLS, align 4
  %30 = call %struct._win_st* @newwin(i32 %28, i32 %29, i32 0, i32 0)
  store %struct._win_st* %30, %struct._win_st** @midwin, align 8
  %31 = load i32, i32* @COLS, align 4
  %32 = load i32, i32* @LINES, align 4
  %33 = sub nsw i32 %32, 1
  %34 = call %struct._win_st* @newwin(i32 1, i32 %31, i32 %33, i32 0)
  store %struct._win_st* %34, %struct._win_st** @footwin, align 8
  br label %93

35:                                               ; preds = %16
  %36 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %37 = and i32 %36, 2048
  %38 = icmp ne i32 %37, 0
  br i1 %38, label %39, label %42

39:                                               ; preds = %35
  %40 = load i32, i32* @LINES, align 4
  %41 = icmp sgt i32 %40, 6
  br label %42

42:                                               ; preds = %39, %35
  %43 = phi i1 [ false, %35 ], [ %41, %39 ]
  %44 = zext i1 %43 to i64
  %45 = select i1 %43, i32 2, i32 1
  store i32 %45, i32* %1, align 4
  %46 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %47 = and i32 %46, 8
  %48 = icmp ne i32 %47, 0
  br i1 %48, label %52, label %49

49:                                               ; preds = %42
  %50 = load i32, i32* @LINES, align 4
  %51 = icmp slt i32 %50, 6
  br label %52

52:                                               ; preds = %49, %42
  %53 = phi i1 [ true, %42 ], [ %51, %49 ]
  %54 = zext i1 %53 to i64
  %55 = select i1 %53, i32 1, i32 3
  store i32 %55, i32* %2, align 4
  %56 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %57 = and i32 %56, 65536
  %58 = icmp ne i32 %57, 0
  br i1 %58, label %63, label %59

59:                                               ; preds = %52
  %60 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %61 = and i32 %60, 131072
  %62 = icmp ne i32 %61, 0
  br i1 %62, label %63, label %64

63:                                               ; preds = %59, %52
  store i32 0, i32* %1, align 4
  br label %64

64:                                               ; preds = %63, %59
  %65 = load i32, i32* @LINES, align 4
  %66 = load i32, i32* %1, align 4
  %67 = sub nsw i32 %65, %66
  %68 = load i32, i32* %2, align 4
  %69 = sub nsw i32 %67, %68
  %70 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %71 = and i32 %70, 131072
  %72 = icmp ne i32 %71, 0
  %73 = zext i1 %72 to i64
  %74 = select i1 %72, i32 1, i32 0
  %75 = add nsw i32 %69, %74
  store i32 %75, i32* @editwinrows, align 4
  %76 = load i32, i32* %1, align 4
  %77 = icmp sgt i32 %76, 0
  br i1 %77, label %78, label %82

78:                                               ; preds = %64
  %79 = load i32, i32* %1, align 4
  %80 = load i32, i32* @COLS, align 4
  %81 = call %struct._win_st* @newwin(i32 %79, i32 %80, i32 0, i32 0)
  store %struct._win_st* %81, %struct._win_st** @topwin, align 8
  br label %82

82:                                               ; preds = %78, %64
  %83 = load i32, i32* @editwinrows, align 4
  %84 = load i32, i32* @COLS, align 4
  %85 = load i32, i32* %1, align 4
  %86 = call %struct._win_st* @newwin(i32 %83, i32 %84, i32 %85, i32 0)
  store %struct._win_st* %86, %struct._win_st** @midwin, align 8
  %87 = load i32, i32* %2, align 4
  %88 = load i32, i32* @COLS, align 4
  %89 = load i32, i32* @LINES, align 4
  %90 = load i32, i32* %2, align 4
  %91 = sub nsw i32 %89, %90
  %92 = call %struct._win_st* @newwin(i32 %87, i32 %88, i32 %91, i32 0)
  store %struct._win_st* %92, %struct._win_st** @footwin, align 8
  br label %93

93:                                               ; preds = %82, %26
  %94 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %95 = call i32 @wnoutrefresh(%struct._win_st* %94)
  %96 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %97 = and i32 %96, 32768
  %98 = icmp ne i32 %97, 0
  br i1 %98, label %104, label %99

99:                                               ; preds = %93
  %100 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %101 = call i32 @keypad(%struct._win_st* %100, i1 zeroext true)
  %102 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %103 = call i32 @keypad(%struct._win_st* %102, i1 zeroext true)
  br label %104

104:                                              ; preds = %99, %93
  %105 = load i32, i32* @COLS, align 4
  %106 = sext i32 %105 to i64
  %107 = load i64, i64* @fill, align 8
  %108 = add nsw i64 %106, %107
  %109 = icmp slt i64 %108, 0
  br i1 %109, label %110, label %111

110:                                              ; preds = %104
  store i64 0, i64* @wrap_at, align 8
  br label %122

111:                                              ; preds = %104
  %112 = load i64, i64* @fill, align 8
  %113 = icmp sle i64 %112, 0
  br i1 %113, label %114, label %119

114:                                              ; preds = %111
  %115 = load i32, i32* @COLS, align 4
  %116 = sext i32 %115 to i64
  %117 = load i64, i64* @fill, align 8
  %118 = add nsw i64 %116, %117
  store i64 %118, i64* @wrap_at, align 8
  br label %121

119:                                              ; preds = %111
  %120 = load i64, i64* @fill, align 8
  store i64 %120, i64* @wrap_at, align 8
  br label %121

121:                                              ; preds = %119, %114
  br label %122

122:                                              ; preds = %121, %110
  ret void
}

declare dso_local %struct._win_st* @newwin(i32, i32, i32, i32) #1

declare dso_local i32 @wnoutrefresh(%struct._win_st*) #1

declare dso_local i32 @keypad(%struct._win_st*, i1 zeroext) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @disable_mouse_support() #0 {
  %1 = call i32 @mousemask(i32 0, i32* null)
  %2 = load i32, i32* @oldinterval, align 4
  %3 = call i32 @mouseinterval(i32 %2)
  ret void
}

declare dso_local i32 @mousemask(i32, i32*) #1

declare dso_local i32 @mouseinterval(i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @enable_mouse_support() #0 {
  %1 = call i32 @mousemask(i32 268435455, i32* null)
  %2 = call i32 @mouseinterval(i32 50)
  store i32 %2, i32* @oldinterval, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @mouse_init() #0 {
  %1 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %2 = and i32 %1, 256
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %4, label %5

4:                                                ; preds = %0
  call void @enable_mouse_support()
  br label %6

5:                                                ; preds = %0
  call void @disable_mouse_support()
  br label %6

6:                                                ; preds = %5, %4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @print_opt(i8* %0, i8* %1, i8* %2) #0 {
  %4 = alloca i8*, align 8
  %5 = alloca i8*, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i8* %0, i8** %4, align 8
  store i8* %1, i8** %5, align 8
  store i8* %2, i8** %6, align 8
  %9 = load i8*, i8** %4, align 8
  %10 = call i64 @breadth(i8* %9)
  %11 = trunc i64 %10 to i32
  store i32 %11, i32* %7, align 4
  %12 = load i8*, i8** %5, align 8
  %13 = call i64 @breadth(i8* %12)
  %14 = trunc i64 %13 to i32
  store i32 %14, i32* %8, align 4
  %15 = load i8*, i8** %4, align 8
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.11, i64 0, i64 0), i8* %15)
  %17 = load i32, i32* %7, align 4
  %18 = icmp slt i32 %17, 14
  br i1 %18, label %19, label %23

19:                                               ; preds = %3
  %20 = load i32, i32* %7, align 4
  %21 = sub nsw i32 14, %20
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.12, i64 0, i64 0), i32 %21, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.13, i64 0, i64 0))
  br label %23

23:                                               ; preds = %19, %3
  %24 = load i8*, i8** %5, align 8
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.11, i64 0, i64 0), i8* %24)
  %26 = load i32, i32* %8, align 4
  %27 = icmp slt i32 %26, 24
  br i1 %27, label %28, label %32

28:                                               ; preds = %23
  %29 = load i32, i32* %8, align 4
  %30 = sub nsw i32 24, %29
  %31 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.12, i64 0, i64 0), i32 %30, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.13, i64 0, i64 0))
  br label %32

32:                                               ; preds = %28, %23
  %33 = load i8*, i8** %6, align 8
  %34 = call i8* @gettext(i8* %33) #9
  %35 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.14, i64 0, i64 0), i8* %34)
  ret void
}

declare dso_local i64 @breadth(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @usage() #0 {
  %1 = call i8* @gettext(i8* getelementptr inbounds ([51 x i8], [51 x i8]* @.str.15, i64 0, i64 0)) #9
  %2 = call i32 (i8*, ...) @printf(i8* %1)
  %3 = call i8* @gettext(i8* getelementptr inbounds ([150 x i8], [150 x i8]* @.str.16, i64 0, i64 0)) #9
  %4 = call i32 (i8*, ...) @printf(i8* %3)
  %5 = call i8* @gettext(i8* getelementptr inbounds ([63 x i8], [63 x i8]* @.str.17, i64 0, i64 0)) #9
  %6 = call i32 (i8*, ...) @printf(i8* %5)
  %7 = call i8* @gettext(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.18, i64 0, i64 0)) #9
  %8 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.19, i64 0, i64 0)) #9
  call void @print_opt(i8* %7, i8* %8, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.20, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.21, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.22, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.23, i64 0, i64 0))
  %9 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %10 = and i32 %9, 4194304
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %15, label %12

12:                                               ; preds = %0
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.24, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.25, i64 0, i64 0), i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.26, i64 0, i64 0))
  %13 = call i8* @gettext(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.27, i64 0, i64 0)) #9
  %14 = call i8* @gettext(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.28, i64 0, i64 0)) #9
  call void @print_opt(i8* %13, i8* %14, i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.29, i64 0, i64 0))
  br label %15

15:                                               ; preds = %12, %0
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.30, i64 0, i64 0), i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.31, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.32, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.33, i64 0, i64 0), i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.34, i64 0, i64 0), i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.35, i64 0, i64 0))
  %16 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %17 = and i32 %16, 4194304
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %20, label %19

19:                                               ; preds = %15
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.36, i64 0, i64 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.37, i64 0, i64 0), i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.38, i64 0, i64 0))
  br label %20

20:                                               ; preds = %19, %15
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.39, i64 0, i64 0), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.40, i64 0, i64 0), i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.41, i64 0, i64 0))
  %21 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %22 = and i32 %21, 4194304
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %25, label %24

24:                                               ; preds = %20
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.42, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.43, i64 0, i64 0), i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.44, i64 0, i64 0))
  br label %25

25:                                               ; preds = %24, %20
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.45, i64 0, i64 0), i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.46, i64 0, i64 0), i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.47, i64 0, i64 0))
  %26 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.48, i64 0, i64 0)) #9
  %27 = call i8* @gettext(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.49, i64 0, i64 0)) #9
  call void @print_opt(i8* %26, i8* %27, i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.50, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.51, i64 0, i64 0), i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.52, i64 0, i64 0), i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.53, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.54, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.55, i64 0, i64 0), i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.56, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.57, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.58, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.59, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.60, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.61, i64 0, i64 0), i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.62, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.63, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.64, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.65, i64 0, i64 0))
  %28 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %29 = and i32 %28, 4194304
  %30 = icmp ne i32 %29, 0
  br i1 %30, label %32, label %31

31:                                               ; preds = %25
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.66, i64 0, i64 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.67, i64 0, i64 0), i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.68, i64 0, i64 0))
  br label %32

32:                                               ; preds = %31, %25
  %33 = call i8* @gettext(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.69, i64 0, i64 0)) #9
  %34 = call i8* @gettext(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.70, i64 0, i64 0)) #9
  call void @print_opt(i8* %33, i8* %34, i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.71, i64 0, i64 0))
  %35 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %36 = and i32 %35, 4194304
  %37 = icmp ne i32 %36, 0
  br i1 %37, label %39, label %38

38:                                               ; preds = %32
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.72, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.73, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.74, i64 0, i64 0))
  br label %39

39:                                               ; preds = %38, %32
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.75, i64 0, i64 0), i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.76, i64 0, i64 0), i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.77, i64 0, i64 0))
  %40 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.78, i64 0, i64 0)) #9
  %41 = call i8* @gettext(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.79, i64 0, i64 0)) #9
  call void @print_opt(i8* %40, i8* %41, i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.80, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.81, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.82, i64 0, i64 0), i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.83, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.84, i64 0, i64 0), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.85, i64 0, i64 0), i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.86, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.87, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.88, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.89, i64 0, i64 0))
  %42 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.90, i64 0, i64 0)) #9
  %43 = call i8* @gettext(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.91, i64 0, i64 0)) #9
  call void @print_opt(i8* %42, i8* %43, i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.92, i64 0, i64 0))
  %44 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %45 = and i32 %44, 4194304
  %46 = icmp ne i32 %45, 0
  br i1 %46, label %50, label %47

47:                                               ; preds = %39
  %48 = call i8* @gettext(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.93, i64 0, i64 0)) #9
  %49 = call i8* @gettext(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.94, i64 0, i64 0)) #9
  call void @print_opt(i8* %48, i8* %49, i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.95, i64 0, i64 0))
  br label %50

50:                                               ; preds = %47, %39
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.96, i64 0, i64 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.97, i64 0, i64 0), i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.98, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.99, i64 0, i64 0), i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.100, i64 0, i64 0), i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.101, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.102, i64 0, i64 0), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.103, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.104, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.105, i64 0, i64 0), i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.106, i64 0, i64 0), i8* getelementptr inbounds ([32 x i8], [32 x i8]* @.str.107, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.108, i64 0, i64 0), i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.109, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.110, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.111, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.112, i64 0, i64 0), i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.113, i64 0, i64 0))
  %51 = call i8* @gettext(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.114, i64 0, i64 0)) #9
  %52 = call i8* @gettext(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.115, i64 0, i64 0)) #9
  call void @print_opt(i8* %51, i8* %52, i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.116, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.117, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.118, i64 0, i64 0), i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.119, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.120, i64 0, i64 0), i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.121, i64 0, i64 0), i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.122, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.123, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.124, i64 0, i64 0), i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.125, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.126, i64 0, i64 0), i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.127, i64 0, i64 0), i8* getelementptr inbounds ([37 x i8], [37 x i8]* @.str.128, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.129, i64 0, i64 0), i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.130, i64 0, i64 0), i8* getelementptr inbounds ([31 x i8], [31 x i8]* @.str.131, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.132, i64 0, i64 0), i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.133, i64 0, i64 0), i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.134, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.135, i64 0, i64 0), i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.136, i64 0, i64 0), i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.137, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.138, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.139, i64 0, i64 0), i8* getelementptr inbounds ([37 x i8], [37 x i8]* @.str.140, i64 0, i64 0))
  %53 = call i8* @gettext(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.141, i64 0, i64 0)) #9
  %54 = call i8* @gettext(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.142, i64 0, i64 0)) #9
  call void @print_opt(i8* %53, i8* %54, i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.143, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.144, i64 0, i64 0), i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.145, i64 0, i64 0), i8* getelementptr inbounds ([37 x i8], [37 x i8]* @.str.146, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.147, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.148, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.149, i64 0, i64 0))
  %55 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.150, i64 0, i64 0)) #9
  %56 = call i8* @gettext(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.151, i64 0, i64 0)) #9
  call void @print_opt(i8* %55, i8* %56, i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.152, i64 0, i64 0))
  %57 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %58 = and i32 %57, 4194304
  %59 = icmp ne i32 %58, 0
  br i1 %59, label %63, label %60

60:                                               ; preds = %50
  %61 = call i8* @gettext(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.153, i64 0, i64 0)) #9
  %62 = call i8* @gettext(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.154, i64 0, i64 0)) #9
  call void @print_opt(i8* %61, i8* %62, i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.155, i64 0, i64 0))
  br label %63

63:                                               ; preds = %60, %50
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.156, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.157, i64 0, i64 0), i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.158, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.159, i64 0, i64 0), i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.160, i64 0, i64 0), i8* getelementptr inbounds ([38 x i8], [38 x i8]* @.str.161, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.162, i64 0, i64 0), i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.163, i64 0, i64 0), i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.164, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.165, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.166, i64 0, i64 0), i8* getelementptr inbounds ([37 x i8], [37 x i8]* @.str.167, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.168, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.169, i64 0, i64 0), i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.170, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.171, i64 0, i64 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.172, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.173, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.174, i64 0, i64 0), i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.175, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.176, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.177, i64 0, i64 0), i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.178, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.179, i64 0, i64 0))
  call void @print_opt(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.180, i64 0, i64 0), i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.181, i64 0, i64 0), i8* getelementptr inbounds ([34 x i8], [34 x i8]* @.str.182, i64 0, i64 0))
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @version() #0 {
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.183, i64 0, i64 0), i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.184, i64 0, i64 0))
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([58 x i8], [58 x i8]* @.str.185, i64 0, i64 0))
  %3 = call i8* @gettext(i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.186, i64 0, i64 0)) #9
  %4 = call i32 (i8*, ...) @printf(i8* %3, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.187, i64 0, i64 0))
  %5 = call i8* @gettext(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.188, i64 0, i64 0)) #9
  %6 = call i32 (i8*, ...) @printf(i8* %5)
  %7 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.189, i64 0, i64 0))
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.190, i64 0, i64 0))
  %9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.191, i64 0, i64 0))
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @make_a_note(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  store i8 1, i8* @control_C_was_pressed, align 1
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @install_handler_for_Ctrl_C() #0 {
  call void @enable_kb_interrupt()
  store void (i32)* @make_a_note, void (i32)** getelementptr inbounds (%struct.sigaction, %struct.sigaction* @newaction, i32 0, i32 0, i32 0), align 8
  store i32 0, i32* getelementptr inbounds (%struct.sigaction, %struct.sigaction* @newaction, i32 0, i32 2), align 8
  %1 = call i32 @sigaction(i32 2, %struct.sigaction* @newaction, %struct.sigaction* @oldaction) #9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @enable_kb_interrupt() #0 {
  %1 = alloca %struct.termios, align 4
  %2 = bitcast %struct.termios* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %2, i8 0, i64 60, i1 false)
  %3 = call i32 @tcgetattr(i32 0, %struct.termios* %1) #9
  %4 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 3
  %5 = load i32, i32* %4, align 4
  %6 = or i32 %5, 1
  store i32 %6, i32* %4, align 4
  %7 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* %1) #9
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @sigaction(i32, %struct.sigaction*, %struct.sigaction*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @restore_handler_for_Ctrl_C() #0 {
  %1 = call i32 @sigaction(i32 2, %struct.sigaction* @oldaction, %struct.sigaction* null) #9
  call void @disable_kb_interrupt()
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @disable_kb_interrupt() #0 {
  %1 = alloca %struct.termios, align 4
  %2 = bitcast %struct.termios* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %2, i8 0, i64 60, i1 false)
  %3 = call i32 @tcgetattr(i32 0, %struct.termios* %1) #9
  %4 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 3
  %5 = load i32, i32* %4, align 4
  %6 = and i32 %5, -2
  store i32 %6, i32* %4, align 4
  %7 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* %1) #9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @reconnect_and_store_state() #0 {
  %1 = alloca i32, align 4
  %2 = call i32 (i8*, i32, ...) @open(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.192, i64 0, i64 0), i32 0)
  store i32 %2, i32* %1, align 4
  %3 = load i32, i32* %1, align 4
  %4 = icmp slt i32 %3, 0
  br i1 %4, label %9, label %5

5:                                                ; preds = %0
  %6 = load i32, i32* %1, align 4
  %7 = call i32 @dup2(i32 %6, i32 0) #9
  %8 = icmp slt i32 %7, 0
  br i1 %8, label %9, label %11

9:                                                ; preds = %5, %0
  %10 = call i8* @gettext(i8* getelementptr inbounds ([39 x i8], [39 x i8]* @.str.193, i64 0, i64 0)) #9
  call void (i8*, ...) @die(i8* %10)
  br label %11

11:                                               ; preds = %9, %5
  %12 = load i32, i32* %1, align 4
  %13 = call i32 @close(i32 %12)
  %14 = load i8, i8* @control_C_was_pressed, align 1
  %15 = trunc i8 %14 to i1
  br i1 %15, label %18, label %16

16:                                               ; preds = %11
  %17 = call i32 @tcgetattr(i32 0, %struct.termios* @original_state) #9
  br label %18

18:                                               ; preds = %16, %11
  ret void
}

declare dso_local i32 @open(i8*, i32, ...) #1

; Function Attrs: nounwind
declare dso_local i32 @dup2(i32, i32) #2

declare dso_local i32 @close(i32) #1

; Function Attrs: nounwind
declare dso_local i32 @tcgetattr(i32, %struct.termios*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @scoop_stdin() #0 {
  %1 = alloca i1, align 1
  %2 = alloca %struct._IO_FILE*, align 8
  %3 = alloca i32, align 4
  call void @restore_terminal()
  %4 = call i32 @isatty(i32 0) #9
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %6, label %10

6:                                                ; preds = %0
  %7 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %8 = call i8* @gettext(i8* getelementptr inbounds ([56 x i8], [56 x i8]* @.str.194, i64 0, i64 0)) #9
  %9 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %7, i8* %8)
  br label %10

10:                                               ; preds = %6, %0
  %11 = call %struct._IO_FILE* @fopen(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.195, i64 0, i64 0), i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.196, i64 0, i64 0))
  store %struct._IO_FILE* %11, %struct._IO_FILE** %2, align 8
  %12 = load %struct._IO_FILE*, %struct._IO_FILE** %2, align 8
  %13 = icmp eq %struct._IO_FILE* %12, null
  br i1 %13, label %14, label %21

14:                                               ; preds = %10
  %15 = call i32* @__errno_location() #11
  %16 = load i32, i32* %15, align 4
  store i32 %16, i32* %3, align 4
  call void @terminal_init()
  %17 = call i32 @doupdate()
  %18 = call i8* @gettext(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.197, i64 0, i64 0)) #9
  %19 = load i32, i32* %3, align 4
  %20 = call i8* @strerror(i32 %19) #9
  call void (i32, i8*, ...) @statusline(i32 7, i8* %18, i8* %20)
  store i1 false, i1* %1, align 1
  br label %33

21:                                               ; preds = %10
  call void @install_handler_for_Ctrl_C()
  call void @make_new_buffer()
  %22 = load %struct._IO_FILE*, %struct._IO_FILE** %2, align 8
  call void @read_file(%struct._IO_FILE* %22, i32 0, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.198, i64 0, i64 0), i1 zeroext true)
  call void @find_and_prime_applicable_syntax()
  call void @restore_handler_for_Ctrl_C()
  %23 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %24 = and i32 %23, 128
  %25 = icmp ne i32 %24, 0
  br i1 %25, label %32, label %26

26:                                               ; preds = %21
  %27 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %28 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %27, i32 0, i32 5
  %29 = load i64, i64* %28, align 8
  %30 = icmp ugt i64 %29, 0
  br i1 %30, label %31, label %32

31:                                               ; preds = %26
  call void @set_modified()
  br label %32

32:                                               ; preds = %31, %26, %21
  store i1 true, i1* %1, align 1
  br label %33

33:                                               ; preds = %32, %14
  %34 = load i1, i1* %1, align 1
  ret i1 %34
}

; Function Attrs: nounwind
declare dso_local i32 @isatty(i32) #2

declare dso_local %struct._IO_FILE* @fopen(i8*, i8*) #1

; Function Attrs: nounwind readnone
declare dso_local i32* @__errno_location() #5

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @terminal_init() #0 {
  %1 = call i32 @raw()
  %2 = call i32 @nonl()
  %3 = call i32 @noecho()
  call void @disable_extended_io()
  %4 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %5 = and i32 %4, 1048576
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %7, label %8

7:                                                ; preds = %0
  call void @enable_flow_control()
  br label %8

8:                                                ; preds = %7, %0
  call void @disable_kb_interrupt()
  %9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.210, i64 0, i64 0))
  %10 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %11 = call i32 @fflush(%struct._IO_FILE* %10)
  ret void
}

declare dso_local i32 @doupdate() #1

; Function Attrs: nounwind
declare dso_local i8* @strerror(i32) #2

declare dso_local void @make_new_buffer() #1

declare dso_local void @read_file(%struct._IO_FILE*, i32, i8*, i1 zeroext) #1

declare dso_local void @find_and_prime_applicable_syntax() #1

declare dso_local void @set_modified() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @signal_init() #0 {
  %1 = alloca %struct.sigaction, align 8
  %2 = bitcast %struct.sigaction* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %2, i8 0, i64 152, i1 false)
  %3 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %4 = bitcast %union.anon* %3 to void (i32)**
  store void (i32)* inttoptr (i64 1 to void (i32)*), void (i32)** %4, align 8
  %5 = call i32 @sigaction(i32 2, %struct.sigaction* %1, %struct.sigaction* null) #9
  %6 = call i32 @sigaction(i32 3, %struct.sigaction* %1, %struct.sigaction* null) #9
  %7 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %8 = bitcast %union.anon* %7 to void (i32)**
  store void (i32)* @handle_hupterm, void (i32)** %8, align 8
  %9 = call i32 @sigaction(i32 1, %struct.sigaction* %1, %struct.sigaction* null) #9
  %10 = call i32 @sigaction(i32 15, %struct.sigaction* %1, %struct.sigaction* null) #9
  %11 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %12 = bitcast %union.anon* %11 to void (i32)**
  store void (i32)* @handle_sigwinch, void (i32)** %12, align 8
  %13 = call i32 @sigaction(i32 28, %struct.sigaction* %1, %struct.sigaction* null) #9
  %14 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 1
  %15 = call i32 @sigfillset(%struct.__sigset_t* %14) #9
  %16 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %17 = bitcast %union.anon* %16 to void (i32)**
  store void (i32)* @suspend_nano, void (i32)** %17, align 8
  %18 = call i32 @sigaction(i32 20, %struct.sigaction* %1, %struct.sigaction* null) #9
  %19 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 1
  %20 = call i32 @sigfillset(%struct.__sigset_t* %19) #9
  %21 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %22 = bitcast %union.anon* %21 to void (i32)**
  store void (i32)* @continue_nano, void (i32)** %22, align 8
  %23 = call i32 @sigaction(i32 18, %struct.sigaction* %1, %struct.sigaction* null) #9
  %24 = call i8* @getenv(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.199, i64 0, i64 0)) #9
  %25 = icmp eq i8* %24, null
  br i1 %25, label %26, label %34

26:                                               ; preds = %0
  %27 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 0
  %28 = bitcast %union.anon* %27 to void (i32)**
  store void (i32)* @handle_crash, void (i32)** %28, align 8
  %29 = getelementptr inbounds %struct.sigaction, %struct.sigaction* %1, i32 0, i32 2
  %30 = load i32, i32* %29, align 8
  %31 = or i32 %30, -2147483648
  store i32 %31, i32* %29, align 8
  %32 = call i32 @sigaction(i32 11, %struct.sigaction* %1, %struct.sigaction* null) #9
  %33 = call i32 @sigaction(i32 6, %struct.sigaction* %1, %struct.sigaction* null) #9
  br label %34

34:                                               ; preds = %26, %0
  ret void
}

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @handle_hupterm(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = call i8* @gettext(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.200, i64 0, i64 0)) #9
  call void (i8*, ...) @die(i8* %3)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @handle_sigwinch(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  store volatile i32 1, i32* @the_window_resized, align 4
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @sigfillset(%struct.__sigset_t*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @suspend_nano(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  call void @disable_mouse_support()
  call void @restore_terminal()
  %3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.202, i64 0, i64 0))
  %4 = call i8* @gettext(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.203, i64 0, i64 0)) #9
  %5 = call i32 (i8*, ...) @printf(i8* %4)
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** @stdout, align 8
  %7 = call i32 @fflush(%struct._IO_FILE* %6)
  store i32 1, i32* @lastmessage, align 4
  %8 = call i32 @kill(i32 0, i32 19) #9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @continue_nano(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %4 = and i32 %3, 256
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %6, label %7

6:                                                ; preds = %1
  call void @enable_mouse_support()
  br label %7

7:                                                ; preds = %6, %1
  store volatile i32 1, i32* @the_window_resized, align 4
  %8 = call i32 @ungetch(i32 1278)
  ret void
}

; Function Attrs: nounwind
declare dso_local i8* @getenv(i8*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @handle_crash(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = call i8* @gettext(i8* getelementptr inbounds ([55 x i8], [55 x i8]* @.str.201, i64 0, i64 0)) #9
  %4 = load i32, i32* %2, align 4
  call void (i8*, ...) @die(i8* %3, i32 %4)
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @kill(i32, i32) #2

declare dso_local i32 @ungetch(i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @block_sigwinch(i1 zeroext %0) #0 {
  %2 = alloca i8, align 1
  %3 = alloca %struct.__sigset_t, align 8
  %4 = zext i1 %0 to i8
  store i8 %4, i8* %2, align 1
  %5 = call i32 @sigemptyset(%struct.__sigset_t* %3) #9
  %6 = call i32 @sigaddset(%struct.__sigset_t* %3, i32 28) #9
  %7 = load i8, i8* %2, align 1
  %8 = trunc i8 %7 to i1
  %9 = zext i1 %8 to i64
  %10 = select i1 %8, i32 0, i32 1
  %11 = call i32 @sigprocmask(i32 %10, %struct.__sigset_t* %3, %struct.__sigset_t* null) #9
  %12 = load volatile i32, i32* @the_window_resized, align 4
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %14, label %15

14:                                               ; preds = %1
  call void @regenerate_screen()
  br label %15

15:                                               ; preds = %14, %1
  ret void
}

; Function Attrs: nounwind
declare dso_local i32 @sigemptyset(%struct.__sigset_t*) #2

; Function Attrs: nounwind
declare dso_local i32 @sigaddset(%struct.__sigset_t*, i32) #2

; Function Attrs: nounwind
declare dso_local i32 @sigprocmask(i32, %struct.__sigset_t*, %struct.__sigset_t*) #2

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @regenerate_screen() #0 {
  store volatile i32 0, i32* @the_window_resized, align 4
  %1 = call i32 @endwin()
  %2 = load %struct._win_st*, %struct._win_st** @stdscr, align 8
  %3 = call i32 @wrefresh(%struct._win_st* %2)
  %4 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %5 = and i32 %4, 4096
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %7, label %13

7:                                                ; preds = %0
  %8 = load i32, i32* @LINES, align 4
  %9 = icmp sgt i32 %8, 5
  br i1 %9, label %10, label %13

10:                                               ; preds = %7
  %11 = load i32, i32* @COLS, align 4
  %12 = icmp sgt i32 %11, 9
  br label %13

13:                                               ; preds = %10, %7, %0
  %14 = phi i1 [ false, %7 ], [ false, %0 ], [ %12, %10 ]
  %15 = zext i1 %14 to i64
  %16 = select i1 %14, i32 1, i32 0
  store i32 %16, i32* @thebar, align 4
  %17 = load i32*, i32** @bardata, align 8
  %18 = bitcast i32* %17 to i8*
  %19 = load i32, i32* @LINES, align 4
  %20 = sext i32 %19 to i64
  %21 = mul i64 %20, 4
  %22 = call i8* @nrealloc(i8* %18, i64 %21)
  %23 = bitcast i8* %22 to i32*
  store i32* %23, i32** @bardata, align 8
  %24 = load i32, i32* @COLS, align 4
  %25 = load i32, i32* @margin, align 4
  %26 = sub nsw i32 %24, %25
  %27 = load i32, i32* @thebar, align 4
  %28 = sub nsw i32 %26, %27
  store i32 %28, i32* @editwincols, align 4
  call void @terminal_init()
  call void @window_init()
  %29 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %30 = icmp ne %struct.openfilestruct* %29, null
  br i1 %30, label %31, label %32

31:                                               ; preds = %13
  call void @ensure_firstcolumn_is_aligned()
  call void @draw_all_subwindows()
  br label %32

32:                                               ; preds = %31, %13
  ret void
}

declare dso_local i8* @nrealloc(i8*, i64) #1

declare dso_local void @ensure_firstcolumn_is_aligned() #1

declare dso_local void @draw_all_subwindows() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @toggle_this(i32 %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i8, align 1
  store i32 %0, i32* %2, align 4
  %4 = load i32, i32* %2, align 4
  %5 = sext i32 %4 to i64
  %6 = udiv i64 %5, 32
  %7 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %6
  %8 = load i32, i32* %7, align 4
  %9 = load i32, i32* %2, align 4
  %10 = sext i32 %9 to i64
  %11 = urem i64 %10, 32
  %12 = trunc i64 %11 to i32
  %13 = shl i32 1, %12
  %14 = and i32 %8, %13
  %15 = icmp ne i32 %14, 0
  %16 = xor i1 %15, true
  %17 = zext i1 %16 to i8
  store i8 %17, i8* %3, align 1
  %18 = load i32, i32* %2, align 4
  %19 = sext i32 %18 to i64
  %20 = urem i64 %19, 32
  %21 = trunc i64 %20 to i32
  %22 = shl i32 1, %21
  %23 = load i32, i32* %2, align 4
  %24 = sext i32 %23 to i64
  %25 = udiv i64 %24, 32
  %26 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %25
  %27 = load i32, i32* %26, align 4
  %28 = xor i32 %27, %22
  store i32 %28, i32* %26, align 4
  store i8 0, i8* @focusing, align 1
  %29 = load i32, i32* %2, align 4
  switch i32 %29, label %112 [
    i32 49, label %30
    i32 3, label %31
    i32 2, label %48
    i32 30, label %75
    i32 24, label %83
    i32 19, label %84
    i32 25, label %85
    i32 8, label %111
  ]

30:                                               ; preds = %1
  call void @window_init()
  call void @draw_all_subwindows()
  br label %185

31:                                               ; preds = %1
  %32 = load i32, i32* @LINES, align 4
  %33 = icmp slt i32 %32, 6
  br i1 %33, label %34, label %47

34:                                               ; preds = %31
  %35 = call i8* @gettext(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.204, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %35)
  %36 = load i32, i32* %2, align 4
  %37 = sext i32 %36 to i64
  %38 = urem i64 %37, 32
  %39 = trunc i64 %38 to i32
  %40 = shl i32 1, %39
  %41 = load i32, i32* %2, align 4
  %42 = sext i32 %41 to i64
  %43 = udiv i64 %42, 32
  %44 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %43
  %45 = load i32, i32* %44, align 4
  %46 = xor i32 %45, %40
  store i32 %46, i32* %44, align 4
  br label %185

47:                                               ; preds = %31
  call void @window_init()
  call void @draw_all_subwindows()
  br label %112

48:                                               ; preds = %1
  %49 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %50 = and i32 %49, 131072
  %51 = icmp ne i32 %50, 0
  br i1 %51, label %55, label %52

52:                                               ; preds = %48
  %53 = load i32, i32* @LINES, align 4
  %54 = icmp eq i32 %53, 1
  br i1 %54, label %55, label %68

55:                                               ; preds = %52, %48
  %56 = call i8* @gettext(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.205, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %56)
  %57 = load i32, i32* %2, align 4
  %58 = sext i32 %57 to i64
  %59 = urem i64 %58, 32
  %60 = trunc i64 %59 to i32
  %61 = shl i32 1, %60
  %62 = load i32, i32* %2, align 4
  %63 = sext i32 %62 to i64
  %64 = udiv i64 %63, 32
  %65 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %64
  %66 = load i32, i32* %65, align 4
  %67 = xor i32 %66, %61
  store i32 %67, i32* %65, align 4
  br label %74

68:                                               ; preds = %52
  %69 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %70 = and i32 %69, 65536
  %71 = icmp ne i32 %70, 0
  br i1 %71, label %73, label %72

72:                                               ; preds = %68
  call void @wipe_statusbar()
  br label %73

73:                                               ; preds = %72, %68
  br label %74

74:                                               ; preds = %73, %55
  br label %185

75:                                               ; preds = %1
  %76 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %77 = and i32 %76, 1073741824
  %78 = icmp ne i32 %77, 0
  br i1 %78, label %82, label %79

79:                                               ; preds = %75
  %80 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %81 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %80, i32 0, i32 6
  store i64 0, i64* %81, align 8
  br label %82

82:                                               ; preds = %79, %75
  store i8 1, i8* @refresh_needed, align 1
  br label %112

83:                                               ; preds = %1
  call void @titlebar(i8* null)
  store i8 1, i8* @refresh_needed, align 1
  br label %112

84:                                               ; preds = %1
  call void @precalc_multicolorinfo()
  store i8 1, i8* @refresh_needed, align 1
  br label %112

85:                                               ; preds = %1
  %86 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %87 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %86, i32 0, i32 22
  %88 = load %struct.syntaxtype*, %struct.syntaxtype** %87, align 8
  %89 = icmp ne %struct.syntaxtype* %88, null
  br i1 %89, label %90, label %110

90:                                               ; preds = %85
  %91 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %92 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %91, i32 0, i32 22
  %93 = load %struct.syntaxtype*, %struct.syntaxtype** %92, align 8
  %94 = getelementptr inbounds %struct.syntaxtype, %struct.syntaxtype* %93, i32 0, i32 9
  %95 = load i8*, i8** %94, align 8
  %96 = icmp ne i8* %95, null
  br i1 %96, label %97, label %110

97:                                               ; preds = %90
  %98 = call i8* @gettext(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.206, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %98)
  %99 = load i32, i32* %2, align 4
  %100 = sext i32 %99 to i64
  %101 = urem i64 %100, 32
  %102 = trunc i64 %101 to i32
  %103 = shl i32 1, %102
  %104 = load i32, i32* %2, align 4
  %105 = sext i32 %104 to i64
  %106 = udiv i64 %105, 32
  %107 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %106
  %108 = load i32, i32* %107, align 4
  %109 = xor i32 %108, %103
  store i32 %109, i32* %107, align 4
  br label %185

110:                                              ; preds = %90, %85
  br label %112

111:                                              ; preds = %1
  call void @mouse_init()
  br label %112

112:                                              ; preds = %111, %110, %84, %83, %82, %47, %1
  %113 = load i32, i32* %2, align 4
  %114 = icmp eq i32 %113, 6
  br i1 %114, label %121, label %115

115:                                              ; preds = %112
  %116 = load i32, i32* %2, align 4
  %117 = icmp eq i32 %116, 41
  br i1 %117, label %121, label %118

118:                                              ; preds = %115
  %119 = load i32, i32* %2, align 4
  %120 = icmp eq i32 %119, 30
  br i1 %120, label %121, label %140

121:                                              ; preds = %118, %115, %112
  %122 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %123 = and i32 %122, 65536
  %124 = icmp ne i32 %123, 0
  br i1 %124, label %125, label %134

125:                                              ; preds = %121
  %126 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %127 = and i32 %126, 131072
  %128 = icmp ne i32 %127, 0
  br i1 %128, label %134, label %129

129:                                              ; preds = %125
  %130 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %131 = and i32 %130, 16384
  %132 = icmp ne i32 %131, 0
  br i1 %132, label %133, label %134

133:                                              ; preds = %129
  br label %185

134:                                              ; preds = %129, %125, %121
  %135 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %136 = and i32 %135, 16384
  %137 = icmp ne i32 %136, 0
  br i1 %137, label %138, label %139

138:                                              ; preds = %134
  call void @titlebar(i8* null)
  br label %139

139:                                              ; preds = %138, %134
  br label %140

140:                                              ; preds = %139, %118
  %141 = load i32, i32* %2, align 4
  %142 = icmp eq i32 %141, 3
  br i1 %142, label %149, label %143

143:                                              ; preds = %140
  %144 = load i32, i32* %2, align 4
  %145 = icmp eq i32 %144, 37
  br i1 %145, label %149, label %146

146:                                              ; preds = %143
  %147 = load i32, i32* %2, align 4
  %148 = icmp eq i32 %147, 24
  br i1 %148, label %149, label %162

149:                                              ; preds = %146, %143, %140
  %150 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %151 = and i32 %150, 65536
  %152 = icmp ne i32 %151, 0
  br i1 %152, label %160, label %153

153:                                              ; preds = %149
  %154 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %155 = and i32 %154, 131072
  %156 = icmp ne i32 %155, 0
  br i1 %156, label %160, label %157

157:                                              ; preds = %153
  %158 = load i32, i32* @LINES, align 4
  %159 = icmp eq i32 %158, 1
  br i1 %159, label %160, label %161

160:                                              ; preds = %157, %153, %149
  br label %185

161:                                              ; preds = %157
  br label %162

162:                                              ; preds = %161, %146
  %163 = load i32, i32* %2, align 4
  %164 = icmp eq i32 %163, 3
  br i1 %164, label %168, label %165

165:                                              ; preds = %162
  %166 = load i32, i32* %2, align 4
  %167 = icmp eq i32 %166, 19
  br i1 %167, label %168, label %173

168:                                              ; preds = %165, %162
  %169 = load i8, i8* %3, align 1
  %170 = trunc i8 %169 to i1
  %171 = xor i1 %170, true
  %172 = zext i1 %171 to i8
  store i8 %172, i8* %3, align 1
  br label %173

173:                                              ; preds = %168, %165
  %174 = load i32, i32* %2, align 4
  %175 = call i8* @epithet_of_flag(i32 %174)
  %176 = call i8* @gettext(i8* %175) #9
  %177 = load i8, i8* %3, align 1
  %178 = trunc i8 %177 to i1
  br i1 %178, label %179, label %181

179:                                              ; preds = %173
  %180 = call i8* @gettext(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.208, i64 0, i64 0)) #9
  br label %183

181:                                              ; preds = %173
  %182 = call i8* @gettext(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.209, i64 0, i64 0)) #9
  br label %183

183:                                              ; preds = %181, %179
  %184 = phi i8* [ %180, %179 ], [ %182, %181 ]
  call void (i32, i8*, ...) @statusline(i32 2, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.207, i64 0, i64 0), i8* %176, i8* %184)
  br label %185

185:                                              ; preds = %183, %160, %133, %97, %74, %34, %30
  ret void
}

declare dso_local void @wipe_statusbar() #1

declare dso_local void @precalc_multicolorinfo() #1

declare dso_local i8* @epithet_of_flag(i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @disable_extended_io() #0 {
  %1 = alloca %struct.termios, align 4
  %2 = bitcast %struct.termios* %1 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 4 %2, i8 0, i64 60, i1 false)
  %3 = call i32 @tcgetattr(i32 0, %struct.termios* %1) #9
  %4 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 3
  %5 = load i32, i32* %4, align 4
  %6 = and i32 %5, -32769
  store i32 %6, i32* %4, align 4
  %7 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 1
  %8 = load i32, i32* %7, align 4
  %9 = and i32 %8, -2
  store i32 %9, i32* %7, align 4
  %10 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* %1) #9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @disable_flow_control() #0 {
  %1 = alloca %struct.termios, align 4
  %2 = call i32 @tcgetattr(i32 0, %struct.termios* %1) #9
  %3 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 0
  %4 = load i32, i32* %3, align 4
  %5 = and i32 %4, -1025
  store i32 %5, i32* %3, align 4
  %6 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* %1) #9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @enable_flow_control() #0 {
  %1 = alloca %struct.termios, align 4
  %2 = call i32 @tcgetattr(i32 0, %struct.termios* %1) #9
  %3 = getelementptr inbounds %struct.termios, %struct.termios* %1, i32 0, i32 0
  %4 = load i32, i32* %3, align 4
  %5 = or i32 %4, 1024
  store i32 %5, i32* %3, align 4
  %6 = call i32 @tcsetattr(i32 0, i32 0, %struct.termios* %1) #9
  ret void
}

declare dso_local i32 @raw() #1

declare dso_local i32 @nonl() #1

declare dso_local i32 @noecho() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @get_keycode(i8* %0, i32 %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8*, align 8
  %5 = alloca i32, align 4
  %6 = alloca i8*, align 8
  store i8* %0, i8** %4, align 8
  store i32 %1, i32* %5, align 4
  %7 = load i8*, i8** %4, align 8
  %8 = call i8* @tigetstr(i8* %7)
  store i8* %8, i8** %6, align 8
  %9 = load i8*, i8** %6, align 8
  %10 = icmp ne i8* %9, null
  br i1 %10, label %11, label %21

11:                                               ; preds = %2
  %12 = load i8*, i8** %6, align 8
  %13 = icmp ne i8* %12, inttoptr (i64 -1 to i8*)
  br i1 %13, label %14, label %21

14:                                               ; preds = %11
  %15 = load i8*, i8** %6, align 8
  %16 = call i32 @key_defined(i8* %15)
  %17 = icmp ne i32 %16, 0
  br i1 %17, label %18, label %21

18:                                               ; preds = %14
  %19 = load i8*, i8** %6, align 8
  %20 = call i32 @key_defined(i8* %19)
  store i32 %20, i32* %3, align 4
  br label %23

21:                                               ; preds = %14, %11, %2
  %22 = load i32, i32* %5, align 4
  store i32 %22, i32* %3, align 4
  br label %23

23:                                               ; preds = %21, %18
  %24 = load i32, i32* %3, align 4
  ret i32 %24
}

declare dso_local i8* @tigetstr(i8*) #1

declare dso_local i32 @key_defined(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @confirm_margin() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i8, align 1
  %3 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %4 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %3, i32 0, i32 2
  %5 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %6 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %5, i32 0, i32 1
  %7 = load i64, i64* %6, align 8
  %8 = call i32 @digits(i64 %7)
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %1, align 4
  %10 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %11 = and i32 %10, 32
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %13, label %18

13:                                               ; preds = %0
  %14 = load i32, i32* %1, align 4
  %15 = load i32, i32* @COLS, align 4
  %16 = sub nsw i32 %15, 4
  %17 = icmp sgt i32 %14, %16
  br i1 %17, label %18, label %19

18:                                               ; preds = %13, %0
  store i32 0, i32* %1, align 4
  br label %19

19:                                               ; preds = %18, %13
  %20 = load i32, i32* %1, align 4
  %21 = load i32, i32* @margin, align 4
  %22 = icmp ne i32 %20, %21
  br i1 %22, label %23, label %41

23:                                               ; preds = %19
  %24 = load i32, i32* @margin, align 4
  %25 = icmp sgt i32 %24, 0
  br i1 %25, label %26, label %29

26:                                               ; preds = %23
  %27 = load i8, i8* @focusing, align 1
  %28 = trunc i8 %27 to i1
  br label %29

29:                                               ; preds = %26, %23
  %30 = phi i1 [ false, %23 ], [ %28, %26 ]
  %31 = zext i1 %30 to i8
  store i8 %31, i8* %2, align 1
  %32 = load i32, i32* %1, align 4
  store i32 %32, i32* @margin, align 4
  %33 = load i32, i32* @COLS, align 4
  %34 = load i32, i32* @margin, align 4
  %35 = sub nsw i32 %33, %34
  %36 = load i32, i32* @thebar, align 4
  %37 = sub nsw i32 %35, %36
  store i32 %37, i32* @editwincols, align 4
  call void @ensure_firstcolumn_is_aligned()
  %38 = load i8, i8* %2, align 1
  %39 = trunc i8 %38 to i1
  %40 = zext i1 %39 to i8
  store i8 %40, i8* @focusing, align 1
  store i8 1, i8* @refresh_needed, align 1
  br label %41

41:                                               ; preds = %29, %19
  ret void
}

declare dso_local i32 @digits(i64) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @unbound_key(i32 %0) #0 {
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = load i32, i32* %2, align 4
  %4 = icmp eq i32 %3, 1276
  br i1 %4, label %5, label %7

5:                                                ; preds = %1
  %6 = call i8* @gettext(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.211, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %6)
  br label %70

7:                                                ; preds = %1
  %8 = load i32, i32* %2, align 4
  %9 = icmp sgt i32 %8, 264
  br i1 %9, label %10, label %17

10:                                               ; preds = %7
  %11 = load i32, i32* %2, align 4
  %12 = icmp slt i32 %11, 289
  br i1 %12, label %13, label %17

13:                                               ; preds = %10
  %14 = call i8* @gettext(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.212, i64 0, i64 0)) #9
  %15 = load i32, i32* %2, align 4
  %16 = sub nsw i32 %15, 264
  call void (i32, i8*, ...) @statusline(i32 5, i8* %14, i32 %16)
  br label %69

17:                                               ; preds = %10, %7
  %18 = load i32, i32* %2, align 4
  %19 = icmp sgt i32 %18, 127
  br i1 %19, label %20, label %22

20:                                               ; preds = %17
  %21 = call i8* @gettext(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.213, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %21)
  br label %68

22:                                               ; preds = %17
  %23 = load i8, i8* @meta_key, align 1
  %24 = trunc i8 %23 to i1
  br i1 %24, label %25, label %50

25:                                               ; preds = %22
  %26 = load i32, i32* %2, align 4
  %27 = icmp slt i32 %26, 32
  br i1 %27, label %28, label %32

28:                                               ; preds = %25
  %29 = call i8* @gettext(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.214, i64 0, i64 0)) #9
  %30 = load i32, i32* %2, align 4
  %31 = add nsw i32 %30, 64
  call void (i32, i8*, ...) @statusline(i32 5, i8* %29, i32 %31)
  br label %49

32:                                               ; preds = %25
  %33 = load i8, i8* @shifted_metas, align 1
  %34 = trunc i8 %33 to i1
  br i1 %34, label %35, label %44

35:                                               ; preds = %32
  %36 = load i32, i32* %2, align 4
  %37 = icmp sle i32 65, %36
  br i1 %37, label %38, label %44

38:                                               ; preds = %35
  %39 = load i32, i32* %2, align 4
  %40 = icmp sle i32 %39, 90
  br i1 %40, label %41, label %44

41:                                               ; preds = %38
  %42 = call i8* @gettext(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.215, i64 0, i64 0)) #9
  %43 = load i32, i32* %2, align 4
  call void (i32, i8*, ...) @statusline(i32 5, i8* %42, i32 %43)
  br label %48

44:                                               ; preds = %38, %35, %32
  %45 = call i8* @gettext(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @.str.216, i64 0, i64 0)) #9
  %46 = load i32, i32* %2, align 4
  %47 = call i32 @toupper(i32 %46) #12
  call void (i32, i8*, ...) @statusline(i32 5, i8* %45, i32 %47)
  br label %48

48:                                               ; preds = %44, %41
  br label %49

49:                                               ; preds = %48, %28
  br label %67

50:                                               ; preds = %22
  %51 = load i32, i32* %2, align 4
  %52 = icmp eq i32 %51, 27
  br i1 %52, label %53, label %55

53:                                               ; preds = %50
  %54 = call i8* @gettext(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.217, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 5, i8* %54)
  br label %66

55:                                               ; preds = %50
  %56 = load i32, i32* %2, align 4
  %57 = icmp slt i32 %56, 32
  br i1 %57, label %58, label %62

58:                                               ; preds = %55
  %59 = call i8* @gettext(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.218, i64 0, i64 0)) #9
  %60 = load i32, i32* %2, align 4
  %61 = add nsw i32 %60, 64
  call void (i32, i8*, ...) @statusline(i32 5, i8* %59, i32 %61)
  br label %65

62:                                               ; preds = %55
  %63 = call i8* @gettext(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.219, i64 0, i64 0)) #9
  %64 = load i32, i32* %2, align 4
  call void (i32, i8*, ...) @statusline(i32 5, i8* %63, i32 %64)
  br label %65

65:                                               ; preds = %62, %58
  br label %66

66:                                               ; preds = %65, %53
  br label %67

67:                                               ; preds = %66, %49
  br label %68

68:                                               ; preds = %67, %20
  br label %69

69:                                               ; preds = %68, %13
  br label %70

70:                                               ; preds = %69, %5
  call void @set_blankdelay_to_one()
  ret void
}

; Function Attrs: nounwind readonly
declare dso_local i32 @toupper(i32) #7

declare dso_local void @set_blankdelay_to_one() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @do_mouse() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca %struct.linestruct*, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i8, align 1
  %10 = call i32 @get_mouseinput(i32* %2, i32* %3, i1 zeroext true)
  store i32 %10, i32* %4, align 4
  %11 = load i32, i32* %4, align 4
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %13, label %15

13:                                               ; preds = %0
  %14 = load i32, i32* %4, align 4
  store i32 %14, i32* %1, align 4
  br label %97

15:                                               ; preds = %0
  %16 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %17 = call zeroext i1 @wmouse_trafo(%struct._win_st* %16, i32* %2, i32* %3, i1 zeroext false)
  br i1 %17, label %18, label %96

18:                                               ; preds = %15
  %19 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %20 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %19, i32 0, i32 4
  %21 = load %struct.linestruct*, %struct.linestruct** %20, align 8
  store %struct.linestruct* %21, %struct.linestruct** %5, align 8
  %22 = load i32, i32* %2, align 4
  %23 = sext i32 %22 to i64
  %24 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %25 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %24, i32 0, i32 9
  %26 = load i64, i64* %25, align 8
  %27 = sub nsw i64 %23, %26
  store i64 %27, i64* %6, align 8
  %28 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %29 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %28, i32 0, i32 7
  %30 = load i64, i64* %29, align 8
  store i64 %30, i64* %8, align 8
  %31 = load i32, i32* %2, align 4
  %32 = sext i32 %31 to i64
  %33 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %34 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %33, i32 0, i32 9
  %35 = load i64, i64* %34, align 8
  %36 = icmp eq i64 %32, %35
  %37 = zext i1 %36 to i8
  store i8 %37, i8* %9, align 1
  %38 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %39 = and i32 %38, 1073741824
  %40 = icmp ne i32 %39, 0
  br i1 %40, label %41, label %47

41:                                               ; preds = %18
  %42 = call i64 @xplustabs()
  %43 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %44 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %43, i32 0, i32 4
  %45 = load %struct.linestruct*, %struct.linestruct** %44, align 8
  %46 = call i64 @leftedge_for(i64 %42, %struct.linestruct* %45)
  store i64 %46, i64* %7, align 8
  br label %50

47:                                               ; preds = %18
  %48 = call i64 @xplustabs()
  %49 = call i64 @get_page_start(i64 %48)
  store i64 %49, i64* %7, align 8
  br label %50

50:                                               ; preds = %47, %41
  %51 = load i64, i64* %6, align 8
  %52 = icmp slt i64 %51, 0
  br i1 %52, label %53, label %60

53:                                               ; preds = %50
  %54 = load i64, i64* %6, align 8
  %55 = sub nsw i64 0, %54
  %56 = trunc i64 %55 to i32
  %57 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %58 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %57, i32 0, i32 4
  %59 = call i32 @go_back_chunks(i32 %56, %struct.linestruct** %58, i64* %7)
  br label %66

60:                                               ; preds = %50
  %61 = load i64, i64* %6, align 8
  %62 = trunc i64 %61 to i32
  %63 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %64 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %63, i32 0, i32 4
  %65 = call i32 @go_forward_chunks(i32 %62, %struct.linestruct** %64, i64* %7)
  br label %66

66:                                               ; preds = %60, %53
  %67 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %68 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %67, i32 0, i32 4
  %69 = load %struct.linestruct*, %struct.linestruct** %68, align 8
  %70 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %69, i32 0, i32 0
  %71 = load i8*, i8** %70, align 8
  %72 = load i64, i64* %7, align 8
  %73 = load i32, i32* %3, align 4
  %74 = sext i32 %73 to i64
  %75 = call i64 @actual_last_column(i64 %72, i64 %74)
  %76 = call i64 @actual_x(i8* %71, i64 %75)
  %77 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %78 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %77, i32 0, i32 7
  store i64 %76, i64* %78, align 8
  %79 = load i8, i8* %9, align 1
  %80 = trunc i8 %79 to i1
  br i1 %80, label %81, label %93

81:                                               ; preds = %66
  %82 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %83 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %82, i32 0, i32 7
  %84 = load i64, i64* %83, align 8
  %85 = load i64, i64* %8, align 8
  %86 = icmp eq i64 %84, %85
  br i1 %86, label %87, label %93

87:                                               ; preds = %81
  call void @do_mark()
  %88 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %89 = and i32 %88, 16384
  %90 = icmp ne i32 %89, 0
  br i1 %90, label %91, label %92

91:                                               ; preds = %87
  call void @titlebar(i8* null)
  br label %92

92:                                               ; preds = %91, %87
  br label %94

93:                                               ; preds = %81, %66
  store i8 0, i8* @keep_cutbuffer, align 1
  br label %94

94:                                               ; preds = %93, %92
  %95 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  call void @edit_redraw(%struct.linestruct* %95, i32 0)
  br label %96

96:                                               ; preds = %94, %15
  store i32 2, i32* %1, align 4
  br label %97

97:                                               ; preds = %96, %13
  %98 = load i32, i32* %1, align 4
  ret i32 %98
}

declare dso_local i32 @get_mouseinput(i32*, i32*, i1 zeroext) #1

declare dso_local zeroext i1 @wmouse_trafo(%struct._win_st*, i32*, i32*, i1 zeroext) #1

declare dso_local i64 @leftedge_for(i64, %struct.linestruct*) #1

declare dso_local i64 @xplustabs() #1

declare dso_local i64 @get_page_start(i64) #1

declare dso_local i32 @go_back_chunks(i32, %struct.linestruct**, i64*) #1

declare dso_local i32 @go_forward_chunks(i32, %struct.linestruct**, i64*) #1

declare dso_local i64 @actual_x(i8*, i64) #1

declare dso_local i64 @actual_last_column(i64, i64) #1

declare dso_local void @do_mark() #1

declare dso_local void @edit_redraw(%struct.linestruct*, i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @wanted_to_move(void ()* %0) #0 {
  %2 = alloca void ()*, align 8
  store void ()* %0, void ()** %2, align 8
  %3 = load void ()*, void ()** %2, align 8
  %4 = icmp eq void ()* %3, @do_left
  br i1 %4, label %50, label %5

5:                                                ; preds = %1
  %6 = load void ()*, void ()** %2, align 8
  %7 = icmp eq void ()* %6, @do_right
  br i1 %7, label %50, label %8

8:                                                ; preds = %5
  %9 = load void ()*, void ()** %2, align 8
  %10 = icmp eq void ()* %9, @do_up
  br i1 %10, label %50, label %11

11:                                               ; preds = %8
  %12 = load void ()*, void ()** %2, align 8
  %13 = icmp eq void ()* %12, @do_down
  br i1 %13, label %50, label %14

14:                                               ; preds = %11
  %15 = load void ()*, void ()** %2, align 8
  %16 = icmp eq void ()* %15, @do_home
  br i1 %16, label %50, label %17

17:                                               ; preds = %14
  %18 = load void ()*, void ()** %2, align 8
  %19 = icmp eq void ()* %18, @do_end
  br i1 %19, label %50, label %20

20:                                               ; preds = %17
  %21 = load void ()*, void ()** %2, align 8
  %22 = icmp eq void ()* %21, @to_prev_word
  br i1 %22, label %50, label %23

23:                                               ; preds = %20
  %24 = load void ()*, void ()** %2, align 8
  %25 = icmp eq void ()* %24, @to_next_word
  br i1 %25, label %50, label %26

26:                                               ; preds = %23
  %27 = load void ()*, void ()** %2, align 8
  %28 = icmp eq void ()* %27, @to_para_begin
  br i1 %28, label %50, label %29

29:                                               ; preds = %26
  %30 = load void ()*, void ()** %2, align 8
  %31 = icmp eq void ()* %30, @to_para_end
  br i1 %31, label %50, label %32

32:                                               ; preds = %29
  %33 = load void ()*, void ()** %2, align 8
  %34 = icmp eq void ()* %33, @to_prev_block
  br i1 %34, label %50, label %35

35:                                               ; preds = %32
  %36 = load void ()*, void ()** %2, align 8
  %37 = icmp eq void ()* %36, @to_next_block
  br i1 %37, label %50, label %38

38:                                               ; preds = %35
  %39 = load void ()*, void ()** %2, align 8
  %40 = icmp eq void ()* %39, @do_page_up
  br i1 %40, label %50, label %41

41:                                               ; preds = %38
  %42 = load void ()*, void ()** %2, align 8
  %43 = icmp eq void ()* %42, @do_page_down
  br i1 %43, label %50, label %44

44:                                               ; preds = %41
  %45 = load void ()*, void ()** %2, align 8
  %46 = icmp eq void ()* %45, @to_first_line
  br i1 %46, label %50, label %47

47:                                               ; preds = %44
  %48 = load void ()*, void ()** %2, align 8
  %49 = icmp eq void ()* %48, @to_last_line
  br label %50

50:                                               ; preds = %47, %44, %41, %38, %35, %32, %29, %26, %23, %20, %17, %14, %11, %8, %5, %1
  %51 = phi i1 [ true, %44 ], [ true, %41 ], [ true, %38 ], [ true, %35 ], [ true, %32 ], [ true, %29 ], [ true, %26 ], [ true, %23 ], [ true, %20 ], [ true, %17 ], [ true, %14 ], [ true, %11 ], [ true, %8 ], [ true, %5 ], [ true, %1 ], [ %49, %47 ]
  ret i1 %51
}

declare dso_local void @do_left() #1

declare dso_local void @do_right() #1

declare dso_local void @do_up() #1

declare dso_local void @do_down() #1

declare dso_local void @do_home() #1

declare dso_local void @do_end() #1

declare dso_local void @to_prev_word() #1

declare dso_local void @to_next_word() #1

declare dso_local void @to_para_begin() #1

declare dso_local void @to_para_end() #1

declare dso_local void @to_prev_block() #1

declare dso_local void @to_next_block() #1

declare dso_local void @do_page_up() #1

declare dso_local void @do_page_down() #1

declare dso_local void @to_first_line() #1

declare dso_local void @to_last_line() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @okay_for_view(%struct.keystruct* %0) #0 {
  %2 = alloca %struct.keystruct*, align 8
  %3 = alloca %struct.funcstruct*, align 8
  store %struct.keystruct* %0, %struct.keystruct** %2, align 8
  %4 = load %struct.funcstruct*, %struct.funcstruct** @allfuncs, align 8
  store %struct.funcstruct* %4, %struct.funcstruct** %3, align 8
  br label %5

5:                                                ; preds = %18, %1
  %6 = load %struct.funcstruct*, %struct.funcstruct** %3, align 8
  %7 = icmp ne %struct.funcstruct* %6, null
  br i1 %7, label %8, label %16

8:                                                ; preds = %5
  %9 = load %struct.funcstruct*, %struct.funcstruct** %3, align 8
  %10 = getelementptr inbounds %struct.funcstruct, %struct.funcstruct* %9, i32 0, i32 0
  %11 = load void ()*, void ()** %10, align 8
  %12 = load %struct.keystruct*, %struct.keystruct** %2, align 8
  %13 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %12, i32 0, i32 3
  %14 = load void ()*, void ()** %13, align 8
  %15 = icmp ne void ()* %11, %14
  br label %16

16:                                               ; preds = %8, %5
  %17 = phi i1 [ false, %5 ], [ %15, %8 ]
  br i1 %17, label %18, label %22

18:                                               ; preds = %16
  %19 = load %struct.funcstruct*, %struct.funcstruct** %3, align 8
  %20 = getelementptr inbounds %struct.funcstruct, %struct.funcstruct* %19, i32 0, i32 6
  %21 = load %struct.funcstruct*, %struct.funcstruct** %20, align 8
  store %struct.funcstruct* %21, %struct.funcstruct** %3, align 8
  br label %5

22:                                               ; preds = %16
  %23 = load %struct.funcstruct*, %struct.funcstruct** %3, align 8
  %24 = icmp eq %struct.funcstruct* %23, null
  br i1 %24, label %30, label %25

25:                                               ; preds = %22
  %26 = load %struct.funcstruct*, %struct.funcstruct** %3, align 8
  %27 = getelementptr inbounds %struct.funcstruct, %struct.funcstruct* %26, i32 0, i32 4
  %28 = load i8, i8* %27, align 1
  %29 = trunc i8 %28 to i1
  br label %30

30:                                               ; preds = %25, %22
  %31 = phi i1 [ true, %22 ], [ %29, %25 ]
  ret i1 %31
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @suck_up_input_and_paste_it() #0 {
  %1 = alloca %struct.linestruct*, align 8
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i32, align 4
  %5 = load %struct.linestruct*, %struct.linestruct** @cutbuffer, align 8
  store %struct.linestruct* %5, %struct.linestruct** %1, align 8
  %6 = call %struct.linestruct* @make_new_node(%struct.linestruct* null)
  store %struct.linestruct* %6, %struct.linestruct** %2, align 8
  store i64 0, i64* %3, align 8
  %7 = call i8* @copy_of(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.220, i64 0, i64 0))
  %8 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %9 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %8, i32 0, i32 0
  store i8* %7, i8** %9, align 8
  %10 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  store %struct.linestruct* %10, %struct.linestruct** @cutbuffer, align 8
  br label %11

11:                                               ; preds = %74, %0
  %12 = load i8, i8* @bracketed_paste, align 1
  %13 = trunc i8 %12 to i1
  br i1 %13, label %14, label %75

14:                                               ; preds = %11
  %15 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %16 = call i32 @get_kbinput(%struct._win_st* %15, i1 zeroext false)
  store i32 %16, i32* %4, align 4
  %17 = load i32, i32* %4, align 4
  %18 = icmp eq i32 %17, 13
  br i1 %18, label %22, label %19

19:                                               ; preds = %14
  %20 = load i32, i32* %4, align 4
  %21 = icmp eq i32 %20, 10
  br i1 %21, label %22, label %33

22:                                               ; preds = %19, %14
  %23 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %24 = call %struct.linestruct* @make_new_node(%struct.linestruct* %23)
  %25 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %26 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %25, i32 0, i32 2
  store %struct.linestruct* %24, %struct.linestruct** %26, align 8
  %27 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %28 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %27, i32 0, i32 2
  %29 = load %struct.linestruct*, %struct.linestruct** %28, align 8
  store %struct.linestruct* %29, %struct.linestruct** %2, align 8
  %30 = call i8* @copy_of(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.220, i64 0, i64 0))
  %31 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %32 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %31, i32 0, i32 0
  store i8* %30, i8** %32, align 8
  store i64 0, i64* %3, align 8
  br label %74

33:                                               ; preds = %19
  %34 = load i32, i32* %4, align 4
  %35 = icmp sle i32 32, %34
  br i1 %35, label %36, label %42

36:                                               ; preds = %33
  %37 = load i32, i32* %4, align 4
  %38 = icmp sle i32 %37, 255
  br i1 %38, label %39, label %42

39:                                               ; preds = %36
  %40 = load i32, i32* %4, align 4
  %41 = icmp ne i32 %40, 127
  br i1 %41, label %45, label %42

42:                                               ; preds = %39, %36, %33
  %43 = load i32, i32* %4, align 4
  %44 = icmp eq i32 %43, 9
  br i1 %44, label %45, label %67

45:                                               ; preds = %42, %39
  %46 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %47 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %46, i32 0, i32 0
  %48 = load i8*, i8** %47, align 8
  %49 = load i64, i64* %3, align 8
  %50 = add i64 %49, 2
  %51 = call i8* @nrealloc(i8* %48, i64 %50)
  %52 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %53 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %52, i32 0, i32 0
  store i8* %51, i8** %53, align 8
  %54 = load i32, i32* %4, align 4
  %55 = trunc i32 %54 to i8
  %56 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %57 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %56, i32 0, i32 0
  %58 = load i8*, i8** %57, align 8
  %59 = load i64, i64* %3, align 8
  %60 = add i64 %59, 1
  store i64 %60, i64* %3, align 8
  %61 = getelementptr inbounds i8, i8* %58, i64 %59
  store i8 %55, i8* %61, align 1
  %62 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %63 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %62, i32 0, i32 0
  %64 = load i8*, i8** %63, align 8
  %65 = load i64, i64* %3, align 8
  %66 = getelementptr inbounds i8, i8* %64, i64 %65
  store i8 0, i8* %66, align 1
  br label %73

67:                                               ; preds = %42
  %68 = load i32, i32* %4, align 4
  %69 = icmp ne i32 %68, 1275
  br i1 %69, label %70, label %72

70:                                               ; preds = %67
  %71 = call i32 @beep()
  br label %72

72:                                               ; preds = %70, %67
  br label %73

73:                                               ; preds = %72, %45
  br label %74

74:                                               ; preds = %73, %22
  br label %11

75:                                               ; preds = %11
  call void @paste_text()
  %76 = load %struct.linestruct*, %struct.linestruct** @cutbuffer, align 8
  call void @free_lines(%struct.linestruct* %76)
  %77 = load %struct.linestruct*, %struct.linestruct** %1, align 8
  store %struct.linestruct* %77, %struct.linestruct** @cutbuffer, align 8
  ret void
}

declare dso_local i32 @get_kbinput(%struct._win_st*, i1 zeroext) #1

declare dso_local void @paste_text() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @inject(i8* %0, i64 %1) #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i64, align 8
  %5 = alloca %struct.linestruct*, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  store i8* %0, i8** %3, align 8
  store i64 %1, i64* %4, align 8
  %10 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %11 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %10, i32 0, i32 4
  %12 = load %struct.linestruct*, %struct.linestruct** %11, align 8
  store %struct.linestruct* %12, %struct.linestruct** %5, align 8
  %13 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %14 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %13, i32 0, i32 0
  %15 = load i8*, i8** %14, align 8
  %16 = call i64 @strlen(i8* %15) #12
  store i64 %16, i64* %6, align 8
  store i64 0, i64* %7, align 8
  store i64 0, i64* %8, align 8
  %17 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %18 = and i32 %17, 1073741824
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %20, label %35

20:                                               ; preds = %2
  %21 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %22 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %21, i32 0, i32 9
  %23 = load i64, i64* %22, align 8
  %24 = load i32, i32* @editwinrows, align 4
  %25 = sub nsw i32 %24, 1
  %26 = sext i32 %25 to i64
  %27 = icmp eq i64 %23, %26
  br i1 %27, label %28, label %32

28:                                               ; preds = %20
  %29 = call i64 @xplustabs()
  %30 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %31 = call i64 @chunk_for(i64 %29, %struct.linestruct* %30)
  store i64 %31, i64* %7, align 8
  br label %32

32:                                               ; preds = %28, %20
  %33 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %34 = call i64 @extra_chunks_in(%struct.linestruct* %33)
  store i64 %34, i64* %8, align 8
  br label %35

35:                                               ; preds = %32, %2
  store i64 0, i64* %9, align 8
  br label %36

36:                                               ; preds = %52, %35
  %37 = load i64, i64* %9, align 8
  %38 = load i64, i64* %4, align 8
  %39 = icmp ult i64 %37, %38
  br i1 %39, label %40, label %55

40:                                               ; preds = %36
  %41 = load i8*, i8** %3, align 8
  %42 = load i64, i64* %9, align 8
  %43 = getelementptr inbounds i8, i8* %41, i64 %42
  %44 = load i8, i8* %43, align 1
  %45 = sext i8 %44 to i32
  %46 = icmp eq i32 %45, 0
  br i1 %46, label %47, label %51

47:                                               ; preds = %40
  %48 = load i8*, i8** %3, align 8
  %49 = load i64, i64* %9, align 8
  %50 = getelementptr inbounds i8, i8* %48, i64 %49
  store i8 10, i8* %50, align 1
  br label %51

51:                                               ; preds = %47, %40
  br label %52

52:                                               ; preds = %51
  %53 = load i64, i64* %9, align 8
  %54 = add i64 %53, 1
  store i64 %54, i64* %9, align 8
  br label %36

55:                                               ; preds = %36
  %56 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %57 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %56, i32 0, i32 20
  %58 = load i32, i32* %57, align 8
  %59 = icmp ne i32 %58, 0
  br i1 %59, label %80, label %60

60:                                               ; preds = %55
  %61 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %62 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %61, i32 0, i32 18
  %63 = load %struct.undostruct*, %struct.undostruct** %62, align 8
  %64 = getelementptr inbounds %struct.undostruct, %struct.undostruct* %63, i32 0, i32 9
  %65 = load i64, i64* %64, align 8
  %66 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %67 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %66, i32 0, i32 1
  %68 = load i64, i64* %67, align 8
  %69 = icmp ne i64 %65, %68
  br i1 %69, label %80, label %70

70:                                               ; preds = %60
  %71 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %72 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %71, i32 0, i32 18
  %73 = load %struct.undostruct*, %struct.undostruct** %72, align 8
  %74 = getelementptr inbounds %struct.undostruct, %struct.undostruct* %73, i32 0, i32 10
  %75 = load i64, i64* %74, align 8
  %76 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %77 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %76, i32 0, i32 7
  %78 = load i64, i64* %77, align 8
  %79 = icmp ne i64 %75, %78
  br i1 %79, label %80, label %81

80:                                               ; preds = %70, %60, %55
  call void @add_undo(i32 0, i8* null)
  br label %81

81:                                               ; preds = %80, %70
  %82 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %83 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %82, i32 0, i32 0
  %84 = load i8*, i8** %83, align 8
  %85 = load i64, i64* %6, align 8
  %86 = load i64, i64* %4, align 8
  %87 = add i64 %85, %86
  %88 = add i64 %87, 1
  %89 = call i8* @nrealloc(i8* %84, i64 %88)
  %90 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %91 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %90, i32 0, i32 0
  store i8* %89, i8** %91, align 8
  %92 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %93 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %92, i32 0, i32 0
  %94 = load i8*, i8** %93, align 8
  %95 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %96 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %95, i32 0, i32 7
  %97 = load i64, i64* %96, align 8
  %98 = getelementptr inbounds i8, i8* %94, i64 %97
  %99 = load i64, i64* %4, align 8
  %100 = getelementptr inbounds i8, i8* %98, i64 %99
  %101 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %102 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %101, i32 0, i32 0
  %103 = load i8*, i8** %102, align 8
  %104 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %105 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %104, i32 0, i32 7
  %106 = load i64, i64* %105, align 8
  %107 = getelementptr inbounds i8, i8* %103, i64 %106
  %108 = load i64, i64* %6, align 8
  %109 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %110 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %109, i32 0, i32 7
  %111 = load i64, i64* %110, align 8
  %112 = sub i64 %108, %111
  %113 = add i64 %112, 1
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 1 %100, i8* align 1 %107, i64 %113, i1 false)
  %114 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %115 = getelementptr inbounds %struct.linestruct, %struct.linestruct* %114, i32 0, i32 0
  %116 = load i8*, i8** %115, align 8
  %117 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %118 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %117, i32 0, i32 7
  %119 = load i64, i64* %118, align 8
  %120 = getelementptr inbounds i8, i8* %116, i64 %119
  %121 = load i8*, i8** %3, align 8
  %122 = load i64, i64* %4, align 8
  %123 = call i8* @strncpy(i8* %120, i8* %121, i64 %122) #9
  %124 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %125 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %126 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %125, i32 0, i32 12
  %127 = load %struct.linestruct*, %struct.linestruct** %126, align 8
  %128 = icmp eq %struct.linestruct* %124, %127
  br i1 %128, label %129, label %143

129:                                              ; preds = %81
  %130 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %131 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %130, i32 0, i32 7
  %132 = load i64, i64* %131, align 8
  %133 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %134 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %133, i32 0, i32 13
  %135 = load i64, i64* %134, align 8
  %136 = icmp ult i64 %132, %135
  br i1 %136, label %137, label %143

137:                                              ; preds = %129
  %138 = load i64, i64* %4, align 8
  %139 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %140 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %139, i32 0, i32 13
  %141 = load i64, i64* %140, align 8
  %142 = add i64 %141, %138
  store i64 %142, i64* %140, align 8
  br label %143

143:                                              ; preds = %137, %129, %81
  %144 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %145 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %146 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %145, i32 0, i32 3
  %147 = load %struct.linestruct*, %struct.linestruct** %146, align 8
  %148 = icmp eq %struct.linestruct* %144, %147
  br i1 %148, label %149, label %155

149:                                              ; preds = %143
  %150 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %151 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %150, i32 0, i32 6
  %152 = load i64, i64* %151, align 8
  %153 = icmp ugt i64 %152, 0
  br i1 %153, label %154, label %155

154:                                              ; preds = %149
  call void @ensure_firstcolumn_is_aligned()
  store i8 1, i8* @refresh_needed, align 1
  br label %155

155:                                              ; preds = %154, %149, %143
  %156 = load %struct.linestruct*, %struct.linestruct** %5, align 8
  %157 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %158 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %157, i32 0, i32 2
  %159 = load %struct.linestruct*, %struct.linestruct** %158, align 8
  %160 = icmp eq %struct.linestruct* %156, %159
  br i1 %160, label %161, label %170

161:                                              ; preds = %155
  %162 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %163 = and i32 %162, 268435456
  %164 = icmp ne i32 %163, 0
  br i1 %164, label %170, label %165

165:                                              ; preds = %161
  call void @new_magicline()
  %166 = load i32, i32* @margin, align 4
  %167 = icmp sgt i32 %166, 0
  br i1 %167, label %168, label %169

168:                                              ; preds = %165
  store i8 1, i8* @refresh_needed, align 1
  br label %169

169:                                              ; preds = %168, %165
  br label %170

170:                                              ; preds = %169, %161, %155
  %171 = load i64, i64* %4, align 8
  %172 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %173 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %172, i32 0, i32 7
  %174 = load i64, i64* %173, align 8
  %175 = add i64 %174, %171
  store i64 %175, i64* %173, align 8
  %176 = load i8*, i8** %3, align 8
  %177 = call i64 @mbstrlen(i8* %176)
  %178 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %179 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %178, i32 0, i32 5
  %180 = load i64, i64* %179, align 8
  %181 = add i64 %180, %177
  store i64 %181, i64* %179, align 8
  call void @set_modified()
  call void @update_undo(i32 0)
  %182 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %183 = and i32 %182, 512
  %184 = icmp ne i32 %183, 0
  br i1 %184, label %185, label %186

185:                                              ; preds = %170
  call void @do_wrap()
  br label %186

186:                                              ; preds = %185, %170
  %187 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %188 = and i32 %187, 1073741824
  %189 = icmp ne i32 %188, 0
  br i1 %189, label %190, label %214

190:                                              ; preds = %186
  %191 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %192 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %191, i32 0, i32 4
  %193 = load %struct.linestruct*, %struct.linestruct** %192, align 8
  %194 = call i64 @extra_chunks_in(%struct.linestruct* %193)
  %195 = load i64, i64* %8, align 8
  %196 = icmp ne i64 %194, %195
  br i1 %196, label %213, label %197

197:                                              ; preds = %190
  %198 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %199 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %198, i32 0, i32 9
  %200 = load i64, i64* %199, align 8
  %201 = load i32, i32* @editwinrows, align 4
  %202 = sub nsw i32 %201, 1
  %203 = sext i32 %202 to i64
  %204 = icmp eq i64 %200, %203
  br i1 %204, label %205, label %214

205:                                              ; preds = %197
  %206 = call i64 @xplustabs()
  %207 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %208 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %207, i32 0, i32 4
  %209 = load %struct.linestruct*, %struct.linestruct** %208, align 8
  %210 = call i64 @chunk_for(i64 %206, %struct.linestruct* %209)
  %211 = load i64, i64* %7, align 8
  %212 = icmp ugt i64 %210, %211
  br i1 %212, label %213, label %214

213:                                              ; preds = %205, %190
  store i8 1, i8* @refresh_needed, align 1
  store i8 0, i8* @focusing, align 1
  br label %214

214:                                              ; preds = %213, %205, %197, %186
  %215 = call i64 @xplustabs()
  %216 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %217 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %216, i32 0, i32 8
  store i64 %215, i64* %217, align 8
  %218 = load i8, i8* @refresh_needed, align 1
  %219 = trunc i8 %218 to i1
  br i1 %219, label %224, label %220

220:                                              ; preds = %214
  %221 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %222 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %221, i32 0, i32 4
  %223 = load %struct.linestruct*, %struct.linestruct** %222, align 8
  call void @check_the_multis(%struct.linestruct* %223)
  br label %224

224:                                              ; preds = %220, %214
  %225 = load i8, i8* @refresh_needed, align 1
  %226 = trunc i8 %225 to i1
  br i1 %226, label %235, label %227

227:                                              ; preds = %224
  %228 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %229 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %228, i32 0, i32 4
  %230 = load %struct.linestruct*, %struct.linestruct** %229, align 8
  %231 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %232 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %231, i32 0, i32 7
  %233 = load i64, i64* %232, align 8
  %234 = call i32 @update_line(%struct.linestruct* %230, i64 %233)
  br label %235

235:                                              ; preds = %227, %224
  ret void
}

; Function Attrs: nounwind readonly
declare dso_local i64 @strlen(i8*) #7

declare dso_local i64 @chunk_for(i64, %struct.linestruct*) #1

declare dso_local i64 @extra_chunks_in(%struct.linestruct*) #1

declare dso_local void @add_undo(i32, i8*) #1

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1 immarg) #8

; Function Attrs: nounwind
declare dso_local i8* @strncpy(i8*, i8*, i64) #2

declare dso_local void @new_magicline() #1

declare dso_local i64 @mbstrlen(i8*) #1

declare dso_local void @update_undo(i32) #1

declare dso_local void @do_wrap() #1

declare dso_local void @check_the_multis(%struct.linestruct*) #1

declare dso_local i32 @update_line(%struct.linestruct*, i64) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @process_a_keystroke() #0 {
  %1 = alloca i32, align 4
  %2 = alloca %struct.linestruct*, align 8
  %3 = alloca %struct.keystruct*, align 8
  %4 = alloca %struct.linestruct*, align 8
  %5 = alloca i64, align 8
  %6 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %7 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %6, i32 0, i32 12
  %8 = load %struct.linestruct*, %struct.linestruct** %7, align 8
  store %struct.linestruct* %8, %struct.linestruct** %2, align 8
  %9 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %10 = call i32 @get_kbinput(%struct._win_st* %9, i1 zeroext true)
  store i32 %10, i32* %1, align 4
  store i32 0, i32* @lastmessage, align 4
  %11 = load i32, i32* %1, align 4
  %12 = icmp eq i32 %11, -2
  br i1 %12, label %13, label %14

13:                                               ; preds = %0
  br label %294

14:                                               ; preds = %0
  %15 = load i32, i32* %1, align 4
  %16 = icmp eq i32 %15, 409
  br i1 %16, label %17, label %25

17:                                               ; preds = %14
  %18 = call i32 @do_mouse()
  %19 = icmp eq i32 %18, 1
  br i1 %19, label %20, label %23

20:                                               ; preds = %17
  %21 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %22 = call i32 @get_kbinput(%struct._win_st* %21, i1 zeroext false)
  store i32 %22, i32* %1, align 4
  br label %24

23:                                               ; preds = %17
  br label %294

24:                                               ; preds = %20
  br label %25

25:                                               ; preds = %24, %14
  %26 = call %struct.keystruct* @get_shortcut(i32* %1)
  store %struct.keystruct* %26, %struct.keystruct** %3, align 8
  %27 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %28 = icmp eq %struct.keystruct* %27, null
  br i1 %28, label %29, label %71

29:                                               ; preds = %25
  %30 = load i32, i32* %1, align 4
  %31 = icmp slt i32 %30, 32
  br i1 %31, label %38, label %32

32:                                               ; preds = %29
  %33 = load i32, i32* %1, align 4
  %34 = icmp sgt i32 %33, 255
  br i1 %34, label %38, label %35

35:                                               ; preds = %32
  %36 = load i8, i8* @meta_key, align 1
  %37 = trunc i8 %36 to i1
  br i1 %37, label %38, label %40

38:                                               ; preds = %35, %32, %29
  %39 = load i32, i32* %1, align 4
  call void @unbound_key(i32 %39)
  br label %70

40:                                               ; preds = %35
  %41 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %42 = and i32 %41, 128
  %43 = icmp ne i32 %42, 0
  br i1 %43, label %44, label %45

44:                                               ; preds = %40
  call void @print_view_warning()
  br label %69

45:                                               ; preds = %40
  %46 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %47 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %46, i32 0, i32 12
  %48 = load %struct.linestruct*, %struct.linestruct** %47, align 8
  %49 = icmp ne %struct.linestruct* %48, null
  br i1 %49, label %50, label %58

50:                                               ; preds = %45
  %51 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %52 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %51, i32 0, i32 14
  %53 = load i8, i8* %52, align 8
  %54 = trunc i8 %53 to i1
  br i1 %54, label %55, label %58

55:                                               ; preds = %50
  %56 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %57 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %56, i32 0, i32 12
  store %struct.linestruct* null, %struct.linestruct** %57, align 8
  store i8 1, i8* @refresh_needed, align 1
  br label %58

58:                                               ; preds = %55, %50, %45
  %59 = load i8*, i8** @process_a_keystroke.puddle, align 8
  %60 = load i64, i64* @process_a_keystroke.depth, align 8
  %61 = add i64 %60, 2
  %62 = call i8* @nrealloc(i8* %59, i64 %61)
  store i8* %62, i8** @process_a_keystroke.puddle, align 8
  %63 = load i32, i32* %1, align 4
  %64 = trunc i32 %63 to i8
  %65 = load i8*, i8** @process_a_keystroke.puddle, align 8
  %66 = load i64, i64* @process_a_keystroke.depth, align 8
  %67 = add i64 %66, 1
  store i64 %67, i64* @process_a_keystroke.depth, align 8
  %68 = getelementptr inbounds i8, i8* %65, i64 %66
  store i8 %64, i8* %68, align 1
  br label %69

69:                                               ; preds = %58, %44
  br label %70

70:                                               ; preds = %69, %38
  br label %71

71:                                               ; preds = %70, %25
  %72 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %73 = icmp ne %struct.keystruct* %72, null
  br i1 %73, label %77, label %74

74:                                               ; preds = %71
  %75 = call i64 @waiting_keycodes()
  %76 = icmp eq i64 %75, 0
  br i1 %76, label %77, label %87

77:                                               ; preds = %74, %71
  %78 = load i8*, i8** @process_a_keystroke.puddle, align 8
  %79 = icmp ne i8* %78, null
  br i1 %79, label %80, label %87

80:                                               ; preds = %77
  %81 = load i8*, i8** @process_a_keystroke.puddle, align 8
  %82 = load i64, i64* @process_a_keystroke.depth, align 8
  %83 = getelementptr inbounds i8, i8* %81, i64 %82
  store i8 0, i8* %83, align 1
  %84 = load i8*, i8** @process_a_keystroke.puddle, align 8
  %85 = load i64, i64* @process_a_keystroke.depth, align 8
  call void @inject(i8* %84, i64 %85)
  %86 = load i8*, i8** @process_a_keystroke.puddle, align 8
  call void @rpl_free(i8* %86)
  store i8* null, i8** @process_a_keystroke.puddle, align 8
  store i64 0, i64* @process_a_keystroke.depth, align 8
  br label %87

87:                                               ; preds = %80, %77, %74
  %88 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %89 = icmp eq %struct.keystruct* %88, null
  br i1 %89, label %90, label %91

90:                                               ; preds = %87
  store %struct.linestruct* null, %struct.linestruct** @pletion_line, align 8
  store i8 0, i8* @keep_cutbuffer, align 1
  br label %294

91:                                               ; preds = %87
  %92 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %93 = and i32 %92, 128
  %94 = icmp ne i32 %93, 0
  br i1 %94, label %95, label %99

95:                                               ; preds = %91
  %96 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %97 = call zeroext i1 @okay_for_view(%struct.keystruct* %96)
  br i1 %97, label %99, label %98

98:                                               ; preds = %95
  call void @print_view_warning()
  br label %294

99:                                               ; preds = %95, %91
  %100 = load i32, i32* %1, align 4
  %101 = icmp eq i32 %100, 8
  br i1 %101, label %102, label %124

102:                                              ; preds = %99
  %103 = load i8, i8* @process_a_keystroke.give_a_hint, align 1
  %104 = trunc i8 %103 to i1
  br i1 %104, label %105, label %124

105:                                              ; preds = %102
  %106 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %107 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %106, i32 0, i32 7
  %108 = load i64, i64* %107, align 8
  %109 = icmp eq i64 %108, 0
  br i1 %109, label %110, label %124

110:                                              ; preds = %105
  %111 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %112 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %111, i32 0, i32 4
  %113 = load %struct.linestruct*, %struct.linestruct** %112, align 8
  %114 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %115 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %114, i32 0, i32 1
  %116 = load %struct.linestruct*, %struct.linestruct** %115, align 8
  %117 = icmp eq %struct.linestruct* %113, %116
  br i1 %117, label %118, label %124

118:                                              ; preds = %110
  %119 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %120 = and i32 %119, 8
  %121 = icmp ne i32 %120, 0
  br i1 %121, label %124, label %122

122:                                              ; preds = %118
  %123 = call i8* @gettext(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.221, i64 0, i64 0)) #9
  call void @statusbar(i8* %123)
  store i8 0, i8* @process_a_keystroke.give_a_hint, align 1
  br label %129

124:                                              ; preds = %118, %110, %105, %102, %99
  %125 = load i8, i8* @meta_key, align 1
  %126 = trunc i8 %125 to i1
  br i1 %126, label %127, label %128

127:                                              ; preds = %124
  store i8 0, i8* @process_a_keystroke.give_a_hint, align 1
  br label %128

128:                                              ; preds = %127, %124
  br label %129

129:                                              ; preds = %128, %122
  %130 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %131 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %130, i32 0, i32 3
  %132 = load void ()*, void ()** %131, align 8
  %133 = icmp ne void ()* %132, @cut_text
  br i1 %133, label %134, label %146

134:                                              ; preds = %129
  %135 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %136 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %135, i32 0, i32 3
  %137 = load void ()*, void ()** %136, align 8
  %138 = icmp ne void ()* %137, @copy_text
  br i1 %138, label %139, label %145

139:                                              ; preds = %134
  %140 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %141 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %140, i32 0, i32 3
  %142 = load void ()*, void ()** %141, align 8
  %143 = icmp ne void ()* %142, @zap_text
  br i1 %143, label %144, label %145

144:                                              ; preds = %139
  store i8 0, i8* @keep_cutbuffer, align 1
  br label %145

145:                                              ; preds = %144, %139, %134
  br label %146

146:                                              ; preds = %145, %129
  %147 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %148 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %147, i32 0, i32 3
  %149 = load void ()*, void ()** %148, align 8
  %150 = icmp ne void ()* %149, @complete_a_word
  br i1 %150, label %151, label %152

151:                                              ; preds = %146
  store %struct.linestruct* null, %struct.linestruct** @pletion_line, align 8
  br label %152

152:                                              ; preds = %151, %146
  %153 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %154 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %153, i32 0, i32 3
  %155 = load void ()*, void ()** %154, align 8
  %156 = icmp eq void ()* %155, bitcast (void (i8*)* @implant to void ()*)
  br i1 %156, label %157, label %161

157:                                              ; preds = %152
  %158 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %159 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %158, i32 0, i32 6
  %160 = load i8*, i8** %159, align 8
  call void @implant(i8* %160)
  br label %294

161:                                              ; preds = %152
  %162 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %163 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %162, i32 0, i32 3
  %164 = load void ()*, void ()** %163, align 8
  %165 = icmp eq void ()* %164, @do_toggle
  br i1 %165, label %166, label %176

166:                                              ; preds = %161
  %167 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %168 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %167, i32 0, i32 4
  %169 = load i32, i32* %168, align 8
  call void @toggle_this(i32 %169)
  %170 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %171 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %170, i32 0, i32 4
  %172 = load i32, i32* %171, align 8
  %173 = icmp eq i32 %172, 11
  br i1 %173, label %174, label %175

174:                                              ; preds = %166
  store i8 0, i8* @keep_cutbuffer, align 1
  br label %175

175:                                              ; preds = %174, %166
  br label %294

176:                                              ; preds = %161
  %177 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %178 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %177, i32 0, i32 4
  %179 = load %struct.linestruct*, %struct.linestruct** %178, align 8
  store %struct.linestruct* %179, %struct.linestruct** %4, align 8
  %180 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %181 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %180, i32 0, i32 7
  %182 = load i64, i64* %181, align 8
  store i64 %182, i64* %5, align 8
  %183 = load i8, i8* @shift_held, align 1
  %184 = trunc i8 %183 to i1
  br i1 %184, label %185, label %203

185:                                              ; preds = %176
  %186 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %187 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %186, i32 0, i32 12
  %188 = load %struct.linestruct*, %struct.linestruct** %187, align 8
  %189 = icmp ne %struct.linestruct* %188, null
  br i1 %189, label %203, label %190

190:                                              ; preds = %185
  %191 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %192 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %191, i32 0, i32 4
  %193 = load %struct.linestruct*, %struct.linestruct** %192, align 8
  %194 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %195 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %194, i32 0, i32 12
  store %struct.linestruct* %193, %struct.linestruct** %195, align 8
  %196 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %197 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %196, i32 0, i32 7
  %198 = load i64, i64* %197, align 8
  %199 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %200 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %199, i32 0, i32 13
  store i64 %198, i64* %200, align 8
  %201 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %202 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %201, i32 0, i32 14
  store i8 1, i8* %202, align 8
  br label %203

203:                                              ; preds = %190, %185, %176
  %204 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %205 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %204, i32 0, i32 3
  %206 = load void ()*, void ()** %205, align 8
  call void %206()
  %207 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %208 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %207, i32 0, i32 12
  %209 = load %struct.linestruct*, %struct.linestruct** %208, align 8
  %210 = icmp ne %struct.linestruct* %209, null
  br i1 %210, label %211, label %248

211:                                              ; preds = %203
  %212 = load i8, i8* @shift_held, align 1
  %213 = trunc i8 %212 to i1
  br i1 %213, label %239, label %214

214:                                              ; preds = %211
  %215 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %216 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %215, i32 0, i32 14
  %217 = load i8, i8* %216, align 8
  %218 = trunc i8 %217 to i1
  br i1 %218, label %219, label %239

219:                                              ; preds = %214
  %220 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %221 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %220, i32 0, i32 4
  %222 = load %struct.linestruct*, %struct.linestruct** %221, align 8
  %223 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %224 = icmp ne %struct.linestruct* %222, %223
  br i1 %224, label %236, label %225

225:                                              ; preds = %219
  %226 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %227 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %226, i32 0, i32 7
  %228 = load i64, i64* %227, align 8
  %229 = load i64, i64* %5, align 8
  %230 = icmp ne i64 %228, %229
  br i1 %230, label %236, label %231

231:                                              ; preds = %225
  %232 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %233 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %232, i32 0, i32 3
  %234 = load void ()*, void ()** %233, align 8
  %235 = call zeroext i1 @wanted_to_move(void ()* %234)
  br i1 %235, label %236, label %239

236:                                              ; preds = %231, %225, %219
  %237 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %238 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %237, i32 0, i32 12
  store %struct.linestruct* null, %struct.linestruct** %238, align 8
  store i8 1, i8* @refresh_needed, align 1
  br label %247

239:                                              ; preds = %231, %214, %211
  %240 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %241 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %240, i32 0, i32 4
  %242 = load %struct.linestruct*, %struct.linestruct** %241, align 8
  %243 = load %struct.linestruct*, %struct.linestruct** %4, align 8
  %244 = icmp ne %struct.linestruct* %242, %243
  br i1 %244, label %245, label %246

245:                                              ; preds = %239
  store i8 0, i8* @also_the_last, align 1
  br label %246

246:                                              ; preds = %245, %239
  br label %247

247:                                              ; preds = %246, %236
  br label %248

248:                                              ; preds = %247, %203
  %249 = load i8, i8* @refresh_needed, align 1
  %250 = trunc i8 %249 to i1
  br i1 %250, label %258, label %251

251:                                              ; preds = %248
  %252 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %253 = call zeroext i1 @okay_for_view(%struct.keystruct* %252)
  br i1 %253, label %258, label %254

254:                                              ; preds = %251
  %255 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %256 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %255, i32 0, i32 4
  %257 = load %struct.linestruct*, %struct.linestruct** %256, align 8
  call void @check_the_multis(%struct.linestruct* %257)
  br label %258

258:                                              ; preds = %254, %251, %248
  %259 = load i8, i8* @refresh_needed, align 1
  %260 = trunc i8 %259 to i1
  br i1 %260, label %279, label %261

261:                                              ; preds = %258
  %262 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %263 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %262, i32 0, i32 3
  %264 = load void ()*, void ()** %263, align 8
  %265 = icmp eq void ()* %264, @do_delete
  br i1 %265, label %271, label %266

266:                                              ; preds = %261
  %267 = load %struct.keystruct*, %struct.keystruct** %3, align 8
  %268 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %267, i32 0, i32 3
  %269 = load void ()*, void ()** %268, align 8
  %270 = icmp eq void ()* %269, @do_backspace
  br i1 %270, label %271, label %279

271:                                              ; preds = %266, %261
  %272 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %273 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %272, i32 0, i32 4
  %274 = load %struct.linestruct*, %struct.linestruct** %273, align 8
  %275 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %276 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %275, i32 0, i32 7
  %277 = load i64, i64* %276, align 8
  %278 = call i32 @update_line(%struct.linestruct* %274, i64 %277)
  br label %279

279:                                              ; preds = %271, %266, %258
  %280 = load i8, i8* @bracketed_paste, align 1
  %281 = trunc i8 %280 to i1
  br i1 %281, label %282, label %283

282:                                              ; preds = %279
  call void @suck_up_input_and_paste_it()
  br label %283

283:                                              ; preds = %282, %279
  %284 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %285 = and i32 %284, 16384
  %286 = icmp ne i32 %285, 0
  br i1 %286, label %287, label %294

287:                                              ; preds = %283
  %288 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %289 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %288, i32 0, i32 12
  %290 = load %struct.linestruct*, %struct.linestruct** %289, align 8
  %291 = load %struct.linestruct*, %struct.linestruct** %2, align 8
  %292 = icmp ne %struct.linestruct* %290, %291
  br i1 %292, label %293, label %294

293:                                              ; preds = %287
  call void @titlebar(i8* null)
  br label %294

294:                                              ; preds = %293, %287, %283, %175, %157, %98, %90, %23, %13
  ret void
}

declare dso_local %struct.keystruct* @get_shortcut(i32*) #1

declare dso_local i64 @waiting_keycodes() #1

declare dso_local void @cut_text() #1

declare dso_local void @copy_text() #1

declare dso_local void @zap_text() #1

declare dso_local void @complete_a_word() #1

declare dso_local void @implant(i8*) #1

declare dso_local void @do_toggle() #1

declare dso_local void @do_delete() #1

declare dso_local void @do_backspace() #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i8, align 1
  %9 = alloca i8, align 1
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca [57 x %struct.option], align 16
  %13 = alloca %struct.vt_stat, align 2
  %14 = alloca i64, align 8
  %15 = alloca i8*, align 8
  %16 = alloca i8*, align 8
  %17 = alloca i64, align 8
  %18 = alloca i64, align 8
  %19 = alloca i8*, align 8
  %20 = alloca i8*, align 8
  %21 = alloca i8*, align 8
  %22 = alloca [4 x i32], align 16
  %23 = alloca i64, align 8
  %24 = alloca i64, align 8
  %25 = alloca i8*, align 8
  %26 = alloca i8*, align 8
  %27 = alloca i64, align 8
  %28 = alloca i64, align 8
  %29 = alloca i8*, align 8
  %30 = alloca i32, align 4
  %31 = alloca i64, align 8
  %32 = alloca i64, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  store i8 0, i8* %8, align 1
  store i8 0, i8* %9, align 1
  store i32 -2, i32* %10, align 4
  %33 = bitcast [57 x %struct.option]* %12 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %33, i8* align 16 bitcast ([57 x %struct.option]* @__const.main.long_options to i8*), i64 1824, i1 false)
  %34 = call i32 (i32, i64, ...) @ioctl(i32 1, i64 22019, %struct.vt_stat* %13) #9
  %35 = icmp eq i32 %34, 0
  %36 = zext i1 %35 to i8
  store i8 %36, i8* @on_a_vt, align 1
  %37 = call i32 @tcgetattr(i32 0, %struct.termios* @original_state) #9
  %38 = call i32 (i32, i32, ...) @rpl_fcntl(i32 0, i32 3, i32 0)
  store i32 %38, i32* %6, align 4
  %39 = load i32, i32* %6, align 4
  %40 = icmp ne i32 %39, -1
  br i1 %40, label %41, label %45

41:                                               ; preds = %2
  %42 = load i32, i32* %6, align 4
  %43 = and i32 %42, -2049
  %44 = call i32 (i32, i32, ...) @rpl_fcntl(i32 0, i32 4, i32 %43)
  br label %45

45:                                               ; preds = %41, %2
  %46 = call i8* @setlocale(i32 6, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.220, i64 0, i64 0)) #9
  %47 = icmp ne i8* %46, null
  br i1 %47, label %48, label %53

48:                                               ; preds = %45
  %49 = call i8* @nl_langinfo(i32 14) #9
  %50 = call i32 @strcmp(i8* %49, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.278, i64 0, i64 0)) #12
  %51 = icmp eq i32 %50, 0
  br i1 %51, label %52, label %53

52:                                               ; preds = %48
  call void @utf8_init()
  br label %53

53:                                               ; preds = %52, %48, %45
  %54 = call i8* @bindtextdomain(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.279, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.280, i64 0, i64 0)) #9
  %55 = call i8* @textdomain(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.279, i64 0, i64 0)) #9
  %56 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %57 = or i32 %56, 32
  store i32 %57, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %58 = load i8**, i8*** %5, align 8
  %59 = getelementptr inbounds i8*, i8** %58, i64 0
  %60 = load i8*, i8** %59, align 8
  %61 = call i8* @tail(i8* %60)
  %62 = load i8, i8* %61, align 1
  %63 = sext i8 %62 to i32
  %64 = icmp eq i32 %63, 114
  br i1 %64, label %65, label %68

65:                                               ; preds = %53
  %66 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %67 = or i32 %66, 4194304
  store i32 %67, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %68

68:                                               ; preds = %65, %53
  br label %69

69:                                               ; preds = %273, %68
  %70 = load i32, i32* %4, align 4
  %71 = load i8**, i8*** %5, align 8
  %72 = getelementptr inbounds [57 x %struct.option], [57 x %struct.option]* %12, i64 0, i64 0
  %73 = call i32 @getopt_long(i32 %70, i8** %71, i8* getelementptr inbounds ([68 x i8], [68 x i8]* @.str.281, i64 0, i64 0), %struct.option* %72, i32* null) #9
  store i32 %73, i32* %7, align 4
  %74 = icmp ne i32 %73, -1
  br i1 %74, label %75, label %274

75:                                               ; preds = %69
  %76 = load i32, i32* %7, align 4
  switch i32 %76, label %267 [
    i32 65, label %77
    i32 66, label %80
    i32 67, label %83
    i32 68, label %87
    i32 69, label %90
    i32 70, label %93
    i32 71, label %96
    i32 72, label %99
    i32 73, label %102
    i32 74, label %103
    i32 75, label %117
    i32 76, label %120
    i32 77, label %123
    i32 78, label %126
    i32 79, label %129
    i32 80, label %132
    i32 81, label %135
    i32 82, label %139
    i32 83, label %142
    i32 36, label %142
    i32 84, label %145
    i32 85, label %159
    i32 86, label %162
    i32 87, label %163
    i32 88, label %166
    i32 89, label %170
    i32 90, label %174
    i32 97, label %177
    i32 98, label %180
    i32 99, label %181
    i32 100, label %184
    i32 101, label %187
    i32 102, label %190
    i32 103, label %194
    i32 104, label %197
    i32 105, label %198
    i32 106, label %201
    i32 107, label %204
    i32 108, label %207
    i32 109, label %210
    i32 110, label %213
    i32 111, label %216
    i32 112, label %220
    i32 113, label %223
    i32 114, label %226
    i32 115, label %237
    i32 116, label %241
    i32 117, label %244
    i32 118, label %247
    i32 119, label %250
    i32 120, label %251
    i32 121, label %254
    i32 122, label %257
    i32 37, label %258
    i32 95, label %261
    i32 48, label %264
  ]

77:                                               ; preds = %75
  %78 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %79 = or i32 %78, 8388608
  store i32 %79, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

80:                                               ; preds = %75
  %81 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %82 = or i32 %81, 131072
  store i32 %82, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

83:                                               ; preds = %75
  %84 = load i8*, i8** @backup_dir, align 8
  %85 = load i8*, i8** @optarg, align 8
  %86 = call i8* @mallocstrcpy(i8* %84, i8* %85)
  store i8* %86, i8** @backup_dir, align 8
  br label %273

87:                                               ; preds = %75
  %88 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %89 = or i32 %88, 536870912
  store i32 %89, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

90:                                               ; preds = %75
  %91 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %92 = or i32 %91, 33554432
  store i32 %92, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

93:                                               ; preds = %75
  %94 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %95 = or i32 %94, 8192
  store i32 %95, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

96:                                               ; preds = %75
  %97 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %98 = or i32 %97, 1
  store i32 %98, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

99:                                               ; preds = %75
  %100 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %101 = or i32 %100, 2097152
  store i32 %101, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

102:                                              ; preds = %75
  store i8 1, i8* %8, align 1
  br label %273

103:                                              ; preds = %75
  %104 = load i8*, i8** @optarg, align 8
  %105 = call zeroext i1 @parse_num(i8* %104, i64* @stripe_column)
  br i1 %105, label %106, label %109

106:                                              ; preds = %103
  %107 = load i64, i64* @stripe_column, align 8
  %108 = icmp sle i64 %107, 0
  br i1 %108, label %109, label %116

109:                                              ; preds = %106, %103
  %110 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %111 = call i8* @gettext(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.282, i64 0, i64 0)) #9
  %112 = load i8*, i8** @optarg, align 8
  %113 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %110, i8* %111, i8* %112)
  %114 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %115 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %114, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.191, i64 0, i64 0))
  call void @exit(i32 1) #10
  unreachable

116:                                              ; preds = %106
  br label %273

117:                                              ; preds = %75
  %118 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %119 = or i32 %118, 32768
  store i32 %119, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

120:                                              ; preds = %75
  %121 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %122 = or i32 %121, 268435456
  store i32 %122, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

123:                                              ; preds = %75
  %124 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %125 = or i32 %124, 8
  store i32 %125, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

126:                                              ; preds = %75
  %127 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %128 = or i32 %127, 65536
  store i32 %128, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

129:                                              ; preds = %75
  %130 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %131 = or i32 %130, 8192
  store i32 %131, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

132:                                              ; preds = %75
  %133 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %134 = or i32 %133, -2147483648
  store i32 %134, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

135:                                              ; preds = %75
  %136 = load i8*, i8** @quotestr, align 8
  %137 = load i8*, i8** @optarg, align 8
  %138 = call i8* @mallocstrcpy(i8* %136, i8* %137)
  store i8* %138, i8** @quotestr, align 8
  br label %273

139:                                              ; preds = %75
  %140 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %141 = or i32 %140, 4194304
  store i32 %141, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

142:                                              ; preds = %75, %75
  %143 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %144 = or i32 %143, 1073741824
  store i32 %144, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

145:                                              ; preds = %75
  %146 = load i8*, i8** @optarg, align 8
  %147 = call zeroext i1 @parse_num(i8* %146, i64* @tabsize)
  br i1 %147, label %148, label %151

148:                                              ; preds = %145
  %149 = load i64, i64* @tabsize, align 8
  %150 = icmp sle i64 %149, 0
  br i1 %150, label %151, label %158

151:                                              ; preds = %148, %145
  %152 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %153 = call i8* @gettext(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.283, i64 0, i64 0)) #9
  %154 = load i8*, i8** @optarg, align 8
  %155 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %152, i8* %153, i8* %154)
  %156 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %157 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %156, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.191, i64 0, i64 0))
  call void @exit(i32 1) #10
  unreachable

158:                                              ; preds = %148
  br label %273

159:                                              ; preds = %75
  %160 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %161 = or i32 %160, 67108864
  store i32 %161, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

162:                                              ; preds = %75
  call void @version()
  call void @exit(i32 0) #10
  unreachable

163:                                              ; preds = %75
  %164 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %165 = or i32 %164, 134217728
  store i32 %165, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

166:                                              ; preds = %75
  %167 = load i8*, i8** @word_chars, align 8
  %168 = load i8*, i8** @optarg, align 8
  %169 = call i8* @mallocstrcpy(i8* %167, i8* %168)
  store i8* %169, i8** @word_chars, align 8
  br label %273

170:                                              ; preds = %75
  %171 = load i8*, i8** @syntaxstr, align 8
  %172 = load i8*, i8** @optarg, align 8
  %173 = call i8* @mallocstrcpy(i8* %171, i8* %172)
  store i8* %173, i8** @syntaxstr, align 8
  br label %273

174:                                              ; preds = %75
  %175 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %176 = or i32 %175, 256
  store i32 %176, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

177:                                              ; preds = %75
  %178 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %179 = or i32 %178, 64
  store i32 %179, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

180:                                              ; preds = %75
  store i32 1, i32* %10, align 4
  br label %273

181:                                              ; preds = %75
  %182 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %183 = or i32 %182, 4
  store i32 %183, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

184:                                              ; preds = %75
  %185 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %186 = or i32 %185, 16384
  store i32 %186, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

187:                                              ; preds = %75
  %188 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %189 = or i32 %188, 2048
  store i32 %189, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

190:                                              ; preds = %75
  %191 = load i8*, i8** @custom_nanorc, align 8
  %192 = load i8*, i8** @optarg, align 8
  %193 = call i8* @mallocstrcpy(i8* %191, i8* %192)
  store i8* %193, i8** @custom_nanorc, align 8
  br label %273

194:                                              ; preds = %75
  %195 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %196 = or i32 %195, 16
  store i32 %196, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

197:                                              ; preds = %75
  call void @usage()
  call void @exit(i32 0) #10
  unreachable

198:                                              ; preds = %75
  %199 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %200 = or i32 %199, 64
  store i32 %200, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

201:                                              ; preds = %75
  %202 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %203 = or i32 %202, 1024
  store i32 %203, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

204:                                              ; preds = %75
  %205 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %206 = or i32 %205, 2048
  store i32 %206, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

207:                                              ; preds = %75
  %208 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %209 = or i32 %208, 32
  store i32 %209, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

210:                                              ; preds = %75
  %211 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %212 = or i32 %211, 256
  store i32 %212, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

213:                                              ; preds = %75
  %214 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %215 = or i32 %214, 2
  store i32 %215, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

216:                                              ; preds = %75
  %217 = load i8*, i8** @operating_dir, align 8
  %218 = load i8*, i8** @optarg, align 8
  %219 = call i8* @mallocstrcpy(i8* %217, i8* %218)
  store i8* %219, i8** @operating_dir, align 8
  br label %273

220:                                              ; preds = %75
  %221 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %222 = or i32 %221, 1048576
  store i32 %222, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

223:                                              ; preds = %75
  %224 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %225 = or i32 %224, 4096
  store i32 %225, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

226:                                              ; preds = %75
  %227 = load i8*, i8** @optarg, align 8
  %228 = call zeroext i1 @parse_num(i8* %227, i64* @fill)
  br i1 %228, label %236, label %229

229:                                              ; preds = %226
  %230 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %231 = call i8* @gettext(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.284, i64 0, i64 0)) #9
  %232 = load i8*, i8** @optarg, align 8
  %233 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %230, i8* %231, i8* %232)
  %234 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %235 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %234, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.191, i64 0, i64 0))
  call void @exit(i32 1) #10
  unreachable

236:                                              ; preds = %226
  store i8 1, i8* %9, align 1
  br label %273

237:                                              ; preds = %75
  %238 = load i8*, i8** @alt_speller, align 8
  %239 = load i8*, i8** @optarg, align 8
  %240 = call i8* @mallocstrcpy(i8* %238, i8* %239)
  store i8* %240, i8** @alt_speller, align 8
  br label %273

241:                                              ; preds = %75
  %242 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %243 = or i32 %242, 1024
  store i32 %243, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

244:                                              ; preds = %75
  %245 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %246 = or i32 %245, 4
  store i32 %246, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

247:                                              ; preds = %75
  %248 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %249 = or i32 %248, 128
  store i32 %249, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

250:                                              ; preds = %75
  store i32 0, i32* %10, align 4
  br label %273

251:                                              ; preds = %75
  %252 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %253 = or i32 %252, 8
  store i32 %253, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %273

254:                                              ; preds = %75
  %255 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %256 = or i32 %255, 128
  store i32 %256, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

257:                                              ; preds = %75
  br label %273

258:                                              ; preds = %75
  %259 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %260 = or i32 %259, 16384
  store i32 %260, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

261:                                              ; preds = %75
  %262 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %263 = or i32 %262, 65536
  store i32 %263, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

264:                                              ; preds = %75
  %265 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %266 = or i32 %265, 131072
  store i32 %266, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %273

267:                                              ; preds = %75
  %268 = call i8* @gettext(i8* getelementptr inbounds ([47 x i8], [47 x i8]* @.str.285, i64 0, i64 0)) #9
  %269 = load i8**, i8*** %5, align 8
  %270 = getelementptr inbounds i8*, i8** %269, i64 0
  %271 = load i8*, i8** %270, align 8
  %272 = call i32 (i8*, ...) @printf(i8* %268, i8* %271)
  call void @exit(i32 1) #10
  unreachable

273:                                              ; preds = %264, %261, %258, %257, %254, %251, %250, %247, %244, %241, %237, %236, %223, %220, %216, %213, %210, %207, %204, %201, %198, %194, %190, %187, %184, %181, %180, %177, %174, %170, %166, %163, %159, %158, %142, %139, %135, %132, %129, %126, %123, %120, %117, %116, %102, %99, %96, %93, %90, %87, %83, %80, %77
  br label %69

274:                                              ; preds = %69
  %275 = call i8* @getenv(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.286, i64 0, i64 0)) #9
  %276 = icmp eq i8* %275, null
  br i1 %276, label %277, label %279

277:                                              ; preds = %274
  %278 = call i32 @putenv(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.287, i64 0, i64 0)) #9
  br label %279

279:                                              ; preds = %277, %274
  %280 = call %struct._win_st* @initscr()
  %281 = icmp eq %struct._win_st* %280, null
  br i1 %281, label %282, label %283

282:                                              ; preds = %279
  call void @exit(i32 1) #10
  unreachable

283:                                              ; preds = %279
  %284 = call zeroext i1 @has_colors()
  br i1 %284, label %285, label %287

285:                                              ; preds = %283
  %286 = call i32 @start_color()
  br label %287

287:                                              ; preds = %285, %283
  %288 = call i8* @getenv(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.288, i64 0, i64 0)) #9
  %289 = icmp ne i8* %288, null
  %290 = zext i1 %289 to i8
  store i8 %290, i8* @rescind_colors, align 1
  call void @shortcut_init()
  %291 = load i8, i8* %8, align 1
  %292 = trunc i8 %291 to i1
  br i1 %292, label %404, label %293

293:                                              ; preds = %287
  %294 = load i64, i64* @fill, align 8
  store i64 %294, i64* %14, align 8
  %295 = load i8*, i8** @backup_dir, align 8
  store i8* %295, i8** %15, align 8
  %296 = load i8*, i8** @word_chars, align 8
  store i8* %296, i8** %16, align 8
  %297 = load i64, i64* @stripe_column, align 8
  store i64 %297, i64* %17, align 8
  %298 = load i64, i64* @tabsize, align 8
  store i64 %298, i64* %18, align 8
  %299 = load i8*, i8** @operating_dir, align 8
  store i8* %299, i8** %19, align 8
  %300 = load i8*, i8** @quotestr, align 8
  store i8* %300, i8** %20, align 8
  %301 = load i8*, i8** @alt_speller, align 8
  store i8* %301, i8** %21, align 8
  %302 = getelementptr inbounds [4 x i32], [4 x i32]* %22, i64 0, i64 0
  %303 = bitcast i32* %302 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %303, i8* align 16 bitcast ([4 x i32]* @flags to i8*), i64 16, i1 false)
  store i8* null, i8** @backup_dir, align 8
  store i8* null, i8** @word_chars, align 8
  store i8* null, i8** @operating_dir, align 8
  store i8* null, i8** @quotestr, align 8
  store i8* null, i8** @alt_speller, align 8
  call void @do_rcfiles()
  %304 = load i8, i8* %9, align 1
  %305 = trunc i8 %304 to i1
  br i1 %305, label %306, label %308

306:                                              ; preds = %293
  %307 = load i64, i64* %14, align 8
  store i64 %307, i64* @fill, align 8
  br label %308

308:                                              ; preds = %306, %293
  %309 = load i8*, i8** %15, align 8
  %310 = icmp ne i8* %309, null
  br i1 %310, label %311, label %314

311:                                              ; preds = %308
  %312 = load i8*, i8** @backup_dir, align 8
  call void @rpl_free(i8* %312)
  %313 = load i8*, i8** %15, align 8
  store i8* %313, i8** @backup_dir, align 8
  br label %314

314:                                              ; preds = %311, %308
  %315 = load i8*, i8** %16, align 8
  %316 = icmp ne i8* %315, null
  br i1 %316, label %317, label %320

317:                                              ; preds = %314
  %318 = load i8*, i8** @word_chars, align 8
  call void @rpl_free(i8* %318)
  %319 = load i8*, i8** %16, align 8
  store i8* %319, i8** @word_chars, align 8
  br label %320

320:                                              ; preds = %317, %314
  %321 = load i64, i64* %17, align 8
  %322 = icmp ugt i64 %321, 0
  br i1 %322, label %323, label %325

323:                                              ; preds = %320
  %324 = load i64, i64* %17, align 8
  store i64 %324, i64* @stripe_column, align 8
  br label %325

325:                                              ; preds = %323, %320
  %326 = load i64, i64* %18, align 8
  %327 = icmp ne i64 %326, -1
  br i1 %327, label %328, label %330

328:                                              ; preds = %325
  %329 = load i64, i64* %18, align 8
  store i64 %329, i64* @tabsize, align 8
  br label %330

330:                                              ; preds = %328, %325
  %331 = load i8*, i8** %19, align 8
  %332 = icmp ne i8* %331, null
  br i1 %332, label %337, label %333

333:                                              ; preds = %330
  %334 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %335 = and i32 %334, 4194304
  %336 = icmp ne i32 %335, 0
  br i1 %336, label %337, label %340

337:                                              ; preds = %333, %330
  %338 = load i8*, i8** @operating_dir, align 8
  call void @rpl_free(i8* %338)
  %339 = load i8*, i8** %19, align 8
  store i8* %339, i8** @operating_dir, align 8
  br label %340

340:                                              ; preds = %337, %333
  %341 = load i8*, i8** %20, align 8
  %342 = icmp ne i8* %341, null
  br i1 %342, label %343, label %346

343:                                              ; preds = %340
  %344 = load i8*, i8** @quotestr, align 8
  call void @rpl_free(i8* %344)
  %345 = load i8*, i8** %20, align 8
  store i8* %345, i8** @quotestr, align 8
  br label %346

346:                                              ; preds = %343, %340
  %347 = load i8*, i8** %21, align 8
  %348 = icmp ne i8* %347, null
  br i1 %348, label %349, label %352

349:                                              ; preds = %346
  %350 = load i8*, i8** @alt_speller, align 8
  call void @rpl_free(i8* %350)
  %351 = load i8*, i8** %21, align 8
  store i8* %351, i8** @alt_speller, align 8
  br label %352

352:                                              ; preds = %349, %346
  br label %353

353:                                              ; preds = %375, %352
  %354 = load i8*, i8** @alt_speller, align 8
  %355 = icmp ne i8* %354, null
  br i1 %355, label %356, label %373

356:                                              ; preds = %353
  %357 = load i8*, i8** @alt_speller, align 8
  %358 = load i8, i8* %357, align 1
  %359 = sext i8 %358 to i32
  %360 = icmp ne i32 %359, 0
  br i1 %360, label %361, label %373

361:                                              ; preds = %356
  %362 = call i16** @__ctype_b_loc() #11
  %363 = load i16*, i16** %362, align 8
  %364 = load i8*, i8** @alt_speller, align 8
  %365 = load i8, i8* %364, align 1
  %366 = sext i8 %365 to i32
  %367 = sext i32 %366 to i64
  %368 = getelementptr inbounds i16, i16* %363, i64 %367
  %369 = load i16, i16* %368, align 2
  %370 = zext i16 %369 to i32
  %371 = and i32 %370, 1
  %372 = icmp ne i32 %371, 0
  br label %373

373:                                              ; preds = %361, %356, %353
  %374 = phi i1 [ false, %356 ], [ false, %353 ], [ %372, %361 ]
  br i1 %374, label %375, label %381

375:                                              ; preds = %373
  %376 = load i8*, i8** @alt_speller, align 8
  %377 = load i8*, i8** @alt_speller, align 8
  %378 = getelementptr inbounds i8, i8* %377, i64 1
  %379 = load i8*, i8** @alt_speller, align 8
  %380 = call i64 @strlen(i8* %379) #12
  call void @llvm.memmove.p0i8.p0i8.i64(i8* align 1 %376, i8* align 1 %378, i64 %380, i1 false)
  br label %353

381:                                              ; preds = %373
  %382 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %383 = and i32 %382, 32
  %384 = icmp ne i32 %383, 0
  br i1 %384, label %388, label %385

385:                                              ; preds = %381
  %386 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %387 = or i32 %386, 512
  store i32 %387, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %388

388:                                              ; preds = %385, %381
  store i64 0, i64* %23, align 8
  br label %389

389:                                              ; preds = %400, %388
  %390 = load i64, i64* %23, align 8
  %391 = icmp ult i64 %390, 4
  br i1 %391, label %392, label %403

392:                                              ; preds = %389
  %393 = load i64, i64* %23, align 8
  %394 = getelementptr inbounds [4 x i32], [4 x i32]* %22, i64 0, i64 %393
  %395 = load i32, i32* %394, align 4
  %396 = load i64, i64* %23, align 8
  %397 = getelementptr inbounds [4 x i32], [4 x i32]* @flags, i64 0, i64 %396
  %398 = load i32, i32* %397, align 4
  %399 = or i32 %398, %395
  store i32 %399, i32* %397, align 4
  br label %400

400:                                              ; preds = %392
  %401 = load i64, i64* %23, align 8
  %402 = add i64 %401, 1
  store i64 %402, i64* %23, align 8
  br label %389

403:                                              ; preds = %389
  br label %404

404:                                              ; preds = %403, %287
  %405 = load i32, i32* %10, align 4
  %406 = icmp eq i32 %405, 0
  br i1 %406, label %407, label %410

407:                                              ; preds = %404
  %408 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %409 = and i32 %408, -513
  store i32 %409, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %417

410:                                              ; preds = %404
  %411 = load i32, i32* %10, align 4
  %412 = icmp eq i32 %411, 1
  br i1 %412, label %413, label %416

413:                                              ; preds = %410
  %414 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %415 = or i32 %414, 512
  store i32 %415, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  br label %416

416:                                              ; preds = %413, %410
  br label %417

417:                                              ; preds = %416, %407
  %418 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %419 = and i32 %418, 536870912
  %420 = icmp ne i32 %419, 0
  br i1 %420, label %421, label %422

421:                                              ; preds = %417
  store i32 2097152, i32* @hilite_attribute, align 4
  br label %422

422:                                              ; preds = %421, %417
  %423 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %424 = and i32 %423, 4194304
  %425 = icmp ne i32 %424, 0
  br i1 %425, label %426, label %433

426:                                              ; preds = %422
  %427 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %428 = and i32 %427, -131073
  store i32 %428, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %429 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %430 = and i32 %429, -2097153
  store i32 %430, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %431 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %432 = and i32 %431, 2147483647
  store i32 %432, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %433

433:                                              ; preds = %426, %422
  %434 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %435 = and i32 %434, 32768
  %436 = icmp ne i32 %435, 0
  br i1 %436, label %437, label %440

437:                                              ; preds = %433
  %438 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %439 = and i32 %438, -257
  store i32 %439, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %440

440:                                              ; preds = %437, %433
  %441 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %442 = and i32 %441, 131072
  %443 = icmp ne i32 %442, 0
  br i1 %443, label %444, label %447

444:                                              ; preds = %440
  %445 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %446 = or i32 %445, 8
  store i32 %446, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %447

447:                                              ; preds = %444, %440
  call void @history_init()
  %448 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %449 = and i32 %448, 2097152
  %450 = icmp ne i32 %449, 0
  br i1 %450, label %455, label %451

451:                                              ; preds = %447
  %452 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %453 = and i32 %452, -2147483648
  %454 = icmp ne i32 %453, 0
  br i1 %454, label %455, label %462

455:                                              ; preds = %451, %447
  %456 = call zeroext i1 @have_statedir()
  br i1 %456, label %462, label %457

457:                                              ; preds = %455
  %458 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %459 = and i32 %458, -2097153
  store i32 %459, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %460 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %461 = and i32 %460, 2147483647
  store i32 %461, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %462

462:                                              ; preds = %457, %455, %451
  %463 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %464 = and i32 %463, 2097152
  %465 = icmp ne i32 %464, 0
  br i1 %465, label %466, label %467

466:                                              ; preds = %462
  call void @load_history()
  br label %467

467:                                              ; preds = %466, %462
  %468 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %469 = and i32 %468, -2147483648
  %470 = icmp ne i32 %469, 0
  br i1 %470, label %471, label %472

471:                                              ; preds = %467
  call void @load_poshistory()
  br label %472

472:                                              ; preds = %471, %467
  %473 = load i8*, i8** @backup_dir, align 8
  %474 = icmp ne i8* %473, null
  br i1 %474, label %475, label %480

475:                                              ; preds = %472
  %476 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %477 = and i32 %476, 4194304
  %478 = icmp ne i32 %477, 0
  br i1 %478, label %480, label %479

479:                                              ; preds = %475
  call void @init_backup_dir()
  br label %480

480:                                              ; preds = %479, %475, %472
  %481 = load i8*, i8** @operating_dir, align 8
  %482 = icmp ne i8* %481, null
  br i1 %482, label %483, label %484

483:                                              ; preds = %480
  call void @init_operating_dir()
  br label %484

484:                                              ; preds = %483, %480
  %485 = load i8*, i8** @punct, align 8
  %486 = icmp eq i8* %485, null
  br i1 %486, label %487, label %489

487:                                              ; preds = %484
  %488 = call i8* @copy_of(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.289, i64 0, i64 0))
  store i8* %488, i8** @punct, align 8
  br label %489

489:                                              ; preds = %487, %484
  %490 = load i8*, i8** @brackets, align 8
  %491 = icmp eq i8* %490, null
  br i1 %491, label %492, label %494

492:                                              ; preds = %489
  %493 = call i8* @copy_of(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.290, i64 0, i64 0))
  store i8* %493, i8** @brackets, align 8
  br label %494

494:                                              ; preds = %492, %489
  %495 = load i8*, i8** @quotestr, align 8
  %496 = icmp eq i8* %495, null
  br i1 %496, label %497, label %499

497:                                              ; preds = %494
  %498 = call i8* @copy_of(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @.str.291, i64 0, i64 0))
  store i8* %498, i8** @quotestr, align 8
  br label %499

499:                                              ; preds = %497, %494
  %500 = load i8*, i8** @quotestr, align 8
  %501 = call i32 @rpl_regcomp(%struct.re_pattern_buffer* @quotereg, i8* %500, i32 1)
  store i32 %501, i32* %11, align 4
  %502 = load i32, i32* %11, align 4
  %503 = icmp ne i32 %502, 0
  br i1 %503, label %504, label %516

504:                                              ; preds = %499
  %505 = load i32, i32* %11, align 4
  %506 = call i64 @rpl_regerror(i32 %505, %struct.re_pattern_buffer* @quotereg, i8* null, i64 0)
  store i64 %506, i64* %24, align 8
  %507 = load i64, i64* %24, align 8
  %508 = call i8* @nmalloc(i64 %507)
  store i8* %508, i8** %25, align 8
  %509 = load i32, i32* %11, align 4
  %510 = load i8*, i8** %25, align 8
  %511 = load i64, i64* %24, align 8
  %512 = call i64 @rpl_regerror(i32 %509, %struct.re_pattern_buffer* @quotereg, i8* %510, i64 %511)
  %513 = call i8* @gettext(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @.str.292, i64 0, i64 0)) #9
  %514 = load i8*, i8** @quotestr, align 8
  %515 = load i8*, i8** %25, align 8
  call void (i8*, ...) @die(i8* %513, i8* %514, i8* %515)
  br label %518

516:                                              ; preds = %499
  %517 = load i8*, i8** @quotestr, align 8
  call void @rpl_free(i8* %517)
  br label %518

518:                                              ; preds = %516, %504
  %519 = load i8*, i8** @alt_speller, align 8
  %520 = icmp eq i8* %519, null
  br i1 %520, label %521, label %533

521:                                              ; preds = %518
  %522 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %523 = and i32 %522, 4194304
  %524 = icmp ne i32 %523, 0
  br i1 %524, label %533, label %525

525:                                              ; preds = %521
  %526 = call i8* @getenv(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.293, i64 0, i64 0)) #9
  store i8* %526, i8** %26, align 8
  %527 = load i8*, i8** %26, align 8
  %528 = icmp ne i8* %527, null
  br i1 %528, label %529, label %532

529:                                              ; preds = %525
  %530 = load i8*, i8** %26, align 8
  %531 = call i8* @copy_of(i8* %530)
  store i8* %531, i8** @alt_speller, align 8
  br label %532

532:                                              ; preds = %529, %525
  br label %533

533:                                              ; preds = %532, %521, %518
  %534 = load i8*, i8** @matchbrackets, align 8
  %535 = icmp eq i8* %534, null
  br i1 %535, label %536, label %538

536:                                              ; preds = %533
  %537 = call i8* @copy_of(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.294, i64 0, i64 0))
  store i8* %537, i8** @matchbrackets, align 8
  br label %538

538:                                              ; preds = %536, %533
  %539 = load i8*, i8** @whitespace, align 8
  %540 = icmp eq i8* %539, null
  br i1 %540, label %541, label %548

541:                                              ; preds = %538
  %542 = call zeroext i1 @using_utf8()
  br i1 %542, label %543, label %545

543:                                              ; preds = %541
  %544 = call i8* @copy_of(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.295, i64 0, i64 0))
  store i8* %544, i8** @whitespace, align 8
  store i32 2, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @whitelen, i64 0, i64 0), align 4
  store i32 2, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @whitelen, i64 0, i64 1), align 4
  br label %547

545:                                              ; preds = %541
  %546 = call i8* @copy_of(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.296, i64 0, i64 0))
  store i8* %546, i8** @whitespace, align 8
  store i32 1, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @whitelen, i64 0, i64 0), align 4
  store i32 1, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @whitelen, i64 0, i64 1), align 4
  br label %547

547:                                              ; preds = %545, %543
  br label %548

548:                                              ; preds = %547, %538
  %549 = call i8* @copy_of(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.220, i64 0, i64 0))
  store i8* %549, i8** @last_search, align 8
  %550 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %551 = and i32 %550, -4097
  store i32 %551, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %552 = load i64, i64* @tabsize, align 8
  %553 = icmp eq i64 %552, -1
  br i1 %553, label %554, label %555

554:                                              ; preds = %548
  store i64 8, i64* @tabsize, align 8
  br label %555

555:                                              ; preds = %554, %548
  %556 = call zeroext i1 @has_colors()
  br i1 %556, label %557, label %558

557:                                              ; preds = %555
  call void @set_interface_colorpairs()
  br label %567

558:                                              ; preds = %555
  %559 = load i32, i32* @hilite_attribute, align 4
  store i32 %559, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 0), align 16
  %560 = load i32, i32* @hilite_attribute, align 4
  store i32 %560, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 1), align 4
  store i32 262144, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 2), align 8
  store i32 0, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 3), align 4
  %561 = load i32, i32* @hilite_attribute, align 4
  store i32 %561, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 4), align 16
  store i32 262144, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 5), align 4
  %562 = load i32, i32* @hilite_attribute, align 4
  store i32 %562, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 6), align 8
  %563 = load i32, i32* @hilite_attribute, align 4
  store i32 %563, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 7), align 4
  %564 = load i32, i32* @hilite_attribute, align 4
  store i32 %564, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 8), align 16
  %565 = load i32, i32* @hilite_attribute, align 4
  store i32 %565, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 9), align 4
  %566 = load i32, i32* @hilite_attribute, align 4
  store i32 %566, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 10), align 8
  store i32 0, i32* getelementptr inbounds ([12 x i32], [12 x i32]* @interface_color_pair, i64 0, i64 11), align 4
  br label %567

567:                                              ; preds = %558, %557
  call void @terminal_init()
  call void @window_init()
  %568 = call i32 @curs_set(i32 0)
  %569 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %570 = and i32 %569, 4096
  %571 = icmp ne i32 %570, 0
  br i1 %571, label %572, label %578

572:                                              ; preds = %567
  %573 = load i32, i32* @LINES, align 4
  %574 = icmp sgt i32 %573, 5
  br i1 %574, label %575, label %578

575:                                              ; preds = %572
  %576 = load i32, i32* @COLS, align 4
  %577 = icmp sgt i32 %576, 9
  br label %578

578:                                              ; preds = %575, %572, %567
  %579 = phi i1 [ false, %572 ], [ false, %567 ], [ %577, %575 ]
  %580 = zext i1 %579 to i64
  %581 = select i1 %579, i32 1, i32 0
  store i32 %581, i32* @thebar, align 4
  %582 = load i32*, i32** @bardata, align 8
  %583 = bitcast i32* %582 to i8*
  %584 = load i32, i32* @LINES, align 4
  %585 = sext i32 %584 to i64
  %586 = mul i64 %585, 4
  %587 = call i8* @nrealloc(i8* %583, i64 %586)
  %588 = bitcast i8* %587 to i32*
  store i32* %588, i32** @bardata, align 8
  %589 = load i32, i32* @COLS, align 4
  %590 = load i32, i32* @thebar, align 4
  %591 = sub nsw i32 %589, %590
  store i32 %591, i32* @editwincols, align 4
  call void @signal_init()
  call void @mouse_init()
  %592 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.297, i64 0, i64 0), i32 1025)
  store i32 %592, i32* @controlleft, align 4
  %593 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.298, i64 0, i64 0), i32 1026)
  store i32 %593, i32* @controlright, align 4
  %594 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.299, i64 0, i64 0), i32 1027)
  store i32 %594, i32* @controlup, align 4
  %595 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.300, i64 0, i64 0), i32 1028)
  store i32 %595, i32* @controldown, align 4
  %596 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.301, i64 0, i64 0), i32 1029)
  store i32 %596, i32* @controlhome, align 4
  %597 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.302, i64 0, i64 0), i32 1030)
  store i32 %597, i32* @controlend, align 4
  %598 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.303, i64 0, i64 0), i32 1037)
  store i32 %598, i32* @controldelete, align 4
  %599 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.304, i64 0, i64 0), i32 1053)
  store i32 %599, i32* @controlshiftdelete, align 4
  %600 = call i32 @get_keycode(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.305, i64 0, i64 0), i32 1107)
  store i32 %600, i32* @shiftup, align 4
  %601 = call i32 @get_keycode(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.306, i64 0, i64 0), i32 1108)
  store i32 %601, i32* @shiftdown, align 4
  %602 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.307, i64 0, i64 0), i32 1041)
  store i32 %602, i32* @shiftcontrolleft, align 4
  %603 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.308, i64 0, i64 0), i32 1042)
  store i32 %603, i32* @shiftcontrolright, align 4
  %604 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.309, i64 0, i64 0), i32 1043)
  store i32 %604, i32* @shiftcontrolup, align 4
  %605 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.310, i64 0, i64 0), i32 1044)
  store i32 %605, i32* @shiftcontroldown, align 4
  %606 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.311, i64 0, i64 0), i32 1045)
  store i32 %606, i32* @shiftcontrolhome, align 4
  %607 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.312, i64 0, i64 0), i32 1046)
  store i32 %607, i32* @shiftcontrolend, align 4
  %608 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.313, i64 0, i64 0), i32 1057)
  store i32 %608, i32* @altleft, align 4
  %609 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.314, i64 0, i64 0), i32 1058)
  store i32 %609, i32* @altright, align 4
  %610 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.315, i64 0, i64 0), i32 1059)
  store i32 %610, i32* @altup, align 4
  %611 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.316, i64 0, i64 0), i32 1060)
  store i32 %611, i32* @altdown, align 4
  %612 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.317, i64 0, i64 0), i32 1063)
  store i32 %612, i32* @altpageup, align 4
  %613 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.318, i64 0, i64 0), i32 1064)
  store i32 %613, i32* @altpagedown, align 4
  %614 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.319, i64 0, i64 0), i32 1068)
  store i32 %614, i32* @altinsert, align 4
  %615 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.320, i64 0, i64 0), i32 1069)
  store i32 %615, i32* @altdelete, align 4
  %616 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.321, i64 0, i64 0), i32 1073)
  store i32 %616, i32* @shiftaltleft, align 4
  %617 = call i32 @get_keycode(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.322, i64 0, i64 0), i32 1074)
  store i32 %617, i32* @shiftaltright, align 4
  %618 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.323, i64 0, i64 0), i32 1075)
  store i32 %618, i32* @shiftaltup, align 4
  %619 = call i32 @get_keycode(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.324, i64 0, i64 0), i32 1076)
  store i32 %619, i32* @shiftaltdown, align 4
  %620 = call i32 @set_escdelay(i32 50)
  br label %621

621:                                              ; preds = %900, %825, %815, %578
  %622 = load i32, i32* @optind, align 4
  %623 = load i32, i32* %4, align 4
  %624 = icmp slt i32 %622, %623
  br i1 %624, label %625, label %631

625:                                              ; preds = %621
  %626 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %627 = icmp ne %struct.openfilestruct* %626, null
  br i1 %627, label %628, label %629

628:                                              ; preds = %625
  br label %629

629:                                              ; preds = %628, %625
  %630 = phi i1 [ true, %625 ], [ true, %628 ]
  br label %631

631:                                              ; preds = %629, %621
  %632 = phi i1 [ false, %621 ], [ %630, %629 ]
  br i1 %632, label %633, label %901

633:                                              ; preds = %631
  store i64 0, i64* %27, align 8
  store i64 0, i64* %28, align 8
  store i8* null, i8** %29, align 8
  %634 = load i32, i32* @optind, align 4
  %635 = load i32, i32* %4, align 4
  %636 = sub nsw i32 %635, 1
  %637 = icmp slt i32 %634, %636
  br i1 %637, label %638, label %803

638:                                              ; preds = %633
  %639 = load i8**, i8*** %5, align 8
  %640 = load i32, i32* @optind, align 4
  %641 = sext i32 %640 to i64
  %642 = getelementptr inbounds i8*, i8** %639, i64 %641
  %643 = load i8*, i8** %642, align 8
  %644 = getelementptr inbounds i8, i8* %643, i64 0
  %645 = load i8, i8* %644, align 1
  %646 = sext i8 %645 to i32
  %647 = icmp eq i32 %646, 43
  br i1 %647, label %648, label %803

648:                                              ; preds = %638
  store i32 1, i32* %30, align 4
  br label %649

649:                                              ; preds = %705, %648
  %650 = call i16** @__ctype_b_loc() #11
  %651 = load i16*, i16** %650, align 8
  %652 = load i8**, i8*** %5, align 8
  %653 = load i32, i32* @optind, align 4
  %654 = sext i32 %653 to i64
  %655 = getelementptr inbounds i8*, i8** %652, i64 %654
  %656 = load i8*, i8** %655, align 8
  %657 = load i32, i32* %30, align 4
  %658 = sext i32 %657 to i64
  %659 = getelementptr inbounds i8, i8* %656, i64 %658
  %660 = load i8, i8* %659, align 1
  %661 = sext i8 %660 to i32
  %662 = sext i32 %661 to i64
  %663 = getelementptr inbounds i16, i16* %651, i64 %662
  %664 = load i16, i16* %663, align 2
  %665 = zext i16 %664 to i32
  %666 = and i32 %665, 1024
  %667 = icmp ne i32 %666, 0
  br i1 %667, label %668, label %706

668:                                              ; preds = %649
  %669 = load i8**, i8*** %5, align 8
  %670 = load i32, i32* @optind, align 4
  %671 = sext i32 %670 to i64
  %672 = getelementptr inbounds i8*, i8** %669, i64 %671
  %673 = load i8*, i8** %672, align 8
  %674 = load i32, i32* %30, align 4
  %675 = add nsw i32 %674, 1
  store i32 %675, i32* %30, align 4
  %676 = sext i32 %674 to i64
  %677 = getelementptr inbounds i8, i8* %673, i64 %676
  %678 = load i8, i8* %677, align 1
  %679 = sext i8 %678 to i32
  switch i32 %679, label %692 [
    i32 99, label %680
    i32 67, label %683
    i32 114, label %686
    i32 82, label %689
  ]

680:                                              ; preds = %668
  %681 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %682 = or i32 %681, 2
  store i32 %682, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %705

683:                                              ; preds = %668
  %684 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %685 = and i32 %684, -3
  store i32 %685, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %705

686:                                              ; preds = %668
  %687 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %688 = or i32 %687, 512
  store i32 %688, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %705

689:                                              ; preds = %668
  %690 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %691 = and i32 %690, -513
  store i32 %691, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %705

692:                                              ; preds = %668
  %693 = call i8* @gettext(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.325, i64 0, i64 0)) #9
  %694 = load i8**, i8*** %5, align 8
  %695 = load i32, i32* @optind, align 4
  %696 = sext i32 %695 to i64
  %697 = getelementptr inbounds i8*, i8** %694, i64 %696
  %698 = load i8*, i8** %697, align 8
  %699 = load i32, i32* %30, align 4
  %700 = sub nsw i32 %699, 1
  %701 = sext i32 %700 to i64
  %702 = getelementptr inbounds i8, i8* %698, i64 %701
  %703 = load i8, i8* %702, align 1
  %704 = sext i8 %703 to i32
  call void (i32, i8*, ...) @statusline(i32 7, i8* %693, i32 %704)
  br label %705

705:                                              ; preds = %692, %689, %686, %683, %680
  br label %649

706:                                              ; preds = %649
  %707 = load i8**, i8*** %5, align 8
  %708 = load i32, i32* @optind, align 4
  %709 = sext i32 %708 to i64
  %710 = getelementptr inbounds i8*, i8** %707, i64 %709
  %711 = load i8*, i8** %710, align 8
  %712 = load i32, i32* %30, align 4
  %713 = sext i32 %712 to i64
  %714 = getelementptr inbounds i8, i8* %711, i64 %713
  %715 = load i8, i8* %714, align 1
  %716 = sext i8 %715 to i32
  %717 = icmp eq i32 %716, 47
  br i1 %717, label %730, label %718

718:                                              ; preds = %706
  %719 = load i8**, i8*** %5, align 8
  %720 = load i32, i32* @optind, align 4
  %721 = sext i32 %720 to i64
  %722 = getelementptr inbounds i8*, i8** %719, i64 %721
  %723 = load i8*, i8** %722, align 8
  %724 = load i32, i32* %30, align 4
  %725 = sext i32 %724 to i64
  %726 = getelementptr inbounds i8, i8* %723, i64 %725
  %727 = load i8, i8* %726, align 1
  %728 = sext i8 %727 to i32
  %729 = icmp eq i32 %728, 63
  br i1 %729, label %730, label %777

730:                                              ; preds = %718, %706
  %731 = load i8**, i8*** %5, align 8
  %732 = load i32, i32* @optind, align 4
  %733 = sext i32 %732 to i64
  %734 = getelementptr inbounds i8*, i8** %731, i64 %733
  %735 = load i8*, i8** %734, align 8
  %736 = load i32, i32* %30, align 4
  %737 = add nsw i32 %736, 1
  %738 = sext i32 %737 to i64
  %739 = getelementptr inbounds i8, i8* %735, i64 %738
  %740 = load i8, i8* %739, align 1
  %741 = icmp ne i8 %740, 0
  br i1 %741, label %742, label %768

742:                                              ; preds = %730
  %743 = load i8**, i8*** %5, align 8
  %744 = load i32, i32* @optind, align 4
  %745 = sext i32 %744 to i64
  %746 = getelementptr inbounds i8*, i8** %743, i64 %745
  %747 = load i8*, i8** %746, align 8
  %748 = load i32, i32* %30, align 4
  %749 = add nsw i32 %748, 1
  %750 = sext i32 %749 to i64
  %751 = getelementptr inbounds i8, i8* %747, i64 %750
  %752 = call i8* @copy_of(i8* %751)
  store i8* %752, i8** %29, align 8
  %753 = load i8**, i8*** %5, align 8
  %754 = load i32, i32* @optind, align 4
  %755 = sext i32 %754 to i64
  %756 = getelementptr inbounds i8*, i8** %753, i64 %755
  %757 = load i8*, i8** %756, align 8
  %758 = load i32, i32* %30, align 4
  %759 = sext i32 %758 to i64
  %760 = getelementptr inbounds i8, i8* %757, i64 %759
  %761 = load i8, i8* %760, align 1
  %762 = sext i8 %761 to i32
  %763 = icmp eq i32 %762, 63
  br i1 %763, label %764, label %767

764:                                              ; preds = %742
  %765 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %766 = or i32 %765, 4096
  store i32 %766, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %767

767:                                              ; preds = %764, %742
  br label %774

768:                                              ; preds = %730
  %769 = load i32, i32* %30, align 4
  %770 = icmp eq i32 %769, 1
  br i1 %770, label %771, label %773

771:                                              ; preds = %768
  %772 = call i8* @gettext(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str.326, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 7, i8* %772)
  br label %773

773:                                              ; preds = %771, %768
  br label %774

774:                                              ; preds = %773, %767
  %775 = load i32, i32* @optind, align 4
  %776 = add nsw i32 %775, 1
  store i32 %776, i32* @optind, align 4
  br label %802

777:                                              ; preds = %718
  %778 = load i8**, i8*** %5, align 8
  %779 = load i32, i32* @optind, align 4
  %780 = add nsw i32 %779, 1
  store i32 %780, i32* @optind, align 4
  %781 = sext i32 %779 to i64
  %782 = getelementptr inbounds i8*, i8** %778, i64 %781
  %783 = load i8*, i8** %782, align 8
  %784 = getelementptr inbounds i8, i8* %783, i64 1
  %785 = load i8, i8* %784, align 1
  %786 = sext i8 %785 to i32
  %787 = icmp eq i32 %786, 0
  br i1 %787, label %788, label %789

788:                                              ; preds = %777
  store i64 -1, i64* %27, align 8
  br label %801

789:                                              ; preds = %777
  %790 = load i8**, i8*** %5, align 8
  %791 = load i32, i32* @optind, align 4
  %792 = sub nsw i32 %791, 1
  %793 = sext i32 %792 to i64
  %794 = getelementptr inbounds i8*, i8** %790, i64 %793
  %795 = load i8*, i8** %794, align 8
  %796 = getelementptr inbounds i8, i8* %795, i64 1
  %797 = call zeroext i1 @parse_line_column(i8* %796, i64* %27, i64* %28)
  br i1 %797, label %800, label %798

798:                                              ; preds = %789
  %799 = call i8* @gettext(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.327, i64 0, i64 0)) #9
  call void (i32, i8*, ...) @statusline(i32 7, i8* %799)
  br label %800

800:                                              ; preds = %798, %789
  br label %801

801:                                              ; preds = %800, %788
  br label %802

802:                                              ; preds = %801, %774
  br label %803

803:                                              ; preds = %802, %638, %633
  %804 = load i8**, i8*** %5, align 8
  %805 = load i32, i32* @optind, align 4
  %806 = sext i32 %805 to i64
  %807 = getelementptr inbounds i8*, i8** %804, i64 %806
  %808 = load i8*, i8** %807, align 8
  %809 = call i32 @strcmp(i8* %808, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.328, i64 0, i64 0)) #12
  %810 = icmp eq i32 %809, 0
  br i1 %810, label %811, label %817

811:                                              ; preds = %803
  %812 = load i32, i32* @optind, align 4
  %813 = add nsw i32 %812, 1
  store i32 %813, i32* @optind, align 4
  %814 = call zeroext i1 @scoop_stdin()
  br i1 %814, label %816, label %815

815:                                              ; preds = %811
  br label %621

816:                                              ; preds = %811
  br label %827

817:                                              ; preds = %803
  %818 = load i8**, i8*** %5, align 8
  %819 = load i32, i32* @optind, align 4
  %820 = add nsw i32 %819, 1
  store i32 %820, i32* @optind, align 4
  %821 = sext i32 %819 to i64
  %822 = getelementptr inbounds i8*, i8** %818, i64 %821
  %823 = load i8*, i8** %822, align 8
  %824 = call zeroext i1 @open_buffer(i8* %823, i1 zeroext true)
  br i1 %824, label %826, label %825

825:                                              ; preds = %817
  br label %621

826:                                              ; preds = %817
  br label %827

827:                                              ; preds = %826, %816
  %828 = load i64, i64* %27, align 8
  %829 = icmp ne i64 %828, 0
  br i1 %829, label %833, label %830

830:                                              ; preds = %827
  %831 = load i64, i64* %28, align 8
  %832 = icmp ne i64 %831, 0
  br i1 %832, label %833, label %836

833:                                              ; preds = %830, %827
  %834 = load i64, i64* %27, align 8
  %835 = load i64, i64* %28, align 8
  call void @goto_line_and_column(i64 %834, i64 %835, i1 zeroext false, i1 zeroext false)
  br label %900

836:                                              ; preds = %830
  %837 = load i8*, i8** %29, align 8
  %838 = icmp ne i8* %837, null
  br i1 %838, label %839, label %874

839:                                              ; preds = %836
  %840 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %841 = and i32 %840, 512
  %842 = icmp ne i32 %841, 0
  br i1 %842, label %843, label %846

843:                                              ; preds = %839
  %844 = load i8*, i8** %29, align 8
  %845 = call zeroext i1 @regexp_init(i8* %844)
  br label %846

846:                                              ; preds = %843, %839
  %847 = load i8*, i8** %29, align 8
  %848 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %849 = and i32 %848, 4096
  %850 = icmp ne i32 %849, 0
  %851 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %852 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %851, i32 0, i32 1
  %853 = load %struct.linestruct*, %struct.linestruct** %852, align 8
  %854 = call i32 @findnextstr(i8* %847, i1 zeroext false, i32 0, i64* null, i1 zeroext %850, %struct.linestruct* %853, i64 0)
  %855 = icmp ne i32 %854, 0
  br i1 %855, label %858, label %856

856:                                              ; preds = %846
  %857 = load i8*, i8** %29, align 8
  call void @not_found_msg(i8* %857)
  br label %863

858:                                              ; preds = %846
  %859 = load i32, i32* @lastmessage, align 4
  %860 = icmp ule i32 %859, 2
  br i1 %860, label %861, label %862

861:                                              ; preds = %858
  call void @wipe_statusbar()
  br label %862

862:                                              ; preds = %861, %858
  br label %863

863:                                              ; preds = %862, %856
  %864 = call i64 @xplustabs()
  %865 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %866 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %865, i32 0, i32 8
  store i64 %864, i64* %866, align 8
  %867 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %868 = and i32 %867, 512
  %869 = icmp ne i32 %868, 0
  br i1 %869, label %870, label %871

870:                                              ; preds = %863
  call void @tidy_up_after_search()
  br label %871

871:                                              ; preds = %870, %863
  %872 = load i8*, i8** @last_search, align 8
  call void @rpl_free(i8* %872)
  %873 = load i8*, i8** %29, align 8
  store i8* %873, i8** @last_search, align 8
  store i8* null, i8** %29, align 8
  br label %899

874:                                              ; preds = %836
  %875 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %876 = and i32 %875, -2147483648
  %877 = icmp ne i32 %876, 0
  br i1 %877, label %878, label %898

878:                                              ; preds = %874
  %879 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %880 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %879, i32 0, i32 0
  %881 = load i8*, i8** %880, align 8
  %882 = getelementptr inbounds i8, i8* %881, i64 0
  %883 = load i8, i8* %882, align 1
  %884 = sext i8 %883 to i32
  %885 = icmp ne i32 %884, 0
  br i1 %885, label %886, label %898

886:                                              ; preds = %878
  %887 = load i8**, i8*** %5, align 8
  %888 = load i32, i32* @optind, align 4
  %889 = sub nsw i32 %888, 1
  %890 = sext i32 %889 to i64
  %891 = getelementptr inbounds i8*, i8** %887, i64 %890
  %892 = load i8*, i8** %891, align 8
  %893 = call zeroext i1 @has_old_position(i8* %892, i64* %31, i64* %32)
  br i1 %893, label %894, label %897

894:                                              ; preds = %886
  %895 = load i64, i64* %31, align 8
  %896 = load i64, i64* %32, align 8
  call void @goto_line_and_column(i64 %895, i64 %896, i1 zeroext false, i1 zeroext false)
  br label %897

897:                                              ; preds = %894, %886
  br label %898

898:                                              ; preds = %897, %878, %874
  br label %899

899:                                              ; preds = %898, %871
  br label %900

900:                                              ; preds = %899, %833
  br label %621

901:                                              ; preds = %631
  %902 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %903 = and i32 %902, -3
  store i32 %903, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %904 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %905 = icmp eq %struct.openfilestruct* %904, null
  br i1 %905, label %906, label %910

906:                                              ; preds = %901
  %907 = call zeroext i1 @open_buffer(i8* getelementptr inbounds ([1 x i8], [1 x i8]* @.str.220, i64 0, i64 0), i1 zeroext true)
  %908 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %909 = and i32 %908, -129
  store i32 %909, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %925

910:                                              ; preds = %901
  %911 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %912 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %911, i32 0, i32 24
  %913 = load %struct.openfilestruct*, %struct.openfilestruct** %912, align 8
  store %struct.openfilestruct* %913, %struct.openfilestruct** @openfile, align 8
  %914 = load i8, i8* @more_than_one, align 1
  %915 = trunc i8 %914 to i1
  br i1 %915, label %916, label %917

916:                                              ; preds = %910
  call void @mention_name_and_linecount()
  br label %917

917:                                              ; preds = %916, %910
  %918 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %919 = and i32 %918, 128
  %920 = icmp ne i32 %919, 0
  br i1 %920, label %921, label %924

921:                                              ; preds = %917
  %922 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %923 = or i32 %922, 8192
  store i32 %923, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  br label %924

924:                                              ; preds = %921, %917
  br label %925

925:                                              ; preds = %924, %906
  call void @prepare_for_display()
  %926 = load i8*, i8** @startup_problem, align 8
  %927 = icmp ne i8* %926, null
  br i1 %927, label %928, label %930

928:                                              ; preds = %925
  %929 = load i8*, i8** @startup_problem, align 8
  call void (i32, i8*, ...) @statusline(i32 7, i8* %929)
  br label %930

930:                                              ; preds = %928, %925
  %931 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %932 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %931, i32 0, i32 0
  %933 = load i8*, i8** %932, align 8
  %934 = load i8, i8* %933, align 1
  %935 = sext i8 %934 to i32
  %936 = icmp eq i32 %935, 0
  br i1 %936, label %937, label %962

937:                                              ; preds = %930
  %938 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %939 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %938, i32 0, i32 5
  %940 = load i64, i64* %939, align 8
  %941 = icmp eq i64 %940, 0
  br i1 %941, label %942, label %962

942:                                              ; preds = %937
  %943 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %944 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %943, i32 0, i32 24
  %945 = load %struct.openfilestruct*, %struct.openfilestruct** %944, align 8
  %946 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %947 = icmp eq %struct.openfilestruct* %945, %946
  br i1 %947, label %948, label %962

948:                                              ; preds = %942
  %949 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %950 = and i32 %949, 8
  %951 = icmp ne i32 %950, 0
  br i1 %951, label %962, label %952

952:                                              ; preds = %948
  %953 = call %struct.keystruct* @first_sc_for(i32 1, void ()* @do_help)
  %954 = icmp ne %struct.keystruct* %953, null
  br i1 %954, label %955, label %962

955:                                              ; preds = %952
  %956 = call %struct.keystruct* @first_sc_for(i32 1, void ()* @do_help)
  %957 = getelementptr inbounds %struct.keystruct, %struct.keystruct* %956, i32 0, i32 1
  %958 = load i32, i32* %957, align 8
  %959 = icmp eq i32 %958, 7
  br i1 %959, label %960, label %962

960:                                              ; preds = %955
  %961 = call i8* @gettext(i8* getelementptr inbounds ([47 x i8], [47 x i8]* @.str.329, i64 0, i64 0)) #9
  call void @statusbar(i8* %961)
  br label %962

962:                                              ; preds = %960, %955, %952, %948, %942, %937, %930
  store i8 1, i8* @we_are_running, align 1
  br label %963

963:                                              ; preds = %1061, %962
  call void @confirm_margin()
  %964 = load i8, i8* @on_a_vt, align 1
  %965 = trunc i8 %964 to i1
  br i1 %965, label %966, label %970

966:                                              ; preds = %963
  %967 = call i64 @waiting_keycodes()
  %968 = icmp eq i64 %967, 0
  br i1 %968, label %969, label %970

969:                                              ; preds = %966
  store i8 0, i8* @mute_modifiers, align 1
  br label %970

970:                                              ; preds = %969, %966, %963
  %971 = load i32, i32* @currmenu, align 4
  %972 = icmp ne i32 %971, 1
  br i1 %972, label %973, label %974

973:                                              ; preds = %970
  call void @bottombars(i32 1)
  br label %974

974:                                              ; preds = %973, %970
  %975 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %976 = and i32 %975, 65536
  %977 = icmp ne i32 %976, 0
  br i1 %977, label %978, label %989

978:                                              ; preds = %974
  %979 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %980 = and i32 %979, 131072
  %981 = icmp ne i32 %980, 0
  br i1 %981, label %989, label %982

982:                                              ; preds = %978
  %983 = load i32, i32* @LINES, align 4
  %984 = icmp sgt i32 %983, 1
  br i1 %984, label %985, label %989

985:                                              ; preds = %982
  %986 = load i32, i32* @lastmessage, align 4
  %987 = icmp ult i32 %986, 2
  br i1 %987, label %988, label %989

988:                                              ; preds = %985
  call void @minibar()
  br label %1008

989:                                              ; preds = %985, %982, %978, %974
  %990 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 0), align 16
  %991 = and i32 %990, 4
  %992 = icmp ne i32 %991, 0
  br i1 %992, label %993, label %1007

993:                                              ; preds = %989
  %994 = load i32, i32* @lastmessage, align 4
  %995 = icmp eq i32 %994, 0
  br i1 %995, label %996, label %1007

996:                                              ; preds = %993
  %997 = load i32, i32* @LINES, align 4
  %998 = icmp sgt i32 %997, 1
  br i1 %998, label %999, label %1007

999:                                              ; preds = %996
  %1000 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %1001 = and i32 %1000, 131072
  %1002 = icmp ne i32 %1001, 0
  br i1 %1002, label %1007, label %1003

1003:                                             ; preds = %999
  %1004 = call i64 @waiting_keycodes()
  %1005 = icmp eq i64 %1004, 0
  br i1 %1005, label %1006, label %1007

1006:                                             ; preds = %1003
  call void @report_cursor_position()
  br label %1007

1007:                                             ; preds = %1006, %1003, %999, %996, %993, %989
  br label %1008

1008:                                             ; preds = %1007, %988
  store i8 1, i8* @as_an_at, align 1
  %1009 = load i8, i8* @refresh_needed, align 1
  %1010 = trunc i8 %1009 to i1
  br i1 %1010, label %1011, label %1014

1011:                                             ; preds = %1008
  %1012 = load i32, i32* @LINES, align 4
  %1013 = icmp sgt i32 %1012, 1
  br i1 %1013, label %1020, label %1014

1014:                                             ; preds = %1011, %1008
  %1015 = load i32, i32* @LINES, align 4
  %1016 = icmp eq i32 %1015, 1
  br i1 %1016, label %1017, label %1021

1017:                                             ; preds = %1014
  %1018 = load i32, i32* @lastmessage, align 4
  %1019 = icmp ule i32 %1018, 1
  br i1 %1019, label %1020, label %1021

1020:                                             ; preds = %1017, %1011
  call void @edit_refresh()
  br label %1022

1021:                                             ; preds = %1017, %1014
  call void @place_the_cursor()
  br label %1022

1022:                                             ; preds = %1021, %1020
  %1023 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %1024 = and i32 %1023, 131072
  %1025 = icmp ne i32 %1024, 0
  br i1 %1025, label %1026, label %1048

1026:                                             ; preds = %1022
  %1027 = load i32, i32* @lastmessage, align 4
  %1028 = icmp ugt i32 %1027, 1
  br i1 %1028, label %1029, label %1048

1029:                                             ; preds = %1026
  %1030 = load %struct.openfilestruct*, %struct.openfilestruct** @openfile, align 8
  %1031 = getelementptr inbounds %struct.openfilestruct, %struct.openfilestruct* %1030, i32 0, i32 9
  %1032 = load i64, i64* %1031, align 8
  %1033 = load i32, i32* @editwinrows, align 4
  %1034 = sub nsw i32 %1033, 1
  %1035 = sext i32 %1034 to i64
  %1036 = icmp eq i64 %1032, %1035
  br i1 %1036, label %1037, label %1043

1037:                                             ; preds = %1029
  %1038 = load i32, i32* @LINES, align 4
  %1039 = icmp sgt i32 %1038, 1
  br i1 %1039, label %1040, label %1043

1040:                                             ; preds = %1037
  call void @edit_scroll(i1 zeroext true)
  %1041 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %1042 = call i32 @wnoutrefresh(%struct._win_st* %1041)
  br label %1043

1043:                                             ; preds = %1040, %1037, %1029
  %1044 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %1045 = call i32 @wredrawln(%struct._win_st* %1044, i32 0, i32 1)
  %1046 = load %struct._win_st*, %struct._win_st** @footwin, align 8
  %1047 = call i32 @wnoutrefresh(%struct._win_st* %1046)
  call void @place_the_cursor()
  br label %1061

1048:                                             ; preds = %1026, %1022
  %1049 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @flags, i64 0, i64 1), align 4
  %1050 = and i32 %1049, 131072
  %1051 = icmp ne i32 %1050, 0
  br i1 %1051, label %1052, label %1060

1052:                                             ; preds = %1048
  %1053 = load i32, i32* @lastmessage, align 4
  %1054 = icmp ugt i32 %1053, 0
  br i1 %1054, label %1055, label %1060

1055:                                             ; preds = %1052
  %1056 = load %struct._win_st*, %struct._win_st** @midwin, align 8
  %1057 = load i32, i32* @editwinrows, align 4
  %1058 = sub nsw i32 %1057, 1
  %1059 = call i32 @wredrawln(%struct._win_st* %1056, i32 %1058, i32 1)
  br label %1060

1060:                                             ; preds = %1055, %1052, %1048
  br label %1061

1061:                                             ; preds = %1060, %1043
  %1062 = call i32* @__errno_location() #11
  store i32 0, i32* %1062, align 4
  store i8 1, i8* @focusing, align 1
  call void @put_cursor_at_end_of_answer()
  call void @process_a_keystroke()
  br label %963
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #8

; Function Attrs: nounwind
declare dso_local i32 @ioctl(i32, i64, ...) #2

declare dso_local i32 @rpl_fcntl(i32, i32, ...) #1

; Function Attrs: nounwind
declare dso_local i8* @setlocale(i32, i8*) #2

; Function Attrs: nounwind readonly
declare dso_local i32 @strcmp(i8*, i8*) #7

; Function Attrs: nounwind
declare dso_local i8* @nl_langinfo(i32) #2

declare dso_local void @utf8_init() #1

; Function Attrs: nounwind
declare dso_local i8* @bindtextdomain(i8*, i8*) #2

; Function Attrs: nounwind
declare dso_local i8* @textdomain(i8*) #2

declare dso_local i8* @tail(i8*) #1

; Function Attrs: nounwind
declare dso_local i32 @getopt_long(i32, i8**, i8*, %struct.option*, i32*) #2

declare dso_local i8* @mallocstrcpy(i8*, i8*) #1

declare dso_local zeroext i1 @parse_num(i8*, i64*) #1

; Function Attrs: nounwind
declare dso_local i32 @putenv(i8*) #2

declare dso_local %struct._win_st* @initscr() #1

declare dso_local zeroext i1 @has_colors() #1

declare dso_local i32 @start_color() #1

declare dso_local void @shortcut_init() #1

declare dso_local void @do_rcfiles() #1

; Function Attrs: nounwind readnone
declare dso_local i16** @__ctype_b_loc() #5

declare dso_local void @history_init() #1

declare dso_local zeroext i1 @have_statedir() #1

declare dso_local void @load_history() #1

declare dso_local void @load_poshistory() #1

declare dso_local void @init_backup_dir() #1

declare dso_local void @init_operating_dir() #1

declare dso_local i32 @rpl_regcomp(%struct.re_pattern_buffer*, i8*, i32) #1

declare dso_local i64 @rpl_regerror(i32, %struct.re_pattern_buffer*, i8*, i64) #1

declare dso_local zeroext i1 @using_utf8() #1

declare dso_local void @set_interface_colorpairs() #1

declare dso_local i32 @set_escdelay(i32) #1

declare dso_local zeroext i1 @parse_line_column(i8*, i64*, i64*) #1

declare dso_local zeroext i1 @open_buffer(i8*, i1 zeroext) #1

declare dso_local void @goto_line_and_column(i64, i64, i1 zeroext, i1 zeroext) #1

declare dso_local zeroext i1 @regexp_init(i8*) #1

declare dso_local i32 @findnextstr(i8*, i1 zeroext, i32, i64*, i1 zeroext, %struct.linestruct*, i64) #1

declare dso_local void @not_found_msg(i8*) #1

declare dso_local void @tidy_up_after_search() #1

declare dso_local zeroext i1 @has_old_position(i8*, i64*, i64*) #1

declare dso_local void @mention_name_and_linecount() #1

declare dso_local void @prepare_for_display() #1

declare dso_local void @do_help() #1

declare dso_local void @bottombars(i32) #1

declare dso_local void @minibar() #1

declare dso_local void @report_cursor_position() #1

declare dso_local void @edit_refresh() #1

declare dso_local void @place_the_cursor() #1

declare dso_local void @edit_scroll(i1 zeroext) #1

declare dso_local i32 @wredrawln(%struct._win_st*, i32, i32) #1

declare dso_local void @put_cursor_at_end_of_answer() #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nofree nosync nounwind willreturn }
attributes #5 = { nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { argmemonly nofree nounwind willreturn writeonly }
attributes #7 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { argmemonly nofree nounwind willreturn }
attributes #9 = { nounwind }
attributes #10 = { noreturn nounwind }
attributes #11 = { nounwind readnone }
attributes #12 = { nounwind readonly }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"Debian clang version 11.0.1-2"}
