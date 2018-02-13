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
    #     времени;
    # *   прикрепляет запись заявки к реестру передаваемой корреспонденции.
    #
    class AddToPendingListProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `pending`
      #
      ALLOWED_STATUSES = %w(packaging rejecting)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = %w(institution_rguid back_office_id) # + `status`

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

      # Обновляет атрибуты заявки и прикрепляет её к реестру передаваемой
      # корреспонденции
      #
      def process
        super
        add_to_register
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

      # Возвращает значение параметра `office_id`
      #
      # @return [Object]
      #   значение параметра `office_id`
      #
      def office_id
        params[:office_id]
      end

      # Возвращает значение атрибута `institution_rguid`
      #
      # @return [Object]
      #   значение атрибута `institution_rguid`
      #
      def institution_rguid
        case_attributes[:institution_rguid]
      end

      # Возвращает значение атрибута `back_office_id`
      #
      # @return [Object]
      #   значение атрибута `back_office_id`
      #
      def back_office_id
        case_attributes[:back_office_id]
      end

      # Возвращает ассоциативный массив атрибутов реестра передаваемой
      # корреспонденции
      #
      # @return [Hash]
      #   ассоциативный массив атрибутов реестра передаваемой корреспонденции
      #
      def register_attributes
        {
          institution_rguid: institution_rguid,
          office_id:         office_id,
          back_office_id:    back_office_id,
          register_type:     'cases',
          exported:          false
        }
      end

      # Осуществляет поиск записи реестра передаваемой корреспонденции по
      # атрибутам, возвращаемым методом {register_attributes}. Если находит
      # такую запись, то возвращает её, иначе создаёт такую запись и возвращает
      # созданную запись.
      #
      # @return [CaseCore::Models::Register]
      #   запись реестра передаваемой корреспонденции
      #
      def find_or_create_register
        CaseCore::Models::Register.find_or_create(register_attributes)
      end

      # Прикрепляет запись заявки к записи реестра передаваемой
      # корреспонденции, создавая последнюю при необходимости
      #
      def add_to_register
        register = find_or_create_register
        args = { case_id: c4s3.id, register_id: register.id }
        CaseCore::Models::CaseRegister.create(args)
      end
    end
  end
end
