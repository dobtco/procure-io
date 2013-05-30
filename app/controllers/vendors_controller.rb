class VendorsController < ApplicationController
  # Load
  load_resource

  # Authorize
  before_filter :authorize, only: [:new, :create]
  before_filter except: [:new, :create] { |c| c.authorize! :collaborate_on, @vendor }

  def show
  end

  def admin
    redirect_to vendor_bids_path(@vendor)
  end

  def new
  end

  def create
    if @vendor.update_attributes(vendor_params)
      @vendor.vendor_team_members.create(user: current_user, owner: true)
      flash[:success] = "Your vendor profile has been created. Why don't you add some " +
                        "<a href='#{members_vendor_path(@vendor)}'>team members</a>?"
      redirect_to edit_vendor_path(@vendor)
    else
      render :new
    end
  end

  def edit
    current_user.read_notifications(@vendor)
  end

  def update
    if @vendor.update_attributes(vendor_params)
      flash[:success] = "Profile updated successfully."
      redirect_to edit_vendor_path(@vendor)
    else
      render :edit
    end
  end

  def destroy
    @vendor.destroy
    redirect_to root_path
  end

  def members
  end

  def add_member
    @user = User.where(email: params[:email]).first ||
            User.invite!(params[:email], current_user)

    if @user
      @vendor.users << @user
      @user = @vendor.users.where(id: @user.id).first # add 'owner' attribute when selecting
    end
  end

  def remove_member
    @vendor_team_member = @vendor.vendor_team_members.where(user_id: params[:user_id]).first
    @vendor.vendor_team_members.delete(@vendor_team_member) unless @vendor_team_member.owner
    render_json_success
  end

  def assign_ownership
    if @vendor.owner == current_user
      @vendor.vendor_team_members.update_all(owner: false)
      @vendor.vendor_team_members.where(user_id: params[:user_id]).first.update_attributes(owner: true)
    end

    redirect_to :back
  end

  def leave
    if @vendor.vendor_team_members.count < 2
      flash[:error] = "Can't remove yourself, as you're the last team member. Did you want to destroy this vendor account instead?"
      return redirect_to edit_vendor_path
    end

    @vendor.vendor_team_members.where(user_id: current_user.id, owner: false).first.destroy
    redirect_to root_path
  end

  private
  def vendor_params
    params.require(:vendor).permit(:name, :email, :address_line_1, :address_line_2, :city, :state, :zip)
  end
end