# encoding: utf-8

require 'json-schema'

module MFCCase
  module Base
    class StateDrivenFSA
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс объектов, содержащих информацию, ассоциированную с переходом по
      # дуге графа переходов состояния заявки
      #
      class EdgeInfo
        attr_reader :check
        attr_reader :raise
        attr_reader :set
        attr_reader :need

        # Инициализирует объект класса
        #
        # @param [Hash] options
        #   ассоциативный массив с информацией, ассоциированной с переходом по
        #   дуге
        #
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является ассоциативным массивом
        #
        # @raise [JSON::Schema::ValidationError]
        #   если значение параметра `set` или `need` не является корректным
        #
        def initialize(options)
          check_options!(options)
          @check = options[:check]
          @raise = options[:raise]
          @set   = options[:set]
          @need  = Array(options[:need]).map(&:to_s)
        end

        private

        # JSON-схема для проверки структуры аргумента конструктора экземпляров
        # класса
        #
        OPTIONS_SCHEMA = {
          type: :object,
          properties: {
            set: {
              type: :object,
              additionalProperties: {
                type: %i(null string)
              }
            },
            need: {
              type: %i(string array),
              items: {
                type: :string
              }
            }
          }
        }

        # Проверяет структуру аргумента конструктора экземпляров класса
        #
        # @param [Object] options
        #   аргумент конструктора
        #
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является ассоциативным массивом
        #
        # @raise [JSON::Schema::ValidationError]
        #   если значение ключа `set` или `need` не является корректным
        #
        def check_options!(options)
          JSON::Validator.validate!(OPTIONS_SCHEMA, options)
        end
      end
    end
  end
end
