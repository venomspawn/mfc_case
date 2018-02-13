# encoding: utf-8

module MFCCase
  module EventProcessors
    class CaseCreationProcessor < Base::CaseEventProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён для классов ошибок,
      # используемых в содержащем классе
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён классов ошибок, связанных с записью заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс ошибок, сигнализирующих о том, что статус записи заявки не
          # пуст
          #
          class BadStatus < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            def initialize(c4s3)
              super(<<-MESSAGE.squish)
                Статус заявки с идентификатором записи `#{c4s3.id}`
                присутствует и не пуст
              MESSAGE
            end
          end
        end
      end
    end
  end
end
