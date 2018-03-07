# encoding: utf-8

module MFCCase
  module Base
    class StateDrivenFSA
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, создаваемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записью заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `c4s3`
          # конструктора содержащего класса не является объектом класса
          # `CaseCore::Models::Case`
          #
          class InvalidClass < ArgumentError
            # Инциализирует объект класса
            #
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `c4s3` не является объектом класса
                `CaseCore::Models::Case`
              MESSAGE
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что значение поля `type`
          # записи заявки не является допустимым
          #
          class BadType < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [#to_s] type
            #   тип корневого модуля
            #
            def initialize(c4s3, type)
              super(<<-MESSAGE.squish)
                Значение поля `type` записи заявки с идентификатором
                `#{c4s3.id}` не равно `#{type}`
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с аргументом `params`
        # конструктора содержащего класса
        #
        module Params
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `params`
          # конструктора содержащего класса не является ни объектом класса
          # `NilClass`, ни объектом класса `Hash`
          #
          class InvalidClass < ArgumentError
            # Инциализирует объект класса
            #
            def initialize
              super('Аргумент `params` не является объектом класса `Hash`')
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с дугами графа переходов
        # состояния заявки
        #
        module Edge
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что
          #
          class Absent < RuntimeError
            # Инциализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [Array<(String, String)>] edge
            #   список из двух элементов: текущего состояния заявки и нового
            #   состояния заявки
            #
            def initialize(c4s3, edge)
              super(<<-MESSAGE.squish)
                Не поддерживается переход из состояния `#{edge.first}` заявки с
                идентификатором записи `#{c4s3.id}` в состояние `#{edge.last}`
              MESSAGE
            end
          end
        end
      end
    end
  end
end