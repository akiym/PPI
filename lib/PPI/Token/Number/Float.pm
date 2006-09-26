package PPI::Token::Number::Float;

=pod

=head1 NAME

PPI::Token::Number::Float - Token class for a floating-point number

=head1 SYNOPSIS

  $n = 1.234;
  $n = 1.0e-2;  # not yet supported
  $n = 1e+2;  # not yet supported

=head1 INHERITANCE

  PPI::Token::Number::Float
  isa PPI::Token::Number
      isa PPI::Token
          isa PPI::Element

=head1 DESCRIPTION

The C<PPI::Token::Number::Float> class is used for tokens that
represent floating point numbers.  A float is identified by either an
decimal point or exponential notation (the C<e> or C<E>).

=head1 METHODS

=cut

use strict;
use base 'PPI::Token::Number';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '1.118';
}

=head2 base

Returns the base for the number: 10.

=cut

sub base {
	return 10;
}


#####################################################################
# Tokenizer Methods

sub __TOKENIZER__on_char {
	my $class = shift;
	my $t     = shift;
	my $char  = substr( $t->{line}, $t->{line_cursor}, 1 );

	# Allow underscores straight through
	return 1 if $char eq '_';

	# Allow digits
	return 1 if $char =~ /\d/o;

	# Is there a second decimal point?  Then version string or '..' operator
	if ( $char eq '.' ) {
		if ( $t->{token}->{content} =~ /\.$/ ) {
			# We have a .., which is an operator.
			# Take the . off the end of the token..
			# and finish it, then make the .. operator.
			chop $t->{token}->{content};
                        $t->_set_token_class( 'Number' );
			$t->_new_token('Operator', '..') or return undef;
			return 0;
		} elsif ( $t->{token}->{content} !~ /_/ ) {
			# Underscore means not a Version
			return $t->_set_token_class( 'Number::Version' ) ? 1 : undef;
		}
	}
	# TODO: else ($char eq 'e' || $char eq 'E')

	# Doesn't fit a special case, or is after the end of the token
	# End of token.
	$t->_finalize_token->__TOKENIZER__on_char( $t );
}

1;

=pod

=head1 SUPPORT

See the L<support section|PPI/SUPPORT> in the main module.

=head1 AUTHOR

Chris Dolan E<lt>cdolank@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2006 Chris Dolan.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
