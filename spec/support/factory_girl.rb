# encoding: utf-8

# Файл поддержки библиотеки factory_girl

require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.definition_file_paths = ["#{__dir__}/../factories/"]
FactoryGirl.find_definitions
