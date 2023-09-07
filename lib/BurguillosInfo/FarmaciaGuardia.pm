package BurguillosInfo::FarmaciaGuardia;

use v5.36.0;

use strict;
use warnings;
use utf8;

use feature 'signatures';

use Data::Dumper;

use Moo;
use DateTime;
use DateTime::Format::Pg;

use Mojo::UserAgent;

use BurguillosInfo::Farmacias;
use BurguillosInfo::Farmacias::CruzDeLaErmita;
use BurguillosInfo::Farmacias::Morera;

has _app => ( is => 'lazy', );
has _db  => ( is => 'lazy' );

sub _build__app {
    require BurguillosInfo;
    return BurguillosInfo->new;
}

sub get_current ($self) {
    my $date_search = $self->_get_search_date;
    my $farmacia_db = $self->_search_horario_db($date_search);
    if (defined $farmacia_db) {
        return $farmacia_db;
    }
    my $farmacia;
    eval {
        $farmacia = $self->_request_horario_internet($date_search);
    };
    if (!defined $farmacia) {
        die "API possibly broken for Farmacia de Guardia. $@";
    }
    $self->_register_farmacia($date_search, $farmacia);
    return $farmacia;
}

sub _register_farmacia($self, $date_search, $farmacia) {
    my $f  = DateTime::Format::Pg->new;
    my $dbh               = $self->_db;
    $dbh->do(<<'EOF', undef, $f->format_datetime($date_search), $farmacia->id);
INSERT INTO farmacia_guardia (date, id_farmacia) VALUES (?, ?);
EOF
}

sub _search_horario_db ( $self, $date_search ) {
    my $f  = DateTime::Format::Pg->new;
    my $db = $self->_db;
    $date_search = $date_search->clone;
    $date_search->set_time_zone('UTC');
    my $start_farmacia_week = $self->_get_start_date_week($date_search);
    my $end_farmacia_week   = $self->_get_end_date_week($date_search);
    my $horarios            = $db->selectall_arrayref(
        <<'EOF', { Slice => {} }, $f->format_datetime($start_farmacia_week), $f->format_datetime($end_farmacia_week) );
SELECT id_farmacia from farmacia_guardia where date > ? and date < ?;
EOF
    if (!scalar @$horarios) {
        return; 
    }
    my $id = $horarios->[0]{id_farmacia};
    return BurguillosInfo::Farmacias->new->by_id($id);
}

sub _request_horario_internet ( $self, $date_search ) {
    my $ua     = $self->_ua;
    my $result = $ua->get(
'http://www.farmaciacruzdelaermita.com/index.php/component/dpcalendar/events',
        form => {
            limit        => 0,
            compact      => 0,
            my           => 0,
            format       => 'raw',
            ids          => 10,
            'date-start' => $date_search->epoch,
            'date-end'   => $date_search->epoch,
            _            => $date_search->epoch * 1000,
        }
    )->result;
    my $json;
    eval { $json = $result->json; };
    if ($@) {
        die "Unable to recover data of Farmacia de Guardia $@.";
    }
    my $data;
    eval { $data = $json->[0]{data}; };
    if ( $@ || !defined $data ) {
        die "Unable to get data of calendar.";
    }
    if ( scalar @$data ) {
        return BurguillosInfo::Farmacias::CruzDeLaErmita->new;
    }
    return BurguillosInfo::Farmacias::Morera->new;
}

sub _ua {
    return Mojo::UserAgent->new;
}

sub _get_search_date ($self) {
    my $current_date = DateTime->now;
    my $date_search  = $current_date->clone;
    if ( $date_search < $self->_get_start_date_week($current_date) ) {
        $date_search = $date_search->add( days => -1 );
    }
    return $date_search;
}

sub _get_end_date_week ( $self, $date_search ) {
    my $start_farmacia_week = $self->_get_start_date_week($date_search);
    my $end_farmacia_week   = $start_farmacia_week->clone->add( weeks => 1 );
    $end_farmacia_week->set_time_zone('Europe/Madrid');
    $end_farmacia_week->set_hour(9);
    $end_farmacia_week->set_minute(30);
    $end_farmacia_week->set_time_zone('UTC');
    return $end_farmacia_week;
}

sub _get_start_date_week ( $self, $date_search ) {
    my $start_farmacia_week = $date_search->clone->truncate( to => 'week' );
    $start_farmacia_week->set_time_zone('Europe/Madrid');
    $start_farmacia_week->set_hour(9);
    $start_farmacia_week->set_minute(30);
    $start_farmacia_week->set_time_zone('UTC');
    return $start_farmacia_week;
}

sub _build__db ($self) {
    require BurguillosInfo::DB;
    return BurguillosInfo::DB->connect( $self->_app );
}
1;
