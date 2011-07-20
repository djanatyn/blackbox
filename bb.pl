#!/usr/bin/perl
use strict;
use warnings;
use v5.10;
use Template;
use IO::File;
use autodie;

my $tt = Template->new(
{
    INCLUDE_PATH => './templates',
});

# sub parseFile($filename)
# returns a list of title, date, and text
sub parseFile {
    my ($filename) = @_;
    my %data;

    my $fh = IO::File->new($filename, 'r');
    $data{'title'} = <$fh>;
    $data{'date'} = <$fh>;
    $data{'text'} = join('', <$fh>);

    return $data{'title'}, $data{'date'}, $data{'text'};
}

my @filenames = glob './input/*';
#my %files = map { $_ => parseFile($_) } @filenames;

my $indexPosts;
my $links;
for my $file (@filenames[0..2]) {
    my ($title, $date, $text) = parseFile($file);
    my $name = $file;
    $name =~ s/.+input\///;
    $indexPosts .= "<h2>$title - $date</h2><hr />$text<br />\n";
    $links .= "<li><a href='$name.html'>$name</a></li>";
}

for my $file (@filenames) {
    my ($title, $date, $text) = parseFile($file);
    my $localvars = {
	content => "<h2>$title - $date</h2><hr />$text<br />\n",
	links => $links,
    };
    $file =~ s/.+input\///;
    $tt->process('index.tt', $localvars, "./output/$file.html");
}
	
my $vars = {
    content => $indexPosts,
    links => $links,
};

$tt->process('index.tt', $vars, './output/index.html');

