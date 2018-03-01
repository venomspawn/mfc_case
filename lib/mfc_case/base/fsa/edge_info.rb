# encoding: utf-8

require 'json-schema'

module MFCCase
  module Base
    class FSA
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс объектов, содержащих информацию, ассоциированную с переходом по
      # дуге графа переходов состояния заявки
      #
      class EdgeInfo
        attr_reader :check
        attr_reader :set
        attr_reader :after
        attr_reader :need

        # Инициализирует объект класса
        #
        # @param [Hash] options
        #   ассоциативный массив со следующими ключами:
        #
        #   *   `:check` — значением ключа должен быть объект, предоставляющий
        #       метод `call`, который должен принимать запись заявки и
        #       ассоциативный массив атрибутов заявки в качестве аргументов;
        #   *   `:set` — значением ключа должен быть ассоциативный массив, в
        #       котором значения являются строками или объектами `nil`;
        #   *   `:after` — значением ключа должен быть объект, предоставляющий
        #       метод `call`, который должен принимать запись заявки и
        #       ассоциативный массив атрибутов заявки в качестве аргументов;
        #   *   `:need` — значением ключа должен быть список названий
        #       извлекаемых атрибутов заявки
        #
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является ассоциативным массивом
        #
        # @raise [JSON::Schema::ValidationError]
        #   если значение ключа `set` или `need` не является корректным
        #
        def initialize(options)
          check_options!(options)
          @check = options[:check]
          @set   = options[:set]
          @after = options[:after]
          @need  = options[:need]
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
              type: :array,
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
