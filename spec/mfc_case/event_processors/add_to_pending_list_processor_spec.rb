# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::AddToPendingListProcessor` обработчиков события
# `add_to_pending_list` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::AddToPendingListProcessor do
  include MFCCase::EventProcessors::AddToPendingListProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case('packaging') }

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
      let(:c4s3) { create_case(nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `packaging` nor `rejecting`' do
      let(:c4s3) { create_case('closed') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }
      let(:c4s3) { create_case('packaging') }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, params) }

    let(:c4s3) { create_case('packaging') }
    let(:params) { nil }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(status) }
    let(:params) { { office_id: office_id } }
    let(:office_id) { create(:string) }

    context 'when case status is `packaging`' do
      let(:status) { 'packaging' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when there is no appropriate register' do
        it 'should create one' do
          expect { subject }.to change { registers.count }.by(1)
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case_id: c4s3.id).count }
            .by(1)
        end
      end

      context 'when there is appropriate register' do
        let!(:register) { create_appropriate_register(c4s3, office_id) }

        it 'shouldn\'t create any register' do
          expect { subject }.not_to change { registers.count }
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case_id: c4s3.id).count }
            .by(1)
        end
      end
    end

    context 'when case status is `rejecting`' do
      let(:status) { 'rejecting' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when there is no appropriate register' do
        it 'should create one' do
          expect { subject }.to change { registers.count }.by(1)
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case_id: c4s3.id).count }
            .by(1)
        end
      end

      context 'when there is appropriate register' do
        let!(:register) { create_appropriate_register(c4s3, office_id) }

        it 'shouldn\'t create any register' do
          expect { subject }.not_to change { registers.count }
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case_id: c4s3.id).count }
            .by(1)
        end
      end
    end
  end
end
