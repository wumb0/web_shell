web_shell
=========

some webby things
Shell like interface for a php style shell

==================
File descriptions
==================

----------
shell.php
----------
The simple shell to upload to the target.
URL Crafting Example: "http://targetserver.com/shell.php?s=ls /" in browser will list contents of / on the server


------------------
shell_interact.pl
------------------

Perl script that interacts with a simple php shell.
It is designed to act like a standard bash style shell.
It does have some limitations and is a work in progress.

 Todos:                       Limitations/Bugs:
 - Completely fix URLEncode   - ctrl-c resets prompt
 - separate commands by ;       the first time but not
   and have them run            after that
   separately (split?)        - Try not to make
 - Fix ctrl-C                   commands too complex
 - remove global vars         - cd will bug out a bit
 - clean up code, always        if there are multiple
 - Base64 encode URL            in one command



