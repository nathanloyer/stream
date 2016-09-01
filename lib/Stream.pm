package Stream;

use Carp;

# package Stream
#
# Description
#	Syntactical sugar that lets you use perl's built-in array manipulators in
#	a syntax more like Streams in Java.
#
#	A brief comparison example:
#
#	Uing built-in perl:
#
#	my @results = map { $_->{c} } sort { $a->{c} cmp $b->{c} } grep { $_->{a} } @array;
#
#	Using Stream:
#
#	my @results = Stream->new(@array)
#		->grep(sub { $_->{a} })
#		->sort('$a->{c} cmp $b->{c}')
#		->map(sub { $_->{c} })
#		->get();
#
#	The advantages here are that it lets the developer read the logic left-to-right insted of backwards
#	as built-in perl would have you do. The built-in way is fine for small stuff, but if you need to string
#	together multiple calls to map, grep, sort, reverse, foreach, or join, the code can get complicated to
#	read through and think about.  This package was designed to minimize dependencies on other packages
#	in an attempt to keep the code speedy. This implementation makes no attempts to emulate Java's
#	stream parallelization.

sub new {
	my ($self, @basearray) = @_;

	my $stream = {
		stream => \@basearray,
	};

	return bless($stream);
}

sub get() {
	my ($self) = @_;
	return @{ $self->{stream} || [] };
}

# returns a Stream
sub map($$) {
	my ($self, $mapArgs) = @_;

	return $self->new(map { $mapArgs->() } $self->get());
}

# returns a Stream
sub grep($$) {
	my ($self, $grepArgs) = @_;

	my @results;

	if ($grepArgs) {
		my $reftype = ref($grepArgs);
		if ($reftype eq 'CODE') {
			@results = grep { $grepArgs->() } $self->get();
		}
		elsif (!$reftype) {
			@results = grep($grepArgs, $self->get());
		}
		elsif ($reftype eq 'Regexp') {
			@results = grep { $_ =~ $grepArgs } $self->get();
		}
		else {
			confess "wrong reftype $reftype";
		}
	}
	else {
		confess "no args";
	}

	return $self->new( @results );
}

# returns a Stream
sub sort($;$) {
	my ($self, $sortArgs) = @_;

	my @results;

	# two options
	# ...use $a and $b with a string passed in and stringy eval
	# ......stringy evals are non-performant and I don't like the user passing it as a string
	# ...or pass $a, $b as two arguments and make the user use $_[0] $_[1] or unpack
	# ......but I dont want them to unpack the variables or use $_[0] $_[1] either...
	# here's hoping I can figure out how to pass the convenience of $a and $b along
	if ($sortArgs) {
		my $reftype = ref($sortArgs);
		if (!$reftype) {
			@results = sort { eval $sortArgs } $self->get();
		}
		elsif ($reftype eq 'CODE') {
			@results = sort { $sortArgs->($a, $b) } $self->get()
		}
		else {
			confess "wrong reftype $reftype";
		}
	}
	
	return $self->new(@results);
}

# returns a Stream
sub reverse($) {
	my ($self) = @_;

	return $self->new(reverse $self->get());
}

# returns nothing
sub foreach($$) {
	my ($self, $foreachblock) = @_;

	foreach ($self->get()) {
		$foreachblock->();
	}
}

# returns a string
sub join($$) {
	my ($self, $joinblock) = @_;

	return join $joinblock, $self->get();
}

1;
