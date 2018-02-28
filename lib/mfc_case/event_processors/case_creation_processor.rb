# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события создания заявки. Обработчик выставляет статус
    # заявки `packaging`.
    #
    class CaseCreationProcessor < Base::CaseEventProcessor
      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [RuntimeError]
      #   если значение поля `type` записи заявки не равно `mfc_case`
      #
      # @raise [RuntimeError]
      #   если заявка обладает выставленным статусом
      #
      def initialize(c4s3)
        super(c4s3, [], [])
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        { state: 'packaging' }
      end

      # Проверяет, что значение атрибута `state` заявки допустимо
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [Hash] case_attributes
      #   ассоциативный массив атрибутов заявки
      #
      # @param [Array] _allowed_states
      #   информация о допустимых статусах
      #
      # @raise [RuntimeError]
      #   если заявка обладает выставленным статусом
      #
      def check_case_state!(c4s3, case_attributes, _allowed_states)
        state = case_attributes[:state]
        raise Errors::Case::BadState.new(c4s3) unless state.blank?
      end
    end
  end
end
