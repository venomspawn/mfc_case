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
        case_ids = Array(params[:id])
        attrs = params.except(:id)
        values = case_ids.each_with_object([]) do |case_id, memo|
          Models::CaseAttribute.where(case_id: case_id).delete
          params.except(:id).each do |(name, value)|
            memo << [case_id, name, value]
          end
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
        args = { case_id: params[:id] }
        args[:name] = params[:names] unless params[:names].nil?
        attrs = Models::CaseAttribute.where(args)
        attrs.each_with_object({}) do |attr, memo|
          memo[attr.name.to_s.to_sym] = attr.value
        end
      end

      # Возвращает список ассоциативных массивов с идентификаторами заявок,
      # удовлетворяющих предоставленным условиям
      #
      # @param [Hash] params
      #   ассоциативный массив параметров
      #
      # @return [Array<Hash>]
      #   результирующий список
      #
      def self.index(params)
        attributes = Models::CaseAttribute
        args = { name: 'state', value: 'issuance' }
        ids1 = attributes.where(args).select(:case_id)
        rejecting_expected_at = params[:filter][:rejecting_expected_at][:max]
        ids2 = attributes.datalist.each_with_object([]) do |obj, memo|
          memo << obj.case_id if obj.name == 'rejecting_expected_at' &&
                                 obj.value <= rejecting_expected_at
        end
        (ids1 & ids2).map { |id| { id: id } }
      end
    end
  end
end
