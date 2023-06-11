module Admin::FontsHelper

  def font_form_params(font)
    form_hash = font.new_record? ? { url: admin_client_fonts_path } : { url: admin_client_font_path, method: :put }
    form_hash.merge(html: { class: 'form-horizontal' })
  end

end