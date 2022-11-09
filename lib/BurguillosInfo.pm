package BurguillosInfo;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('Page#index');
#  $r->get('/:post')->to('Page#post');
  $r->get('/:category')->to('Page#category');
  $r->get('/posts/:slug')->to('Page#post');
}

1;
