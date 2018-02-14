# encoding: utf-8

module MFCCase
  module EventProcessors
    module Base
      class CaseEventProcessor
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Вспомогательный модуль, предназначенный для включения в содержащий
        # класс
        #
        module Helpers
          # Проверяет, что аргумент является объектом класса
          # `CaseCore::Models::Case`
          #
          # @param [Object] c4s3
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является объектом класса
          #   `CaseCore::Models::Case`
          #
          def check_case!(c4s3)
            return if c4s3.is_a?(CaseCore::Models::Case)
            raise Errors::Case::InvalidClass
          end

          # Проверяет, что запись заявки обладает значением поля `type`,
          # которое равно `mfc_case`
          #
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки
          #
          # @raise [RuntimeError]
          #   значение поля `type` записи заявки не равно `mfc_case`
          #
          def check_case_type!(c4s3)
            return if c4s3.type == 'mfc_case'
            raise Errors::Case::BadType.new(c4s3)
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Array`
          #
          # @params [Hash] attrs
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Array`
          #
          def check_attrs!(attrs)
            return if attrs.nil? || attrs.is_a?(Array)
            raise Errors::Attrs::InvalidClass
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Array`
          #
          # @params [Hash] allowed_statuses
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Array`
          #
          def check_allowed_statuses!(allowed_statuses)
            return if allowed_statuses.nil? || allowed_statuses.is_a?(Array)
            raise Errors::AllowedStatuses::InvalidClass
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Hash`
          #
          # @params [Hash] params
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Hash`
          #
          def check_params!(params)
            return if params.nil? || params.is_a?(Hash)
            raise Errors::Params::InvalidClass
          end

          # Проверяет, что значение атрибута `status` заявки допустимо
          #
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки
          #
          # @param [Hash] case_attributes
          #   ассоциативный массив атрибутов заявки
          #
          # @param [NilClass, Array] allowed_statuses
          #   список статусов заявки, которые допустимы для данного
          #   обработчика, или `nil`, если допустим любой статус, а также его
          #
          # @raise [RuntimeError]
          #   если значение атрибута `status` не является допустимым
          #
          def check_case_status!(c4s3, case_attributes, allowed_statuses)
            return if allowed_statuses.nil?
            status = case_attributes[:status]
            allowed_statuses.map!(&:to_s)
            return if allowed_statuses.include?(status)
            raise Errors::Case::BadStatus.new(c4s3, status, allowed_statuses)
          end
        end
      end
    end
  end
end
