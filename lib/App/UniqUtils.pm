package App::UniqUtils;

use 5.010001;
use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Utilities related to unique lines and/or Unix uniq utility',
};

$SPEC{lookup_lines} = {
    v => 1.1,
    summary => 'Report or omit lines found in another "reference" file',
    args => {
        reference_file => {
            summary => 'Path to reference file',
            schema => 'filename*',
            req => 1,
            pos => 0,
        },
        test_files => {
            schema => ['array*', {of=>'filename*'}],
            pos => 1,
            slurpy => 1,
        },
        # XXX option: ci
        invert_match => {
            schema => 'bool*',
            description => <<'_',

By default the utility will report lines that are found in the reference file.
If this option is specified, then will instead report lines that are *not* found
in reference file.

_
            cmdline_aliases => {v=>{}},
        },
    },
    description => <<'_',

By default will report lines that are found in the reference file (unless when
`-v` a.k.a. `--invert-match` option is specified, in which case will report
lines that are *not* found in reference file).

_
};
sub lookup_lines {
    my %args = @_;

    open my $fh, "<", $args{reference_file}
        or return [500, "Cannot open reference file '$args{reference_file}': $!"];
    my %mem;
    while (my $line = <$fh>) {
        chomp $line;
        $mem{$line}++;
    }

  FILE:
    for my $file (@{ $args{test_files} // ["-"] }) {
        my $fh;
        if ($file eq '-') {
            $fh = \*STDIN;
        } else {
            open $fh, "<", $file or do {
                warn "Cannot open test file '$file': $!, skipped";
                next FILE;
            };
        }

        while (my $line = <$fh>) {
            chomp $line;
            if ($mem{$line}) {
                if (!$args{invert_match}) { say $line }
            } else {
                if ( $args{invert_match}) { say $line }
            }
        }
    }

    [200];
}

1;
#ABSTRACT:

=head1 DESCRIPTION

This distributions provides the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<App::nauniq>

L<csv-lookup-fields> from L<App::CSVUtils>

=cut
