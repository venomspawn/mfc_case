# encoding: utf-8

module MFCCase
  module EventProcessors
    class ExportAndCloseProcessor < Base::CaseEventProcessor
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
          # заявку в состояние `closed`
          #
          class CantClose < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            def initialize(c4s3)
              super(<<-MESSAGE.squish)
                Невозможно перевести заявку с идентификатором `#{c4s3.id}` в
                статус `closed`, так как атрибут заявки `issue_location_type`
                отсутствует или его значение не равно `institution`, а атрибут
                заявки `added_to_rejecting_at` отсутствует или его значение
                пусто
              MESSAGE
            end
          end
        end
      end
    end
  end
end
