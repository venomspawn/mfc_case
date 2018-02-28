# encoding: utf-8

module MFCCase
  module EventProcessors
    module Base
      class CaseEventProcessor
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
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Значение поля `type` записи заявки с идентификатором
                  `#{c4s3.id}` не равно `mfc_case`
                MESSAGE
              end
            end

            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс исключений, сигнализирующих о том, что значение атрибута
            # `state` заявки не является допустимым
            #
            class BadState < RuntimeError
              # Инициализирует объект класса
              #
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              #
              # @param [#to_s] state
              #   статус заявки
              #
              # @param [Array] allowed_states
              #   список допустимых статусов заявки
              #
              def initialize(c4s3, state, allowed_states)
                super(<<-MESSAGE.squish)
                  Статус `#{state}` заявки с идентификатором записи
                  `#{c4s3.id}` не находится среди следующих допустимых
                  статусов: `#{allowed_states.join('`, `')}`
                MESSAGE
              end
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён исключений, связанных с аргументом `attrs`
          # конструктора содержащего класса
          #
          module Attrs
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс исключений, сигнализирующих о том, что аргумент `attrs`
            # конструктора содержащего класса не является ни объектом класса
            # `NilClass`, ни объектом класса `Array`
            #
            class InvalidClass < ArgumentError
              # Инциализирует объект класса
              #
              def initialize
                super(<<-MESSAGE.squish)
                  Аргумент `attrs` не является ни объектом класса `NilClass`,
                  ни объектом класса `Array`
                MESSAGE
              end
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён исключений, связанных с аргументом
          # `allowed_states` конструктора содержащего класса
          #
          module AllowedStates
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс исключений, сигнализирующих о том, что аргумент
            # `allowed_states` конструктора содержащего класса не является ни
            # объектом класса `NilClass`, ни объектом класса `Array`
            #
            class InvalidClass < ArgumentError
              # Инциализирует объект класса
              #
              def initialize
                super(<<-MESSAGE.squish)
                  Аргумент `allowed_states` не является ни объектом класса
                  `NilClass`, ни объектом класса `Array`
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
                super(<<-MESSAGE.squish)
                  Аргумент `params` не является ни объектом класса `NilClass`,
                  ни объектом класса `Hash`
                MESSAGE
              end
            end
          end
        end
      end
    end
  end
end
