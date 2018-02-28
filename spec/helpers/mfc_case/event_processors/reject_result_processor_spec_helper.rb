# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::RejectResultProcessor`
    #
    module RejectResultProcessorSpecHelper
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
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = {
            state:                state.to_s,
            rejecting_expected_at: rejecting_expected_at
          }
          FactoryGirl.create(:case_attributes, case_id: c4s3.id, **attributes)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      #
      # @param [Object] case_id
      #   идентификатор записи заявки
      #
      def case_attributes(case_id)
        CaseCore::Actions::Cases.show_attributes(id: case_id)
      end

      # Возвращает значение атрибута `state` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `state` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_state(c4s3)
        case_attributes(c4s3.id).dig(:state)
      end

      # Возвращает значение атрибута `added_to_rejecting_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_rejecting_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_rejecting_at(c4s3)
        case_attributes(c4s3.id).dig(:added_to_rejecting_at)
      end
    end
  end
end
