#!/usr/bin/perl
use Proc::Daemon;
use Mail::Sendmail;
$hostname=`hostname`;
$SendmailPath = '/usr/sbin/sendmail';
sub sendmail {
        my ($to, $from, $subj, $msg) = @_;
        open (MAIL, "|$SendmailPath -t -n")|| die "Error! Can't use sendmail\n";
        print MAIL "To: $to\n";
        print MAIL "From: $from\n";
        print MAIL "Subject: $subj\n";
        print MAIL "Reply-To: $from\n\n";
        print MAIL "$msg\n";
        close (MAIL);
}

sub notify {
     sendmail('bbozhev@gmail.com', 'watcher@neshtosi.com', "Exim queue watcher $hostname ", "Messages queue has more than 150 messages in it and i will now process or otherwise delete them !");
}

 
sub eximcheck { 
 $check = `exim -bpc`; 
  chomp($check);
 
  if ( $check <= 150 ) {
    sleep(1);
  } else {
   system("/usr/local/sbin/exiqr");
   system("/usr/local/sbin/exidl");
   notify;
  }

}

 Proc::Daemon::Init;
$0 = "exim-watcher";
 while(1){
  sleep(1);
   eximcheck;
}
