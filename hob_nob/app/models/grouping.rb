class Grouping < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  
  resourcify
  OPERATOR_SIGN = {"Greater than" => '>', "Greater than equal to" => '>=', "Less than" => '<', "Less than equal to" => '<=', "Equal to" => 'IN', "Not equal to" => 'NOT IN', 'Contains' => 'like', 'Not contains' => 'not like', 'Starts with' => 'like',  'Ends with' => 'like','In' => '=','Between two numbers' => 'between', 'Having blank records' => 'blank'}#, 'In' => '=', 'Between' => '='}
  attr_accessor :value, :validation, :options
  serialize :condition, Hash
  
  belongs_to :event

  #attr_accessor :attr1_value, :attr2_value, :attr3_value, :attr4_value, :attr5_value, :attr6_value, :attr7_value, :attr8_value, :attr9_value, :attr10_value, :attr11_value, :attr12_value, :attr13_value, :attr14_value, :attr15_value
  #attr_accessor :attr1_validation, :attr2_validation, :attr3_validation, :attr4_validation, :attr5_validation, :attr6_validation, :attr7_validation, :attr8_validation, :attr9_validation, :attr10_validation, :attr11_validation, :attr12_validation, :attr13_validation, :attr14_validation, :attr15_validation
  #attr_accessor :attr1_options, :attr2_options, :attr3_options, :attr4_options, :attr5_options, :attr6_options, :attr7_options, :attr8_options, :attr9_options, :attr10_options, :attr11_options, :attr12_options, :attr13_options, :attr14_options, :attr15_options
  validates :name, presence: { :message => "This field is required." }
  after_create :update_multi_lng_model_data 
  default_scope { order('created_at desc') }

  # def self.default_validation
  #   ["Greater than", "Greater than equal to", "Less than", "Less than equal to", "Equal to", "Not equal", 'Contains', 'Not contains', 'Starts with', 'Ends with']#, 'In', 'Between']
  # end 

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  
  
  def self.default_validation
    ["Equal to", "Not equal to", 'Starts with', 'Ends with', 'Contains','Greater than','Less than','Greater than equal to','Less than equal to','Between two numbers','Having blank records' ]#, 'In', 'Between']
  end

  def self.get_query_value(c, v)
    case c
    when 'Contains'
      "#{v}".split(",").map{|v|v.strip && "%"+v.strip+"%"}
    when 'Not contains'
      # "%#{v}%".split(',')
      "#{v}".split(",").map{|v|v.strip && "%"+v.strip+"%"}
    when 'Starts with'
      # "#{v}%".split(',')
      "#{v}".split(",").map{|v|v.strip && v.strip+"%"}
    when 'Ends with'
      # "%#{v}".split(',')
      "#{v}".split(",").map{|v|v.strip && "%"+v.strip}
    when 'Equal to'
      "#{v}".split(',').map{|v|v.strip}
    when 'Greater than'
      "#{v}".to_i rescue 0
    when 'Greater than equal to'
      "#{v}".to_i rescue 0
    when 'Less than'
      "#{v}".to_i rescue 0
    when 'Less than equal to'
      "#{v}".to_i rescue 0
    when 'Between two numbers'
      "#{v}".split(",").map{|v|v.strip.to_i} rescue 0
    when 'Not equal to'
      "#{v}".split(',').map{|v|v.strip}
    else
      "#{v}"
    end
  end

  def self.get_query_condition(c)
    OPERATOR_SIGN[c]
  end

  def self.get_default_grouping_fields(event)
    arr = event.invitee_structures.first.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field','mandate_attr2','mandate_attr3','mandate_attr4','mandate_attr5','mandate_attr6','mandate_attr7','mandate_attr8','mandate_attr9','mandate_attr10','mandate_attr11','mandate_attr12','mandate_attr13','mandate_attr14','mandate_attr15','mandate_attr16','mandate_attr17','mandate_attr18','mandate_attr19','mandate_attr20','mandate_attr21','mandate_attr22','mandate_attr23','mandate_attr24','mandate_attr25','mandate_attr26','mandate_attr27','mandate_attr28','mandate_attr29','mandate_attr30','expiry_date').map{|st| st[1].to_s.length > 0 ? st : nil}
    if arr.include?nil
      arr.compact!
    else
      arr
    end
  end

  def get_search_data_count(invitee_data)
    conditions = []
    #self.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil}
    self.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil} 
    self.condition.map{|condition| condition[1]['condition'].present? ? conditions << condition :nil}
    if conditions.present? and invitee_data.present?
      conditions.each do |condition|
        k = condition[0] 
        c = Grouping.get_query_condition(condition[1]['condition'])
        v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
        if false#c == "like"
          v.each do |value|
            invitee_data = invitee_data.where("#{k} #{c} (?)", value)
          end 
        elsif c == "blank"
          invitee_data = invitee_data.where(:"#{k}" => "")       
        elsif c == "between" and v.count == 2
          v1 = (v.first + 1)
          v2 = (v.last - 1)
          invitee_data = invitee_data.where("#{k} #{c} (?) and (?)", v1,v2)
        elsif c == "like" and v.count > 1
          # c = "IN"
          # v = v.map{|a|a.gsub("%", "")}
          like_invitees = []
          v.map{|x| like_invitees << invitee_data.where("#{k} #{c} (?)", x)}
          invitee_data = invitee_data.where(:id => like_invitees.compact.flatten.map(&:id))
        elsif c == "NOT IN" and v.blank?
          invitee_data = invitee_data.where.not("#{k} =?"," ")#invitee_data.where("#{k} #{c}")
        else
          invitee_data = invitee_data.where("#{k} #{c} (?)", v) if v.present?
        end
      end
    end
    invitee_data.present? ? invitee_data : []
  end

  def self.get_search_data_count(invitee_data, groupings)
    conditions = []
    invitee_data_ids = []
    if groupings.present?
      if groupings.flatten.map{|g| g.name}.include? "Default Group"
        invitee_data = invitee_data
      else
        groupings.flatten.each do |grouping|
          grouping.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil}
          if conditions.present? and invitee_data.present?
            conditions.each do |condition|
              k = condition[0] 
              c = Grouping.get_query_condition(condition[1]['condition'])
              v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
              if c == "like"
                v.each do |value|
                  invitee_data_ids += invitee_data.where("#{k} #{c} (?)", value)
                end 
              else
                invitee_data = invitee_data.where("#{k} #{c} (?)", v)
                invitee_data_ids += invitee_data.pluck(:id)
              end
            end
          else
            invitee_data_ids += invitee_data.pluck(:id)
          end
        end
        invitee_data_ids = invitee_data_ids.compact.uniq
        invitee_data = invitee_data.where(:id => invitee_data_ids) rescue []
      end
      invitee_data.present? ? invitee_data : []
    else
      []
    end
  end

  def self.get_multiple_group_data_count(invitee_data, groupings)
    # conditions = []
    invitee_data_ids = []
    invitee_data_list = invitee_data
    if groupings.present?
      if groupings.flatten.map{|g| g.present? and g.name}.include? "Default Group"
        invitee_data = invitee_data
      else
        groupings.flatten.each do |grouping|
          conditions = []
          grouping.condition.map{|condition| condition.present? and condition[1]['value'].present? ? conditions << condition : nil}  if grouping.present?
          if conditions.present? and invitee_data.present?
            conditions.each do |condition|
              k = condition[0]
              c = Grouping.get_query_condition(condition[1]['condition'])
              v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
              if c == "like"
                like_invitees = []
                v.map{|x| like_invitees << invitee_data_list.where("#{k} #{c} (?)", x)}
                invitee_data = invitee_data.where(:id => like_invitees.compact.flatten.map(&:id))
                # invitee_data_ids += invitee_data.pluck(:id)
              # elsif c == 'between'
              #   invitee_data = invitee_data.where("#{k} #{c} (?) AND (?)", v[0], v[1])
              elsif c == "between" and v.count == 2
                v1 = (v.first + 1)
                v2 = (v.last - 1)
                invitee_data = invitee_data.where("#{k} #{c} (?) and (?)", v1,v2)
                # invitee_data_ids += invitee_data.pluck(:id)
              else
                invitee_data = invitee_data.where("#{k} #{c} (?)", v)
                # invitee_data_ids += invitee_data.pluck(:id)
              end
            end
          else
            invitee_data = invitee_data_list
            invitee_data_ids += invitee_data.pluck(:id)
          end
          invitee_data_ids += invitee_data.pluck(:id)
          invitee_data = invitee_data_list
        end
        invitee_data_ids = invitee_data_ids.compact.uniq
        invitee_data = invitee_data.where(:id => invitee_data_ids) rescue []
      end
      invitee_data.present? ? invitee_data : []
    else
      []
    end
  end

  def self.get_data_count_for_db(invitee_data, groupings)
    # conditions = []
    invitee_data_ids = []
    invitee_data_list = invitee_data
    if groupings.present?
      if groupings.flatten.map{|g| g.name}.include? "Default Group"
        invitee_data = invitee_data
      else
        groupings.flatten.each do |grouping|
          conditions = []
          grouping.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil}
          if conditions.present? and invitee_data.present?
            conditions.each do |condition|
              k = condition[0]
              c = Grouping.get_query_condition(condition[1]['condition'])
              v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
              if c == "like"
                v.each do |value|
                  invitee_data_ids += invitee_data.where("#{k} #{c} (?)", value)
                end
              else
                invitee_data_deatils = invitee_data.where("#{k} #{c} (?)", v)
                invitee_data_ids += invitee_data_deatils.pluck(:id)
              end
            end
          else
            invitee_data_deatils = invitee_data_list
            invitee_data_ids += invitee_data_deatils.pluck(:id)
          end
        end
        invitee_data_ids = invitee_data_ids.compact.uniq
        invitee_data = invitee_data.where(:id => invitee_data_ids) rescue []
      end
      invitee_data.present? ? invitee_data : []
    else
      []
    end
  end

end