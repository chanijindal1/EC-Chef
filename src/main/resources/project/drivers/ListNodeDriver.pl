#
#  Copyright 2015 Electric Cloud, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use Cwd;
use Carp;
use strict;
use Data::Dumper;
use utf8;
use Encode;
use warnings;
use diagnostics;
use open IO => ':encoding(utf8)';
use File::Basename;
use ElectricCommander;
use ElectricCommander::PropDB;
use ElectricCommander::PropMod;

$|=1;


# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------
 
###########################################################################
=head2 main
 
  Title    : main
  Usage    : main();
  Function : Performs a Chef run
  Returns  : none
  Args     : named arguments: none
=cut
###########################################################################


sub main {
    my $ec = ElectricCommander->new();
    $ec->abortOnError(0);
    
    # -------------------------------------------------------------------------
    # Parameters
    # -------------------------------------------------------------------------
    $::g_knife_path = ($ec->getProperty( "knife_path" ))->findvalue('//value')->string_value;
    $::g_with_uri = ($ec->getProperty( "with_uri" ))->findvalue('//value')->string_value;
    $::g_additional_options = ($ec->getProperty( "additional_options" ))->findvalue('//value')->string_value;
    $::g_result_property = ($ec->getProperty( "result_property" ))->findvalue('//value')->string_value;
    #Variable that stores the command to be executed
    $::g_command = $::g_knife_path . " node list";

    my @cmd;
    my %props;

    #Prints procedure and parameters information
    my $pluginKey  = 'EC-Chef';
    my $xpath      = $ec->getPlugin($pluginKey);
    my $pluginName = $xpath->findvalue('//pluginVersion')->value;
    print "Using plugin $pluginKey version $pluginName\n";
    print "Running procedure ListNode\n";
    
    #Parameters are checked to see which should be included
    if($::g_with_uri && $::g_with_uri ne '')
    {
        $::g_command = $::g_command . " --with-uri";
    }
    if($::g_additional_options && $::g_additional_options ne '')
    {   
        $::g_command = $::g_command . " " . $::g_additional_options;
    }

    my $storage;
    if($::g_result_property && $::g_result_property ne '')
    {
        $storage = $::g_result_property;
    }
    else
    {
        $storage = "/myJob/result";
    }
    #Print out the command to be executed
    $::g_command = $::g_command . " -F json";
    print "\nCommand to be executed: \n$::g_command \n\n";

    #Executes the command
    my $cmdLog = `$::g_command`;
    print $cmdLog;
    $ec->setProperty($storage, $cmdLog);  
}
  
main();