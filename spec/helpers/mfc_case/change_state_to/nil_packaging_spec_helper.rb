# frozen_string_literal: true

require_relative 'spec_helper'

module MFCCase
  class ChangeStateTo
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::ChangeStateTo` при проверке перехода состояния заявки из
    # отсутствия состояния в `packaging`
    module NilPackagingSpecHelper
      include SpecHelper

      # Возвращает значение атрибута `case_id` заявки
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      # @return [NilClass, String]
      #   значение атрибута `case_id` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      def case_id(c4s3)
        case_attributes(c4s3.id)[:case_id]
      end
    end
  end
end
