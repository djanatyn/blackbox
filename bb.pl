#!/usr/bin/perl -w
use strict;
use Template;

my $tt = Template->new(
{
    INCLUDE_PATH => './templates',
});

my $title = 'a blog post';
my $content;

my @filenames = glob './input/*';
@filenames = sort @filenames;

my @categories;

sub getInfo {
    my ($filename) = @_;
    my @info;

    open(TEXT, "$filename") or die "can't open $filename";
    $info[0] = <TEXT>; $info[1] = <TEXT>; my $text;
    my @lines = <TEXT>; close TEXT;

    for $_ (@lines) { $info[2] .= $_; }

    return @info;
}

my $firstThree;
for my $three (@filenames[0..2]) {
    my @info = getInfo($three);
    $firstThree .= "<h2>$info[0] - $info[1]</h2><hr />$info[2]<br />\n";
}

my $links;
for my $file (@filenames) { my @info = getInfo($file); push @categories, $info[0]; }

for my $category (@categories) { $links .= "<li><a href='$category'>$category</a></li>\n"; }

my $vars = {
    content => "$firstThree",
    links => "$links",
};

$tt->process('index.tt', $vars, './output/index.html');
