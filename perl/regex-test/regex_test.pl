#!/usr/bin/env perl
use strict;
use warnings;

if (@ARGV < 2 || $ARGV[0] eq '-h' || $ARGV[0] eq '--help') {
    print "Usage: regex_test.pl <pattern> <string>\n";
    print "  Tests a regex against a string. Shows match and groups.\n";
    exit(@ARGV < 2 ? 1 : 0);
}

my ($pattern, $string) = @ARGV;

eval {
    if ($string =~ /$pattern/) {
        print "MATCH: yes\n";
        print "Full: '$&'\n";
        my @groups = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
        for my $i (0..$#groups) {
            print "Group " . ($i+1) . ": '$groups[$i]'\n" if defined $groups[$i];
        }
    } else {
        print "MATCH: no\n";
    }
    1;
} or do {
    print "Error: invalid regex '$pattern'\n";
    exit 1;
};
