package MooseX::Getopt::ProcessedArgs;
use Moose;

has 'argv_copy'          => (is => 'ro', isa => 'ArrayRef');
has 'extra_argv'         => (is => 'ro', isa => 'ArrayRef');
has 'usage'              => (is => 'ro', isa => 'Maybe[Object]');
has 'constructor_params' => (is => 'ro', isa => 'HashRef');
has 'cli_params'         => (is => 'ro', isa => 'HashRef');

__PACKAGE__->meta->make_immutable();

1;

=pod

=encoding utf-8

=head1 NAME

MooseX::Getopt::ProcessedArgs - contains result of process_args

=head1 SYNOPSIS

  use My::App;

  my $pa = My::App->process_args(@params);
  my $argv_copy          = $pa->argv_copy();
  my $extra_argv         = $pa->extra_argv();
  my $usage              = $pa->usage();
  my $constructor_params = $pa->constructor_params();
  my $cli_params         = $pa->cli_params();

=head1 DESCRIPTION

This object contains the result of a L<MooseX::Getopt/process_args> call. It
contains all the information that L<MooseX::Getopt/new_with_options> uses
when calling new.

=head1 METHODS

=over

=item argv_copy

Reference to a copy of the original C<@ARGV> array as it originally existed
at the time of C<new_with_options>.

=item extra_arg

Arrayref of leftover C<@ARGV> elements that L<Getopt::Long> did not parse.

=item usage    

Contains the L<Getopt::Long::Descriptive::Usage> object (if
L<Getopt::Long::Descriptive> is used).

=item constructor_params

Parameters passed to process_args.

=item cli_param

Command-line parameters parsed out of C<@ARGV>.

=back

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

Brandon L. Black, E<lt>blblack@gmail.comE<gt>

Yuval Kogman, E<lt>nothingmuch@woobling.orgE<gt>

=head1 CONTRIBUTORS

Ryan D Johnson, E<lt>ryan@innerfence.comE<gt>

Drew Taylor, E<lt>drew@drewtaylor.comE<gt>

Tomas Doran, (t0m) C<< <bobtfish@bobtfish.net> >>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
