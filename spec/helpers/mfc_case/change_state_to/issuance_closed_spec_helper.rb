# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `issuance` в `closed`
    #
    module IssuanceClosedSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Object] rejecting_expected_at
      #   дата, после которой результат заявки невозможно выдать
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, rejecting_expected_at)
        super(state, rejecting_expected_at: rejecting_expected_at)
      end
    end
  end
end
