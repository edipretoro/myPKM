package myPKM;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;

use HTML::ExtractMain qw( extract_main_html );
use LWP::UserAgent;
use HTML::ResolveLink;
use HTML::TreeBuilder::XPath;
use Encode;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any [ 'get', 'post' ] => '/view/:id' => sub {
    redirect '/' unless params->{id};

    my $article = schema->resultset('Link')->search( { id => params->{id} } )->first;
    redirect '/' unless defined( $article );
    template 'view', {
        url => $article->url,
        content => decode('utf8', $article->content),
        title => decode('utf8', $article->title),
        date => $article->creation_date,
        next => params->{id} + 1,
        prev => params->{id} - 1 || params->{id},
    };
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
    my $title;

    if ($response->is_success) {
        my $xpath = HTML::TreeBuilder::XPath->new_from_content( $response->decoded_content );
        $title = $xpath->findvalue( '//title' );
        $title ||= "No title";

        my $linker = HTML::ResolveLink->new(
            base => params->{url}
        );

        $content = extract_main_html( $linker->resolve( $response->decoded_content ) );
        $content ||= $linker->resolve( $response->decoded_content );

        schema->txn_do(
            sub {
                my $link = schema->resultset('Link')->find_or_create({
                    url => params->{url},
                    content => $content,
                    title => $title,
                });
                $link->insert();
            }
        );
    } else {
        $content = "We couldn't get <a href=\"" . params->{url} . "\">this url</a>";
    }
    template 'read', { url => params->{url}, content => $content, title => $title, date => $date };
};

any [ 'get', 'post' ] => '/add' => sub {
    redirect '/' unless params->{url};

    schema->txn_do(
        sub {
            my $title = params->{title} || 'not defined';
            my $link = schema->resultset('Link')->find_or_create({
                url => params->{url},
                title => $title,
                content => 'not defined',
            });
            $link->insert();
        }
    );

    redirect '/';
};

sub deploy {
    schema->deploy();
}

sub existing_database {
    -e config->{plugins}{DBIC}{mypkm}{dsn};
}

sub get_article {
    my ($link) = @_;

    my $ua = LWP::UserAgent->new();
    $ua->agent( 'Mozilla/5.0' );
    $ua->timeout( 30 );
    $ua->cookie_jar( {} );

    my $response = $ua->get( $link );
    my $content;

    if ($response->is_success) {
        my $linker = HTML::ResolveLink->new(
            base => $link,
        );

        eval { $content = extract_main_html( $linker->resolve( $response->decoded_content ) ); };
        $content ||= $linker->resolve( $response->decoded_content );
    }
}

true;
