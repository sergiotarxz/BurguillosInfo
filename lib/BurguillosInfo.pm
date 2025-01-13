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
    push @{ $self->commands->namespaces }, 'BurguillosInfo::Command';
    $self->hook(
        before_render => sub($c, $args) {
            my $current_route = $c->url_for;
            $c->stash(current_route => $current_route);
            my $is_android = $c->req->headers->user_agent =~ /android/i; 
            $c->stash(is_android => $is_android);
            $c->stash(has_seen_search_explanation => $c->cookie('has-seen-search-explanation'));
            my $onion_base_url = $self->config->{onion_base_url};
            my $base_url = $self->config->{base_url};
            if (!defined $onion_base_url) {
                return;
            }
            $current_route =~ s/^$base_url//;
            $c->res->headers->header('Onion-Location' => $onion_base_url.$current_route);
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
    $r->get('/index', sub ($c) {
        $c->redirect_to('/');
    });
    $r->get('/privacy.txt')->to('Privacy#index');
    $r->get('/sitemap.xml')->to('Sitemap#sitemap');
    $r->get('/robots.txt')->to('Robots#robots');

    #  $r->get('/:post')->to('Page#post');
    $r->get('/stats')->to('Metrics#stats');
    $r->get('/product/:slug')->to('Product#direct_buy');
    $r->get('/producto/:slug')->to('Product#direct_buy');
    $r->get('/producto/<:slug>.json')->to('Product#get_data');
    $r->get('/search.json')->to('Search#search');
    $r->get('/search.html')->to('Search#search_user');
    $r->get('/farmacia-guardia.json')->to('FarmaciaGuardia#current');
    $r->get('/<:category>.rss')->to('Page#category_rss');
    $r->get('/:category_slug/atributo/<:attribute_slug>-preview.png')->to('Attribute#get_attribute_preview');
    $r->get('/:category_slug/atributo/:attribute_slug')->to('Attribute#get');
    $r->get('/<:category>-preview.png')->to('Page#get_category_preview');
    $r->get('/:category')->to('Page#category');
    $r->get('/posts/<:slug>-preview.png')->to('Page#get_post_preview');
    $r->get('/posts/:slug')->to('Page#post');
    $r->get('/next-ad.json')->to('Ads#next_ad');
    $r->get('/filtros')->to('Filter#list');
    $r->get('/filtros/:slug')->to('Filter#get');
    $r->get('/stats/login')->to('Metrics#login');
    $r->post('/stats/login')->to('Metrics#submit_login');
    $r->get('/search/suggestions.json', sub ($c) {
        return $c->render(json=> [
            'Juguetes de Moda',
            'Sonny Angel',
            'Bar Beluche',
            'Bar Cristóbal',
            'Mesa escritorio',
            'Linux',
            'Libros de hacking',
            'Pizzería pepin',
            'Modem datos moviles USB',
            'Martillo emergencia coche',
        ]);
    });
}

1;
