# encoding: utf-8

load "#{__dir__}/base/fsa.rb"

module MFCCase
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Класс обработчиков события изменения состояния заявки
  #
  class ChangeStateTo < Base::FSA
    load "#{__dir__}/change_state_to/errors.rb"

    # Событие A (см. `docs/STATES.md`)
    edge nil:        :packaging

    # B1
    edge packaging:  :pending,
         set:        { added_to_pending_at: :now }

    # B2
    edge pending:    :packaging,
         need:       %w(added_to_rejecting_at),
         check:      ->(c4s3, attrs) do
                       next if attrs[:added_to_rejecting_at].nil?
                       raise Errors::PendingPackaging.new(c4s3)
                     end,
         set:        { added_to_pending_at: nil }

    # B3
    edge pending:    :processing,
         need:       %w(issue_location_type added_to_rejecting_at),
         check:      ->(c4s3, attrs) do
                       next if attrs[:issue_location_type] != 'institution' &&
                               attrs[:added_to_rejecting_at].nil?
                       raise Errors::PendingProcessing.new(c4s3)
                     end,
         set:        {
                       docs_sent_at:        :now,
                       processor_person_id: :person_id
                     }

    # B4
    edge pending:    :rejecting,
         need:       %w(added_to_rejecting_at),
         check:      ->(c4s3, attrs) do
                       next unless attrs[:added_to_rejecting_at].nil?
                       raise Errors::PendingRejecting.new(c4s3)
                     end,
         set:        { added_to_pending_at: nil }

    # B5
    edge rejecting:  :pending,
         set:        { added_to_pending_at: :now }

    # B6
    edge pending:    :closed,
         need:       %w(issue_location_type added_to_rejecting_at),
         check:      ->(c4s3, attrs) do
                       next if attrs[:issue_location_type] == 'institution' ||
                               attrs[:added_to_rejecting_at].nil?
                       raise Errors::PendingClosed.new(c4s3)
                     end,
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
         need:       %w(rejecting_expected_at),
         check:      ->(c4s3, attrs) do
                       date = attrs[:rejecting_expected_at].to_s
                       date = Date.parse(date, false)
                       next if date <= Date.today
                       raise Errors::IssuanceRejecting.new(c4s3)
                     end,
         set:        { added_to_rejecting_at: :now }

    # B9
    edge issuance:   :closed,
         need:       %w(rejecting_expected_at),
         check:      ->(c4s3, attrs) do
                       date = attrs[:rejecting_expected_at].to_s
                       date = Date.parse(date, false)
                       next if Date.today < date
                       raise Errors::IssuanceClosed.new(c4s3)
                     end,
         set:        {
                       closed_at:        :now,
                       issuer_person_id: :person_id,
                       issued_at:        :now
                     }
  end
end
