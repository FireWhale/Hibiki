class UserSession < Authlogic::Session::Base
  
  FormFields = [{type: "text", attribute: :name, label: "Username:"},
                {type: "text_password", attribute: :password, label: "Password:"},]
end
