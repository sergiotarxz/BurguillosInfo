package BurguillosInfo::Controller::Robots;
use Mojo::Base 'Mojolicious::Controller', '-signatures';

sub robots($self) {
    my $robots_txt = <<"EOF";
Sitemap: @{[$self->config('base_url')]}/sitemap.xml

User-Agent: *
Disallow: /stats
Disallow: /stats/*
EOF
    $self->render(text => $robots_txt, format => 'txt');
}
1;
