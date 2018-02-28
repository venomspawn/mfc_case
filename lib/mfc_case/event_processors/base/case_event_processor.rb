# encoding: utf-8

module MFCCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён классов обработчиков событий
  #
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён базовых классов обработчиков событий
    #
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Базовый класс обработчиков событий, связанных с записью заявки
      #
      class CaseEventProcessor
        include Helpers

        # Инициализирует объект класса
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @param [NilClass, Array] attrs
        #   список названий извлекаемых атрибутов или `nil`, если нужно извлечь
        #   все атрибуты
        #
        # @param [NilClass, Array] allowed_states
        #   список статусов заявки, которые допустимы для данного обработчика,
        #   или `nil`, если допустим любой статус, а также его отсутствие
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
        #   если аргумент `attrs` не является ни объектом класса `NilClass`, ни
        #   объектом класса `Array`
        #
        # @raise [ArgumentError]
        #   если аргумент `allowed_states` не является ни объектом класса
        #   `NilClass`, ни объектом класса `Array`
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
        def initialize(c4s3, attrs = [], allowed_states = nil, params = nil)
          check_case!(c4s3)
          check_case_type!(c4s3)
          check_attrs!(attrs)
          check_allowed_states!(allowed_states)
          check_params!(params)

          attrs = sanitize_attrs(attrs, allowed_states)

          @c4s3 = c4s3
          @case_attributes = extract_case_attributes(attrs)

          check_case_state!(c4s3, case_attributes, allowed_states)

          @params = params || {}
        end

        # Обновляет атрибуты заявки
        #
        def process
          CaseCore::Actions::Cases.update(id: c4s3.id, **new_case_attributes)
        end

        private

        # Запись заявки
        #
        # @return [CaseCore::Models::Case]
        #   запись заявки
        #
        attr_reader :c4s3

        # Ассоциативный массив параметров обработчика события
        #
        # @return [Hash]
        #   ассоциативный массив параметров обработчика события
        #
        attr_reader :params

        # Ассоциативный массив атрибутов заявки
        #
        # @return [Hash]
        #   ассоциативный массив атрибутов заявки
        #
        attr_reader :case_attributes

        # Возвращает дополненную информацию о названиях атрибутов, созданный на
        # основе предоставленной информации о названиях атрибутов и информации
        # о допустимых статусах
        #
        # @param [NilClass, Array] attrs
        #   список названий извлекаемых атрибутов или `nil`, если нужно извлечь
        #   все атрибуты
        #
        # @param [NilClass, Array] allowed_states
        #   список статусов заявки, которые допустимы для данного обработчика,
        #   или `nil`, если допустим любой статус, а также его отсутствие
        #
        # @return [NilClass]
        #   если аргумент `attrs` равен `nil`
        #
        # @return [Array]
        #   если аргумент `attrs` является списком
        #
        def sanitize_attrs(attrs, allowed_states)
          return if attrs.nil?
          attrs += ['state'] if allowed_states.is_a?(Array)
          attrs.uniq
        end

        # Извлекает требуемые атрибуты заявки из соответствующих записей и
        # возвращает ассоциативный массив атрибутов заявки
        #
        # @param [NilClass, Array] attrs
        #   список названий извлекаемых атрибутов или `nil`, если нужно извлечь
        #   все атрибуты
        #
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив
        #
        def extract_case_attributes(attrs)
          CaseCore::Actions::Cases.show_attributes(id: c4s3.id, names: attrs)
        end

        # Возвращает идентификатор оператора из параметров `operator_id` и
        # `exporter_id`
        #
        # @return [Object]
        #   результирующий идентификатор оператора
        #
        def person_id
          params[:operator_id] || params[:exporter_id]
        end

        # Возвращает объект с информацией о текущих дате и времени
        #
        # @return [Time]
        #   объект с информацией о текущих дате и времени
        #
        def now
          Time.now
        end

        # Возвращает ассоциативный массив обновлённых атрибутов заявки
        #
        # @return [Hash]
        #   ассоциативный массив обновлённых атрибутов заявки
        #
        def new_case_attributes
          {}
        end
      end
    end
  end
end
