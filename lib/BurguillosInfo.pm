package BurguillosInfo;

use BurguillosInfo::Controller::Metrics;

use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {
  my $metrics = BurguillosInfo::Controller::Metrics->new;
  $self->hook(around_dispatch => sub {
      my $next = shift;
      my $c = shift;
      $metrics->request($c);
      if (defined $next) {
	      $next->();
      }
  });
  my $config = $self->plugin('JSONConfig');
  $self->config(hypnotoad => {listen => ['http://localhost:3000']});
  # Router
  my $r = $self->routes;
  
  # Normal route to controller
  $r->get('/')->to('Page#index');
#  $r->get('/:post')->to('Page#post');
  $r->get('/<:category>.rss')->to('Page#category_rss');
  $r->get('/:category')->to('Page#category');
  $r->get('/posts/<:slug>-preview.png')->to('Page#get_post_preview');
  $r->get('/posts/:slug')->to('Page#post');
}

1;
