class RatingSerializer < ActiveModel::Serializer
  attributes :id, :ratable_id, :ratable_type, :rating, :out_of, :comments, :rated_by
end
