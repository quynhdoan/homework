class OrgHierarchy
    attr_accessor :root_org, :parent_org, :role

    def initialize(root_org, parent_org, role)
        @root_org = root_org
        @parent_org = parent_org
        @role = role
    end
end