class UsersController < ApplicationController

  def new
    @user = User.new

    respond_to do |format|
      format.html
    end
  end

  def index
    
  end

  def create
    @user = User.create!(params[:user])
    sign_in @user
    redirect_to  "http://localhost:3001/users/auth/doorkeeper"
  end

end
