# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модуля `MFCCase`, предоставляющего обработчики событий
# бизнес-логики неавтоматизированной услуги
#

RSpec.describe MFCCase do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:change_state_to, :on_case_creation) }
  end

  describe '.change_state_to' do
    subject { described_class.change_state_to(c4s3, state, params) }

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: :wrong) }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is absent' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let(:state) { 'pending' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:case_attributes) { create(:case_attributes, **traits) }
      let(:traits) { { case_id: c4s3.id, state: 'packaging' } }
      let(:state) { 'pending' }
      let(:params) { 'not of `NilClass` nor of `Hash` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case state transition isn\'t supported' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:case_attributes) { create(:case_attributes, **traits) }
      let(:traits) { { case_id: c4s3.id, state: 'packaging' } }
      let(:state) { 'a state' }
      let(:params) { {} }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is switching from `packaging` to `pending`' do
      include MFCCase::ChangeStateTo::PackagingPendingSpecHelper

      let(:c4s3) { create_case('packaging') }
      let(:params) { { office_id: office_id } }
      let(:office_id) { create(:string) }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end
    end

    context 'when case state is switching from `rejecting` to `pending`' do
      include MFCCase::ChangeStateTo::RejectingPendingSpecHelper

      let(:c4s3) { create_case('rejecting') }
      let(:params) { { office_id: office_id } }
      let(:office_id) { create(:string) }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end
    end

    context 'when case state is switching from `pending` to `packaging`' do
      include MFCCase::ChangeStateTo::PendingPackagingSpecHelper

      let(:c4s3) { create_case(:pending, nil) }
      let(:added_to_rejecting_at) { nil }
      let(:params) { {} }
      let(:state) { 'packaging' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('packaging')
      end

      it 'should set `added_to_pending_at` case attribute to nil' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_nil
      end
    end

    context 'when case state is switching from `pending` to `rejecting`' do
      include MFCCase::ChangeStateTo::PendingRejectingSpecHelper

      let(:c4s3) { create_case(:pending, Time.now) }
      let(:added_to_rejecting_at) { nil }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `added_to_pending_at` case attribute to nil' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_nil
      end
    end

    context 'when case state is switching from `processing` to `issuance`' do
      include MFCCase::ChangeStateTo::ProcessingIssuanceSpecHelper

      let(:c4s3) { create_case(:processing) }
      let(:params) { { operator_id: 'operator_id', result_id: 'result_id' } }
      let(:state) { 'issuance' }

      it 'should set case state to `issuance`' do
        expect { subject }.to change { case_state(c4s3) }.to('issuance')
      end

      it 'should set `responded_at` case attribute to now' do
        subject
        expect(case_responded_at(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `response_processor_person_id` attribute by params' do
        subject
        expect(case_response_processor_person_id(c4s3))
          .to be == params[:operator_id]
      end

      it 'should set `result_id` attribute by params' do
        subject
        expect(case_result_id(c4s3)).to be == params[:result_id]
      end
    end

    context 'when case state is switching from `issuance` to `closed`' do
      include MFCCase::ChangeStateTo::IssuanceClosedSpecHelper

      let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
      let(:rejecting_expected_at) { (Time.now + 86_400).strftime('%F %T') }
      let(:params) { { operator_id: '123' } }
      let(:state) { 'closed' }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `closed_at` case attribute to now' do
        subject
        expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `issuer_person_id` case attribute by params' do
        subject
        expect(case_issuer_person_id(c4s3))
          .to be == params[:operator_id] || params[:exported_id]
      end

      it 'should set `issued_at` case attribute to now' do
        subject
        expect(case_issued_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when `rejecting_expected_at` attribute is absent' do
        let(:c4s3) { create(:case, type: 'mfc_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should raise NoMethodError' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end

      context 'when `rejecting_expected_at` attribute is nil' do
        let(:rejecting_expected_at) { nil }

        it 'should raise NoMethodError' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end

      context 'when `rejecting_expected_at` attribute value is invalid' do
        let(:rejecting_expected_at) { 'invalid' }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when now date is more than value of `rejecting_expected_at`' do
        let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `issuance` to `rejecting`' do
      include MFCCase::ChangeStateTo::IssuanceRejectingSpecHelper

      let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
      let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `rejecting`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `added_to_rejecting_at` case attribute to now' do
        subject
        expect(case_added_to_rejecting_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when `rejecting_expected_at` attribute is absent' do
        let(:c4s3) { create(:case, type: 'mfc_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should raise NoMethodError' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end

      context 'when `rejecting_expected_at` attribute is nil' do
        let(:rejecting_expected_at) { nil }

        it 'should raise NoMethodError' do
          expect { subject }.to raise_error(NoMethodError)
        end
      end

      context 'when `rejecting_expected_at` attribute value is invalid' do
        let(:rejecting_expected_at) { 'invalid' }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when now date is less than value of `rejecting_expected_at`' do
        let(:rejecting_expected_at) { Time.now + 24 * 60 * 60 }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `pending` to `closed`' do
      include MFCCase::ChangeStateTo::PendingClosedSpecHelper

      let(:c4s3) { create_case('pending', *args) }
      let(:state) { 'closed' }
      let(:args) { [issue_location_type, added_to_rejecting_at] }
      let(:issue_location_type) { 'institution' }
      let(:added_to_rejecting_at) { nil }
      let(:params) { { operator_id: 'operator_id' } }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `closed_at` case attribute to now' do
        subject
        expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `docs_sent_at` case attribute to now' do
        subject
        expect(case_docs_sent_at(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `processor_person_id` attribute by params' do
        subject
        expect(case_processor_person_id(c4s3)).to be == params[:operator_id]
      end

      context 'when `issue_location_type` value isn\'t `institution`' do
        let(:issue_location_type) { '' }

        context 'when `added_to_rejecting_at` value is nil' do
          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end
      end
    end

    context 'when case state is switching from `pending` to `processing`' do
      include MFCCase::ChangeStateTo::PendingProcessingSpecHelper

      let(:c4s3) { create_case('pending', *args) }
      let(:state) { 'processing' }
      let(:args) { [issue_location_type, added_to_rejecting_at] }
      let(:issue_location_type) { 'mfc' }
      let(:added_to_rejecting_at) { nil }
      let(:params) { { operator_id: 'operator_id' } }

      it 'should set case state to `processing`' do
        expect { subject }.to change { case_state(c4s3) }.to('processing')
      end

      it 'should set `docs_sent_at` case attribute to now' do
        subject
        expect(case_docs_sent_at(c4s3)).to be_within(1).of(Time.now)
      end

      it 'should set `processor_person_id` attribute by params' do
        subject
        expect(case_processor_person_id(c4s3)).to be == params[:operator_id]
      end

      context 'when `issue_location_type` value is `institution`' do
        let(:issue_location_type) { 'institution' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `added_to_rejecting_at` value is present' do
        let(:added_to_rejecting_at) { Time.now.strftime('%F %T') }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '.on_case_creation' do
    include MFCCase::ChangeStateTo::NilPackagingSpecHelper

    subject { described_class.on_case_creation(c4s3) }

    let(:c4s3) { create(:case, type: 'mfc_case') }

    it 'should set case state to `packaging`' do
      expect { subject }.to change { case_state(c4s3) }.to('packaging')
    end

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: 'wrong') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is present' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:case_attribute) { create(:case_attribute, *traits) }
      let(:traits) { [case_id: c4s3.id, name: 'state', value: 'state'] }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
