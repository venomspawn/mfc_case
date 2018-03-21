# encoding: utf-8

load "#{__dir__}/base/state_driven_fsa.rb"

module MFCCase
  # Класс обработчиков события изменения состояния заявки
  class ChangeStateTo < Base::StateDrivenFSA
    load "#{__dir__}/change_state_to/dsl.rb"
    load "#{__dir__}/change_state_to/errors.rb"

    extend DSL

    # Значения атрибута `case_status`, выставляемые соответственно состоянию
    # заявки
    CASE_STATUS = {
      packaging:  'Формирование пакета документов',
      pending:    'Ожидание отправки в ведомство',
      processing: 'Обработка пакета документов в ведомстве',
      issuance:   'Выдача результата оказания услуги',
      rejecting:  'Возврат невостребованного результата в ведомство',
      closed:     'Закрыта'
    }.freeze


    # Событие A (см. `docs/STATES.md`)
    edge nil: :packaging,
         set: {
           case_creation_date: :now,
           case_id: :case_id,
           case_status: CASE_STATUS[:packaging],
         }

    # B1
    edge packaging: :pending,
         set: {
           case_status: CASE_STATUS[:pending],
           pending_register_sending_date: :now,
           **from_params_with_the_same_names(
             :pending_register_institution_name,
             :pending_register_institution_office_building,
             :pending_register_institution_office_city,
             :pending_register_institution_office_country_code,
             :pending_register_institution_office_country_name,
             :pending_register_institution_office_district,
             :pending_register_institution_office_house,
             :pending_register_institution_office_index,
             :pending_register_institution_office_region_code,
             :pending_register_institution_office_region_name,
             :pending_register_institution_office_room,
             :pending_register_institution_office_settlement,
             :pending_register_institution_office_street,
             :pending_register_number,
             :pending_register_operator_middle_name,
             :pending_register_operator_name,
             :pending_register_operator_position,
             :pending_register_operator_surname
           )
        }

    # B2
    edge pending: :packaging,
         need:    :rejecting_date,
         check:   -> { !rejected? },
         raise:   Errors::PendingPackaging,
         set: {
           case_status: CASE_STATUS[:packaging],
           **blank(
             :pending_register_institution_name,
             :pending_register_institution_office_building,
             :pending_register_institution_office_city,
             :pending_register_institution_office_country_code,
             :pending_register_institution_office_country_name,
             :pending_register_institution_office_district,
             :pending_register_institution_office_house,
             :pending_register_institution_office_index,
             :pending_register_institution_office_region_code,
             :pending_register_institution_office_region_name,
             :pending_register_institution_office_room,
             :pending_register_institution_office_settlement,
             :pending_register_institution_office_street,
             :pending_register_number,
             :pending_register_operator_middle_name,
             :pending_register_operator_name,
             :pending_register_operator_position,
             :pending_register_operator_surname,
             :pending_register_sending_date
           )
         }

    # B3
    edge pending: :processing,
         need:    %w(issue_method rejecting_date),
         check:   -> { !issuance_in_institution? && !rejected? },
         raise:   Errors::PendingProcessing,
         set: {
           case_status: CASE_STATUS[:processing],
           processing_sending_date: :now,
           **from_params_with_the_same_names(
             :processing_institution_name,
             :processing_institution_office_building,
             :processing_institution_office_city,
             :processing_institution_office_country_code,
             :processing_institution_office_country_name,
             :processing_institution_office_district,
             :processing_institution_office_house,
             :processing_institution_office_index,
             :processing_institution_office_region_code,
             :processing_institution_office_region_name,
             :processing_institution_office_room,
             :processing_institution_office_settlement,
             :processing_institution_office_street,
             :processing_number,
             :processing_operator_middle_name,
             :processing_operator_name,
             :processing_operator_position,
             :processing_operator_surname
           )
         }

    # B4
    edge pending: :rejecting,
         need:    :rejecting_date,
         check:   -> { rejected? },
         raise:   Errors::PendingRejecting,
         set: {
           case_status: CASE_STATUS[:rejecting],
           **blank(
             :pending_rejecting_register_institution_name,
             :pending_rejecting_register_institution_office_building,
             :pending_rejecting_register_institution_office_city,
             :pending_rejecting_register_institution_office_country_code,
             :pending_rejecting_register_institution_office_country_name,
             :pending_rejecting_register_institution_office_district,
             :pending_rejecting_register_institution_office_house,
             :pending_rejecting_register_institution_office_index,
             :pending_rejecting_register_institution_office_region_code,
             :pending_rejecting_register_institution_office_region_name,
             :pending_rejecting_register_institution_office_room,
             :pending_rejecting_register_institution_office_settlement,
             :pending_rejecting_register_institution_office_street,
             :pending_rejecting_register_number,
             :pending_rejecting_register_operator_middle_name,
             :pending_rejecting_register_operator_name,
             :pending_rejecting_register_operator_position,
             :pending_rejecting_register_operator_surname,
             :pending_rejecting_register_sending_date
           )
         }

    # B5
    edge rejecting: :pending,
         set: {
           case_status: CASE_STATUS[:pending],
           pending_rejecting_register_sending_date: :now,
           **from_params_with_the_same_names(
             :pending_rejecting_register_institution_name,
             :pending_rejecting_register_institution_office_building,
             :pending_rejecting_register_institution_office_city,
             :pending_rejecting_register_institution_office_country_code,
             :pending_rejecting_register_institution_office_country_name,
             :pending_rejecting_register_institution_office_district,
             :pending_rejecting_register_institution_office_house,
             :pending_rejecting_register_institution_office_index,
             :pending_rejecting_register_institution_office_region_code,
             :pending_rejecting_register_institution_office_region_name,
             :pending_rejecting_register_institution_office_room,
             :pending_rejecting_register_institution_office_settlement,
             :pending_rejecting_register_institution_office_street,
             :pending_rejecting_register_number,
             :pending_rejecting_register_operator_middle_name,
             :pending_rejecting_register_operator_name,
             :pending_rejecting_register_operator_position,
             :pending_rejecting_register_operator_surname
           )
         }

    # B6
    edge pending: :closed,
         need:    %w(issue_method rejecting_date),
         check:   -> { issuance_in_institution? || rejected? },
         raise:   Errors::PendingClosed,
         set: {
           case_status: CASE_STATUS[:closed],
           closed_date: :now,
           **from_params_with_the_same_names(
             :closed_office_mfc_building,
             :closed_office_mfc_city,
             :closed_office_mfc_country_code,
             :closed_office_mfc_country_name,
             :closed_office_mfc_district,
             :closed_office_mfc_house,
             :closed_office_mfc_index,
             :closed_office_mfc_region_code,
             :closed_office_mfc_region_name,
             :closed_office_mfc_room,
             :closed_office_mfc_settlement,
             :closed_office_mfc_street,
             :closed_operator_middle_name,
             :closed_operator_name,
             :closed_operator_position,
             :closed_operator_surname
           )
         }

    # B7
    edge processing: :issuance,
         set: {
           case_status: CASE_STATUS[:issuance],
           issuance_receiving_date: :now,
           **from_params_with_the_same_names(
             :issuance_office_mfc_building,
             :issuance_office_mfc_city,
             :issuance_office_mfc_country_code,
             :issuance_office_mfc_country_name,
             :issuance_office_mfc_district,
             :issuance_office_mfc_house,
             :issuance_office_mfc_index,
             :issuance_office_mfc_region_code,
             :issuance_office_mfc_region_name,
             :issuance_office_mfc_room,
             :issuance_office_mfc_settlement,
             :issuance_office_mfc_street,
             :issuance_operator_middle_name,
             :issuance_operator_name,
             :issuance_operator_position,
             :issuance_operator_surname,
             :result_id
           )
         }

    # B8
    edge issuance: :rejecting,
         need:     :planned_rejecting_date,
         check:    -> { planned_rejecting_date.to_date <= Date.today },
         raise:    Errors::IssuanceRejecting,
         set: {
           case_status: CASE_STATUS[:rejecting],
           rejecting_date: :now,
         }

    # B9
    edge issuance: :closed,
         need:     :planned_rejecting_date,
         check:    -> { Date.today < planned_rejecting_date.to_date },
         raise:    Errors::IssuanceClosed,
         set: {
           case_status: CASE_STATUS[:closed],
           closed_date: :now,
           **from_params_with_the_same_names(
             :closed_office_mfc_building,
             :closed_office_mfc_city,
             :closed_office_mfc_country_code,
             :closed_office_mfc_country_name,
             :closed_office_mfc_district,
             :closed_office_mfc_house,
             :closed_office_mfc_index,
             :closed_office_mfc_region_code,
             :closed_office_mfc_region_name,
             :closed_office_mfc_room,
             :closed_office_mfc_settlement,
             :closed_office_mfc_street,
             :closed_operator_middle_name,
             :closed_operator_name,
             :closed_operator_position,
             :closed_operator_surname
           )
         }

    private

    # Модуль методов, подключаемых к объекту, в контексте которого происходят
    # проверки атрибутов при переходе по дуге графа переходов состояния заявки
    module CheckContextMethods
      # Возвращает, предполагается ли выдача результатов оказания услуги
      # непосредственно в ведомстве
      # @return [Boolean]
      #   предполагается ли выдача результатов оказания услуги непосредственно
      #   в ведомстве
      def issuance_in_institution?
        issue_method == 'institution'
      end

      # Возвращает, присутствует ли атрибут `rejecting_date` с непустым
      # значением
      # @return [Boolean]
      #   присутствует ли атрибут `rejecting_date` с непустым значением
      def rejected?
        !rejecting_date.nil?
      end
    end

    # Дополняет объект, в контексте которого происходят проверки атрибутов при
    # переходе по дуге графа переходов состояния заявки, методами модуля
    # `CheckContextMethods`
    # @return [Object]
    #   результирующий объект
    def check_context
      super.extend(CheckContextMethods)
    end

    # Возвращает идентификатор записи заявки
    # @return [String]
    #   идентификатор записи заявки
    def case_id
      c4s3.id
    end
  end
end
