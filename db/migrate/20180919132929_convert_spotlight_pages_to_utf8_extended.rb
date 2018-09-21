##
# This migration converts Spotlight::Pages to utf8mb for storing of non-latin 
class ConvertSpotlightPagesToUtf8Extended < ActiveRecord::Migration[5.2]
  def up
    # Convert everthing to utf8
    if ActsAsTaggableOn::Utils.using_mysql?
      connection = ActiveRecord::Base.connection
      dbname = connection.current_database
      execute <<-SQL
        ALTER DATABASE `#{dbname}` CHARACTER SET utf8 COLLATE utf8_general_ci;
      SQL
      tables.each do |tablename|
        execute <<-SQL
          ALTER TABLE `#{dbname}`.#{tablename} CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
        SQL
      end
    end

    # Only convert Spotlight::Pages to utf8mb (actual utf8 support)
    remove_index :spotlight_pages, name: 'index_spotlight_pages_on_slug_and_scope'
    remove_index :spotlight_pages, :locale

    change_column :spotlight_pages, :title, :string, limit: 191
    change_column :spotlight_pages, :type, :string, limit: 191
    change_column :spotlight_pages, :slug, :string, limit: 191
    change_column :spotlight_pages, :scope, :string, limit: 191
    change_column :spotlight_pages, :locale, :string, limit: 191

    # Adding a length to the index limit, as MySQL's utf8mb will hit index
    # length limits without this. This is why we are also not automatically
    # converting the entire database.
    # See: https://stackoverflow.com/a/19940770
    add_index :spotlight_pages, [:slug,:scope], unique: true, length: 191
    add_index :spotlight_pages, :locale, length: 191

    if ActsAsTaggableOn::Utils.using_mysql?
      execute("ALTER TABLE spotlight_pages CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;")
    end
  end
  
  def down
    if ActsAsTaggableOn::Utils.using_mysql?
      connection = ActiveRecord::Base.connection
      dbname = connection.current_database
      execute <<-SQL
        ALTER DATABASE `#{dbname}` CHARACTER SET latin1 COLLATE latin1_swedish_ci;
      SQL
      tables.each do |tablename|
        execute <<-SQL
          ALTER TABLE `#{dbname}`.#{tablename} CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;
        SQL
      end
    end

    remove_index :spotlight_pages, name: 'index_spotlight_pages_on_slug_and_scope'
    remove_index :spotlight_pages, :locale

    change_column :spotlight_pages, :title, :string, limit: 255
    change_column :spotlight_pages, :type, :string, limit: 255
    change_column :spotlight_pages, :slug, :string, limit: 255
    change_column :spotlight_pages, :scope, :string, limit: 255
    change_column :spotlight_pages, :locale, :string, limit: 255

    add_index :spotlight_pages, [:slug,:scope], unique: true
    add_index :spotlight_pages, :locale

    if ActsAsTaggableOn::Utils.using_mysql?
      execute("ALTER TABLE spotlight_pages MODIFY key VARCHAR(255);")
      execute("ALTER TABLE spotlight_pages CONVERT TO CHARACTER SET latin1 COLLATE latin1_swedish_ci;")
    end
  end
end
