# frozen_string_literal: true

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `processing` в `issuance`
    module ProcessingIssuanceSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      # @param [Object] state
      #   статус заявки
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      def create_case(state)
        attrs = { planned_issuance_finish_date: Time.now.strftime('%d.%m.%Y') }
        super(state, attrs)
      end
    end
  end
end
