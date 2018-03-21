# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `issuance` в `rejecting`
    #
    module IssuanceRejectingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Object] planned_rejecting_date
      #   дата, после которой результат заявки невозможно выдать
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, planned_rejecting_date)
        super(state, planned_rejecting_date: planned_rejecting_date)
      end
    end
  end
end
