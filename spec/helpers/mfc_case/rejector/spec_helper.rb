# encoding: utf-8

module MFCCase
  module Rejector
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам модуля `MFCCase::Rejector`
    #
    module SpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] state
      #   статус заявки
      #
      # @param [Hash]
      #   ассоциативный массив атрибутов
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(state, attributes)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = { case_id: c4s3.id, state: state.to_s, **attributes }
          FactoryGirl.create(:case_attributes, **attributes)
        end
      end

      # Возвращает ассоциативный массив атрибутов заявки с предоставленным
      # идентификатором записи заявки
      #
      # @param [Object] case_id
      #   идентификатор записи заявки
      #
      def case_attributes(case_id)
        CaseCore::Actions::Cases.show_attributes(id: case_id)
      end

      # Возвращает объект с информацией о дате и времени, восстановленных из
      # значения атрибута заявки с предоставленным названием. Возвращает `nil`,
      # если атрибут отсутствует или его значение равно `nil`.
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [Symbol] name
      #   название атрибута
      #
      # @return [Time]
      #   результирующий объект с информацией о дате и времени
      #
      # @return [NilClass]
      #   если атрибут отсутствует или его значение равно `nil`
      #
      def case_time_at(c4s3, name)
        value = case_attributes(c4s3.id)[name]
        value && Time.parse(value)
      end

      # Возвращает значение атрибута `state` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `state` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_state(c4s3)
        case_attributes(c4s3.id)[:state]
      end

      # Возвращает значение атрибута `added_to_rejecting_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_rejecting_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_rejecting_at(c4s3)
        case_time_at(c4s3, :added_to_rejecting_at)
      end
    end
  end
end
