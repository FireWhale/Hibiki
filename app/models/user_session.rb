class UserSession < Authlogic::Session::Base
  
  #Constants
  FormFields = [{type: "text", attribute: :name, label: "Username:"},
                {type: "text_password", attribute: :password, label: "Password:"}]
                
  #generalize error message
  generalize_credentials_error_messages "Your login information is invalid"
end
