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
