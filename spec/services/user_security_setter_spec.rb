require 'rails_helper'
require 'cancan/matchers'

describe UserSecuritySetter do
  let(:input_user) {create(:user)}

  it 'adds roles to the user' do
    role = create(:role, name: 'User')
    role2 = create(:role, name: 'Admin')
    expect(input_user.roles).to be_empty
    user = UserSecuritySetter.perform(input_user.id, {role_ids: [role.id, role2.id]})
    expect(user.user_roles).to match_array([role,role2])
  end

  it 'removes roles from the user' do
    role = create(:role)
    input_user.roles << role
    expect(input_user.user_roles.first.role).to eq(role)
    user = UserSecuritySetter.perform(input_user.id,{role_ids: []})
    user.save
    expect(user.user_roles).to be_empty
  end

  it 'does not add a role that does not exist' do
    user = UserSecuritySetter.perform(input_user.id,{role_ids: [55]})
    expect(user.user_roles).to be_empty
  end

  it 'modifies status' do
    user = UserSecuritySetter.perform(input_user.id,{status: 'new status!'})
    expect(user.status).to eq('new status!')
  end

  it 'sets status to nil if status is not present' do
    user = UserSecuritySetter.perform(input_user.id,{})
    expect(user.status).to be_nil
  end

  it 'handles roles being nil in params' do
    user = UserSecuritySetter.new(input_user.id,{})
    expect(user.instance_variable_get(:@new_roles)).to match_array([])
  end

  it 'errors out with no user id' do
    expect{UserSecuritySetter.perform(3,{})}.to raise_error(ActiveRecord::RecordNotFound)
  end

end