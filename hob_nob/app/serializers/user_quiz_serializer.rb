class UserQuizSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :quiz_id, :answer
end
