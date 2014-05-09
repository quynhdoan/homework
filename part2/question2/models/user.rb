class User
    attr_accessor :id, :name
    def self.current_user
        User.new
    end
end