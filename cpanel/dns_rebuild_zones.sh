#!/usr/bin/perl
$nameddir = '/var/named';
$cpanelusers = '/var/cpanel/users';
$wwwacct = '/etc/wwwacct.conf';

print "Rebuild na vsichki zoni pod cPanel\n\n";
print "NAPRAVETE SI BACKUP NA SUSHTESTYVASHTIQT $nameddir PAPKA !\n";
print "Izchakvat se 5 sec pri start ako iskate da sprete script-a ctrl+c za \n";
sleep 5;
print "\n\n";

opendir(USERS,"$cpanelusers");
@CPUSERS=readdir(USERS);
closedir(USERS);

print "Vzimame dvata NS-a ot conf-a na cPanel-a $wwwacct...";
open(CONF,"$wwwacct");
while(<CONF>) {
$_ =~ s/\n//g;
if ($_ !~ /^;/) {
if ($_ =~ /^NS /) {
                        (undef,$nameserver) = split(/ /, $_);
                }
if ($_ =~ /^NS2 /) {
                        (undef,$nameserver2) = split(/ /, $_);
                }
}
}
close(CONF);
print "done.\n";

print "Rebuildvame zoneite ......";
foreach $cpusers (@CPUSERS) {
chomp;
open(USERDB,"$cpanelusers/$cpusers");
while(<USERDB>) {
if(/IP=/i) { (undef,$ip) = split(/=/, $_, 2); }
if(/DNS=/i) { (undef,$dns) = split(/=/, $_, 2); }
chomp($ip);
chomp($dns);
}
createzone();
}
print "Napraveno.\n";
print "\n\nZonite sa rebuildnati no samiqt config ne e !!!!! .\n";
print "Izpolzvaite /scripts/rebuildnamedconf za da rebuildnete config-a\n";

sub createzone(){
$time=time();

$nameddata = <<EOM;
; Zone file for $domain
@    14400   IN      SOA     $nameserver. hostmaster.$dns. (
                        $time      ; serial, todays date+todays
                        28800           ; refresh, seconds
                        7200            ; retry, seconds
                        3600000         ; expire, seconds
                        86400 )         ; minimum, seconds

$dns. 14400 IN NS $nameserver.
$dns. 14400 IN NS $nameserver2.
$dns. 14400 IN A $ip

localhost.$dns.   14400    IN A   127.0.0.1

$dns. 14400 IN MX 0 $dns.

mail    14400        IN CNAME    $dns.
www     14400        IN CNAME    $dns.
ftp     14400        IN CNAME    $dns.

EOM

open(VNAMEDF,">$nameddir/$dns.db");
print VNAMEDF $nameddata;
close(VNAMEDF);

}
