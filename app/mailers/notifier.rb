class Notifier < ActionMailer::Base
  default from: "\"Password Reset\" <hibikimusicdb@gmail.com>"
  
  def welcome(user)
  end
  
  def password_reset_instructions(user)
    #For testing
    @host = 'http://localhost:3000/' 
    #For real environment
    #@host = 'http://71.63.131.110:8050/' 
    @url = @host + 'resetpassword?token=' + user.perishable_token
    
    mail(to: user.email, 
         subject: "Password Reset Instructions", 
         content_type: "text/html")
  end
end
