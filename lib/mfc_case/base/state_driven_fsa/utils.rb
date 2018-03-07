# encoding: utf-8

module MFCCase
  module Base
    class StateDrivenFSA
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предназначенный для включения в содержащий класс,
      # предоставляющий вспомогательные методы для использования в заполнении
      # новых значений атрибутов заявки
      #
      module Utils
        # Формат строки с датой и временем (`ГГГГ-ММ-ДД ЧЧ:ММ:СС`) для метода
        # `now`
        #
        NOW_TIME_FORMAT = '%F %T'

        # Возвращает строку с информацией о текущих дате и времени в формате
        # `ГГГГ-ММ-ДД ЧЧ:ММ:СС`
        #
        # @return [String]
        #   результирующая строка
        #
        def now
          Time.now.strftime(NOW_TIME_FORMAT)
        end

        # Возвращает идентификатор оператора из параметров `operator_id` и
        # `exporter_id`
        #
        # @return [Object]
        #   результирующий идентификатор оператора
        #
        def person_id
          params[:operator_id] || params[:exporter_id]
        end
      end
    end
  end
end
