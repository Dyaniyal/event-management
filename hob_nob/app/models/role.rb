class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  validates :name, :presence =>true
         
  scopify

  def self.get_role_on_resource(resource_type, resource_id, user_id)
  	Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', resource_type, resource_id, user_id).last
  end

  def self.not_manage_user_dropdown(role)
    if role == 'licensee_admin'
      ['licensee_admin']
    elsif role == 'client_admin'
      ['licensee_admin', 'client_admin', 'db_manager']
    elsif role == 'event_admin'
      ['licensee_admin', 'client_admin', 'event_admin', 'db_manager']
    elsif role == 'moderator'
      ['licensee_admin', 'client_admin', 'event_admin', 'moderator', 'db_manager']
    end    
  end

  def self.get_user_role_list(user)
    if user.has_role? :licensee_admin
      ["client_admin", "event_admin", "moderator"]
    elsif user.has_role? :client_admin
      ["event_admin", "moderator"]
    elsif user.has_role? :event_admin
      ["moderator"]
    else
      []   
    end      
  end

  def self.get_client_role(id,current_user)
    client = Client.find_by_id(id)
    users = []
    if client.present?
      role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', client.class.name, client.id, current_user.id).uniq.last
      users = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name NOT IN (?)', client.class.name, client.id, Role.not_manage_user_dropdown(role.name)).uniq if role.present?
    end
    users
 end
end
