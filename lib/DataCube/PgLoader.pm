
package DataCube::PgLoader;

use Moose;
use DBIx::Connector;
use Carp qw| confess |;
use Time::HiRes qw| time |;
use Storable qw| retrieve |;
use Digest::MD5 qw| md5_hex |;
use Sys::Hostname;

has columns         => (is => 'ro', isa => 'ArrayRef[Str]', lazy_build => 1);
has dbi             => (is => 'ro', isa => 'DBIx::Connector', lazy_build => 1);
has dsn             => (is => 'ro', isa => 'Str');
has final_sql       => (is => 'ro', isa => 'ArrayRef[Str]', lazy_build => 1);
has final_table     => (is => 'ro', isa => 'Str', lazy_build => 1);
has load_sql        => (is => 'ro', isa => 'ArrayRef[Str]', lazy_build => 1);
has merge_sql       => (is => 'ro', isa => 'ArrayRef[Str]', lazy_build => 1);
has password        => (is => 'ro', isa => 'Str');
has schema          => (is => 'ro', isa => 'DataCube::Schema', required => 1);
has temp_table      => (is => 'ro', isa => 'Str', lazy_build => 1);
has types           => (is => 'ro', isa => 'HashRef[Str]', lazy_build => 1);
has username        => (is => 'ro', isa => 'Str');

sub _build_columns {
    my( $self ) = @_;
    [ $self->schema->columns ];
}

sub _build_dbi {
    my( $self ) = @_;
    return DBIx::Connector->new(
        $self->dsn,
        $self->username,
        $self->password,
        {
            RaiseError => 1,
            AutoCommit => 1,
        }
    );
}

sub _build_final_table {
    my( $self ) = @_;
    'fact_' . md5_hex(join('__',  $self->schema->fields))
}

sub _build_final_sql {
    my( $self ) = @_;
    my @sql;
    my $columns     = join(",\n    ", @{ $self->columns });
    my $final_table = $self->final_table;
    my %types       = %{ $self->types };
    my @column_defs = map { $_ . ' ' . $types{$_} } @{ $self->columns };
    unshift @column_defs, '_id bigserial primary key';
    my $column_defs = join (",\n    ", @column_defs);
    push @sql, "\n-- create final table\ncreate table $final_table (\n    $column_defs\n)";
    for( @{ $self->columns } ) {
        push @sql, "create index on $final_table ($_)"
    }
    return \@sql;
}

sub _build_load_sql {
    my( $self ) = @_;
    my @load_sql;
    my $columns     = join(",\n    ", @{ $self->columns });
    my $temp_table  = $self->temp_table;
    my %types       = %{ $self->types };
    my @column_defs = map { $_ . ' ' . $types{$_} } @{ $self->columns };
    my $column_defs = join (",\n    ", @column_defs);
    
    push @load_sql, "\n-- drop temp table if already exists\ndrop table if exists $temp_table"
                  , "\n-- create temp table\ncreate table $temp_table (\n    $column_defs\n)"
                  , "\n-- load via copy\ncopy $temp_table (\n    $columns\n) from stdin" ;
    
    return \@load_sql;
}

sub _build_merge_sql {
    my( $self ) = @_;
    my $temp_table    = $self->temp_table;
    my $final_table   = $self->final_table; 
    my @fields        = $self->schema->fields;
    my @measure_names = $self->schema->measure_names;

    my @sql;
   
    my $update_sql = "\n-- update existing records in target table"
        . "\nupdate $final_table set\n       "; 

    my @updates;
    for( @measure_names ) {
        my $operation = $_ =~ /^sum__/ 
            ? '+' 
            : die "Operation for $_ not yet implemented.";    
        push @updates, "$_ = $final_table.$_ $operation $temp_table.$_";
    }

    $update_sql .= join("\n     , ", @updates);
    $update_sql .= "\n  from $temp_table\n where ";

    my @where;
    for( @fields ) {
        push @where, "$final_table.$_ = $temp_table.$_"
    }
    
    my $where    = join("\n   and ", @where);
    $update_sql .= $where;

    push @sql, $update_sql;
    
    my $insert_sql = "\n-- insert new records into target table" 
        . "\ninsert into $final_table (\n      " 
        . join("\n    , ", @{$self->columns})  
        . "\n)\nselect\n      " 
        . join("\n    , ", @{$self->columns}) 
        . "\nfrom $temp_table" 
        . "\nwhere not exists ("
        . "\n    select 1 from $final_table\n     where " 
        . join("\n       and ", @where) 
        . "\n)"; 

    push @sql, $insert_sql;
    \@sql;
}

sub _build_temp_table {
    my( $self ) = @_;
    'fact_' . md5_hex(join('__',  $self->schema->fields, time() . rand() . $$ . hostname()));
}

sub _build_types {
    my( $self ) = @_;
    my %types = $self->schema->pg_types; 
    \%types;
}

sub merge_final {
    my( $self ) = @_;
    my $dbh = $self->dbi->dbh;
    my @merge_sql = @{ $self->merge_sql };
    $dbh->do( $_ ) for @merge_sql;
}

sub check_final_table {
    my( $self ) = @_;
    my $final_table = $self->final_table;
    my $sql = "select 1 as true from pg_tables where tablename = ?";
    my $sth = $self->dbi->dbh->prepare_cached( $sql );
    $sth->execute( $final_table );
    my $row = $sth->fetchrow_hashref;
    return if $row && $row->{true};
    my @sql = @{ $self->final_sql };
    $self->dbi->dbh->do( $_ ) for @sql;
}

sub load {
    my( $self, @data ) = @_;
    $self->check_final_table;
    my $dbh = $self->dbi->dbh;
    $dbh->do( $_ ) for @{ $self->load_sql };
    $dbh->pg_putcopydata( "$_\n" ) for @data;
    $dbh->pg_putcopyend;
    $self->merge_final;
    $dbh->do( "drop table " . $self->temp_table );
}

sub dmp {use Data::Dumper; print Dumper \@_ }

__PACKAGE__->meta->make_immutable;
1;



