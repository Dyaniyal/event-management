module BadgePdfsHelper
  def badge_styles
    top = @badge_pdf.try(:top) ? @badge_pdf.top : "0"
    bottom = @badge_pdf.try(:bottom) ? @badge_pdf.bottom : "0"
    right = @badge_pdf.try(:right) ? @badge_pdf.right : "0"
    left = @badge_pdf.try(:left) ? @badge_pdf.left : "0"
    text_alignment = @badge_pdf.try(:print_alignment) ? @badge_pdf.print_alignment : "center"
    color = @badge_pdf.try(:color) ? @badge_pdf.color : "fff"
    font_family = @badge_pdf.try(:printing_font_style) ? @badge_pdf.printing_font_style : "micross"
    width = @badge_pdf.try(:badge_width).present? ? @badge_pdf.badge_width.to_i - 10 : '396'
    "width: #{width}px; top: #{top}px; left: #{left}px; right: #{right}px; bottom: #{bottom}px; color: ##{color}; text-align: #{text_alignment}; font-family: #{font_family};"
  end
end