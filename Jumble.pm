# Copyright (c) 2001-2003 Douglas Sparling. All rights reserved. 
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Games::Jumble;

use strict;
use Carp;
use vars qw($VERSION);

$VERSION = '0.05';

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

sub word_length_allow {
    my($self) = shift;
    if(@_) { 
        my %allowed;
        foreach my $allow( @_ ) {
            $allowed{$allow}++; 
        }
        $self->{word_length_allow} = \%allowed;
    }
    return $self->{word_length_allow};
}

sub word_length_deny {
    my($self) = shift;
    if(@_) { 
        my %denied;
        foreach my $deny( @_ ) {
            $denied{$deny}++; 
        }
        $self->{word_length_deny} = \%denied;
    }
    return $self->{word_length_deny};
}


sub create_jumble {

    my($self) = shift;
    my @jumble;
    my @jumble_out;
    my %words;

    # Read dictionary and get words
    open FH, $self->{dict} or croak "Cannot open $self->{dict}: $!";
    while(<FH>) {
        chomp;
        my $word = lc $_;             # Lower case all words
        next if $word !~ /^[a-z]+$/;  # Letters only

        # Sort letters so we can check for unique "unjumble"
        my @temp_array = split(//, $word);
        @temp_array = sort(@temp_array);
        my $key = join('', @temp_array);

        # Check for word length allow
        if( $self->{word_length_allow} ) {
            my $allowed_ref = $self->{word_length_allow};
            my %allowed = %$allowed_ref;
            next unless exists $allowed{length $_};
        }

        # Check for word length deny 
        if( $self->{word_length_deny} ) {
            my $denied_ref = $self->{word_length_deny};
            my %denied = %$denied_ref;
            next if exists $denied{length $_};
        }

        # perlreftut is your friend
        push @{$words{$key}}, $_;
       
    }
    close FH;

    # Get words that only "unjumble" one way
    my @unique_words;

    foreach my $word (keys %words) {
        my $length = @{$words{$word}};
        if ($length == 1) {
            push @unique_words, @{$words{$word}};
        }
    }
    @unique_words = sort @unique_words;


    # Get random words for jumble
    for (1..$self->{num_words}) {

            my $el = $unique_words[rand @unique_words];
            redo if $el =~ /(\w)\1+/;  # No words like ii, ooo or aaa
            push(@jumble, $el);
    }

    # Scramble the words
    foreach my $word (@jumble) {
        my $jumbled_word = $self->jumble_word($word);
        push @jumble_out, "$jumbled_word ($word)";
    }

    return @jumble_out;


}

sub jumble_word {

    my($self) = shift;
    my $word;

    if(@_) { 
        $word = shift;
    } else {
        $word = undef;
        return $word;
    }

    my @temp_array = split(//, $word);

    # From the camel
    my $array = \@temp_array;
    my $jumbled_word = $word;

    # Make sure we actually scramble the word
    while( $jumbled_word eq $word ) {
        for (my $i = @$array; --$i; ) {
            my $j = int rand ($i+1);
            next if $i == $j;
            @$array[$i,$j] = @$array[$j,$i];
        }
        $jumbled_word = join('', @temp_array);
    }

    return $jumbled_word;

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

Games::Jumble - Create and solve Jumble word puzzles.

=head1 SYNOPSIS

  use Games::Jumble;

  my $jumble = Games::Jumble->new();
  $jumble->num_words(6);
  $jumble->dict('/home/doug/crossword_dict/unixdict.txt');

  my @jumble = $jumble->create_jumble;

  foreach my $word (@jumble) {
    print "$word\n";
  }

  # Solve jumbled word
  my @good_words = $jumble->solve_word('rta');

  if (@good_words) {
    foreach my $good_word (@good_words) {
      print "$good_word\n";
    }
  } else {
    print "No words found\n";
  }

  # Create jumbled word
  my $word = 'camel';
  my $jumbled_word = $jumble->jumble_word($word);

  print "$jumbled_word ($word)\n";


=head1 DESCRIPTION

C<Games::Jumble> is used to create and solve Jumble word puzzles.

Currently C<Games::Jumble> will create random five- and six-letter
jumbled words from dictionary. Future versions of C<Games::Jumble> will
allow user to create custom jumbles by using a user defined word file
with words of any length.
Individual words of any length may be jumbled by using the 
C<jumble_word()> method.

Default number of words is 5.
Default dictionary is '/usr/dict/words'.
Dictionary file must contain one word per line.

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

=item word_length_allow ( LENGTH1 [, LENGTH2, LENGTH3,...] )

If C<LENGTHx> is(are) passed, this method will set word lengths 
that will be used when creating jumble.  
The default setting will use all word lengths. 
A hash containing all allow values is returned. 
Note: Allow all is designated by empty hash.

=item word_length_deny ( LENGTH1 [, LENGTH2, LENGTH3,...] )

If C<LENGTHx> is(are) passed, this method will set word lengths 
that will be skipped when creating jumble.
The default setting will not skip any word lengths. 
A hash containing all deny values is returned. 
Note: Deny none is designated by empty hash.

=item create_jumble ( )

This method creates the jumble.
Returns list containing words (normal and jumbled).

=item solve_word ( WORD )

This method will solve a jumbled word.
Returns list of solved words.

=item jumble_word ( WORD )

This method will create a jumbled word.
Returns scalar containing jumbled word.

=back

=head1 CREDITS

Tim Maher for pointing out some outdated documentation in the Synopsis.

=head1 AUTHOR

Doug Sparling, doug@dougsparling.com

=head1 COPYRIGHT

Copyright (c) 2001-2003 Douglas Sparling. All rights reserved. This program is 
free software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut
