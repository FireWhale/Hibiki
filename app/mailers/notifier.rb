class Notifier < ActionMailer::Base
  default from: "\"Password Reset\" <hibikimusicdb@gmail.com>"
  
  def welcome(user)
  end
  
  def password_reset_instructions(user)
    @url = "#{Rails.application.secrets.email_url}reset_password?token=#{user.perishable_token}"
    
    mail(to: user.email, 
         subject: "Password Reset Instructions", 
         content_type: "text/html")
  end
end
