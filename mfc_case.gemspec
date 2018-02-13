# encoding: utf-8

require_relative 'lib/mfc_case/version.rb'

Gem::Specification.new do |spec|
  spec.name    = 'mfc_case'
  spec.version = MFCCase::VERSION
  spec.summary = 'Библиотека с бизнес-логикой неавтоматизированной услуги'

  spec.description = <<-DESCRIPTION.tr("\n", ' ').squeeze
    Библиотека с бизнес-логикой неавтоматизированной услуги для сервиса
    `case_core`
  DESCRIPTION

  spec.authors = ["Александр Ильчуков"]
  spec.email   = 'a.s.ilchukov@cit.rkomi.ru'
  spec.files   = Dir['lib/**/*.rb']
end
