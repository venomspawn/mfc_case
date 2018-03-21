# frozen_string_literal: true

# Файл поддержки эмуляции действий сервиса `case_core`

module CaseCore
  module Actions
    module Cases
      # Обновляет записи атрибутов, связанных с записью заявки
      # @param [Hash]
      #   ассоциативный массив значений атрибутов
      def self.update(params)
        case_ids = Array(params[:id])
        attrs = params.except(:id)
        names = attrs.keys.map(&:to_s)
        Models::CaseAttribute.where(case_id: case_ids, name: names).delete
        values = case_ids.each_with_object([]) do |case_id, memo|
          attrs.each do |(name, value)|
            memo << [case_id, name.to_s, value]
          end
        end
        Models::CaseAttribute.import(%i(case_id name value), values)
      end

      # Возвращает ассоциативный массив атрибутов записи заявки
      # @param [Hash{:id => String}] params
      #   ассоциативный массив параметров
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show_attributes(params)
        args = { case_id: params[:id] }
        args[:name] = params[:names] unless params[:names].nil?
        attrs = Models::CaseAttribute.where(args)
        attrs.each_with_object({}) do |attr, memo|
          memo[attr.name.to_s.to_sym] = attr.value
        end
      end

      # Возвращает список ассоциативных массивов с идентификаторами заявок,
      # удовлетворяющих предоставленным условиям
      # @param [Hash] params
      #   ассоциативный массив параметров
      # @return [Array<Hash>]
      #   результирующий список
      def self.index(params)
        attributes = Models::CaseAttribute
        args = { name: 'state', value: 'issuance' }
        ids1 = attributes.where(args).select(:case_id)
        planned_rejecting_date = params[:filter][:planned_rejecting_date][:max]
        ids2 = attributes.datalist.each_with_object([]) do |obj, memo|
          memo << obj.case_id if obj.name == 'planned_rejecting_date' &&
                                 obj.value <= planned_rejecting_date
        end
        (ids1 & ids2).map { |id| { id: id } }
      end
    end
  end
end
