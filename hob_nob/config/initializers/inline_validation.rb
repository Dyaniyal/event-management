ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  unless html_tag =~ /^<label/
    %{#{html_tag}<div class="field_with_errors"><span class="errorMessage" for="#{instance.send(:tag_id)}">#{instance.error_message.first}</span></div>}.html_safe
  else
    %{#{html_tag}}.html_safe
  end
end

