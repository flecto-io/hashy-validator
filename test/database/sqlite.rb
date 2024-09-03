# Create database
conn = { adapter: "sqlite3", database: ":memory:" }
ActiveRecord::Base.establish_connection(conn)

# Schema
ActiveRecord::Schema.define do
  create_table :profiles do |t|
    t.string(:name)
    t.string(:notifications)

    # @Todo: use Postgres
    # Also check if i really need to create test with pg integration
    # t.jsonb :notifications
  end
  create_table :products do |t|
    t.string(:name)
    t.string(:discount_by_quantity)
  end

  create_table :items do |t|
    t.string(:name)
    t.string(:metas)
  end

  create_table :customers do |t|
    t.integer(:age)
    t.string(:custom)
  end
end