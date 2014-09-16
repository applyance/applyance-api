attributes :id, :name, :first_name, :last_name, :initials, :email, :is_verified, :created_at, :updated_at

child :avatar => :avatar do
  extends "attachments/_shallow"
end

child :roles => :roles do
  extends "roles/_shallow"
end
