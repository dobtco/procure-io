class UsersController < Clearance::UsersController
  before_filter :load_user, only: [:accept_invite, :post_accept_invite]
  before_filter :only_logged_out_users, only: [:accept_invite, :post_accept_invite]

  def create
    @user = user_from_params

    if @user.save
      sign_in @user
      is_organization = params[:user][:vendor_or_organization] == 'organization'
      flash[:success] = "Great, your personal login has been created. Now, create a profile for " +
                        "your #{is_organization ? 'organization' : 'vendor'} account."
      redirect_to is_organization ? new_organization_path : new_vendor_path
    else
      render template: 'users/new'
    end
  end

  def accept_invite
  end

  def post_accept_invite
    @user.assign_attributes(user_params)

    if @user.save
      sign_in @user
      redirect_to root_path
    else
      render 'accept_invite'
    end
  end

  private
  def load_user
    @user = find_user_by_id_and_confirmation_token || not_found
  end

  def find_user_by_id_and_confirmation_token
    Clearance.configuration.user_model.
      find_by_id_and_confirmation_token params[:id], params[:token].to_s
  end

  def user_params
    params.require(:user).permit(:name, :password)
  end
end
