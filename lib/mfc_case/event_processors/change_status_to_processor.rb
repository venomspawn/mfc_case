# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события изменения статуса заявки
    #
    class ChangeStatusToProcessor < Base::CaseEventProcessor
      # Извлекаемые атрибуты заявки
      #
      ATTRS = %w(status)

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [Object] status
      #   выставляемый статус заявки
      #
      # @param [NilClass, Hash] params
      #   ассоциативный массив параметров или `nil`
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является ни объектом класса `NilClass`, ни
      #   объектом класса `Hash`
      #
      # @raise [RuntimeError]
      #   если значение поля `type` записи заявки не равно `mfc_case`
      #
      # @raise [RuntimeError]
      #   если выставление статуса невозможно для данного статуса заявки
      #
      def initialize(c4s3, status, params)
        super(c4s3, ATTRS, nil, params)
        status = status.to_s
        check_transition!(status)
        @status = status
      end

      # Ассоциативный массив, который отображает двухэлементный списки,
      # представляющие дуги переходов из состояния в состояние заявки, в классы
      # обработчиков этих переходов
      #
      PROCESSOR_CLASSES = {
        %w(packaging pending)   => AddToPendingListProcessor,
        %w(rejecting pending)   => AddToPendingListProcessor,
        %w(pending packaging)   => RemoveFromPendingListProcessor,
        %w(pending rejecting)   => RemoveFromPendingListProcessor,
        %w(processing issuance) => SendToFrontOfficeProcessor,
        %w(issuance closed)     => IssueProcessor,
        %w(issuance rejecting)  => RejectResultProcessor
      }

      # Изменяет статус заявки
      #
      # @raise [ArgumentError]
      #   если заявка переходит из статуса `processing` в статус `issuance`, но
      #   значение атрибута `rejecting_expected_at` не может быть
      #   интерпретировано в качестве даты
      #
      # @raise [ArgumentError]
      #   если заявка переходит из статуса `issuance` в статус `rejecting`, но
      #   значение атрибута `rejecting_expected_at` не может быть
      #   интерпретировано в качестве даты
      #
      # @raise [RuntimeError]
      #   если заявка переходит из статуса `pending` в статус `packaging` или
      #   `rejecting`, но запись заявки не прикреплена к записи реестра
      #   передаваемой корреспонденции
      #
      # @raise [RuntimeError]
      #   если заявка переходит из статуса `processing` в статус `issuance`, но
      #   текущая дата больше значения, записанного в атрибуте
      #   `rejecting_expected_at`;
      #
      # @raise [RuntimeError]
      #   если заявка переходит из статуса `issuance` в статус `rejecting`, но
      #   текущая дата не больше значения, записанного в атрибуте
      #   `rejecting_expected_at`;
      #
      def process
        PROCESSOR_CLASSES[[case_status, status]].new(c4s3, params).process
      end

      private

      # Выставляемый статус заявки
      #
      # @return [String]
      #   выставляемый статус заявки
      #
      attr_reader :status

      # Возвращает статус заявки
      #
      # @return [NilClass, String]
      #   статус заявки
      #
      def case_status
        case_attributes[:status]
      end

      # Проверяет, что из статуса заявки поддерживается переход в выставляемый
      # статус
      #
      # @param [String] status
      #   выставляемый статус заявки
      #
      def check_transition!(status)
        return if PROCESSOR_CLASSES.key?([case_status, status])
        raise Errors::Transition::NotSupported.new(c4s3, case_status, status)
      end
    end
  end
end
