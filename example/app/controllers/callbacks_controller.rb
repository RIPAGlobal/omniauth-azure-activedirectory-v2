class CallbacksController < Devise::OmniauthCallbacksController

  include Devise::Controllers::Rememberable

  def azure_activedirectory_v2
    response_params = request.env['omniauth.auth']['info']
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user&.persisted?
      flash[:notice] = "Authenticated with AzureAD"
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:danger] = "AzureAD authentication failed"
      session["devise.azuread_data"] = request.env["omniauth.auth"]
      redirect_back(fallback_location: root_path)
    end
  end

end
