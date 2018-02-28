# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::RemoveFromPendingListProcessor` обработчиков
# события `remove_from_pending_list` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::RemoveFromPendingListProcessor do
  include MFCCase::EventProcessors::RemoveFromPendingListProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case(:pending, nil) }

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
      let(:c4s3) { create_case(nil, nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case state is not `pending`' do
      let(:c4s3) { create_case(:closed, nil) }

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

    let(:c4s3) { create_case(:pending, nil) }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(:pending, added_to_rejecting_at) }
    let(:added_to_rejecting_at) { nil }
    let(:params) { {} }

    context 'when `added_to_rejecting_at` case attribute is present' do
      let(:added_to_rejecting_at) { Time.now }

      it 'should set case state to `rejecting`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end
    end

    context 'when `added_to_rejecting_at` case attribute is absent or nil' do
      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('packaging')
      end
    end

    it 'should set `added_to_pending_at` case attribute to nil' do
      subject
      expect(case_added_to_pending_at(c4s3)).to be_nil
    end
  end
end
