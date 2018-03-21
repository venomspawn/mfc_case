# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `pending` в `rejecting`
    #
    module PendingRejectingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Object] rejecting_date
      #   дата добавления в состояние `rejecting`
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, rejecting_date)
        super(state, rejecting_date: rejecting_date)
      end
    end
  end
end
