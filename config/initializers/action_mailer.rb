if Settings.application.default_host
  VaticanExhibits::Application.config.action_mailer.default_url_options ||= {}
  VaticanExhibits::Application.config.action_mailer.default_url_options[:host] ||= Settings.application.default_host.sub(%r{https?://}, '')
end

if Settings.application.default_from
  VaticanExhibits::Application.config.action_mailer.default_options ||= {}
  VaticanExhibits::Application.config.action_mailer.default_options[:from] ||= Settings.application.default_from
end
