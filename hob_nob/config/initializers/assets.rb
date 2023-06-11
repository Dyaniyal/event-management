# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(demo-min.css vendors-min.css custome.css bootstrap-material-datetimepicker.css owl.carousel.css owl.theme.css new-card.css theme.css forms.css jquery.fancybox.css css/bootstrap_polls.min.css print_invoice.css css/telecaller_show.css warehouse_main.css activity_feed.css fonts.css responsive1.css main.css css/badge-pdf.css)
Rails.application.config.assets.precompile += %w(jquery-1.11.3.min.js demo-min.js vendors-min.js material.js moment-with-locales-min.js bootstrap-material-datetimepicker.js timepicki.js common.js owl.carousel.min.js pick-a-color-1.2.0.min.js tinycolor.js select2.min.js jquery.fancybox.js)
Rails.application.config.assets.precompile += %w(js/jquery.ui.widget.js js/jquery.blueimp-gallery.min.js js/tmpl.min.js js/load-image.all.min.js js/canvas-to-blob.min.js js/bootstrap.min.js js/jquery.fileupload.js js/jquery.fileupload-process.js js/jquery.fileupload-image.js js/jquery.fileupload-ui.js js/main.js js/test.js)
Rails.application.config.assets.precompile += %w(css/bootstrap.min.css css/blueimp-gallery.min.css css/jquery.fileupload.css css/jquery.fileupload-ui.css)
Rails.application.config.assets.precompile += %w(jquery-ui.min-dash.js highcharts.js d3.min.js c3.min.js circles.js jquery.jvectormap.min.js jquery-jvectormap-us-lcc-en.js utility.js demo-dash.js main.js dash-widgets.js dash-widgets_sidebar.js dashboard.js)
Rails.application.config.assets.precompile += %w(c3.css theme.css login_style.css login_page.js ckeditor/filebrowser/images/gal_del.png)
Rails.application.config.assets.precompile += %w(theme_color_pick.js custom_page.js external_login.js external_login.css user_registration.js user_registration.css llqrcode.js webqr.js scanner.js scanner.css qr_code_scanner.js ckeditor/filebrowser/images/gal_del.png css/edm_time.css edm_header_footer_color_display_hash.js)
Rails.application.config.assets.precompile += %w( autocomplete-rails.js css/invitee_search.css js/invitee_search.js signup.css)
Rails.application.config.assets.precompile += %w(AbhayaLibre-Regular.ttf BioRhymeExpanded-Regular.ttf ComicSansMS3.ttf EBGaramond-Regular.ttf Georgia.ttf LiberationMono-Regular.ttf Tahoma.ttf Verdana.ttf micross.ttf trebuc.ttf)
Rails.application.config.assets.precompile += %w( ckeditor/filebrowser/images/thumbs/pdf.gif ckeditor/filebrowser/images/thumbs/docx.gif )
Rails.application.config.assets.precompile += %w( bootstrap1.min.js )
Rails.application.config.assets.precompile += %w( box-video.js )
Rails.application.config.assets.precompile += %w( jquery1.min.js )
Rails.application.config.assets.precompile += %w( microsites/bootstrap.min.css )
Rails.application.config.assets.precompile += %w( microsites/box-video.css )
Rails.application.config.assets.precompile += %w( microsites/reset.css )
Rails.application.config.assets.precompile += %w( microsites/style.css )

# Rails.application.config.assets.precompile += %w( jquery_ujs.js )
