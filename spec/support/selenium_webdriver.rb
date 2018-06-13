# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rails'
require 'selenium-webdriver'

Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu no-sandbox] },
    loggingPrefs: { 'browser' => 'ALL' }
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end
