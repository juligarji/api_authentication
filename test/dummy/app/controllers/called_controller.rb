class CalledController < ApplicationController
  before_action :authenticate_user

  def test
    render json:{hola:"test"}
  end
end
