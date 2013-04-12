class OfficersController < ApplicationController
  before_filter :only_unauthenticated_user, only: [:invite, :post_invite]
  before_filter :invite_exists?, only: [:invite, :post_invite]
  before_filter :authenticate_officer!, except: [:invite, :post_invite]
  before_filter :officer_exists?, only: [:edit, :update]

  def index
    authorize! :read, Officer
    @officers = Officer.order("id").paginate(page: params[:page])
  end

  def invite
    if GlobalConfig.instance[:passwordless_invites_enabled]
      flash[:success] = "Heya! We logged you in without a password, but you can always create one if you want. " +
                        "If you don't create one, you can just use the same invite link to login in the future."

      UserSession.create(@user)
      redirect_to mine_projects_path
    end
  end

  def post_invite
    @user.update_attributes(password: params[:user][:password])
    @user.reset_perishable_token!
    UserSession.create(@user)
    redirect_to mine_projects_path
  end

  def edit
    authorize! :update, @officer
  end

  def update
    authorize! :update, @officer
    @officer.update_attributes(officer_params)
    flash[:success] = "Officer successfully updated."
    redirect_to officers_path
  end

  def typeahead
    render json: User.where("email LIKE ?", "%#{params[:query]}%").where(owner_type: "Officer").order("email").pluck("email").to_json
  end

  private
  def officer_exists?
    @officer = Officer.find(params[:id])
  end

  def officer_params
    filtered_params = params.require(:officer).permit(:name, :title, :email, :role_id, user_attributes: [:id, :email])

    role = Role.find(filtered_params[:role_id])
    filtered_params.delete(:role_id) unless role.assignable_by_officer?(current_officer)

    filtered_params
  end

  def invite_exists?
    @user = User.where("crypted_password IS NULL").where(perishable_token: params[:token]).first
    redirect_to(root_path) unless @user
  end
end
