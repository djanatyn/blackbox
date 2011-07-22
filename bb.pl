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

my $index;
for my $entry (@entries)
{
    my $content  = "<h2>$$entry{title} - $$entry{date}</h2><hr />$$entry{text}<br />\n";
    $index  .= "<h2><a href='$$entry{name}.html'>$$entry{title}</a> - $$entry{date}</h2><hr />$$entry{text}<br />\n";
    my $page = "$$entry{title}";
    my $links = '';

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
    links   => '',
};

$tt->process('index.tt', $vars, "./output/index.html");
