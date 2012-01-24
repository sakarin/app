class UserPasswordsController < Devise::PasswordsController
  include SpreeBase
  helper :users, 'spree/base'

  def new

    if Rails.env.production?
      ActionMailer::Base.default_url_options[:host] = current_store.email
    else
      ActionMailer::Base.default_url_options[:host] = current_store.email.to_s + ":" + request.port.to_s
    end
    super

  end

  def create

    super

  end

  def edit
    super
  end

  def update
    super
  end
end
