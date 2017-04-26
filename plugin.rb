# name: discourse-oauth2-participa
# about: Enable login via Participa
# version: 1.0.0
# authors: Carles Muiños <carles@adabits.org>
# url: https://github.com/adab1ts/discourse-oauth2-participa

require 'auth/oauth2_authenticator'

# Plugin::Instance#gem(name, version, opts = {})
# See: PluginGem.load(path, name, version, opts=nil)
gem 'omniauth-participa', '1.0.0'

enabled_site_setting :participa_enabled


class Auth::ParticipaAuthenticator < ::Auth::OAuth2Authenticator

  # Auth::OAuth2Authenticator#name
  def name
    'participa'
  end

  # Auth::Authenticator#register_middleware(omniauth)
  def register_middleware(omniauth)
    omniauth.provider :participa,
                      setup: lambda { |env|
                        strategy = env['omniauth.strategy']
                        strategy.options[:client_id] = SiteSetting.participa_client_id
                        strategy.options[:client_secret] = SiteSetting.participa_client_secret
                        strategy.options[:client_options] = {
                          site: SiteSetting.participa_site,
                          authorize_url: SiteSetting.participa_authorize_url,
                          token_url: SiteSetting.participa_token_url,
                          endpoint_url: SiteSetting.participa_endpoint_url
                        }
                      }
  end

  # Auth::OAuth2Authenticator#after_authenticate(auth_token)
  # See:
  # - https://github.com/discourse/discourse/blob/5dbd6a304bed5400be481d71061d3e3ebb4d6785/lib/auth/oauth2_authenticator.rb#L13
  # - https://github.com/adab1ts/omniauth-participa/blob/master/lib/omniauth/strategies/participa.rb#L39
  # Trace:
  # - https://github.com/discourse/discourse/blob/93556bb950d4c58e3e08ae927ccb32408fead9f4/config/routes.rb#L458
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L39
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L63
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L104
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L115
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L123
  # Authenticaton Denied:
  # - https://github.com/intridea/omniauth-oauth2/blob/master/lib/omniauth/strategies/oauth2.rb#L69
  # - https://github.com/omniauth/omniauth/blob/master/lib/omniauth/strategy.rb#L478
  # - https://github.com/omniauth/omniauth/blob/640e5d9cd55225390b9547dcd5e1b3da827102f6/lib/omniauth.rb#L36
  # - https://github.com/omniauth/omniauth/blob/master/lib/omniauth/failure_endpoint.rb#L2
  # - https://github.com/omniauth/omniauth/blob/640e5d9cd55225390b9547dcd5e1b3da827102f6/lib/omniauth/failure_endpoint.rb#L19
  # - https://github.com/omniauth/omniauth/blob/640e5d9cd55225390b9547dcd5e1b3da827102f6/lib/omniauth.rb#L37
  # - https://github.com/omniauth/omniauth/blob/640e5d9cd55225390b9547dcd5e1b3da827102f6/lib/omniauth/failure_endpoint.rb#L30
  def after_authenticate(auth_token)
    result = super
    result.extra_data[:profile] = auth_token[:extra]

    user = result.user
    user_profile = result.extra_data[:profile][:raw_info]

    # TODO: user account auto-creation
    # See:
    # - https://github.com/discourse/discourse/blob/5943543ec30fe5194b0126bd05477e7969b20036/app/controllers/users_controller.rb#L295
    # - https://github.com/discourse/discourse/blob/76dd6933d2955aba01ef12fff599fcdcd1068d2d/app/services/user_authenticator.rb#L23
    # - https://meta.discourse.org/t/disable-create-account-screen-for-cas-logins/11334/6
    # create_user_account(auth) unless user
    update_user_email(user, user_profile)
    update_user_groups(user, user_profile) if SiteSetting.participa_manage_groups

    result
  end

  # Auth::OAuth2Authenticator#after_create_account(user, auth)
  # See:
  # - https://github.com/discourse/discourse/blob/5dbd6a304bed5400be481d71061d3e3ebb4d6785/lib/auth/oauth2_authenticator.rb#L44
  # - https://github.com/adab1ts/omniauth-participa/blob/master/lib/omniauth/strategies/participa.rb#L39
  # Trace:
  # - https://github.com/discourse/discourse/blob/93556bb950d4c58e3e08ae927ccb32408fead9f4/config/routes.rb#L458
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L39
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L63
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L108
  # - https://github.com/discourse/discourse/blob/master/lib/auth/result.rb#L20
  # - https://github.com/discourse/discourse/blob/c99f4260c0dc021a0fee743d4f715f41191c6391/app/controllers/users/omniauth_callbacks_controller.rb#L69
  # - https://github.com/discourse/discourse/blob/7b6242bfbb52486318d0136d230bc2c5790a52dd/app/assets/javascripts/discourse/controllers/create-account.js.es6#L193
  # - https://github.com/discourse/discourse/blob/5943543ec30fe5194b0126bd05477e7969b20036/app/controllers/users_controller.rb#L339
  # - https://github.com/discourse/discourse/blob/76dd6933d2955aba01ef12fff599fcdcd1068d2d/app/services/user_authenticator.rb#L5
  # - https://github.com/discourse/discourse/blob/5943543ec30fe5194b0126bd05477e7969b20036/app/controllers/users_controller.rb#L355
  # - https://github.com/discourse/discourse/blob/76dd6933d2955aba01ef12fff599fcdcd1068d2d/app/services/user_authenticator.rb#L24
  # - https://github.com/discourse/discourse/blob/5943543ec30fe5194b0126bd05477e7969b20036/app/controllers/users_controller.rb#L361
  # - https://github.com/discourse/discourse/blob/7b6242bfbb52486318d0136d230bc2c5790a52dd/app/assets/javascripts/discourse/controllers/create-account.js.es6#L200
  # - https://github.com/discourse/discourse/blob/3dcad123f5a7cf0de3c4a57554a752b96a214943/config/routes.rb#L324
  def after_create_account(user, auth)
    super

    user_profile = auth[:extra_data][:profile][:raw_info]

    update_user_groups(user, user_profile) if SiteSetting.participa_manage_groups

    true
  end


  private


  def update_user_email(user, user_profile)
    new_email = user_profile['email']

    if user && new_email && (user.email != new_email)
      begin
        user.update_columns(email: new_email)
      rescue
        used_by = User.find_by(email: new_email).try(:username)
        Rails.logger.warn("FAILED to update email for #{user.username} to #{new_email} cause it is in use by #{used_by}")
      end
    end
  end

  # See: https://github.com/discourse/discourse/blob/f34907b5235b435a61a6eafd51c06831356e6f16/app/models/discourse_single_sign_on.rb#L108
  def update_user_groups(user, user_profile)
    if user
      begin
        new_groups = user_profile['list_groups']
        current_groups = Group.joins(:group_users).where(groups: {automatic: false}, group_users: {user_id: user.id}).pluck(:name)

        groups_to_add = new_groups - current_groups
        if groups_to_add.length > 0
          Group.where(name: groups_to_add, automatic: false).pluck(:id).each do |id|
            GroupUser.create(group_id: id, user_id: user.id)
          end
        end

        groups_to_remove = current_groups - new_groups
        if groups_to_remove.length > 0
          GroupUser
            .where(user_id: user.id)
            .where('group_id IN (SELECT id FROM groups WHERE name in (?))', groups_to_remove)
            .destroy_all
        end
      rescue => e
        Rails.logger.error("FAILED to update groups for #{user.username} => #{e}")
      end
    end
  end

end


# Plugin::Instance#auth_provider(opts)
# See: Plugin::AuthProvider.auth_attributes
auth_provider title: 'via Participa',
              message: 'Log in via Participa',
              enabled_setting: 'participa_enabled',
              full_screen_login: true,
              authenticator: Auth::ParticipaAuthenticator.new('participa', trusted: true)

# Plugin::Instance#register_css
register_css <<CSS
  .btn-social.participa {
    background: #6d6d6d
  }
CSS
