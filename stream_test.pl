#!/usr/local/bin/perl

use Stream;
use Data::Dumper;
use feature 'signatures';

my @things = (
	{
		1 => 2,
		3 => 4,
	},
	{
		a => 'b',
		c => 'd',
	},
	{
		1 => 6,
		3 => 7,
	},
	{
		a => 'q',
		c => 'w',
	},
	{
		1 => 8,
		3 => 9,
	},
	{
		a => 'e',
		c => 'r',
	},
);

my $stream = new Stream(@things);

print Dumper('stream', $stream);

my $filtered = $stream->grep(sub { $_->{a} });

print Dumper('filtered', $filtered);

my $sorted = $filtered->sort(sub { $_[0]->{c} cmp $_[1]->{c} });

print Dumper('sorted1', $sorted);

$sorted = $filtered->sort('$a->{c} cmp $b->{c}');

print Dumper('sorted2', $sorted);

my $mapped = $sorted->map(sub { $_->{c} });

print Dumper('mapped', $mapped);


my $exprgrep = $mapped->grep('d');

print Dumper('exprgrep', $exprgrep);


my $regexgrep = $mapped->grep(sub { /d/ });

print Dumper('regexgrep', $regexgrep);


$regexgrep->foreach(sub { print "foreach: $_\n"; });


print Dumper('original stream', $stream);

# ok that was testing, here's the cool stuff

print Dumper('strung together', $stream->grep(sub { $_->{a} })->sort('$a->{c} cmp $b->{c}')->map(sub { $_->{c} }));

print Dumper('strung and getting just data', [ $stream->grep(sub { $_->{a} })->sort('$a->{c} cmp $b->{c}')->map(sub { $_->{c} })->get() ]);


# print "strung together & data dumper\n", 
# 	$stream->grep(sub { $_->{a} })
# 		->sort('$a->{c} cmp $b->{c}')
# 		->map(sub { $_->{c} })
# 		->dump();
# print "strung together & yaml dumper\n",
# 	$stream->grep(sub { $_->{a} })
# 		->sort('$a->{c} cmp $b->{c}')
# 		->map(sub { $_->{c} })
# 		->yaml();
# print "strung together & json dumper\n", $stream->grep(sub { $_->{a} })->sort('$a->{c} cmp $b->{c}')->map(sub { $_->{c} })->json(), "\n";

use Stream::More;

my $streammore = new Stream::More(@things)
	->grep(sub { $_->{1} })
	->sort(sub ($a, $b) { $a->{1} cmp $b->{1} })
	->map(sub { $_->{1} });


print Dumper('more 1', $streammore->any(sub { $_ == 2 }));

print Dumper('more undef', $streammore->any(sub { $_ == 1 }));
print Dumper('all undef', $streammore->all(sub { $_ == 2 }));
print Dumper('all 1', $streammore->all(sub { $_ }));


exit();

