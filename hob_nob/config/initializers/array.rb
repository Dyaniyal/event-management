require 'spreadsheet'

class Array

  def to_xls(options = {}, &block)
    #return '' if self.empty?
    model_name = nil
    if self.empty?
      if options[:model_name] == "product_occasion"
        model_name = ProductOccasion
      elsif options[:model_name] == "product_gift"
        model_name = ProductGift
      elsif options[:model_name] == "product_genre"
        model_name = ProductGenre
      elsif options[:model_name] == "product_my_style"
        model_name = ProductMyStyle
      elsif options[:model_name] == "assets_product"
        model_name = AssetsProduct
      else
        if options[:filename] == "user_polls"
          model_name = "UserPoll".constantize
        elsif options[:filename] == "user_feedbacks"
          model_name = "UserFeedback".constantize
        elsif options[:filename] == "comments"
          model_name = "comment".constantize
        elsif options[:filename] == "likes"
          model_name = "Like".constantize
        else
          model_name = options[:model_name].constantize rescue nil
        end
      end
    else
      model_name = self.first.class
    end

    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    columns = []

    if options[:only].present?
      columns = Array(options[:only]).map(&:to_sym)
    elsif options[:except].present?
      columns = model_name.column_names.map(&:to_sym) - Array(options[:except]).map(&:to_sym)
    elsif options[:all]
      columns = model_name.column_names.map(&:to_sym)
    end

    if options[:methods].present?
      columns += Array(options[:methods])
    end

    return '' if columns.empty?

    sheet.row(0).concat(columns.map(&:to_s).collect{|s|
      if ["product_occasion", "product_gift", "product_genre", "product_my_style"].include?(options[:model_name])
        s.gsub("_", " ")
      else
        s.gsub("_", " ").titleize
      end
    })

    self.each_with_index do |obj, index|
      if block
        sheet.row(index + 1).replace(columns.map { |column| block.call(column, obj.send(column)) })
      elsif options[:only_export_column].present? and options[:only_export_column] =="true"        
      else
        sheet.row(index + 1).replace(columns.map { |column|
          send_method = obj.send(column) rescue false
          unless send_method
            a = obj.class.respond_to? column
            if a
              #obj.class.send(column, )
              send_method = obj.class.send(column, obj) rescue ""
            end
          end
          send_method
        })
      end
    end

    book.write(xls_report)

    xls_report.string
  end

  def to_url_xls(options = {}, &block)
    return '' if self.empty?
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    sheet.row(0).concat(["URL", "Title", "Description", "Keywords", "OG Description", "OG Title", "OG Type", "OG URL", "OG Site Name", "FB Admins", "Content Type", "Robots", "Google Site Verification"])
    self.each_with_index do |obj, index|
      meta_tag = MetaTag.find_by_url(obj)
      @classification = Classification.find_by_route_url(obj[1..-1]) if meta_tag.blank?
      if meta_tag.blank? and @classification.blank? and obj =~ /\d/
        code = obj.split("/").last.split("-").last
        @product = Product.unscoped.find_by_code(code)
      end
      if meta_tag.present?
        sheet.row(index + 1).replace([obj, meta_tag.title, meta_tag.description, meta_tag.keywords, meta_tag.og_description, meta_tag.og_title, meta_tag.og_type, meta_tag.og_url, meta_tag.og_site_name, meta_tag.fb_admins, meta_tag.content_type, meta_tag.robots, meta_tag.google_site_verification])
      elsif @classification.present?
        sheet.row(index + 1).replace([obj, @classification.name, @classification.description, "", @classification.description, @classification.name, 'Product', 'http://velvetcase.com'+obj, 'velvetcase', "Velvetcase", "Velvetcase", "Velvetcase", "Velvetcase"])
      elsif @product.present?
        sheet.row(index + 1).replace([obj, @product.name, @product.description, "Velvetcase", @product.description, @product.name, 'Product', 'http://velvetcase.com'+obj, 'velvetcase', "Velvetcase", "Velvetcase", "Velvetcase", "Velvetcase"])
      else
        sheet.row(index + 1).replace([obj, "Velvetcase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase", "VelvetCase"])
      end
    end

    book.write(xls_report)

    xls_report.string
  end

  def array_to_xls(options = {}, &block)
    return '' if options[:only].empty?

    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    columns = []

    if options[:only].present?
      columns = Array(options[:only]).map(&:to_sym)
    elsif options[:except].present?
      columns = model_name.column_names.map(&:to_sym) - Array(options[:except]).map(&:to_sym)
    elsif options[:all]
      columns = model_name.column_names.map(&:to_sym)
    end

    sheet.row(0).replace(options[:only])

    if options[:rows].present?
      index = options[:rows].count
      self.each_with_index do |obj, index|
        sheet.row(index + 1).replace(options[:rows][index].flatten)
      end
    end

    book.write(xls_report)
    xls_report.string
  end

  def to_reports_xls(options = {}, &block)
    return '' if self.empty?
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    sheet.row(0).default_format = Spreadsheet::Format.new(:weight => :bold)
    self.each_with_index do |label, index|
      sheet[0, index] = label
      # sheet.column(index).width = 25
    end
    row_index = 0
    self.each do |row|
      row.each_with_index do |cell, cell_index|
        sheet[row_index, cell_index] = cell
      end
      row_index += 1
    end

    book.write(xls_report)
    xls_report.string
  end


end

