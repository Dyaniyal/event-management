class UserMailerPreview < ActionMailer::Preview

  def default_template
    user = User.first
    UserMailer.default_template(user)
  end

end