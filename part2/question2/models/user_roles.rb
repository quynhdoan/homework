class UserRoles
    attr_accessor :user_id

    def initialize(role_id, user_id, org, role)
        @role_id = role_id
        @user_id = user_id
        @org     = org
        @role    = role
    end
end