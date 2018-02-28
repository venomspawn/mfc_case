# encoding: utf-8

module MFCCase
  module EventProcessors
    class ExportToProcessProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, подключаемый к тестам класса
      # `MFCCase::EventProcessors::ExportToProcessProcessor`
      #
      module SpecHelper
        # Создаёт запись заявки с необходимыми атрибутами
        #
        # @param [Object] state
        #   статус заявки
        #
        # @return [CaseCore::Models::Case]
        #   созданная запись заявки
        #
        def create_case(state, issue_location_type, added_to_rejecting_at)
          FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
            attributes = {
              case_id:               c4s3.id,
              state:                state,
              issue_location_type:   issue_location_type,
              added_to_rejecting_at: added_to_rejecting_at
            }
            FactoryGirl.create(:case_attributes, attributes)
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

        # Возвращает значение атрибута `docs_sent_at` заявки
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @return [NilClass, Time]
        #   значение атрибута `docs_sent_at` или `nil`, если атрибут
        #   отсутствует или его значение пусто
        #
        def case_docs_sent_at(c4s3)
          case_attributes(c4s3.id)[:docs_sent_at]
        end

        # Возвращает значение атрибута `processor_person_id` заявки
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @return [NilClass, String]
        #   значение атрибута `processor_person_id` или `nil`, если атрибут
        #   отсутствует или его значение пусто
        #
        def case_processor_person_id(c4s3)
          case_attributes(c4s3.id)[:processor_person_id]
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
      end
    end
  end
end
