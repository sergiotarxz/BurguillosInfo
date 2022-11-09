package BurguillosInfo;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Page#index');
#  $r->get('/:post')->to('Page#post');
  $r->get('/:category')->to('Page#category');
  $r->get('/posts/:slug')->to('Page#post');
}

1;
