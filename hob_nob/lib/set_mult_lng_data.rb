module SetMultLngData

	def self.set_model_details(old_objekt)
    if old_objekt.parent_id.blank?
      if old_objekt.class == Winner
        multilingual_events = Event.where(parent_id:old_objekt.award.event_id)
      elsif old_objekt.class == Image
        multilingual_events = Event.where(parent_id:old_objekt.imageable_id)
      else
        multilingual_events = Event.where(parent_id: old_objekt.class == Theme ? old_objekt.event_ids : old_objekt.event_id)
      end
      if multilingual_events.present?
        multilingual_events.each do |event|
          new_objekt = old_objekt.dup
          new_objekt.event_id = event.id if old_objekt.class != Winner and old_objekt.class != Image
          new_objekt.parent_id = old_objekt.id
          if old_objekt.class == Image
            new_objekt.imageable_id = event.id
            new_folder = Folder.find_or_create_by(:event_id => event.id, :name => old_objekt.folder.name) if old_objekt.folder.present?
            new_objekt.folder_id = new_folder.present? ? new_folder.id : nil
          end
          if old_objekt.class == Agenda and old_objekt.agenda_track_id.present?
            agenda_track = AgendaTrack.find_by_parent_id(old_objekt.agenda_track_id)
            new_objekt.agenda_track_id = agenda_track.id if agenda_track.present?
          end  
          if old_objekt.class == Winner
            award = event.awards.where(:parent_id=>old_objekt.award_id).first
            new_objekt.award_id = award.id if award.present? 
          end            
          if old_objekt.class == Feedback
            feedback_forms = FeedbackForm.where(parent_id: old_objekt.feedback_form_id,event_id:event.id)
            new_objekt.feedback_form_id = feedback_forms.first.id if feedback_forms.present?
          end
          if old_objekt.class == Poll and old_objekt.select_session.present?
            selected_session = event.agendas.find_by_parent_id(old_objekt.select_session)
            new_objekt.select_session = selected_session.id if selected_session.present?
          end
          new_objekt.save
        end
      end
    end 
	end	

end