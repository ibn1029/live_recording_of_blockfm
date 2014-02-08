#!/bin/env/perl
use strict;
use warnings;
use Furl;
use JSON;
use File::Which;
use Time::Piece;
use Time::Seconds;
use File::Copy;

use Data::Dumper;

#
# 終了時間の計算
#
my $end = $ARGV[0] ? $ARGV[0] : undef;
my $end_t;
if ($end) {
    $end =~ /(\d\d)(\d\d)/;
    my ($hh, $mm) = ($1, $2);
    $hh =~ s/^0//; $mm =~ s/^0//;
    my $t = localtime;
    $end_t = Time::Piece->localtime->strptime($t->ymd." $hh:$mm:00", '%Y-%m-%d %H:%M:%S');
    if ($t->epoch - $end_t->epoch > 0) {
        $end_t += ONE_DAY;
    }
}

#
# mixlr api
#
my $furl = Furl->new;
my $res = $furl->get('http://api.mixlr.com/users/blockfm?source=tcyradio');
die $res->status_line unless $res->is_success;
my $json = decode_json $res->content;
#warn Dumper $json;

#
# download streaming
#
my $rtmpdump = which('rtmpdump') || '/usr/local/bin/rtmpdump';
# rtmpdump --protocol 0 --host edge01.mixlr.com --port 443 --app live/production --playpath 8f9a21a9cf483c71ae3384ede467d59c --live --flv blockfm.flv
# or
# rtmpdump --rtmp rtmp://edge01.mixlr.com:443/live/production/8f9a21a9cf483c71ae3384ede467d59c --live --flv blockfm.flv
my $rtmp = $json->{broadcasts}[0]{streams}{rtmp} or die 'Now not broadcasting on block.fm';
my $cmd;
my $t = localtime;
if ($end_t) {
    my $seconds = $end_t->epoch - $t->epoch + 15;
    $cmd = "$rtmpdump --rtmp $json->{rtmp_server}:$rtmp->{port}.$rtmp->{path}/$rtmp->{stream_name} --live --stop $seconds --flv blockfm.flv";
} else {
    $cmd = "$rtmpdump --rtmp $json->{rtmp_server}:$rtmp->{port}.$rtmp->{path}/$rtmp->{stream_name} --live --flv blockfm.flv";
}
warn Dumper $cmd;
eval { `$cmd` };
warn $@ if $@;

#
# flv->mp3変換
#
my $date = $t->ymd('').$t->hms('');
my $ffmpeg = which('ffmpeg') || '/usr/local/bin/ffmpeg';
$cmd = "$ffmpeg -i blockfm.flv -vn -acodec copy blockfm_$date.m4a";
warn Dumper $cmd;
eval { `$cmd` };
warn $@ if $@;

#
# move dropbox
#
if ( $ENV{MODE} eq 'production' ) {
    move "blockfm_$date.m4a", "/home/viage/Dropbox/Private/BlockFM/blockfm_$date.m4a" or die $!;
} else {
    move "blockfm_$date.m4a", "/Users/viage/Dropbox/Private/BlockFM/blockfm_$date.m4a" or die $!;
}
__END__
