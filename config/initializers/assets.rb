# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.precompile += %w( jquery3.min.js jquery-ui/widgets/autocomplete.js )
Rails.application.config.assets.precompile += %w( bootstrap.min.js popper.js )
Rails.application.config.assets.precompile += %w( aoc board play tree weight ).map{|a| "elm_#{a}.min.js"}
