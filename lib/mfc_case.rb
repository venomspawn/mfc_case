# encoding: utf-8

require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/conversions.rb'
require 'active_support/core_ext/string/filters.rb'

load "#{__dir__}/mfc_case/change_state_to.rb"
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
  def self.on_case_creation(c4s3)
    ChangeStateTo.new(c4s3, 'packaging', {}).process
  end

  # Выставляет статус заявки
  #
  # @param [CaseCore::Models::Case] c4s3
  #   запись заявки
  #
  # @param [Object] state
  #   выставляемый статус заявки
  #
  # @param [Hash] params
  #   ассоциативный массив параметров
  #
  # @raise [ArgumentError]
  #   если аргумент `c4s3` не является объектом класса `CaseCore::Models::Case`
  #
  # @raise [ArgumentError]
  #   если аргумент `params` не является объектом класса `Hash`
  #
  # @raise [ArgumentError]
  #   если заявка переходит из статуса `issuance` в статус `closed`, но
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
  #   если заявка переходит из статуса `issuance` в статус `closed`, но
  #   текущая дата больше значения, записанного в атрибуте
  #   `rejecting_expected_at`
  #
  # @raise [RuntimeError]
  #   если заявка переходит из статуса `issuance` в статус `rejecting`, но
  #   текущая дата не больше значения, записанного в атрибуте
  #   `rejecting_expected_at`
  #
  # @raise [RuntimeError]
  #   если заявка переходит из статуса `pending` в статус `processing`, но либо
  #   атрибут `issue_location_type` присутствует и его значение равно
  #   `institution`, либо атрибут `added_to_rejecting_at` присутствует и его
  #   значение непусто
  #
  # @raise [RuntimeError]
  #   если заявка переходит из статуса `pending` в статус `closed`, но
  #   атрибут `issue_location_type` отсутствует или его значение не равно
  #   `institution`, а атрибут `added_to_rejecting_at` отсутствует или его
  #   значение пусто
  #
  def self.change_state_to(c4s3, state, params)
    ChangeStateTo.new(c4s3, state, params).process
  end
end
