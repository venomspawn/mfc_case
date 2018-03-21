# encoding: utf-8

# Поддержка эмуляции моделей в FactoryGirl

FactoryGirl.define do
  to_create { |obj| obj.class.datalist << obj }
end
