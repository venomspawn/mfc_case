# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `add_to_pending_list!` заявки. Обработчик
    # выполняет следующие действия:
    #
    # *   выставляет статус заявки `packaging` в том и только в том случае,
    #     если статус заявки `pending` и значение атрибута
    #     `added_to_rejecting_at` отсутствует или пусто;
    # *   выставляет статус заявки `rejecting` в том и только в том случае,
    #     если статус заявки `pending` и значение атрибута
    #     `added_to_rejecting_at` присутствует и непусто;
    # *   выставляет значение атрибута `added_to_pending_at` равным `nil`;
    # *   открепляет запись заявки от реестра передаваемой корреспонденции;
    # *   если реестр передаваемой корреспонденции пуст, то удаляет его.
    #
    class RemoveFromPendingListProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `pending`
      #
      ALLOWED_STATUSES = %w(pending)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = %w(added_to_rejecting_at) # + `status`

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

      # Обновляет атрибуты заявки и открепляет её от реестра передаваемой
      # корреспонденции
      #
      # @raise [RuntimeError]
      #   если запись заявки не прикреплена к записи реестра передаваемой
      #   корреспонденции
      #
      def process
        super
        remove_from_register
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        { status: new_status, added_to_pending_at: nil }
      end

      # Возвращает новый статус заявки
      #
      # @return [String]
      #   новый статус заявки
      #
      def new_status
        added_to_rejecting_at = case_attributes[:added_to_rejecting_at]
        added_to_rejecting_at.present? ? 'rejecting' : 'packaging'
      end

      # Возвращает значение параметра `register_id` в ассоциативном массиве
      # параметров
      #
      # @return [Object]
      #   значение параметра `register_id` в ассоциативном массиве параметров
      #
      def register_id
        params[:register_id]
      end

      # Возвращает количество заявок в последнем реестре передаваемой
      # корреспонденции, к которому прикреплена заявка
      #
      # @return [Integer]
      #   результирующее количество
      #
      def count_of_cases_in_register
        CaseCore::Models::CaseRegister.where(register_id: register_id).count
      end

      # Открепляет запись заявки от записи реестра передаваемой
      # корреспонденции, удаляя его, если он пуст
      #
      # @raise [RuntimeError]
      #   если запись заявки не прикреплена к записи реестра передаваемой
      #   корреспонденции
      #
      def remove_from_register
        case count_of_cases_in_register
        when 0
          raise Errors::Case::NotInRegister.new(c4s3, register_id)
        when 1
          CaseCore::Models::Register.where(id: register_id).delete
        else
          conditions = { case_id: c4s3.id, register_id: register_id }
          CaseCore::Models::CaseRegister.where(conditions).delete
        end
      end
    end
  end
end
