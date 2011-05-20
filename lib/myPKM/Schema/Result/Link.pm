package myPKM::Schema::Result::Link;

use base 'DBIx::Class';
use DateTime;

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

1;    # End of myPKM::Schema::Result::Link
