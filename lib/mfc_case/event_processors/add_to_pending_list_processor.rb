# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `add_to_pending_list` заявки. Обработчик
    # выполняет следующие действия:
    #
    # *   выставляет статус заявки `pending` в том и только в том случае, если
    #     статус заявки `packaging` или `rejecting`;
    # *   выставляет значение атрибута `added_to_pending_at` равным текущему
    #     времени.
    #
    class AddToPendingListProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `pending`
      #
      ALLOWED_STATUSES = %w(packaging rejecting)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = [] # + `status`

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
        { status: 'pending', added_to_pending_at: now }
      end
    end
  end
end
