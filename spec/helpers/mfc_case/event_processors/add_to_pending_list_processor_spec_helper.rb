# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # `MFCCase::EventProcessors::AddToPendingListProcessor`
    #
    module AddToPendingListProcessorSpecHelper
      # Создаёт запись заявки с необходимыми атрибутами
      #
      # @param [Object] status
      #   статус заявки
      #
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      #
      def create_case(status)
        FactoryGirl.create(:case, type: 'mfc_case').tap do |c4s3|
          attributes = {
            status:            status,
            institution_rguid: FactoryGirl.create(:string),
            back_office_id:    FactoryGirl.create(:string)
          }
          FactoryGirl.create(:case_attributes, case_id: c4s3.id, **attributes)
        end
      end

      # Список названий атрибутов реестра передаваемой корреспонденции
      #
      ATTR_NAMES = %i(institution_rguid back_office_id)

      # Ассоциативный массив атрибутов реестра передаваемой корреспонденции
      #
      REGISTER_ATTRS = { register_type: 'cases', exported: false }

      # Создаёт и возвращает запись реестра передаваемой корреспонденции, с
      # которым будет связана предоставленная запись заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [String] office_id
      #   идентификатор офиса, куда будет отправлен реестр передаваемой
      #   корреспонденции
      #
      # @return [CaseCore::Models::Register]
      #   созданная запись реестра передаваемой корреспонденции
      #
      def create_appropriate_register(c4s3, office_id)
        case_attributes = case_attributes(c4s3.id)
        attributes = case_attributes.slice(*ATTR_NAMES).merge(REGISTER_ATTRS)
        attributes[:office_id] = office_id
        FactoryGirl.create(:register, attributes)
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

      # Возвращает значение атрибута `added_to_pending_at` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, Time]
      #   значение атрибута `added_to_pending_at` или `nil`, если атрибут
      #   отсутствует или его значение пусто
      #
      def case_added_to_pending_at(c4s3)
        case_attributes(c4s3.id)[:added_to_pending_at]
      end

      # Возвращает значение атрибута `status` заявки
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `status` или `nil`, если атрибут отсутствует или
      #   его значение пусто
      #
      def case_status(c4s3)
        case_attributes(c4s3.id)[:status]
      end

      # Возвращает объект, предоставляющий доступ к записям реестров
      # передаваемой корреспонденции
      #
      # @return [#where]
      #   результирующий объект
      #
      def registers
        CaseCore::Models::Register
      end

      # Возвращает объект, предоставляющий доступ к записям связей между
      # записями заявок и записями реестров передаваемой корреспонденции
      #
      # @return [#where]
      #   результирующий объект
      #
      def case_registers
        CaseCore::Models::CaseRegister
      end
    end
  end
end
