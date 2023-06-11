class Admin::FontsController < ApplicationController

  layout 'admin'

  before_filter :authenticate_user
  before_filter :find_client
  before_filter :find_object, only: :destroy

  def index
    @fonts = @client.fonts.includes(:documents)
  end

  def new
    build_font
  end

  def create
    @font = @client.fonts.new(font_params)
    if @font.save
      redirect_to admin_client_fonts_path(client_id: @client.id)
    else
      build_font
      render 'new'
    end
  end

  def destroy
    c_id, files = @font.client.id, @font.document_files
    destroy_files(c_id, files) if @font.destroy
    redirect_to admin_client_fonts_path
  end

  private

  def find_client
    @client = Client.find(params[:client_id])
  end

  def find_object
    @font = Font.find(params[:id])
  end

  def build_font
    @font = @font || @client.fonts.new(font_name: params[:font_name])
    @font_files = params[:counts] ? params[:counts].to_i : 1
    if (1..6).exclude?(@font_files)
      @font.errors.add(:file_count, 'Font files must be within 1 to 6')
      @font_files = 1
    end
    @font_files.times { |x| @font.documents.build } unless @font.documents.present?
  end

  def font_params
    params.require(:font).permit(:font_name, documents_attributes: [:id, :document, :_destroy])
  end

  def destroy_files(client_id, files)
    dir = "#{Rails.root}/public/custom_fonts/client_#{client_id}"
    files.each do |file_name|
      path_to_file = dir + '/' + file_name
      File.delete(path_to_file) if File.exist?(path_to_file)
    end
    FileUtils.remove_dir(dir, true) if Dir.entries(dir).size == 2
  end

end