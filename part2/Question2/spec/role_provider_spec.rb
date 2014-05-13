require_relative '../role_provider'
require_relative '../models/role_map'

describe RoleProvider do
    before(:each) do
        @role_map = double()
        @role_map.stub(:user_id) { 1 }

        @organization = double()
        @organization.stub(:name) { 'Org1' }
        @organization.stub(:parent) { 'RootOrg' }
    end

    it "should show 'Denied' if nil is passed as roles" do
        role_checker = RoleProvider.new(nil)
        role_name = role_checker.find_role_in(@organization)
        expect(role_name).to eq('Denied')
    end

    describe "when the user is an 'Admin'" do
        it "should show 'Admin' in the current organization" do
            role_map = RoleMap.new('Org1', 'Admin', 'RootOrg')

            role_checker = RoleProvider.new([role_map])
            role_name = role_checker.find_role_in(@organization)
            expect(role_name).to eq('Admin')
        end

        it "the parent organization" do
            role_map = RoleMap.new('RootOrg', 'Admin', nil)

            role_checker = RoleProvider.new([role_map])
            role_name = role_checker.find_role_in(@organization)
            expect(role_name).to eq('Admin')
        end
    end

    describe "when the user is a 'User'" do
        it "should show 'User' in the current organization" do
            role_map = RoleMap.new('Org1', 'User', 'RootOrg')

            role_checker = RoleProvider.new( [role_map])
            role_name = role_checker.find_role_in(@organization)
            expect(role_name).to eq('User')
        end

        it "should show 'User' in the parent organization" do
            role_map = RoleMap.new('RootOrg', 'User', nil)

            role_checker = RoleProvider.new( [role_map])
            role_name = role_checker.find_role_in(@organization)
            expect(role_name).to eq('User')
        end
    end

    describe "when the role is set to 'Denied'" do
        describe "when user has the role of 'Denied'" do
            it "should show 'Denied' in the current organization" do
                role_map = RoleMap.new('Org1', 'Denied', 'RootOrg')

                role_checker = RoleProvider.new( [role_map] )
                role_name = role_checker.find_role_in(@organization)
                expect(role_name).to eq('Denied')
            end

            it "should show 'Denied' in the parent organization" do
                @organization = double()
                @organization.stub(:name) { 'ChildOrg1' }
                @organization.stub(:parent) { 'Org1' }

                role_map = RoleMap.new('Org1', 'Denied', 'RootOrg')

                role_checker = RoleProvider.new([role_map])
                role_name = role_checker.find_role_in(@organization)
                expect(role_name).to eq('Denied')
            end
        end

        it "show show 'Denied' if a role is not specfied" do
            role_map = RoleMap.new('Org1', 'Denied', 'RootOrg')

            role_checker = RoleProvider.new( [] )
            role_name = role_checker.find_role_in(@organization)
            expect(role_name).to eq( 'Denied' )
        end
    end

    describe "Role Inheritance" do
        before(:each) do
            @child_org1 = double()
            @child_org1.stub(:name){'ChildOrg1'}
            @child_org1.stub(:parent){'Org1'}

            @child_org2 = double()
            @child_org2.stub(:name){'ChildOrg2'}
            @child_org2.stub(:parent){'Org1'}
        end

        it "should inherit the 'Admin' role from parent" do
            role_map = RoleMap.new('Org1', 'Admin', 'RootOrg')
            role_checker = RoleProvider.new([role_map])
            role_child1 = role_checker.find_role_in(@child_org1)
            role_child2 = role_checker.find_role_in(@child_org2)

            expect(role_child1).to eq('Admin')
            expect(role_child2).to eq('Admin')
        end

        it "should inherit the 'Admin' role from the RootOrg" do
            role_map = RoleMap.new('RootOrg', 'Admin', nil)
            role_checker = RoleProvider.new([role_map])
            role_child1 = role_checker.find_role_in(@child_org1)
            role_child2 = role_checker.find_role_in(@child_org2)

            expect(role_child1).to eq('Admin')
            expect(role_child2).to eq('Admin')
        end

        it "should not inherit anything if the current role is 'Denied' " do
            role_map = RoleMap.new('RootOrg', 'User', nil)
            denied_role_map = RoleMap.new('ChildOrg1', 'Denied', 'Org1')

            role_checker = RoleProvider.new([role_map, denied_role_map])
            role_child1 = role_checker.find_role_in(@child_org1)
            role_child2 = role_checker.find_role_in(@child_org2)

            expect(role_child1).to eq('Denied')
            expect(role_child2).to eq('User')
        end
    end
end