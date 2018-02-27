# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::ChangeStatusToProcessor` обработчиков события
# `change_status_to` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::ChangeStatusToProcessor do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, status, params) }

    let(:c4s3) { create(:case, type: 'mfc_case') }
    let!(:case_attributes) { create(:case_attributes, **traits) }
    let(:traits) { { case_id: c4s3.id, status: 'packaging' } }
    let(:status) { 'pending' }
    let(:params) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }
      let!(:case_attributes) {}

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: :wrong) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is absent' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:case_attributes) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case status transition isn\'t supported' do
      let(:status) { 'a status' }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, status, params) }

    let(:c4s3) { create(:case, type: 'mfc_case') }
    let!(:case_attributes) { create(:case_attributes, **traits) }
    let(:traits) { { case_id: c4s3.id, status: 'packaging' } }
    let(:status) { 'pending' }
    let(:params) { nil }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, status, params) }

    context 'when case status is switching from `packaging` to `pending`' do
      include MFCCase::EventProcessors::AddToPendingListProcessorSpecHelper

      let(:c4s3) { create_case('packaging') }
      let(:params) { { office_id: office_id } }
      let(:office_id) { create(:string) }
      let(:status) { 'pending' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end
    end

    context 'when case status is switching from `rejecting` to `pending`' do
      include MFCCase::EventProcessors::AddToPendingListProcessorSpecHelper

      let(:c4s3) { create_case('rejecting') }
      let(:params) { { office_id: office_id } }
      let(:office_id) { create(:string) }
      let(:status) { 'pending' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end
    end

    context 'when case status is switching from `pending` to `packaging`' do
      event_processors = MFCCase::EventProcessors
      include event_processors::RemoveFromPendingListProcessorSpecHelper

      let(:c4s3) { create_case(:pending, nil) }
      let(:added_to_rejecting_at) { nil }
      let(:params) { {} }
      let(:status) { 'packaging' }

      it 'should set case status to `packaging`' do
        expect { subject }.to change { case_status(c4s3) }.to('packaging')
      end

      it 'should set `added_to_pending_at` case attribute to nil' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_nil
      end
    end

    context 'when case status is switching from `pending` to `rejecting`' do
      event_processors = MFCCase::EventProcessors
      include event_processors::RemoveFromPendingListProcessorSpecHelper

      let(:c4s3) { create_case(:pending, Time.now) }
      let(:added_to_rejecting_at) { nil }
      let(:params) { {} }
      let(:status) { 'rejecting' }

      it 'should set case status to `packaging`' do
        expect { subject }.to change { case_status(c4s3) }.to('rejecting')
      end

      it 'should set `added_to_pending_at` case attribute to nil' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_nil
      end
    end

    context 'when case status is switching from `processing` to `issuance`' do
      include MFCCase::EventProcessors::SendToFrontOfficeProcessorSpecHelper

      let(:c4s3) { create_case(:processing) }
      let(:params) { { operator_id: 'operator_id', result_id: 'result_id' } }
      let(:status) { 'issuance' }

      it 'should set case status to `issuance`' do
        expect { subject }.to change { case_status(c4s3) }.to('issuance')
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

    context 'when case status is switching from `issuance` to `closed`' do
      include MFCCase::EventProcessors::IssueProcessorSpecHelper

      let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
      let(:rejecting_expected_at) { Time.now + 24 * 60 * 60 }
      let(:params) { { operator_id: '123' } }
      let(:status) { 'closed' }

      it 'should set case status to `closed`' do
        expect { subject }.to change { case_status(c4s3) }.to('closed')
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
        let(:args) { { case_id: c4s3.id, status: 'issuance' } }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when `rejecting_expected_at` attribute is nil' do
        let(:rejecting_expected_at) { nil }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
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

    context 'when case status is switching from `issuance` to `rejecting`' do
      include MFCCase::EventProcessors::RejectResultProcessorSpecHelper

      let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
      let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }
      let(:params) { {} }
      let(:status) { 'rejecting' }

      it 'should set case status to `rejecting`' do
        expect { subject }.to change { case_status(c4s3) }.to('rejecting')
      end

      it 'should set `added_to_rejecting_at` case attribute to now' do
        subject
        expect(case_added_to_rejecting_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when `rejecting_expected_at` attribute is absent' do
        let(:c4s3) { create(:case, type: 'mfc_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, status: 'issuance' } }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when `rejecting_expected_at` attribute is nil' do
        let(:rejecting_expected_at) { nil }

        it 'should raise ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
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
  end
end
