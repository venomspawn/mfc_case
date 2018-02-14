# encoding: utf-8

require 'date'

module MFCCase
  module EventProcessors
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён модулей, подключаемых к классам-потомкам класса
      # `MFCCase::EventProcessors::EventProcessor::CaseEventProcessor`
      #
      module Mixins
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, подключаемый к классам-потомкам класса
        # `MFCCase::EventProcessors::EventProcessor::CaseEventProcessor`,
        # предоставляющий метод `expired?`, который возвращает, необходимо ли
        # возвратить результат заявки в ведомство
        #
        module Expired
          # Возвращает значение атрибута `rejecting_expected_at` заявки
          #
          # @return [NilClass, String]
          #   значение атрибута `rejecting_expected_at` заявки
          #
          def rejecting_expected_at
            case_attributes[:rejecting_expected_at]
          end

          # Возвращает дату, хранящуюся в атрибуте `rejecting_expected_at`
          #
          # @return [Date]
          #   результирующая дата
          #
          # @raise [ArgumentError]
          #   если значение атрибута `rejecting_expected_at` не может быть
          #   интерпретировано в качестве даты
          #
          def rejecting_expected_at_date
            Date.parse(rejecting_expected_at.to_s, false)
          end

          # Возвращает, необходимо ли возвратить результат заявки в ведомство
          #
          # @return [Boolean]
          #   необходимо ли возвратить результат заявки в ведомство
          #
          # @raise [ArgumentError]
          #   если значение атрибута `rejecting_expected_at` не может быть
          #   интерпретировано в качестве даты
          #
          def expired?
            rejecting_expected_at_date < Date.today
          end
        end
      end
    end
  end
end
