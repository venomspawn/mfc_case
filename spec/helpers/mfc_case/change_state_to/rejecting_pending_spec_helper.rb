# frozen_string_literal: true

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `rejecting` в `pending`
    module RejectingPendingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state)
        attributes = {
          institution_rguid: FactoryGirl.create(:string),
          back_office_id:    FactoryGirl.create(:string)
        }
        super(state, attributes)
      end
    end
  end
end
