# frozen_string_literal: true

# Фабрика записей заявок

FactoryGirl.define do
  factory :case, class: CaseCore::Models::Case do
    id         { create(:string) }
    type       { create(:string) }
    created_at { Time.now }
  end
end
