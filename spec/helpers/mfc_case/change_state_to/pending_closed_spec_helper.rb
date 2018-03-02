# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `pending` в `closed`
    #
    module PendingClosedSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Object] issue_location_type
      #   тип места выдачи результата оказания услуги
      #
      # @param [Object] added_to_rejecting_at
      #   дата и время изменения состояния заявки в `rejecting`
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, issue_location_type, added_to_rejecting_at)
        attributes = {
          issue_location_type:   issue_location_type,
          added_to_rejecting_at: added_to_rejecting_at
        }
        super(state, attributes)
      end
    end
  end
end
