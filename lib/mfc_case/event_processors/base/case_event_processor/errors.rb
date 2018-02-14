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
            # `status` заявки не является допустимым
            #
            class BadStatus < RuntimeError
              # Инициализирует объект класса
              #
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              #
              # @param [#to_s] status
              #   статус заявки
              #
              # @param [Array] allowed_statuses
              #   список допустимых статусов заявки
              #
              def initialize(c4s3, status, allowed_statuses)
                super(<<-MESSAGE.squish)
                  Статус `#{status}` заявки с идентификатором записи
                  `#{c4s3.id}` не находится среди следующих допустимых
                  статусов: `#{allowed_statuses.join('`, `')}`
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
          # `allowed_statuses` конструктора содержащего класса
          #
          module AllowedStatuses
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс исключений, сигнализирующих о том, что аргумент
            # `allowed_statuses` конструктора содержащего класса не является ни
            # объектом класса `NilClass`, ни объектом класса `Array`
            #
            class InvalidClass < ArgumentError
              # Инциализирует объект класса
              #
              def initialize
                super(<<-MESSAGE.squish)
                  Аргумент `allowed_statuses` не является ни объектом класса
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
