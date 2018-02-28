# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::ExportToProcessProcessor` обработчиков события
# `export_to_process` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::ExportToProcessProcessor do
  include described_class::SpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case('pending', 'institution', '') }

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
      let(:c4s3) { create_case(nil, 'institution', '') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is not `pending`' do
      let(:c4s3) { create_case(:closed, 'institution', '') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }
      let(:c4s3) { create_case('pending', 'institution', '') }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, params) }

    let(:c4s3) { create_case('pending', 'institution', '') }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case('pending', *args) }
    let(:args) { [issue_location_type, added_to_rejecting_at] }
    let(:issue_location_type) { 'institution' }
    let(:added_to_rejecting_at) { '' }
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
      context 'when `added_to_rejecting_at` value is present' do
        let(:added_to_rejecting_at) { Time.now }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
