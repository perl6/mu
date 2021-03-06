
use KindaPerl6::Runtime::Perl6::Scope;
use KindaPerl6::Runtime::Perl6::GlobalScope;

say '1..4';

my $env = GlobalScope.new( vars => {} );

say 'ok 1 - load GlobalScope.pm';

$env.create( '$abc' );
$env.create( '$def' );

$env.LOOKUP( '$abc' ) = 123;

if $env.LOOKUP( '$abc' ) == 123 {
    say 'ok 2 - lookup';
}
else {
    say 'not ok 2';
};

my $s2 = $env.inner;

if $s2.LOOKUP( '$abc' ) == 123 {
    say 'ok 3 - inner';
}
else {
    say 'not ok 3';
};

if $s2{'$abc'} == 123 {
    say 'ok 4 - Scope behaves like Hash';
}
else {
    say 'not ok 4';
};


=begin

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end

