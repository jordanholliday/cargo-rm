# Cargo-RM
Cargo is a lightweight ORM written in Ruby.

Cargo metaprogrammatically adds semantic classes and methods that translate into SQL queries. Currently, it includes single- and multi-step associations, as well as lazy, chainable queries. More features coming—watch this space!

## Setup

#### Models
Add model classes as separate files in `app/models`. Declare associations much like you would in a Rails app:

```ruby
# player.rb
class Player < SQLObject
  belongs_to :team
  has_one_through :arena, :team, :arena
end
```

```ruby
# arena.rb
class Arena < SQLObject
  has_one :team
end
```

#### Database
Specify your database in `config/databse.yml`:

```yaml
SQL_FILE: 'example.sql'
DB_FILE: 'example.db'
```

For easy reference, the repo includes a SQL file (`basketball.sql`) with example syntax for creating tables and records. For even easier seeding, see [Seeding](#seeding) below.

## Booting

To start your app:

```ruby
> load 'boot.rb'
```

💣Kaboom—💣you're ready to go.

All associations and attrribute accessors will be in place. Start using class methods like `.all()`, `.find()`, and `.where()`, and instance methods like `.update()` and `insert()`, right away!

## <a name="seeding"></a>Seeding

As a convenience, a `SeedUtil` class is included. Use `SeedUtil::csv_seed!` to save a CSV to your database:

```ruby
> SeedUtil.csv_seed!(Model, 'path/to/csv.csv', ["column_one_name", "column_two_name", "column_three_name"])
```

Note that your CSV column names should correspond to the class's attributes. Exclude the headings from the CSV file itself.
