# encoding: utf-8

load "#{__dir__}/base/state_driven_fsa.rb"

module MFCCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Класс обработчиков события изменения состояния заявки
  #
  class ChangeStateTo < Base::StateDrivenFSA
    load "#{__dir__}/change_state_to/errors.rb"

    # Событие A (см. `docs/STATES.md`)
    edge nil:        :packaging

    # B1
    edge packaging:  :pending,
         set:        { added_to_pending_at: :now }

    # B2
    edge pending:    :packaging,
         need:       :added_to_rejecting_at,
         check:      -> { !added_to_rejecting? },
         raise:      Errors::PendingPackaging,
         set:        { added_to_pending_at: nil }

    # B3
    edge pending:    :processing,
         need:       %w(issue_location_type added_to_rejecting_at),
         check:      -> { !issue_to_institution? && !added_to_rejecting? },
         raise:      Errors::PendingProcessing,
         set:        { docs_sent_at: :now, processor_person_id: :person_id }

    # B4
    edge pending:    :rejecting,
         need:       :added_to_rejecting_at,
         check:      -> { added_to_rejecting? },
         raise:      Errors::PendingRejecting,
         set:        { added_to_pending_at: nil }

    # B5
    edge rejecting:  :pending,
         set:        { added_to_pending_at: :now }

    # B6
    edge pending:    :closed,
         need:       %w(issue_location_type added_to_rejecting_at),
         check:      -> { issue_to_institution? || added_to_rejecting? },
         raise:      Errors::PendingClosed,
         set:        {
                       closed_at:           :now,
                       docs_sent_at:        :now,
                       processor_person_id: :person_id
                     }

    # B7
    edge processing: :issuance,
         set:        {
                       responded_at:                 :now,
                       response_processor_person_id: :person_id,
                       result_id:                    :result_id
                     }

    # B8
    edge issuance:   :rejecting,
         need:       :rejecting_expected_at,
         check:      -> { rejecting_expected_at.to_date <= Date.today },
         raise:      Errors::IssuanceRejecting,
         set:        { added_to_rejecting_at: :now }

    # B9
    edge issuance:   :closed,
         need:       :rejecting_expected_at,
         check:      -> { Date.today < rejecting_expected_at.to_date },
         raise:      Errors::IssuanceClosed,
         set:        {
                       closed_at:        :now,
                       issuer_person_id: :person_id,
                       issued_at:        :now
                     }

    private

    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модуль методов, подключаемых к объекту, в контексте которого происходят
    # проверки атрибутов при переходе по дуге графа переходов состояния заявки
    #
    module CheckContextMethods
      # Возвращает, предполагается ли выдача результатов оказания услуги
      # непосредственно в ведомстве
      #
      # @return [Boolean]
      #   предполагается ли выдача результатов оказания услуги непосредственно
      #   в ведомстве
      #
      def issue_to_institution?
        issue_location_type == 'institution'
      end

      # Возвращает, присутствует ли атрибут `added_to_rejecting_at` с непустым
      # значением
      #
      # @return [Boolean]
      #   присутствует ли атрибут `added_to_rejecting_at` с непустым значением
      #
      def added_to_rejecting?
        !added_to_rejecting_at.nil?
      end
    end

    # Дополняет объект, в контексте которого происходят проверки атрибутов при
    # переходе по дуге графа переходов состояния заявки, методами модуля
    # `CheckContextMethods`
    #
    # @return [Object]
    #   результирующий объект
    #
    def check_context
      super.extend(CheckContextMethods)
    end
  end
end
