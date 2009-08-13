

package DataCube::Report::Formatter;


use strict;
use warnings;


sub new {
    my($class,%opts) = @_;
    bless {}, ref($class) || $class;
}

sub dir {
    my($self,$path) = @_;
    opendir(my $D, $path) or die "DataCube::FileSplitter(dir):\ncant open directory:$path\n$!\n";
    grep {/[^\.]/} readdir($D);
}

sub sort_format {
    my($self,$path) = @_;
    my @lines = $self->fcon($path);
    @lines[1..$#lines] = sort @lines[1..$#lines];
    {
        local $| = 1;
        open(my $F, '>', $path)
            or die "DataCube::Report::Formatter(sort_format):\ncant open file for writing:\n$path\n$!\n";
        print $F join("\n",@lines);
        close $F;
    }
    return $self;
}

sub fcon {
    my($self,$path) = @_;
    open(my $F, '<' , $path)
        or die "DataCube::Report::Formatter(fcon):\ncant open:\n$path\n$!\n";
    my @lines = grep {/\S/} <$F>;
    $_ =~ s/\n//g for @lines;
    return @lines;
}







1;



__DATA__

#date=yyyymmdd
#with by month #'s as yyyymm01

#uniques_bysite:
#"date","site_id","country_id","imps","uniques"
#
#uniques_bychannel:
#"date","country_id","channel_id","imps","uniques"
#
#uniques
#"date","country_id","imps","uniques"
#
#uniques_bysize
#"date","size_id","country_id","imps","uniques"
#
#uniques_bysitesize
#"date","site_id","size_id","country_id","imps","uniques"
#
#uniques_bynetwork
#"date","network_id","country_id","imps","uniques"
#
#uniques_bynetworksitesize
#"date","network_id","site_id","size_id","country_id","imps","uniques"

















__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Rubicon - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Rubicon;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Rubicon, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

David Williams, E<lt>david@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by David Williams

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

