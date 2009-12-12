
package MooseX::Getopt;
use Moose::Role;

use Getopt::Long;

use MooseX::Getopt::OptionTypeMap;
use MooseX::Getopt::Meta::Attribute;

our $VERSION   = '0.03';
our $AUTHORITY = 'cpan:STEVAN';

has ARGV => (is => 'rw', isa => 'ArrayRef');

sub new_with_options {
    my ($class, %params) = @_;

    my (@options, %name_to_init_arg);
    foreach my $attr ($class->meta->compute_all_applicable_attributes) {
        my $name = $attr->name;

        my $aliases;

        if ($attr->isa('MooseX::Getopt::Meta::Attribute')) {
            $name = $attr->cmd_flag if $attr->has_cmd_flag;
            $aliases = $attr->cmd_aliases if $attr->has_cmd_aliases;
        }
        else {
            next if $name =~ /^_/;
        }
        
        $name_to_init_arg{$name} = $attr->init_arg;        
        
        my $opt_string = $aliases
            ? join(q{|}, $name, @$aliases)
            : $name;

        if ($attr->has_type_constraint) {
            my $type_name = $attr->type_constraint->name;
            if (MooseX::Getopt::OptionTypeMap->has_option_type($type_name)) {                   
                $opt_string .= MooseX::Getopt::OptionTypeMap->get_option_type($type_name);
            }
        }
        
        push @options => $opt_string;
    }

    my $saved_argv = [ @ARGV ];
    my %options;
    
    GetOptions(\%options, @options);
    
    #use Data::Dumper;
    #warn Dumper \@options;
    #warn Dumper \%name_to_init_arg;
    #warn Dumper \%options;
    
    $class->new(
        ARGV => $saved_argv,
        %params, 
        map { 
            $name_to_init_arg{$_} => $options{$_} 
        } keys %options,
    );
}

no Moose::Role; 1;

__END__

=pod

=head1 NAME

MooseX::Getopt - A Moose role for processing command line options

=head1 SYNOPSIS

  ## In your class 
  package My::App;
  use Moose;
  
  with 'MooseX::Getopt';
  
  has 'out' => (is => 'rw', isa => 'Str', required => 1);
  has 'in'  => (is => 'rw', isa => 'Str', required => 1);
  
  # ... rest of the class here
  
  ## in your script
  #!/usr/bin/perl
  
  use My::App;
  
  my $app = My::App->new_with_options();
  # ... rest of the script here
  
  ## on the command line
  % perl my_app_script.pl -in file.input -out file.dump

=head1 DESCRIPTION

This is a role which provides an alternate constructor for creating 
objects using parameters passed in from the command line. 

This module attempts to DWIM as much as possible with the command line 
params by introspecting your class's attributes. It will use the name 
of your attribute as the command line option, and if there is a type 
constraint defined, it will configure Getopt::Long to handle the option
accordingly.

You can use the attribute metaclass L<MooseX::Getopt::Meta::Attribute>
to get non-default commandline option names and aliases.

By default, attributes which start with an underscore are not given
commandline argument support, unless the attribute's metaclass is set
to L<MooseX::Getopt::Meta::Attribute>. If you don't want you accessors
to have the leading underscore in thier name, you can do this:

  # for read/write attributes
  has '_foo' => (accessor => 'foo', ...);
  
  # or for read-only attributes
  has '_bar' => (reader => 'bar', ...);  

This will mean that Getopt will not handle a --foo param, but your 
code can still call the C<foo> method. 

=head2 Supported Type Constraints

=over 4

=item I<Bool>

A I<Bool> type constraint is set up as a boolean option with 
Getopt::Long. So that this attribute description:

  has 'verbose' => (is => 'rw', isa => 'Bool');

would translate into C<verbose!> as a Getopt::Long option descriptor, 
which would enable the following command line options:

  % my_script.pl --verbose
  % my_script.pl --noverbose  
  
=item I<Int>, I<Float>, I<Str>

These type constraints are set up as properly typed options with 
Getopt::Long, using the C<=i>, C<=f> and C<=s> modifiers as appropriate.

=item I<ArrayRef>

An I<ArrayRef> type constraint is set up as a multiple value option
in Getopt::Long. So that this attribute description:

  has 'include' => (
      is      => 'rw', 
      isa     => 'ArrayRef', 
      default => sub { [] }
  );

would translate into C<includes=s@> as a Getopt::Long option descriptor, 
which would enable the following command line options:

  % my_script.pl --include /usr/lib --include /usr/local/lib

=item I<HashRef>

A I<HashRef> type constraint is set up as a hash value option
in Getopt::Long. So that this attribute description:

  has 'define' => (
      is      => 'rw', 
      isa     => 'HashRef', 
      default => sub { {} }
  );

would translate into C<define=s%> as a Getopt::Long option descriptor, 
which would enable the following command line options:

  % my_script.pl --define os=linux --define vendor=debian

=back

=head2 Custom Type Constraints

It is possible to create custom type constraint to option spec 
mappings if you need them. The process is fairly simple (but a
little verbose maybe). First you create a custom subtype, like 
so:

  subtype 'ArrayOfInts'
      => as 'ArrayRef'
      => where { scalar (grep { looks_like_number($_) } @$_)  };

Then you register the mapping, like so:

  MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
      'ArrayOfInts' => '=i@'
  );

Now any attribute declarations using this type constraint will 
get the custom option spec. So that, this:

  has 'nums' => (
      is      => 'ro',
      isa     => 'ArrayOfInts',
      default => sub { [0] }
  );

Will translate to the following on the command line:

  % my_script.pl --nums 5 --nums 88 --nums 199

This example is fairly trivial, but more complex validations are 
easily possible with a little creativity. The trick is balancing
the type constraint validations with the Getopt::Long validations.

Better examples are certainly welcome :)

=head1 METHODS

=over 4

=item B<new_with_options (%params)>

This method will take a set of default C<%params> and then collect 
params from the command line (possibly overriding those in C<%params>)
and then return a newly constructed object.

=item B<ARGV>

This accessor contains a reference to a copy of the C<@ARGV> array
which was copied before L<Getopt::Long> mangled it, in case you want
to see your original options.

=item B<meta>

This returns the role meta object.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

Brandon L. Black, E<lt>blblack@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
