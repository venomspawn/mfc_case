# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::AddToPendingListProcessor`
    #
    module AddToPendingListProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = {
            state:            state,
            institution_rguid: FactoryGirl.create(:string),
            back_office_id:    FactoryGirl.create(:string)
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

      # Возвращает значение атрибута `added_to_pending_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_pending_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_pending_at(c4s3)
        value = case_attributes(c4s3.id)[:added_to_pending_at]
        value && Time.parse(value)
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
        case_attributes(c4s3.id)[:state]
      end
    end
  end
end
