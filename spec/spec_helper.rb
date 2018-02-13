# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки тестирования
#

require 'rspec'

RSpec.configure do |config|
  # Исключение поддержки конструкций describe без префикса RSpec.
  config.expose_dsl_globally = false
end

spec = File.absolute_path(__dir__)

Dir["#{spec}/helpers/**/*.rb"].each(&method(:require))
Dir["#{spec}/shared/**/*.rb"].each(&method(:require))
Dir["#{spec}/support/**/*.rb"].each(&method(:require))
