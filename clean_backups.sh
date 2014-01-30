#!/usr/local/bin/perl
#cron job - 0 2 * * * cd /kloshar/backup && /usr/local/sbin/clean_backup
use strict;

my $TODAY = time;
my $DIR = '.';
my $wktime = 604800;

#############################################################################
sub write_to_file 

{
     open (LOGFILE, ">/var/log/clean-backups.log");
     opendir DIR, $DIR or die "could not open directory: $!";
     while (my $file = readdir DIR) 
     {
     next if -d "$DIR/$file";
     my $mtime = (stat "$DIR/$file")[9];
   if ($TODAY - $wktime > $mtime) 
           {

     print LOGFILE "$DIR/$file is older than 7 days...removing\n";

           }
     }
}

close LOGFILE;
close DIR;

###############################################################################
sub remove_old_files
{
     opendir DIR, $DIR or die "could not open directory: $!";
     while (my $file = readdir DIR) 
     {
     next if -d "$DIR/$file";
     my $mtime = (stat "$DIR/$file")[9];
     if ($TODAY - $wktime > $mtime) 
     {
     unlink $file;
     }

     }

}
close LOGFILE;
close DIR;
##################################################################################
Main:
{
     write_to_file();
     remove_old_files();
}
