# Run in discourse root:
# ./bin/docker/rake "plugin:spec['discourse-oauth2-participa']"
require 'rails_helper'

describe ::Auth::ParticipaAuthenticator do
  def info
    { email: 'jane.doe@acme.com', name: 'Jane Doe', username: 'Jane_Doe', admin: true }
  end

  def raw_info
    { id: '12345', email: 'jane.doe@acme.com', full_name: 'Jane Doe', username: 'Jane_Doe', admin: true, list_groups: ['group-1', 'group-2'] }
  end

  let(:authenticator) { ::Auth::ParticipaAuthenticator.new('participa', trusted: true) }

  describe '#after_authenticate' do
    let(:auth_token) {{ provider: 'participa', uid: '12345', info: info, extra: { raw_info: raw_info } }}

    context 'in any scenario' do
      before do
        ::Auth::ParticipaAuthenticator.any_instance.stubs(:update_user_email)
        ::Auth::ParticipaAuthenticator.any_instance.stubs(:update_user_groups)
      end

      it 'can authenticate and create a user record for already existing users' do
        user = Fabricate(:user, name: 'Jane Doe', email: 'jane.doe@acme.com')
        result = authenticator.after_authenticate(auth_token)

        expect(result.user.id).to eq(user.id)
      end

      it 'can create a proper result for non existing users' do
        result = authenticator.after_authenticate(auth_token)

        expect(result.user).to eq(nil)
        expect(result.name).to eq('Jane Doe')
        expect(result.email).to eq('jane.doe@acme.com')
      end

      it 'should manage email updates' do
        ::Auth::ParticipaAuthenticator.any_instance.expects(:update_user_email).once
        authenticator.after_authenticate(auth_token)
      end
    end

    context 'when group management is disabled' do
      before do
        ::Auth::ParticipaAuthenticator.any_instance.stubs(:update_user_email)
        SiteSetting.participa_manage_groups = false
      end

      it 'should not manage user\'s groups updates' do
        ::Auth::ParticipaAuthenticator.any_instance.expects(:update_user_groups).never
        authenticator.after_authenticate(auth_token)
      end
    end

    context 'when group management is enabled' do
      before do
        ::Auth::ParticipaAuthenticator.any_instance.stubs(:update_user_email)
        SiteSetting.participa_manage_groups = true
      end

      it 'should manage user\'s groups updates' do
        ::Auth::ParticipaAuthenticator.any_instance.expects(:update_user_groups).once
        authenticator.after_authenticate(auth_token)
      end

      # TODO: make it work
      # it 'should update user\'s groups' do
      #   user = Fabricate(:user, name: 'Jane Doe', email: 'jane.doe@acme.com')
      #   user.groups << Fabricate(:group, name: 'group-0')
      #   user.save
      #
      #   result = authenticator.after_authenticate(auth_token)
      #
      #   expect(result.user.groups.map(&:name)).to eq(%w[group-1 group-2])
      # end
    end
  end

  describe '#after_create_account' do
    let(:auth) {{ extra_data: { profile: { raw_info: raw_info } } }}

    before do
      @user = mock()
      @user.stubs(:id)

      Oauth2UserInfo.stubs(:create)
       ::Auth::ParticipaAuthenticator.any_instance.stubs(:update_user_groups)
    end

    context 'when group management is disabled' do
      before { SiteSetting.participa_manage_groups = false }

      it 'should not manage user\'s groups updates' do
        ::Auth::ParticipaAuthenticator.any_instance.expects(:update_user_groups).never
        authenticator.after_create_account(@user, auth)
      end
    end

    context 'when group management is enabled' do
      before { SiteSetting.participa_manage_groups = true }

      it 'should manage user\'s groups updates' do
        ::Auth::ParticipaAuthenticator.any_instance.expects(:update_user_groups).once
        authenticator.after_create_account(@user, auth)
      end
    end
  end
end
