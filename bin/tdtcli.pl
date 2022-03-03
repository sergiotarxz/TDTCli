#!/usr/bin/env perl

use v5.30.0;

use strict;
use warnings;

use Data::Dumper;
use Term::ReadLine;
use FileHandle;

use Mojo::UserAgent;
use JSON;

binmode STDOUT, ':utf8';

my $ua           = Mojo::UserAgent->new;
my $tdt_channels = decode_json(
    $ua->get('https://www.tdtchannels.com/lists/tv.json')->result->body );
my $epg       = $tdt_channels->{epg}{json};
my $countries = $tdt_channels->{countries};

my $selected_country;
my $selected_ambit;

my $term = Term::ReadLine->new('tdtcli');

while ( defined( my $line = $term->readline('~> ') ) ) {
    proccess_line($line);
    $term->addhistory($line);

    if ( defined $selected_country ) {
        say 'Selected country: ' . $countries->[$selected_country]{name};
    }
    if ( defined $selected_ambit ) {
        say 'Selected ambit: '
          . $countries->[$selected_country]{ambits}[$selected_ambit]{name};
    }
}

sub proccess_line {
    my $line = shift;
    return unless defined $line;
    my @line = split /\s+/, $line;
    return unless defined $line[0];
    my $command = shift @line;
    show_countries()          if $command eq 'countries';
    select_country( [@line] ) if $command eq 'select_country';
    show_ambits()             if $command eq 'ambits';
    select_ambit( [@line] )   if $command eq 'select_ambit';
    show_channels()           if $command eq 'channels';
    select_channel( [@line] ) if $command eq 'select_channel';
}

sub select_channel {
    my $arguments = shift;
    say('You must pass a channel number.'), return
      unless exists $arguments->[0];
    my $channel = $arguments->[0];
    return unless $channel =~ /^\d+$/;
    say('You must first select a ambit with /select_ambit'),
      return undef $selected_ambit
      unless defined $selected_ambit;
    my $ambits                  = $countries->[$selected_country]{ambits};
    my $channels                = $ambits->[$selected_ambit]{channels};
    my $current_channel_options = $channels->[$channel]{options};
    say('This channel doesn\'t provides an option to see online.'), return
      unless scalar @$current_channel_options;

    if (fork) {
        return;
    }
    close(STDOUT);
    close(STDERR);
    close(STDIN);
    system 'mpv', $current_channel_options->[0]{url};
    exit;
}

sub show_channels {
    say('You must first select a ambit with /select_ambit'), return
      unless defined $selected_ambit;
    my $names =
      [ map { $_->{name} }
          $countries->[$selected_country]{ambits}[$selected_ambit]{channels}
          ->@* ];
    my $i = 0;
    for my $name (@$names) {
        say "$i : $name";
        $i++;
    }
}

sub select_ambit {
    my $arguments = shift;
    say('You must first select a country with /select_country'), return
      unless defined $selected_country;
    say('No ambit passed see /ambits'), return
      unless defined $arguments->[0];
    my $ambit = $arguments->[0];
    return unless $ambit =~ /^\d+$/;
    say('Such ambit doesn\'t exists see /ambits'), return
      unless exists $countries->[$selected_country]{ambits}[$ambit];
    $selected_ambit = $ambit;
}

sub select_country {
    my $arguments = shift;
    say('No country passed see /countries'), return
      unless defined $arguments->[0];
    my $country = $arguments->[0];
    return unless $country =~ /^\d+$/;
    say('Such country doesn\'t exists see /countries'), return
      if !exists $countries->[$country];
    $selected_country = $country;
    undef $selected_ambit;
}

sub show_countries {
    my $names = [ map { $_->{name} } @$countries ];
    my $i     = 0;
    for my $name (@$names) {
        say "$i : $name";
        $i++;
    }
}

sub show_ambits {
    say('You must set first a country'), return
      if !defined $selected_country;
    my $names =
      [ map { $_->{name} } $countries->[$selected_country]{ambits}->@* ];
    my $i = 0;
    for my $name (@$names) {
        say "$i : $name";
        $i++;
    }
}
