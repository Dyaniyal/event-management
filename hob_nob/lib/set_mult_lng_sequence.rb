module SetMultLngSequence
	
  def self.set_seuqence(record)
		model_name = record.class.name.constantize
		multi_lng_model = model_name.where(parent_id:record.id)		
		# multi_lng_model.update_all(sequence:record.sequence) if multi_lng_model.present?
		multi_lng_model.map{|x| x.update_attributes(:sequence => record.sequence)} if multi_lng_model.present?
	end

	def self.remve_mlt_lng_data(record)
		if record.class == Image
			model_name = record.class.name.constantize
			multi_lng_model = model_name.where(parent_id:record.id,imageable_type: "Event")	
			multi_lng_model.destroy_all if multi_lng_model.present?
		else
			model_name = record.class.name.constantize
			multi_lng_model = model_name.where(parent_id:record.id)
			multi_lng_model.destroy_all if multi_lng_model.present?		
		end
	end
end	