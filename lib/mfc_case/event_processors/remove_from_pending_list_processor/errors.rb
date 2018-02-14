# encoding: utf-8

module MFCCase
  module EventProcessors
    class RemoveFromPendingListProcessor < Base::CaseEventProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, используемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, сигнализирующих об ошибках обработки
        # записи заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключения, создаваемого в случае, когда запись заявки не
          # прикреплена к записи реестра передаваемой корреспонденции
          #
          class NotInRegister < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [Object] register_id
            #   идентификатор записи реестра
            #
            def initialize(c4s3, register_id)
              super(<<-MESSAGE.squish)
                Запись заявки с идентификатором `#{c4s3.id}` не прикреплена к
                записи реестра передаваемой корреспонденции с идентификатором
                `#{register_id}`
              MESSAGE
            end
          end
        end
      end
    end
  end
end
