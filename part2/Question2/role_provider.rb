class RoleProvider
    BLOCKED_ROLE = "Denied"
    ROOT_BR = "RootOrg"

    def initialize(role_maps)
        @role_maps = role_maps.nil? ? [] : role_maps
    end

    def find_role(org_name)
        @role_maps.find { |rm| rm.org == org_name }
    end

    def find_role_in(org)
        role ||= BLOCKED_ROLE

        unless has_denied_role?(org.name)
            # Look for the requested role in the current org
            role = find_role_in_org(org.name, role)

            # Look for the requested role in the parent org
            role = find_role_in_org(org.parent, role)

            # Find in the Root Org
            role = find_role_in_org(ROOT_BR, role)
        end

        role
    end

    def find_role_in_org(org_name, current_role)
        role ||= BLOCKED_ROLE

        if(current_role != BLOCKED_ROLE)
            role = current_role
        else
            org = find_role(org_name)
            role = org.role_name if !org.nil?
        end
        role
    end

    def has_denied_role?(org_name)
        @role_maps.any? { |rm| rm.role_name == BLOCKED_ROLE && rm.org == org_name }
    end
end