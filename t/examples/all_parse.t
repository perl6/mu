use v6;
use File::Find;
use Test;

=begin pod

Test examples

This loads all the scripts of the examples/ dir and verifies they
can compile.  It does not verify run ability or verify output.

=end pod

# The following depend on modules that are not universally installed.
my %suppress;
%suppress<cpan-upload.pl evalbot.pl> = 1 xx *;

my File::Find $f .= new(
    wanted_file => sub ($file, $path, $pathfile) {
        return 0 if $file ~~ m:P5/-p5/;
        return 0 if %suppress{$file};
        return 1 if $file ~~ m:P5/\.pl$/;
        return 1 if $file ~~ m:P5/\.pm$/;
    },
    wanted_dir => sub ($dir, $path, $pathdir) {
        return 0 if $dir eq '.svn';
        return 0 if $dir eq 'p5';
        return 1;
    },
    dirs => qw[examples]
);

# This should be removed ASAP
# Currently (2006-08-21) only way Win32 works
if $*OS eq any(<MSWin32 mingw msys cygwin>) {
    $f.debug = 1;
}

my @files = $f.find;
plan +@files;

if $*OS eq "browser" {
    skip_rest "Programs running in browsers don't have access to regular IO.";
    exit;
}

# The following is ugly and should be rewritten
# Specifically, there should be a way to test
# $! instead of this yucky workaround
for sort(@files) -> $ex {
    my $out = qqx[$*EXECUTABLE_NAME -c -Iblib6/lib $ex];

    if $out ~~ m:P5/syntax OK\s*$/ {
        pass "$ex parsed correctly";
    }
    else {
        flunk "$ex failed to parse";
    }
}
