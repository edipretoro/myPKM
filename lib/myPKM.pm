package myPKM;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;

use HTML::ExtractMain qw( extract_main_html );
use LWP::UserAgent;
use HTML::ResolveLink;
use HTML::TreeBuilder::XPath;
use Encode;
use DateTime;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

any [ 'get', 'post' ] => '/delete/:id' => sub {
    redirect '/' unless params->{id};

    schema->resultset('Link')->search( { id => params->{id} } )->delete();
    redirect '/last';
};

any [ 'get', 'post' ] => '/view/:id' => sub {
    redirect '/' unless params->{id};

    my $article = schema->resultset('Link')->search( { id => params->{id} } )->first;
    redirect '/' unless defined( $article );
    my $max_id = schema->resultset('Link')->get_column('id')->max;
    template 'view', {
        url => $article->url,
        content => $article->content,
        title => $article->title,
        date => $article->creation_date,
        next_link => params->{id} == $max_id ? $max_id : params->{id} + 1,
        prev_link => params->{id} - 1 || params->{id},
        delete_link => params->{id},
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
            base => $response->base()
        );

        eval { $content = extract_main_html( $linker->resolve( $response->decoded_content ) ); };
        $content ||= $linker->resolve( $response->decoded_content );

        schema->txn_do(
            sub {
                my $link = schema->resultset('Link')->find_or_create({
                    url => $response->base,
                    content => $content,
                    title => $title,
                });
                $link->insert();
                redirect '/view/' . $link->id;
            }
        );
    } else {
        $content = "We couldn't get <a href=\"" . params->{url} . "\">this url</a>";
    }
    template 'read', { url => $response->base || params->{url}, content => $content, title => $title, date => $date };
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

any [ 'get', 'post' ] => '/list' => sub {
    my @links = schema->resultset('Link')->search(
        { creation_date => { like => DateTime->now->ymd('-') . '%' }},
        { order_by => { -desc => 'creation_date' }}
    )->all();
    template 'list', { links => \@links };
};

any [ 'get', 'post' ] => '/last' => sub {
    my $last_id = schema->resultset('Link')->get_column('id')->max;
    redirect "/view/$last_id";
};

any [ 'get', 'post' ] => '/search' => sub {
    template 'search';
};

any [ 'get', 'post' ] => '/random' => sub {
    my $last_id = schema->resultset('Link')->get_column('id')->max;
    my $random = int(rand($last_id)) + 1;
    redirect "/view/$random";
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
            base => $response->base,
        );

        eval { $content = extract_main_html( $linker->resolve( $response->decoded_content ) ); };
        $content ||= $linker->resolve( $response->decoded_content );
    }
}

true;
