# encoding: utf-8

module MFCCase
  module EventProcessors
    class ExportRegisterProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      #
      module Helpers
        # Проверяет, что аргумент является объектом класса
        # `CaseCore::Models::Register`
        #
        # @param [Object] register
        #   аргумент
        #
        # @raise [ArgumentError]
        #   если аргумент не является объектом класса
        #   `CaseCore::Models::Register`
        #
        def check_register!(register)
          return if register.is_a?(CaseCore::Models::Register)
          raise Errors::Register::BadType
        end

        # Проверяет, что аргумент является объектом класса `Hash`
        #
        # @param [Object] register
        #   аргумент
        #
        # @raise [ArgumentError]
        #   если аргумент `params` не является ни объектом класса `NilClass`,
        #   ни объектом класса `Hash`
        #
        def check_params!(params)
          return if params.nil? || params.is_a?(Hash)
          raise Errors::Params::BadType
        end

        # Проверяет, что атрибут `status` заявки присутствует и его значение
        # равно `pending`
        #
        # @param [String] case_id
        #   идентификатор записи заявки
        #
        # @param [Hash{Symbol => Object}] case_attributes
        #   ассоциативный массив атрибутов заявки
        #
        # @raise [RuntimeError]
        #   если атрибут `status` заявки отсутствует или его значение отлично
        #   от `pending`
        #
        def check_case_status!(case_id, case_attributes)
          status = case_attributes[:status]
          return if status == 'pending'
          raise Errors::Case::BadStatus.new(case_id, status)
        end

        # Проверяет, что реестр передаваемой корреспонденции не пуст
        #
        # @param [CaseCore::Models::Register] register
        #   запись реестра передаваемой корреспонденции
        #
        # @param [Integer] cases_count
        #   количество заявок в реестре передаваемой корреспонденции
        #
        def check_cases_count!(register, cases_count)
          raise Errors::Register::Empty.new(register) if cases_count.zero?
        end

        # Проверяет, что в реестре передаваемой корреспонденции нет заявок без
        # атрибутов
        #
        # @param [Hash] cases_attributes
        #   ассоциативный массив, в котором ключами являются идентификаторы
        #   всех записей заявок, находящихся в реестре передаваемой
        #   корреспонденции
        #
        # @param [CaseCore::Models::Register] register
        #   запись реестра передаваемой корреспонденции
        #
        # @param [Integer] cases_count
        #   количество заявок в реестре передаваемой корреспонденции
        #
        def check_cases_attributes!(cases_attributes, register, cases_count)
          return if cases_attributes.size == cases_count
          raise Errors::Case::Attributeless.new(register)
        end
      end
    end
  end
end
