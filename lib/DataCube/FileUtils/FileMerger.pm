


package DataCube::FileUtils::FileMerger;

use strict;
use warnings;

use File::Copy;
use Time::HiRes;
use Storable qw(nstore retrieve);

use DataCube;
use DataCube::Schema;
use DataCube::FileUtils;
use DataCube::MeasureUpdater;

sub new {
    my($class,%opts) = @_;
    bless {%opts}, ref($class) || $class;
}

sub merge {
    my($self,%opts) = @_;
    
    my $schema = $opts{schema};
    my $files  = $opts{source};
    my $target = $opts{target};
    my $unlink = $opts{unlink};
    
    $files = [$files] unless ref($files);
        
    if(@$files == 1 && ! -f($target)){
        File::Copy::copy($files->[0],$target);
        return $self;
    }
    
    my $updater = DataCube::MeasureUpdater->new($schema);
    
    my $hash = {};
    if(-f($target)){
        $hash = Storable::retrieve($target);
    }
    
    for(@$files){
        my $data = Storable::retrieve($_);
        while(my($key,$val) = each %$data){
            $updater->update(
                source     => $data,
                target     => $hash,
                source_key => $key,
                target_key => $key,
            );
            delete $data->{$key};
        }
        undef $data;
    }
    
    
    my $write_time = Time::HiRes::time;
    my $temp_file  = $target . '.' . $write_time;
    Storable::nstore($hash, $temp_file);
    
    if($unlink){
        for(@$files){
            unlink($_)
                or die "DataCube::FileUtils::FileMerge(merge : unlink):\ncant unlink:\n$_\n$!\n";
        }
    }
    
    rename($temp_file, $target)
        or die "DataCube::FileUtils::FileMerger(merge):\ncant rename:\n$temp_file\nto\n$target\n$!\n";
    
    undef $hash;
    return $self;
}




1;





