#!/usr/bin/perl -w
use strict;
use Games::Jumble;

my $jumble = Games::Jumble->new;
$jumble->num_words(6);
$jumble->word_length_allow(5,6);
$jumble->dict('/home/doug/crossword_dict/unixdict.txt');

my @jumble = $jumble->create_jumble;

foreach my $word (@jumble) {
    print "$word\n";
}
