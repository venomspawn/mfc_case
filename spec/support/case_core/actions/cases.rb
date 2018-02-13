# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки эмуляции действий сервиса `case_core`
#

module CaseCore
  module Actions
    module Cases
      # Обновляет записи атрибутов, связанных с записью заявки
      #
      # @param [Hash]
      #   ассоциативный массив значений атрибутов
      #
      def self.update(params)
        case_id = params[:id]
        attrs = params.except(:id)
        Models::CaseAttribute.where(case_id: case_id).delete
        values = params.except(:id).map do |(name, value)|
          [case_id, name, value]
        end
        Models::CaseAttribute.import(%i(case_id name value), values)
      end

      # Возвращает ассоциативный массив атрибутов записи заявки
      #
      # @param [Hash{:id => String}] params
      #   ассоциативный массив параметров
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      def self.show_attributes(params)
        case_id = params[:id]
        attrs = Models::CaseAttribute.where(case_id: case_id)
        attrs.each_with_object({}) do |attr, memo|
          memo[attr.name.to_s.to_sym] = attr.value
        end
      end
    end
  end
end
