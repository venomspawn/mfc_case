# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `pending` в `processing`
    #
    module PendingProcessingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Object] issue_method
      #   тип места выдачи результата оказания услуги
      #
      # @param [Object] rejecting_date
      #   дата и время изменения состояния заявки в `rejecting`
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, issue_method, rejecting_date)
        attributes = {
          issue_method:   issue_method,
          rejecting_date: rejecting_date
        }
        super(state, attributes)
      end
    end
  end
end
