# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей заявок
#

FactoryGirl.define do
  factory :case, class: CaseCore::Models::Case do
    id         { create(:string) }
    type       { create(:string) }
    created_at { Time.now }
  end
end
