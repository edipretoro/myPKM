package myPKM::Schema::Result::Link;

use base 'DBIx::Class';
use DateTime;
use XML::Writer;

__PACKAGE__->load_components(qw/ Core InflateColumn::DateTime /);
__PACKAGE__->table('links');

__PACKAGE__->add_columns(
    'id' => {
        'data_type'         => 'bigint',
        'is_auto_increment' => 1,
        'default_value'     => undef,
        'is_foreign_key'    => 0,
        'name'              => 'id',
        'is_nullable'       => 0,
        'size'              => '20'
    },
    'title' => {
        'data_type'         => 'text',
        'is_auto_increment' => 0,
        'default_value'     => undef,
        'is_foreign_key'    => 0,
        'name'              => 'title',
        'is_nullable'       => 0,
    },
    'url' => {
        'data_type'         => 'text',
        'is_auto_increment' => 0,
        'default_value'     => undef,
        'is_foreign_key'    => 0,
        'name'              => 'url',
        'is_nullable'       => 0,
    },
    'content' => {
        'data_type'         => 'text',
        'is_auto_increment' => 0,
        'default_value'     => undef,
        'is_foreign_key'    => 0,
        'name'              => 'content',
        'is_nullable'       => 0,
    },
    'creation_date' => {
        'data_type'         => 'datetime',
        'is_auto_increment' => 0,
        'default_value'     => \'CURRENT_TIMESTAMP',
        'is_foreign_key'    => 0,
        'name'              => 'creation_date',
        'is_nullable'       => 0,
    },
);

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [ 'url' ] );

sub as_dublin_core {
    my ( $self ) = shift;
    my $xml_output;
    my $oai_dc_ns = 'http://www.openarchives.org/OAI/2.0/oai_dc/';
    my $dc_ns = 'http://purl.org/dc/elements/1.1/';

    my $xml_writer = XML::Writer->new(
        OUTPUT => \$xml_output,
        NAMESPACES => 1,
        FORCE_NS_DECLS => 1,
        ENCODING => 'utf-8',
        DATA_MODE => 1,
        DATA_INDENT => 2,
        PREFIX_MAP => {
            $oai_dc_ns => 'oai_dc',
            $dc_ns => 'dc',
        },
    );

    $xml_writer->startTag( [$oai_dc_ns, 'metadata']);
    $xml_writer->startTag( [$oai_dc_ns, 'dc']);
    $xml_writer->startTag( [$dc_ns, 'title']);
    $xml_writer->characters( $self->title );
    $xml_writer->endTag( [$dc_ns, 'title']);
    $xml_writer->endTag( [$oai_dc_ns, 'dc']);
    $xml_writer->endTag( [$oai_dc_ns, 'metadata']);

    $xml_writer->end();

    return $xml_output;
}

1;    # End of myPKM::Schema::Result::Link
