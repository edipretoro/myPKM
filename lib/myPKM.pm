package myPKM;
use Dancer ':syntax';

use HTML::ExtractMain qw( extract_main_html );
use LWP::UserAgent;
use HTML::ResolveLink;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any [ 'get', 'post' ] => '/read' => sub {
    redirect '/' unless params->{url};
    my $ua = LWP::UserAgent->new();
    $ua->agent( 'Mozilla/5.0' );
    $ua->timeout( 30 );
    $ua->cookie_jar( {} );

    my $response = $ua->get( params->{url} );
    my $date = localtime;
    my $content;

    if ($response->is_success) {
        my $linker = HTML::ResolveLink->new(
            base => params->{url}
        );
        $content = extract_main_html( $linker->resolve( $response->decoded_content ) );
        unless (defined($content)) {
            $content = "We couldn't get a content from <a href=\"" . params->{url} . "\">" . params->{url} . "</a>";
        }
    } else {
        $content = "We couldn't get <a href=\"" . params->{url} . "\">this url</a>";
    }
    template 'read', { url => params->{url}, content => $content, title => "Pour plus tard...", date => $date };
};

true;
