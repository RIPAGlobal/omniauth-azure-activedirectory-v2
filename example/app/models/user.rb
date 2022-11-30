class User < ApplicationRecord

  devise :database_authenticatable,
         :omniauthable, omniauth_providers: %i[azure_activedirectory_v2]

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_initialize.tap do |user|
      user.name = auth.info.name if user.name.blank?
      user.password = Devise.friendly_token[0,20]
      user.provider = auth.provider
      user.uid = auth.uid

      user.save
    end
  end

end
