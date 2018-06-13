##
# A simple helper to give easy access to
# the javascript console output in tests
# Example: puts console_output.map(&:message).join("\n")
module SeleniumConsoleOutput
  def console_output
    page.driver.browser.manage.logs.get(:browser)
  end
end
