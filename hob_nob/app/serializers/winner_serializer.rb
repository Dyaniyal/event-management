class WinnerSerializer < ActiveModel::Serializer
  attributes :id, :award_id, :name, :sequence
end
