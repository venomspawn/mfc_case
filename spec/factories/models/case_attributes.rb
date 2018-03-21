# encoding: utf-8

# Фабрика записей атрибутов заявок

FactoryGirl.define do
  factory :case_attribute, class: CaseCore::Models::CaseAttribute do
    name    { create(:string) }
    value   { create(:string) }
    case_id { create(:case).id }
  end

  factory :case_attributes, class: Array do
    skip_create
    initialize_with do
      case_id = attributes[:case_id]
      attributes.except(:case_id).map do |(name, value)|
        name = name.to_s
        create(:case_attribute, case_id: case_id, name: name, value: value)
      end
    end
  end
end
