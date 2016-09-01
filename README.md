# Stream

## Description

Syntactical sugar that lets you use perl's built-in array manipulators in a syntax similar to Streams in Java.

## A brief example:

Using built-in perl:

`my @results = map { $_->{c} } sort { $a->{c} cmp $b->{c} } grep { $_->{a} } @array;`

Using Stream:

`my @results = Stream->new(@array)
	->grep(sub { $_->{a} })
	->sort('$a->{c} cmp $b->{c}')
	->map(sub { $_->{c} })
	->get();`

The advantages here are that it lets the developer read the logic left-to-right instead of backwards
as built-in perl would have you do. The built-in way is fine for small stuff, but if you need to string
together multiple calls to map, grep, sort, reverse, foreach, or join, the code can get complicated to
read through and think about. This package was designed to minimize dependencies on other packages
in an attempt to keep the code speedy. However, when run at a large scale, it is likely going to be
significantly slower than using the built-in syntax due to OOP and function overhead. This implementation
makes no attempts to emulate Java's stream parallelization, but maybe such things can be added later.
