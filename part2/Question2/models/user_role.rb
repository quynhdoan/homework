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