package BurguillosInfo::Controller::Privacy;

use v5.34.1;

use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub index($self) {
    return $self->render(text => <<"EOF");
Esta aplicación no almacena datos que puedan identificar
de forma única a los usuarios.\r\n
Con fines analíticos y técnicos se almacenan la cantidad
de visitas a cada página.\r\n
Esta política puede cambiar en un futuro si se
requieren funcionalidades como registros.\r\n
EOF
}
1;
