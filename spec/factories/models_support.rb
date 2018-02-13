# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Поддержка эмуляции моделей в FactoryGirl
#

FactoryGirl.define do
  to_create { |obj| obj.class.datalist << obj }
end
