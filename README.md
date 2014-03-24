web_shell
=========
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
Perl script that interacts with a simple php shell using curl.
It is designed to act like a standard bash style shell.
It does have some limitations and is a work in progress.

Features:
Pipes stderr to stdin, checks for sudo nopasswd as well as if the server is running as root, URL encodes each request, ctrl-c kills curl and gives you the prompt again, supports changing directories.

Special Commands:
exit/quit = quit the program
debugon = show the command entered, the command being run before encoding, and the encoded command sent to the server
debugoff = turn debugging off

=====
Todos
=====
- separate commands by ; and have them run separately (split?)
- remove global vars
- clean up code, always
- Base64 encode URL
- Implement vim support (download file, edit locally, re-upload)

================
Limitations/Bugs
================
- Complex commands may not work
- Don't use vim or any other interactive commands as they will not work
- cd MAY bug out if there are multiple in one command


