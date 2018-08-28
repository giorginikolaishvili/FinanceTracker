class UsersController < ApplicationController
  def my_portfolio
    @user = current_user
  end

  def my_friends
    @friendships = current_user.friends
  end

  def show
    @user = User.find(params[:id])
  end

  def add_friend
    friend = User.find(params[:friend])
    current_user.friendships.build(friend_id: friend.id)
    if current_user.save
      flash[:success] = "friend added"
    else
      flash[:danger] = "friend not added error"
    end
    redirect_to my_friends_path
  end

  def search
    if params[:search_param].blank?
      flash.now[:danger] = "You have entered an empty search string"
    else
      @users = User.search(params[:search_param])
      @users = current_user.except_current_user(@users)
      flash.now[:danger] = "No users match" if @users.blank?
    end
    respond_to do |format|
      format.js {render partial: 'friends/result'}
    end
  end
end