#!/usr/bin/perl -w
use strict;
use Games::Jumble;

my $jumble = Games::Jumble->new;
$jumble->dict('/home/doug/crossword_dict/unixdict.txt');

my $word = 'camel';
my $jumbled_word = $jumble->jumble_word($word);

print "$jumbled_word ($word)\n";
