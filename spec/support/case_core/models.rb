# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки эмуляции моделей сервиса `case_core`
#

module CaseCore
  module Models
    module Model
      # Создаёт новую структуру, эмулирующую модель сервиса `case_core`
      #
      # @param [Array<Symbol>]
      #   список названий полей структуры
      #
      # @return [Class]
      #   результирующая структура
      #
      def self.new(members)
        Struct.new(*members) do
          extend ClassMethods
          include InstanceMethods
        end
      end

      # Класс, эмулирующий выборку записей
      #
      class Dataset
        include Enumerable

        # Инициализирует объект класса
        #
        # @param [Array] array
        #   список записей выборки
        #
        # @param [Class] model
        #   структура записей выборки
        #
        def initialize(array, model)
          @array = array
          @model = model
        end

        # Удаляет записи выборки
        #
        def delete
          array.each(&model.method(:remove))
        end

        # Возвращает количество записей выборки
        #
        def count
          array.count
        end

        # Перечисляет записи
        #
        # @return [Enumerator]
        #   если блок не предоставлен
        #
        # @yieldparam [Struct]
        #   запись выборки
        #
        def each(&block)
          array.each(&block)
        end

        private

        # Список записей выборки
        #
        # @return [Array]
        #   список записей выборки
        #
        attr_reader :array

        # Структура записей выборки
        #
        # @return [Class]
        #   структура записей выборки
        #
        attr_reader :model
      end

      # Модуль методов структуры
      #
      module ClassMethods
        # Возвращает структуру, которую расширяет этот модуль
        #
        # @return [Class]
        #   структура, которую расширяет этот модуль
        #
        def dataset
          self
        end

        # Возвращает список экземпляров структуры
        #
        # @return [Array]
        #   список экземпляров структуры
        #
        def datalist
          @datalist ||= []
        end

        # Возвращает количество экземпляров структуры
        #
        # @return [Integer]
        #   количество экземпляров структуры
        #
        def count
          datalist.count
        end

        # Удаляет экземпляр из списка экземпляров
        #
        # @param [Struct] obj
        #   экземпляр
        #
        def remove(obj)
          datalist.delete(obj)
        end

        # Создаёт экземпляр структуры, помещает его в список `datalist` и
        # возвращает его
        #
        # @param [Hash] hash
        #   ассоциативный массив атрибутов экземпляра структуры
        #
        # @return [Object]
        #   созданный экземпляр
        #
        def create(hash)
          new(*hash.values_at(*members)).tap(&datalist.method(:<<))
        end

        # Создаёт экземпляры структуры согласно предоставленным названиям и
        # значениям свойств, после чего помещает их в список `datalist`
        #
        # @param [Array] prop_names
        #   названия свойств
        #
        # @param [Array<Array>] values
        #   значения свойств
        #
        def import(prop_names, values)
          values.each do |obj_values|
            hash = Hash[prop_names.zip(obj_values)]
            create(hash)
          end
        end

        # Ищет экземпляр структуры по предоставленным значениям полей и
        # возвращает его в случае успешного нахождения. Если такой экземпляр
        # невозможно найти, создаёт экземпляр структуры, помещает его в список
        # `datalist` и возвращает его
        #
        # @param [Hash] hash
        #   ассоциативный массив атрибутов экземпляра структуры
        #
        # @return [Object]
        #   результирующий экземпляр
        #
        def find_or_create(hash)
          where(hash).first || create(hash)
        end

        # Возвращает выборку записей на основе точного совпадения значений
        # полей
        #
        # @param [Hash] hash
        #   ассоциативный массив значений полей
        #
        # @return [CaseCore::Models::Model::Dataset]
        #   результирующая выборка
        #
        def where(hash)
          offsets = hash.each_key.map(&members.method(:find_index))
          values = hash.values
          array = datalist.find_all { |obj| obj.values_at(*offsets) == values }
          Dataset.new(array, self)
        end
      end

      # Модуль методов экземпляров структуры
      #
      module InstanceMethods
      end
    end

    Case          = Model.new %i(id type created_at)
    CaseAttribute = Model.new %i(case_id name value)
    CaseRegister  = Model.new %i(case_id register_id)

    Register      = Model.new %i(
                                  id
                                  institution_rguid
                                  office_id
                                  back_office_id
                                  register_type
                                  exported
                                  exporter_id
                                  exported_at
                                )

    # Удаляет экземпляр из списка экземпляров
    #
    # @param [Struct] obj
    #   экземпляр
    #
    def Register.remove(obj)
      super
      CaseRegister.where(register_id: obj.id).delete if obj.is_a?(Register)
    end
  end
end
