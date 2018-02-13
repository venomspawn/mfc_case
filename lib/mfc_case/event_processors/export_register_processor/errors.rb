# encoding: utf-8

module MFCCase
  module EventProcessors
    class ExportRegisterProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, используемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записью реестра
        # передаваемой корреспонденции
        #
        module Register
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `register`
          # конструктора содержащего класса не является объектом класса
          # `CaseCore::Models::Register`
          #
          class BadType < ArgumentError
            # Инициализирует объект класса
            #
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `register` не является объектом класса
                `CaseCore::Models::Register`
              MESSAGE
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что в реестре передаваемой
          # корреспонденции нет заявок
          #
          class Empty < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Register] register
            #   запись реестра передаваемой корреспонденции
            #
            def initialize(register)
              super(<<-MESSAGE.squish)
                Реестр передаваемой корреспонденции с идентификатором записи
                `#{register.id}` пуст
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
          class BadType < ArgumentError
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

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записью заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигналиризущих о том, что значение атрибута
          # `status` заявки не является допустимым
          #
          class BadStatus < RuntimeError
            # Инициализирует объект класса
            #
            # @param [#to_s] case_id
            #   идентификатор записи заявки
            #
            # @param [#to_s] status
            #   статус заявки
            #
            def initialize(case_id, status)
              super(<<-MESSAGE.squish)
                Статус `#{status}` заявки с идентификатором записи
                `#{case_id}` не равен `pending`
              MESSAGE
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигналиризущих о том, что реестре передаваемой
          # корреспонденции есть заявки без атрибутов
          #
          class Attributeless < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Register] register
            #   запись реестра передаваемой корреспонденции
            #
            def initialize(register)
              super(<<-MESSAGE.squish)
                В реестре передаваемой корреспонденции с идентификатором записи
                `#{register.id}` есть заявка без атрибутов
              MESSAGE
            end
          end
        end
      end
    end
  end
end
