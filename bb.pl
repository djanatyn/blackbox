#!/usr/bin/perl
use strict;
use warnings;
use v5.10;
use Template;
use IO::File;
use autodie;

package Entry;

sub new {
    my ($pkg, $file) = @_;
    my $fh = IO::File->new($file, 'r');

    my $title = <$fh>;
    my $date = <$fh>;
    my $tag = <$fh>;
    my $text = join('', <$fh>);

    $file =~ s/.+input\///;
    chomp($tag);

    my $self = {
	title => $title,
        date  => $date,
	tag   => $tag,
	text  => $text,
	name  => $file,
    };
    bless $self, $pkg;
    return $self;
}

package main;

my $tt = Template->new(
{
    INCLUDE_PATH => './templates',
});

my @filenames = glob './input/*';
my @entries = map { Entry->new($_) } @filenames;

# generate a list of tags, with no duplicates
my @tags;
for my $entry (@entries) { push @tags, $$entry{tag}; }
my %seen = ();
my @taglist = grep { ! $seen{ $_ }++ } @tags;
# generate the links
my $links;
for my $tag (@taglist) { $links .= "<li><a href='$tag.html'>$tag</a></li>\n"; }
# create a page for each tag
for my $tag (@taglist) {
    my $content;
    for my $entry (@entries) {
	if ($$entry{tag} eq $tag) { $content .= "<h2><a href='$$entry{name}.html'>$$entry{title}</a> - $$entry{date}</h2><hr />$$entry{text}<br />\n"; }
    };
    
    my $vars = {
	page    => $tag,
	content => $content,
	links   => $links,
    };
    $tt->process('index.tt', $vars, "./output/$tag.html");
}

my $index;
for my $entry (@entries)
{
    my $content  = "<h2>$$entry{title} - $$entry{date}</h2><hr />$$entry{text}<br />\n";
    $index  .= "<h2><a href='$$entry{name}.html'>$$entry{title}</a> - $$entry{date}</h2><hr />$$entry{text}<br />\n";
    my $page = "$$entry{title}";

    my $vars = {
	page    => $page,
	content => $content,
	links   => $links,
    };

    $tt->process('index.tt', $vars, "./output/$$entry{name}.html");
}

my $vars = {
    page    => 'home',
    content => $index,
    links   => $links,
};

$tt->process('index.tt', $vars, "./output/index.html");
