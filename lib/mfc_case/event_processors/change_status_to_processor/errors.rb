# encoding: utf-8

module MFCCase
  module EventProcessors
    class ChangeStatusToProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён классов ошибок содержащему
      # классу
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён ошибок, связанных с переводами статуса заявки
        #
        module Transition
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс ошибок, сигнализирующих о том, что переход из cтатуса заявки
          # в выставляемый статус не поддерживается
          #
          class NotSupported < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [NilClass, String] case_status
            #   статус заявки
            #
            # @param [String] status
            #   выставляемый статус заявки
            #
            def initialize(c4s3, case_status, status)
              super(<<-MESSAGE.squish)
                Переход из статуса `#{case_status}` заявки с идентификатором
                записи `#{c4s3.id}` в статус `#{status}` не поддерживается
              MESSAGE
            end
          end
        end
      end
    end
  end
end
