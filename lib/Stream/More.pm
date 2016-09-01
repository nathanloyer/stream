package Stream::More;

use parent 'Stream';

use Carp;
# use List::Util;
# use List::Util qw( first max maxstr min minstr reduce shuffle sum );

sub new {
	my ($self, @basearray) = @_;

	my $stream = {
		stream => \@basearray,
	};

	return bless($stream);
}


sub AUTOLOAD {
	my $fullsubname = $AUTOLOAD;
	my ($self, $args) = @_;

	require List::Util;

	if (my ($subname) = $fullsubname =~ m/^.*::(any|all|none|notall|first)$/) {
		my $newsubname = "List::Util::$subname";
		if (ref($args) eq 'CODE') {
			return &$newsubname(sub { $args->() }, $self->get());
		}
		else {
			confess "argument must be a coderef";
		}
	}
	elsif (my ($subname) = $fullsubname =~ m/.*::(max|maxstr|min|minstr|product|sum|sum0)/) {
		if (!$args) {
			return &$subname($self->get());
		}
		else {
			confess "don't supply any arguments";
		}
	}
	else {
		confess "$fullsubname is not a valid method";
	}

	return;
}

# # these are nice, but should be excluded to limit dependencies

# sub dump($) {
# 	my ($self) = @_;

# 	require Data::Dumper;
# 	return Data::Dumper::Dumper([ $self->get() ]);
# }

# sub yaml($) {
# 	my ($self) = @_;

# 	require YAML::Any;
# 	return YAML::Any::Dump([ $self->get() ]);
# }

# sub json($) {
# 	my ($self) = @_;

# 	require JSON;
# 	return JSON->new->utf8->encode([ $self->get() ]);
# }

1;
