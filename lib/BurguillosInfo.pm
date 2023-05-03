package BurguillosInfo;

use BurguillosInfo::Controller::Metrics;

use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {
    my $metrics = BurguillosInfo::Controller::Metrics->new;
    $self->hook(
        around_dispatch => sub {
            my $next = shift;
            my $c    = shift;
            $metrics->request($c);
            if ( defined $next ) {
                $next->();
            }
        }
    );
    my $config = $self->plugin('JSONConfig');
    $self->config(
        hypnotoad => { proxy => 1, listen => [$self->config('listen') // 'http://localhost:3000'] } );
    $self->config( css_version => int( rand(10000) ) );
    $self->secrets( $self->config->{secrets} );

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('Page#index');
    $r->get('/sitemap.xml')->to('Sitemap#sitemap');
    $r->get('/robots.txt')->to('Robots#robots');

    #  $r->get('/:post')->to('Page#post');
    $r->get('/stats')->to('Metrics#stats');
    $r->get('/<:category>.rss')->to('Page#category_rss');
    $r->get('/:category_slug/atributo/:attribute_slug')->to('Attribute#get');
    $r->get('/:category')->to('Page#category');
    $r->get('/posts/<:slug>-preview.webp')->to('Page#get_post_preview');
    $r->get('/posts/:slug')->to('Page#post');
    $r->get('/filtros')->to('Filter#list');
    $r->get('/filtros/:slug')->to('Filter#get');
    $r->get('/stats/login')->to('Metrics#login');
    $r->post('/stats/login')->to('Metrics#submit_login');
}

1;
