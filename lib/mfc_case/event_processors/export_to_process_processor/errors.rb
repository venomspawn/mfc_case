# encoding: utf-8

module MFCCase
  module EventProcessors
    class ExportToProcessProcessor < Base::CaseEventProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, используемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, сигнализирующих об ошибках обработки
        # заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключения, создаваемого в случае, когда невозможно перевести
          # заявку в состояние `processing`
          #
          class CantProcess < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            def initialize(c4s3)
              super(<<-MESSAGE.squish)
                Невозможно перевести заявку с идентификатором `#{c4s3.id}` в
                статус `processing`, так как либо значение атрибута заявки
                `issue_location_type` равно `institution`, либо значение
                атрибута заявки `added_to_rejecting_at` присутствует
              MESSAGE
            end
          end
        end
      end
    end
  end
end
