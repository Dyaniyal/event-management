module UserRegistrationsHelper
  def check_box_conditions(key, option)
    (params.key?(:user_registration).present? and params[:user_registration][key].include?(option)) || @user_registration.send(key).try(:include?, option) ? 'checked' : false rescue false
  end
end