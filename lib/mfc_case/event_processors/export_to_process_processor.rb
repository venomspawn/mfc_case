# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `export_to_process` заявки. Обработчик
    # выполняет следующие действия:
    #
    # *   выставляет статус заявки `processing` в том и только в том случае,
    #     если одновременно выполнены следующие условия:
    #     -   статус заявки `pending`;
    #     -   атрибут `issue_location_type` отсутствует или его значение не
    #         равно `institution`;
    #     -   атрибут `added_to_rejecting_at` отсутствует или его значение
    #         пусто;
    # *   выставляет значение атрибута `closed_at` равным текущим дате и
    #     времени;
    # *   выставляет значение атрибута `docs_sent_at` равным текущим дате и
    #     времени;
    # *   выставляет значение атрибута `processor_person_id` равным значению
    #     дополнительного параметра `operator_id`.
    #
    class ExportToProcessProcessor < Base::CaseEventProcessor
      # Список статусов, поддерживаемых событием
      #
      ALLOWED_STATUSES = %w(pending)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = %w(issue_location_type added_to_rejecting_at) # + `status`

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
        check_attributes!
      end

      # Проверяет условия и обновляет атрибуты заявки
      #
      # @raise [RuntimeError]
      #   если атрибут `issue_location_type` присутствует и его значение равно
      #   `institution` или атрибут `added_to_rejecting_at` присутствует и его
      #   значение непусто
      #
      def process
        check_conditions!
        super
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        {
          status:              'processing',
          docs_sent_at:        now,
          processor_person_id: person_id
        }
      end

      # Проверяет выполнение следующих условий:
      #
      # -   атрибут `issue_location_type` отсутствует или его значение не равно
      #     `institution`;
      # -   атрибут `added_to_rejecting_at` отсутствует или его значение пусто
      #
      # @raise [RuntimeError]
      #   если атрибут `issue_location_type` присутствует и его значение равно
      #   `institution` или атрибут `added_to_rejecting_at` присутствует и его
      #   значение непусто
      #
      def check_conditions!
        return if case_attributes[:issue_location_type] != 'institution'
        return if case_attributes[:added_to_rejecting_at].blank?
        raise Errors::Case::CantProcess.new(c4s3)
      end
    end
  end
end
