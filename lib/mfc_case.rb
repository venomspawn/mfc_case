# encoding: utf-8

require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/filters.rb'

load "#{__dir__}/mfc_case/event_processors.rb"
load "#{__dir__}/mfc_case/version.rb"

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Модуль, реализующий бизнес-логику неавтоматизированной услуги
#
module MFCCase
  # Выставляет начальный статус заявки `packaging`
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если заявка обладает выставленным статусом
  #
  def self.on_case_creation(c4s3)
    processor = EventProcessors::CaseCreationProcessor.new(c4s3)
    processor.process
  end

  # Выставляет статус заявки
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
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является ни объектом класса `NilClass`, ни
  #   объектом класса `Hash`
  #
  # @raise [ArgumentError]
  #   если заявка переходит из статуса `processing` в статус `issuance`, но
  #   значение атрибута `rejecting_expected_at` не может быть интерпретировано
  #   в качестве даты
  #
  # @raise [ArgumentError]
  #   если заявка переходит из статуса `issuance` в статус `rejecting`, но
  #   значение атрибута `rejecting_expected_at` не может быть интерпретировано
  #   в качестве даты
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если выставление статуса невозможно для данного статуса заявки
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
  def self.change_status_to(c4s3, status, params)
    processor =
      EventProcessors::ChangeStatusToProcessor.new(c4s3, status, params)
    processor.process
  end

  # Выполняет следующие действия:
  #
  # *   выставляет значение поля `exported` записи реестра передаваемой
  #     корреспонденции равным `true`;
  # *   выставляет значение поля `exported_at` записи реестра передаваемой
  #     корреспонденции равным текущим дате и времени;
  # *   выставляет значение поля `exporter_id` записи реестра передаваемой
  #     корреспонденции равным значению параметру `exporter_id`;
  # *   у каждой записи заявки, прикреплённой к записи реестра передаваемой
  #     корреспонденции выполняет следующие действия:
  #
  #     +   выставляет статус заявки `processing` в том и только в том
  #         случае, если одновременно выполнены следующие условия:
  #
  #         -   статус заявки `pending`;
  #         -   значение атрибута `issue_location_type` не равно
  #             `institution`;
  #         -   значение атрибута `added_to_rejecting_at` отсутствует или
  #             пусто;
  #
  #     +   выставляет статус заявки `closed` в том и только в том случае,
  #         если одновременно выполнены следующие условия:
  #
  #         -   статус заявки `pending`;
  #         -   значение атрибута `issue_location_type` равно `institution`,
  #             или значение атрибута `added_to_rejecting_at` присутствует;
  #
  #     +   выставляет значение атрибута `docs_sent_at` равным текущему
  #         времени;
  #     +   выставляет значение атрибута `processor_person_id` равным
  #         значению дополнительного параметра `operator_id`.
  #
  # @param [CaseCore::Models::Register] register
  #   запись реестра передаваемой корреспонденции
  #
  # @param [NilClass, Hash] params
  #   ассоциативный массив параметров или `nil`
  #
  # @raise [ArgumentError]
  #   если аргумент `register` не является объектом класса
  #   `CaseCore::Models::Register`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является ни объектом класса `NilClass`, ни
  #   объектом класса `Hash`
  #
  # @raise [RuntimeError]
  #   если значение поля `type` записи заявки не равно `mfc_case`
  #
  # @raise [RuntimeError]
  #   если среди записей заявок, прикреплённых к записи реестра передаваемой
  #   корреспонденции, нашлась запись со значением атрибута`status`, который не
  #   равен `pending`, или без атрибута `status`
  #
  def self.export_register(register, params)
    processor = EventProcessors::ExportRegisterProcessor.new(register, params)
    processor.process
  end
end
