# Copyright (c) 2001 Douglas Sparling. All rights reserved. This program is free
# software; you can redistribute it and/or modify it under the same terms
# as Perl itself.

package Games::Jumble;

use strict;
use Carp;
use vars qw($VERSION);

$VERSION = '0.01';

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    if (defined $_[0]) {
        $self->{num_words} = $_[0];
    } else {
        $self->{num_words} = 5;
    }
    $self->{dict}   = '/usr/dict/words';

    bless($self, $class);
    return $self;
}

sub num_words {
    my($self) = shift;
    if(@_) { $self->{num_words} = shift }
    return $self->{num_words};
}

sub dict {
    my($self) = shift;
    if(@_) { $self->{dict} = shift }
    return $self->{dict};
}

sub create_puzzle {

    my($self) = shift;
    my @jumble;
    my @jumble_out;
    my %five_letter_words;
    my %six_letter_words;

    # Read dictionary and get five- and six-letter words
    open FH, $self->{dict} or croak "Cannot open $self->{dict}: $!";
    while(<FH>) {
        chomp;
        my $word = lc $_;             # Lower case all words
        next if $word !~ /^[a-z]+$/;  # Letters only

        # Sort letters so we can check for unique "unjumble"
        my @temp_array = split(//, $word);
        @temp_array = sort(@temp_array);
        my $key = join('', @temp_array); #TEST

        push @{$five_letter_words{$key}}, $_ if length $_ == 5;
        push @{$six_letter_words{$key}}, $_  if length $_ == 6;
       
    }
    close FH;

    # Get words that only "unjumble" one way
    my @unique_five_letter_words;
    my @unique_six_letter_words;

    foreach my $word (keys %five_letter_words) {
        my $length = @{$five_letter_words{$word}};
        if ($length == 1) {
            push @unique_five_letter_words, @{$five_letter_words{$word}};
        }
    }
    @unique_five_letter_words = sort @unique_five_letter_words;

    foreach my $word (keys %six_letter_words) {
        my $length = @{$six_letter_words{$word}};
        if ($length == 1) {
            push @unique_six_letter_words, @{$six_letter_words{$word}};
        }
    }

    # Get random words for jumble
    for (1..$self->{num_words}) {
        my $length = int(rand(7));
        until ($length == 5 or $length == 6) {
            $length = int(rand(7));
        }

        # Randomly select five- and six-character words.
        if ($length == 5) {
            my $el = $unique_five_letter_words[rand @unique_five_letter_words];
            push(@jumble, $el);
        } elsif ($length == 6) {
            my $el = $unique_six_letter_words[rand @unique_six_letter_words];
            push(@jumble, $el);
        }
    }

    # Scramble the words
    foreach my $word (@jumble) {
        my @temp_array = split(//, $word);
        # From the camel
        my $array = \@temp_array;
        for (my $i = @$array; --$i; ) {
            my $j = int rand ($i+1);
            next if $i == $j;
            @$array[$i,$j] = @$array[$j,$i];
        }
        my $scrambled_word = join('', @temp_array);
        push @jumble_out, "$scrambled_word ($word)";
    }

    return @jumble_out;


}

sub solve_word {

    my($self) = shift;
    my @good_words;
   
    if(@_) { 
        $self->{word} = shift;
    } else {
        croak "No word to solve\n";
    }

    my @temp_array = split(//, $self->{word});
    @temp_array = sort(@temp_array);
    $self->{key} = join('', @temp_array);

    # Read dictionary and get five- and six-letter words
    open FH, $self->{dict} or croak "Cannot open $self->{dict}: $!";
    while(<FH>) {
        chomp;
        my $word = lc $_;             # Lower case all words
        next if $word !~ /^[a-z]+$/;  # Letters only
        next if length($word) ne length($self->{word});

        # Sort letters so we can check for unique "unjumble"
        my @temp_array = split(//, $word);
        @temp_array = sort(@temp_array);
        my $key = join('', @temp_array);

        if ($self->{key} eq $key) {
            push @good_words, $word;
        }
       
    }
    close FH;

    return @good_words;
}

1;

__END__

=head1 NAME

Games::Jumble - Create Jumble word puzzles.

=head1 SYNOPSIS

  use Games::Jumble;

  my $jumble = Games::Jumble->new();
  $jumble->num_words(6);
  $jumble->dict('/home/doug/crossword_dict/unixdict.txt');

  my @jumble = $jumble->create_puzzle;

  foreach my $word (@jumble) {
    print "$word\n";
  }

  my @good_words = $jumble->solve_word('rta');

  if (@good_words) {
    foreach my $good_word (@good_words) {
      print "$good_word\n";
    }
  } else {
    print "No words found\n";
  }

=head1 DESCRIPTION

C<Games::Jumble> is used to create and solve Jumble word puzzles.

Default number of words is 5.
Default dictionary is '/usr/dict/words'.
Use your own dictionary or word file to create custom puzzles.
Dictionary or word file must contain one word per line.

=head1 OVERVIEW

=over 4

=item TODO

=back

=head1 CONSTRUCTOR

=over 4

=item new ( [NUMBER_OF_WORDS] );

This is the constructor for a new Games::Jumble object. 
If C<NUMBER_OF_WORDS> is passed, this method will set the number of words for the puzzle.

=back

=head1 METHODS

=over 4

=item num_words ( NUMBER_OF_WORDS )

If C<NUMBER_OF_WORDS> is passed, this method will set the number of words for the puzzle.
The default value is 5. 
The number of words is returned. 

=item dict ( PATH_TO_DICT )

If C<PATH_TO_DICT> is passed, this method will set the path to 
the dictionary file. Dictionary file must have one word per line.
The default value is /usr/dict/words. 
The path to the dictionary file is returned. 

=item create_puzzle ( )

Method that creates the jumble.
Returns array containing words (normal and jumbled).

=item solve_word ( WORD )

This method will solve a jumbled word.
Returns array containing valid words.

=back

=head1 AUTHOR

Doug Sparling, doug@dougsparling.com

=head1 COPYRIGHT

Copyright (c) 2001 Douglas Sparling. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut
