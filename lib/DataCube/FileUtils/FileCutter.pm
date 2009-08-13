


package DataCube::FileUtils::FileCutter;

use strict;
use warnings;
use Time::HiRes;
use Fcntl;
use DataCube::FileUtils;
use DataCube::FileUtils::FileReader;

sub new {
    my($class,%opts) = @_;
    bless { %opts }, ref($class) || $class;
}

sub cut {
    my($self,%opts) = @_;
    @{$opts{fields}} = sort @{$opts{fields}};
    my $reader = DataCube::FileUtils::FileReader->new;
    my @cuts;
    my @rows = $reader->slurp($opts{source});
    while(my $row = shift @rows){
        push @cuts, join("\t", @{$row}{@{$opts{fields}}} ); 
    }
    sysopen(my $F, $opts{target} . '.working', O_WRONLY | O_CREAT) 
        or die "DataCube::FileUtils::FileCutter(cut | sysopen):\ncant sysopen:\n$opts{target}\n$!\n";
    
    output: {
        use bytes;
        my $data  = join("\n", join("\t", @{$opts{fields}}),join("\n",@cuts));
        my $size  = bytes::length($data);
        my $wrote = syswrite($F, $data, $size);
        die "DataCube::FileUtils::FileCutter(cut | syswrite):\nsyswrite return: $wrote bytes\nwanted to get:  $size bytes\n$!\n"
            unless $size == $wrote;
        close($F);
        no bytes;
        rename($opts{target} . '.working', $opts{target})
            or die "DataCube::FileUtils::FileCutter(cut | rename):\ncant rename:\n" .
                   "$opts{target}.working\nto\n$opts{target}\n$!\n"
    }
   
    if($opts{unlink}){    
        unlink($opts{source})
            or die "DataCube::FileUtils::FileCutter(cut | unlink):\n".
                   "cant unlink\n$opts{source}\n$!\n";
    }
    
    return $self;
}


1;






__END__


=head1 NAME

DataCube::FileUtils::FileReader - An object oriented Perl module for reading files;

=head1 SYNOPSIS

    use strict;
    use warnings;
    use DataCube::FileUtils::FileReader;

    my $file   = 'some_flat_file.tsv';

    my $reader = DataCube::FileUtils::FileReader->new;

    $reader->read($file);

    while($reader->next_line){
        printf "\tcolumn_a  =>  %s\n",$reader->column_a;
        printf "\tcolumn_b  =>  %s\n",$reader->column_b;
        printf "\tcolumn_c  =>  %s\n",$reader->column_c;
        print '-' x 80,"\n";
    }



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

David Williams, E<lt>david@gorillamatrix.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by David Williams

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
