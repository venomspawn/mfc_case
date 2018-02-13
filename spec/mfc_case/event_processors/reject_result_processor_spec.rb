# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MFCCase::EventProcessors::RejectResultProcessor`
# обработчиков события `reject_result` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::RejectResultProcessor do
  include MFCCase::EventProcessors::RejectResultProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case(:issuance, Time.now) }

      it { is_expected.to be_an_instance_of(described_class) }
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

    context 'when case status is absent' do
      let(:c4s3) { create(:case, type: :mfc_case) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is nil' do
      let(:c4s3) { create_case(nil, Time.now) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `issuance`' do
      let(:c4s3) { create_case('closed', Time.now) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }
      let(:c4s3) { create_case('packaging', Time.now) }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, params) }

    let(:c4s3) { create_case(:issuance, Time.now) }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
    let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }
    let(:params) { {} }

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
