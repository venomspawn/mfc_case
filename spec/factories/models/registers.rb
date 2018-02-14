# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей реестров передаваемой корреспонденции
#

FactoryGirl.define do
  factory :register, class: CaseCore::Models::Register do
    id                { create(:integer) }
    institution_rguid { create(:string) }
    office_id         { create(:string) }
    back_office_id    { create(:string) }
    register_type     { create(:enum, values: %w(cases requests)) }
    exported          { create(:boolean) }
    exporter_id       { create(:string) }
    exported_at       { Time.now }

    trait :with_cases do
      transient { case_count { 2 } }

      after(:create) do |register, store|
        cases = create_list(:case, store.case_count)
        cases.each do |c4s3|
          create(:case_register, case_id: c4s3.id, register_id: register.id)
        end
      end
    end
  end
end
