#!/usr/bin/perl -w
use strict;
use Template;

my $tt = Template->new(
{
    INCLUDE_PATH => './templates',
});

# sub returnHash
# when given a filename, this subroutine creates a hash for that file and fills 
sub returnHash {
    my ($self) = @_; my %self;

    open(TEXT, "$self") or die "can't open $self";
    ($self{title}, $self{date}, my @rest) = <TEXT>;
    close TEXT;

    for $_ (@rest) { $self{text} .= $_; }

    return %self;
}

my @filenames = glob './input/*'; my %files;
for my $file (@filenames) { $files{%$file} = returnHash($file); }

my $indexPosts; for my $file (@filenames[0..2]) {
    $indexPosts .= "<h2>$files{$file}{title} - $files{$file}{date}</h2><hr />$files{$file}{text}<br />\n";
}

my $vars = {
    content => "$indexPosts",
    links => "hello world",
};

$tt->process('index.tt', $vars, './output/index.html');
