# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::ExportRegisterProcessor`
    #
    module ExportRegisterProcessorSpecHelper
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

      # Возвращает значение атрибута `docs_sent_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `docs_sent_at` или `nil`, если атрибут отсутствует
      #   или его значение пусто
      #
      def case_docs_sent_at(c4s3)
        case_attributes(c4s3.id).dig(:docs_sent_at)
      end

      # Возвращает значение атрибута `processor_person_id` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `processor_person_id` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_processor_person_id(c4s3)
        case_attributes(c4s3.id).dig(:processor_person_id)
      end

      # Связывает записи реестра передаваемой корреспонденции и заявок
      #
      # @param [CaseCore::Models::Register] register
      #   запись реестра передаваемой корреспонденции
      #
      # @param [Array<CaseCore::Models::Case>] cases
      #   список записей заявок
      #
      def put_cases_into_register(register, *cases)
        cases.map do |c4s3|
          args = { case_id: c4s3.id, register_id: register.id }
          CaseCore::Models::CaseRegister.create(args)
        end
      end
    end
  end
end
