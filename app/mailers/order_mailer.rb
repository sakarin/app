class OrderMailer < ActionMailer::Base
  helper "spree/base"

  def confirm_email(order, resend=false)
    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope =>'order_mailer.confirm_email')} ##{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end

  def cancel_email(order, resend=false)
    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'order_mailer.cancel_email')} ##{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end

  def payment_email(order, ppx_response, resend=false)
    @order = order
    @ppx_response = ppx_response
    subject = (resend ? "[DEBUG] " : "")
    subject += "#{Spree::Config[:site_name]} Payment of ##{order.number}"
    mail(:to => "sakarin.my@gmail.com",
         :subject => subject)
  end


end
