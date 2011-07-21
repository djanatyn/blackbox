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
    $data{'tag'} = <$fh>;
    $data{'text'} = join('', <$fh>);

    return $data{'title'}, $data{'date'}, $data{'tag'}, $data{'text'};
}

my @filenames = glob './input/*';
#my %files = map { $_ => parseFile($_) } @filenames;

my $indexPosts;
my $links;
my %tags;
for my $file (@filenames[0..2]) {
    my ($title, $date, $tag, $text) = parseFile($file);
    my $name = $file;
    $name =~ s/.+input\///;
    $indexPosts .= "<h2><a href='$name.html'>$title</a> - $date</h2><hr />$text<br />\n";
}

for my $file (@filenames) {
    my ($title, $date, $tag, $text) = parseFile($file);
    chomp($tag);
    
    my $localvars = {
	page => $title,
	content => "<h2>$title - $date</h2><hr />$text<br />\n",
	links => $links,
    };
    $file =~ s/.+input\///;
    $tags{$tag} .= "<h2>$title - $date</h2><hr />$text<br />\n";
    $tt->process('index.tt', $localvars, "./output/$file.html");
}
while ((my $tag, my $content) = each %tags) {
    $links .= "<li><a href='$tag.html'>$tag</a></li>\n"
}

while ((my $tag, my $content) = each %tags) {
    my $vars = {
	page => $tag,
	content => $content,
	links => $links,
    };
    $tt->process('index.tt', $vars, "./output/$tag.html");
}

my $vars = {
    page => "home",
    content => $indexPosts,
    links => $links,
};

$tt->process('index.tt', $vars, './output/index.html');

