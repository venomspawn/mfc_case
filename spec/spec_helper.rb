# encoding: utf-8

# Файл поддержки тестирования

require 'rspec'

require_relative '../lib/mfc_case'

RSpec.configure do |config|
  # Исключение поддержки конструкций describe без префикса RSpec.
  config.expose_dsl_globally = false
end

spec = File.absolute_path(__dir__)

Dir["#{spec}/helpers/**/*.rb"].each(&method(:require))
Dir["#{spec}/shared/**/*.rb"].each(&method(:require))
Dir["#{spec}/support/**/*.rb"].each(&method(:require))
