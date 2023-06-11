class ActiveRecord::Base
 
 	def as_json(opts={})
  	json = super(opts)
  	if opts[:event_check] == "event"
  		image = json["images"]
  		json.delete("images")
  		output = Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  		output["images"] = image
  		output
  	else
  		Hash[*json.map{|k, v| v == false ?  [k,v] : [k,v || ""]}.flatten]
  	end
	end
end