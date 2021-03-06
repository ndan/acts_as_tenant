ActiveRecord::Schema.define(:version => 1) do
  create_table :accounts, :force => true do |t|
    t.column :name, :string
    t.column :subdomain, :string
    t.column :domain, :string
  end

  create_table :organizations, :force => true do |t|
    t.column :name, :string
  end

  create_table :products, :force => true do |t|
    t.column :name, :string
    t.column :organization_id, :integer
  end

  create_table :projects, :force => true do |t|
    t.column :name, :string
    t.column :account_id, :integer
  end

  create_table :managers, :force => true do |t|
    t.column :name, :string
    t.column :project_id, :integer
    t.column :account_id, :integer
  end

  create_table :tasks, :force => true do |t|
    t.column :name, :string
    t.column :account_id, :integer
    t.column :project_id, :integer
    t.column :completed, :boolean
  end

  create_table :countries, :force => true do |t|
    t.column :name, :string
  end

  create_table :unscoped_models, :force => true do |t|
    t.column :name, :string
  end

  create_table :aliased_tasks, :force => true do |t|
    t.column :name, :string
    t.column :project_alias_id, :integer
    t.column :account_id, :integer
  end

  create_table :unique_tasks, :force => true do |t|
    t.column :name, :string
    t.column :user_defined_scope, :string
    t.column :project_id, :integer
    t.column :account_id, :integer
  end

  create_table :custom_foreign_key_tasks, :force => true do |t|
    t.column :name, :string
    t.column :accountID, :integer
  end

  create_table :comments, :force => true do |t|
    t.column :commentable_id, :integer
    t.column :commentable_type, :string
    t.column :account_id, :integer
  end

end

class Account < ActiveRecord::Base
  has_many :projects
end

class Organization < ActiveRecord::Base
end

class Product < ActiveRecord::Base
  acts_as_tenant :organization
end

class Project < ActiveRecord::Base
  has_one :manager
  has_many :tasks
  acts_as_tenant :account

  validates_uniqueness_to_tenant :name
end

class Manager < ActiveRecord::Base
  belongs_to :project
  acts_as_tenant :account
end

class Task < ActiveRecord::Base
  belongs_to :project
  default_scope -> { where(:completed => nil).order("name") }

  acts_as_tenant :account
  validates_uniqueness_of :name
end

class UnscopedModel < ActiveRecord::Base
  validates_uniqueness_of :name
end

class AliasedTask < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :project_alias, :class_name => "Project"
end

class UniqueTask < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :project
  validates_uniqueness_to_tenant :name, scope: :user_defined_scope
end

class CustomForeignKeyTask < ActiveRecord::Base
  acts_as_tenant(:account, :foreign_key => "accountID")
  validates_uniqueness_to_tenant :name
end

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :task, -> { where(comments: { commentable_type: 'Task'  })  }, foreign_key: 'commentable_id'
  acts_as_tenant :account
end

class GlobalProject < ActiveRecord::Base
  self.table_name = 'projects'

  acts_as_tenant :account, has_global_records: true
  validates_uniqueness_to_tenant :name
end
