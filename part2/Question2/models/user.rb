class User
    attr_accessor :user_id, :username

    def initialize(user_id, username)
        @user_id = user_id
        @username = username
    end

    def self.get_current_user
        return User.new
    end
end

class UserRoles
    attr_accessor :user_id

    def initialize(id, user_id, org, role_name)
        @id = id
        @user_id = user_id
        @org = org
        @role_name = role_name
    end

    def find_by(filter)
    end
end
