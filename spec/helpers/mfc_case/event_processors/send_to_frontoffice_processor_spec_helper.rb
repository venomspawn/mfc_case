# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::SendToFrontOfficeProcessor`
    #
    module SendToFrontOfficeProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          args = { case_id: c4s3.id, status: status.to_s }
          FactoryGirl.create(:case_attributes, **args)
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

      # Возвращает значение атрибута `status` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `status` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_status(c4s3)
        case_attributes(c4s3.id).dig(:status)
      end

      # Возвращает значение атрибута `responded_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `responded_at` или `nil`, если атрибут отсутствует
      #   или его значение пусто
      #
      def case_responded_at(c4s3)
        case_attributes(c4s3.id).dig(:responded_at)
      end

      # Возвращает значение атрибута `response_processor_person_id` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `response_processor_person_id` или `nil`, если
      #   атрибут отсутствует или его значение пусто
      #
      def case_response_processor_person_id(c4s3)
        case_attributes(c4s3.id).dig(:response_processor_person_id)
      end

      # Возвращает значение атрибута `result_id` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `result_id` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_result_id(c4s3)
        case_attributes(c4s3.id).dig(:result_id)
      end
    end
  end
end
