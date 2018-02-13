# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `export_register` реестра передаваемой
    # корреспонденции. Обработчик выполняет следующие действия:
    #
    # *   выставляет значение поля `exported` записи реестра передаваемой
    #     корреспонденции равным `true`;
    # *   выставляет значение поля `exported_at` записи реестра передаваемой
    #     корреспонденции равным текущим дате и времени;
    # *   выставляет значение поля `exporter_id` записи реестра передаваемой
    #     корреспонденции равным значению параметру `exporter_id`;
    # *   у каждой записи заявки, прикреплённой к записи реестра передаваемой
    #     корреспонденции выполняет следующие действия:
    #
    #     +   выставляет статус заявки `processing` в том и только в том
    #         случае, если одновременно выполнены следующие условия:
    #
    #         -   статус заявки `pending`;
    #         -   значение атрибута `issue_location_type` не равно
    #             `institution`;
    #         -   значение атрибута `added_to_rejecting_at` отсутствует или
    #             пусто;
    #
    #     +   выставляет статус заявки `closed` в том и только в том случае,
    #         если одновременно выполнены следующие условия:
    #
    #         -   статус заявки `pending`;
    #         -   значение атрибута `issue_location_type` равно `institution`,
    #             или значение атрибута `added_to_rejecting_at` присутствует;
    #
    #     +   выставляет значение атрибута `docs_sent_at` равным текущему
    #         времени;
    #     +   выставляет значение атрибута `processor_person_id` равным
    #         значению дополнительного параметра `operator_id`.
    #
    class ExportRegisterProcessor
      include Helpers

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Register] register
      #   запись реестра передаваемой корреспонденции
      #
      # @param [NilClass, Hash] params
      #   ассоциативный массив параметров или `nil`
      #
      # @raise [ArgumentError]
      #   если аргумент `register` не является объектом класса
      #   `CaseCore::Models::Register`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является ни объектом класса `NilClass`, ни
      #   объектом класса `Hash`
      #
      # @raise [RuntimeError]
      #   если в реестре передаваемой корреспонденции нет заявок
      #
      def initialize(register, params)
        check_register!(register)
        check_params!(params)
        @register = register
        @cases_count = register.cases_dataset.count
        check_cases_count!(register, cases_count)
        @params = params || {}
      end

      # Осуществляет обработку события
      #
      # @raise [RuntimeError]
      #   если среди записей заявок, прикреплённых к записи реестра
      #   передаваемой корреспонденции, нашлась запись со значением атрибута
      #   `status`, который не равен `pending`, или без атрибута `status`
      #
      def process
        register.update(new_register_attributes)
        process_cases
      end

      private

      # Запись реестра передаваемой корреспонденции
      #
      # @return [CaseCore::Models::Register]
      #   запись реестра передаваемой корреспонденции
      #
      attr_reader :register

      # Количество заявок в реестре передаваемой корреспонденции
      #
      # @return [Integer]
      #   количество заявок в реестре передаваемой корреспонденции
      #
      attr_reader :cases_count

      # Ассоциативный массив параметров
      #
      # @return [Hash]
      #   ассоциативный массив параметров
      #
      attr_reader :params

      # Возвращает информацию о текущих дате и времени
      #
      # @return [Time]
      #   объект с информацией о текущих дате и времени
      #
      def now
        @now ||= Time.now
      end

      # Возвращает идентификатор оператора из параметров `operator_id` и
      # `exporter_id`
      #
      # @return [Object]
      #   результирующий идентификатор оператора
      #
      def person_id
        @person_id ||= params[:operator_id] || params[:exporter_id]
      end

      # Возвращает ассоциативный массив полей записи реестра передаваемой
      # корреспонденции, подлежащих обновлению
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      def new_register_attributes
        { exported: true, exported_at: now, exporter_id: person_id }
      end

      # Обрабатывает записи заявок, прикреплённых к записи реестра передаваемой
      # корреспонденции, и обновляет атрибуты заявок
      #
      def process_cases
        new_cases_attributes = process_cases_attributes
        update_cases_attributes(new_cases_attributes)
      end

      # Обрабатывает записи заявок, прикреплённых к записи реестра передаваемой
      # корреспонденции, и возвращает новые атрибуты заявок
      #
      def process_cases_attributes
        cases_attributes.each_with_object({}) do |(case_id, attrs), memo|
          case_attributes = Hash[attrs].symbolize_keys
          memo[case_id] = process_case_attributes(case_id, case_attributes)
        end
      end

      # Возвращает запрос Sequel на получение всех идентификаторов записей
      # заявок, прикреплённых к записи реестра передаваемой корреспонденции
      #
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      #
      def cases_ids_dataset
        register.cases_dataset.select(:id)
      end

      # Список названий атрибутов заявок, чьи записи прикреплены к записи
      # реестра передаваемой корреспонденции
      #
      CASE_ATTRS = %w(status issue_location_type added_to_rejecting_at)

      # Возвращает запрос Sequel на получение требуемых атрибутов заявок, чьи
      # записи прикреплены к записи реестра передаваемой корреспонденции
      #
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      #
      def cases_attributes_dataset
        CaseCore::Models::CaseAttribute
          .where(case_id: cases_ids_dataset, name: CASE_ATTRS)
          .naked
      end

      # Возвращает ассоциативный массив, в котором идентификаторам записей
      # заявок, прикреплённых к записи реестра, соответствуют списки
      # двухэлементных списков, состоящих из названия и значения атрибута
      #
      # @return [Hash{String => Array<(String, Object)>}]
      #   результирующий ассоциативный массив
      #
      # @raise [RuntimeError]
      #   если среди заявок, находящихся в реестре передаваемой
      #   корреспонденции, найдётся заявка без атрибутов
      #
      def cases_attributes
        result =
          cases_attributes_dataset.select_hash_groups(:case_id, %i(name value))
        result.tap { check_cases_attributes!(result, register, cases_count) }
      end

      # Список названий атрибутов заявок, подлежащих обновлению
      #
      NEW_CASE_ATTRS = %w(status docs_sent_at processor_person_id)

      # Класс структуры, содержащей в себе значения атрибутов заявки,
      # подлежащих обновлению
      #
      NewCaseAttributes = Struct.new(*NEW_CASE_ATTRS.map(&:to_sym))

      # Проверяет статус заявки и возвращает атрибуты заявки, подлежащие
      # обновлению
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @param [Hash{Symbol => Object}] case_attributes
      #   ассоциативный массив атрибутов заявки
      #
      # @return [NewCaseAttributes]
      #   структура со значениями атрибутов заявки, подлежащих обновлению
      #
      # @raise [RuntimeError]
      #   если атрибут `status` заявки отсутствует или его значение отлично от
      #   `pending`
      #
      def process_case_attributes(case_id, case_attributes)
        check_case_status!(case_id, case_attributes)
        status = new_case_status(case_attributes)
        { status: status, docs_sent_at: now, processor_person_id: person_id }
      end

      # Возвращает новый статус для заявки с данными атрибутами
      #
      # @param [Hash{Symbol => Object}] case_attributes
      #   ассоциативный массив атрибутов заявки
      #
      # @return [String]
      #   новый статус для заявки
      #
      def new_case_status(case_attributes)
        issue_location_type = case_attributes[:issue_location_type]
        return 'closed' if issue_location_type == 'institution'
        added_to_rejecting_at = case_attributes[:added_to_rejecting_at]
        return 'closed' if added_to_rejecting_at.present?
        'processing'
      end

      # Обновляет атрибуты заявок
      #
      # @param [Hash{String => NewCaseAttributes}}]
      #   ассоциативный массив, в котором идентификаторам заявок соответствуют
      #   структуры со значениями атрибутов, подлежащих обновлению
      #
      def update_cases_attributes(new_cases_attributes)
        delete_cases_attributes(new_cases_attributes)
        import_cases_attributes(new_cases_attributes)
      end

      # Удаляет атрибуты заявок, чьи названия совпадают со значениями в списке
      # {NEW_CASE_ATTRS}
      #
      # @param [Hash{String => NewCaseAttributes}}]
      #   ассоциативный массив, в котором идентификаторам заявок соответствуют
      #   структуры со значениями атрибутов, подлежащих обновлению
      #
      def delete_cases_attributes(attributes)
        case_ids = attributes.keys
        CaseCore::Models::CaseAttribute
          .where(case_id: case_ids, name: NEW_CASE_ATTRS)
          .delete
      end

      # Импортирует атрибуты заявок
      #
      # @param [Hash{String => NewCaseAttributes}}]
      #   ассоциативный массив, в котором идентификаторам заявок соответствуют
      #   структуры со значениями атрибутов, подлежащих обновлению
      #
      def import_cases_attributes(attributes)
        values = attributes.each_with_object([]) do |(case_id, attrs), memo|
          attrs.each_pair { |name, value| memo << [case_id, name.to_s, value] }
        end
        CaseCore::Models::CaseAttribute.import(%i(case_id name value), values)
      end
    end
  end
end
