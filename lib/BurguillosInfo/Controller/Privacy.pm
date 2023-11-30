package BurguillosInfo::Controller::Privacy;

use v5.34.1;

use strict;
use warnings;
use utf8;

use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub index($self) {
    return $self->render(text => <<"EOF");
Con fines analíticos y técnicos se almacenan la cantidad
de visitas a cada página.\r\n
La dirección IP, Agente de Usuario y parametros GET con los 
que se visita la página es almacenado de forma temporal 
(90 días) para detectar posibles ciberataques, tras ese tiempo
es sustituido por un hash.
Esta política puede cambiar en un futuro si se
requieren funcionalidades como registros.\r\n
EOF
}
1;
