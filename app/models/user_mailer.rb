class UserMailer < ActionMailer::Base

  helper "spree/base"


  def reset_password_instructions(user)

    @edit_password_reset_url = edit_user_password_url(:reset_password_token => user.reset_password_token)

    mail(:to => user.email,
         :subject => default_url_options[:host] + ' ' + I18n.t("password_reset_instructions"))
  end

end

