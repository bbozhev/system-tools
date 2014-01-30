#!/usr/bin/perl
 use Proc::Daemon;
 
sub APcheck { 
 $check = `ps -elf |grep httpd|grep -v grep`; 
  chomp($check);
 
  if ( $check =~ /httpd/ ) {
    sleep(1);
  } else {
   system("/etc/init.d/httpd restart");
  }

}

 Proc::Daemon::Init;
$0 = "apache-checker";
 while(1){
  sleep(1);
   APcheck;
}
