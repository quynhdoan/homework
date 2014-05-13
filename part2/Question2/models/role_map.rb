class RoleMap
    attr_accessor :org, :role_name, :org_parent

    def initialize(org_name, role, parent)
        @org = org_name
        @role_name = role
        @org_parent = parent
    end
end
