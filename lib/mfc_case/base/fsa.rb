# encoding: utf-8

module MFCCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для базового класса обработчиков события изменения
  # состояния заявки
  #
  module Base
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Базовый класс обработчиков события изменения состояния заявки
    #
    class FSA
      Dir["#{__dir__}/fsa/*.rb"].each(&method(:load))

      extend  Edges
      include Helpers
      include Utils

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [Object] state
      #   выставляемый статус заявки
      #
      # @param [Hash] params
      #   ассоциативный массив параметров
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является объектом класса `Hash`
      #
      # @raise [RuntimeError]
      #   если значение поля `type` записи заявки указывает на иной модуль
      #   бизнес-логики, нежели корневой модуль
      #
      def initialize(c4s3, state, params)
        check_case!(c4s3)
        check_case_type!(c4s3, type)
        check_params!(params)
        @c4s3 = c4s3
        @state = state.to_s
        @params = params || {}
        @case_attributes = extract_case_attributes(c4s3, all_needed_attrs)
      end

      # Осуществляет следующие действия согласно информации, ассоциированной с
      # дугой графа переходов состояния заявки.
      #
      # 1.  Проверяет, возможно ли перейти из текущего состояния заявки в новое
      #     состояние.
      # 2.  Если с дугой ассоциирован параметр `check`, то вызывает метод
      #     `call` объекта, являющегося значением параметра, c записью заявки и
      #     ассоциативным массивом атрибутов заявки в качестве аргументов
      # 3.  Если с дугой ассоциирован параметр `set`, то обновляет атрибуты
      #     заявки согласно ассоциативному массиву, который является значением
      #     параметра. Каждый ключ ассоциативного массива интерпретируется в
      #     качестве названия атрибута заявки, а соответствующее значение
      #     интерпретируется следующим образом.
      #     *   Если значение является названием метода экземпляра класса, то
      #         этот метод вызывается и результат вызова подставляется в
      #         качестве значения атрибута.
      #     *   Если значение не является названием метода экземпляра класса,
      #         то проверяется, является ли оно ключом ассоциативного массива
      #         параметров. Если это так, то в качестве значения атрибута
      #         берётся значение соответствующего параметра. Если нет, то в
      #         качестве значения атрибута берётся само исходное значение.
      # 4.  Если с дугой ассоциирован параметр `after`, то вызывает метод
      #     `call` объекта, являющегося значением параметра, с записью заявки и
      #     ассоциативным массивом атрибутов заявки в качестве аргументов.
      #
      # @raise [RuntimeError]
      #   если выставление статуса невозможно для данного статуса заявки
      #
      def process
        edge = [case_attributes[:state], state]
        check_edge!(c4s3, edge, edges)
        edge_info = edges[edge]
        edge_info.check&.call(c4s3, case_attributes)
        update_case_attributes(edge_info.set)
        edge_info.after&.call(c4s3, case_attributes)
      end

      private

      # Запись заявки
      #
      # @return [CaseCore::Models::Case]
      #   запись заявки
      #
      attr_reader :c4s3

      # Выставляемый статус заявки
      #
      # @return [String]
      #   выставляемый статус заявки
      #
      attr_reader :state

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

      # Возвращает ассоциативный массив с информацией о графе переходов
      # состояния заявки, созданного с помощью Edges класса
      #
      # @return [Hash{Array<(String, String)> => Edges::EdgeInfo}]
      #   результирующий ассоциативный массив
      #
      def edges
        self.class.edges
      end

      # Возвращает список названий всех атрибутов, извлекаемых при переходах
      # графа состояний заявки
      #
      # @return [Array<String>]
      #   результирующий список
      #
      def all_needed_attrs
        attrs = edges.each_value.each_with_object([]) do |edge_info, memo|
          memo.concat(edge_info.need) unless edge_info.need.nil?
        end
        attrs.uniq
      end

      # Обновляет атрибуты заявки согласно информации об их значениях
      #
      # @param [NilClass, Hash] info
      #   ассоциативный массив с информацией о значениях атрибутов или `nil`,
      #   если такая информация отсутствует
      #
      def update_case_attributes(info)
        attributes = new_case_attributes(info)
        CaseCore::Actions::Cases.update(id: c4s3.id, **attributes)
      end

      # Возвращает ассоциативный массив, в котором названиям атрибутов заявки
      # соответствуют их новые значения
      #
      # @param [NilClass, Hash] info
      #   ассоциативный массив с информацией о значениях атрибутов или `nil`,
      #   если такая информация отсутствует
      #
      def new_case_attributes(info)
        info ||= {}
        values = info.each_value.map(&method(:obtain_value))
        Hash[info.keys.zip(values)].update(state: state)
      end

      # Возвращает значение согласно следующим проверкам.
      #
      # *   Если аргумент является названием метода экземпляра класса, то
      #     возвращает результат вызова метода без аргументов.
      # *   Если аргумент не является названием метода экземпляра класса, то
      #     проверяется, является ли он ключом ассоциативного массива `params`.
      #     Если это так, то возвращается значение по этому ключу, иначе
      #     возвращается аргумент.
      #
      # @param [Object] value_info
      #   аргумент
      #
      # @return [Object]
      #   результирующее значение
      #
      def obtain_value(value_info)
        return value_info unless value_info.is_a?(String) ||
                                 value_info.is_a?(Symbol)
        if respond_to?(value_info, true)
          send(value_info)
        elsif params.key?(value_info)
          params[value_info]
        else
          value_info
        end
      end
    end
  end
end
