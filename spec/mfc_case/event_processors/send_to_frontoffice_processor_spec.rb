# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::SendToFrontOfficeProcessor` обработчиков события
# `send_to_frontoffice` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::SendToFrontOfficeProcessor do
  include MFCCase::EventProcessors::SendToFrontOfficeProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case(:processing) }

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

    context 'when case state is absent' do
      let(:c4s3) { create(:case, type: :mfc_case) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is nil' do
      let(:c4s3) { create_case(nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is not `processing`' do
      let(:c4s3) { create_case(:closed) }

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

    let(:c4s3) { create_case(:processing) }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(:processing) }
    let(:params) { { operator_id: 'operator_id', result_id: 'result_id' } }

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
end
