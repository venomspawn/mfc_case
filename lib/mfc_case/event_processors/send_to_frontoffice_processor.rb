# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `send_to_frontoffice!` заявки. Обработчик
    # выполняет следующие действия:
    #
    # *   выставляет статус заявки `issuance` в том и только в том случае,
    #     если статус заявки `processing`;
    # *   выставляет значение атрибута `responded_at` равным текущему
    #     времени;
    # *   выставляет значение атрибута `response_processor_person_id` равным
    #     значению дополнительного параметра `operator_id`;
    # *   выставляет значение атрибута `result_id` равным значению
    #     дополнительного параметра `result_id`.
    #
    class SendToFrontOfficeProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `issuance`
      #
      ALLOWED_STATUSES = %w(processing)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = [] # Не извлекаются никакие атрибуты, кроме атрибута `status`

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [NilClass, Hash] params
      #   ассоциативный массив параметров обработчика события или `nil`, если
      #   обработчик не нуждается в параметрах
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является ни объектом класса `NilClass`,
      #   ни объектом класса `Hash`
      #
      # @raise [RuntimeError]
      #   если значение поля `type` записи заявки не равно `mfc_case`
      #
      # @raise [RuntimeError]
      #   если заявка обладает статусом, который недопустим для данного
      #   обработчика
      #
      def initialize(c4s3, params = nil)
        super(c4s3, ATTRS, ALLOWED_STATUSES, params)
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        {
          status:                       'issuance',
          responded_at:                 now,
          response_processor_person_id: person_id,
          result_id:                    result_id
        }
      end

      # Возвращает значение параметра `result_id`
      #
      # @return [Object]
      #   значение параметра `result_id`
      #
      def result_id
        params[:result_id]
      end
    end
  end
end
