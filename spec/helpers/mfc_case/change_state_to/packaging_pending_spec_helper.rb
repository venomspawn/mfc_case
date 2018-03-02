# encoding: utf-8

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # `packaging` в `pending`
    #
    module PackagingPendingSpecHelper
      include SpecHelper

      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
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
