class GreeterController < ApplicationController
  def hello
	@time = Time.now
  end

  def goodbye
  end
end
