# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MFCCase::EventProcessors::ExportRegisterProcessor`
# обработчиков события `export_register` заявки на неавтоматизированную услугу
#

RSpec.describe MFCCase::EventProcessors::ExportRegisterProcessor do
  include MFCCase::EventProcessors::ExportRegisterProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(register, params) }

    let(:register) { create(:register) }
    let(:c4s3) { create(:case) }
    let!(:link) { put_cases_into_register(register, c4s3) }
    let(:params) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when `register` argument is of wrong type' do
      let(:register) { 'of wrong type' }
      let!(:link) {}

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `params` argument is of wrong type' do
      let(:params) { 'of wrong type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when register is empty' do
      let(:link) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(register, params) }

    let(:register) { create(:register) }
    let(:c4s3) { create(:case) }
    let!(:link) { put_cases_into_register(register, c4s3) }
    let(:params) { nil }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(register, params) }
    let(:register) { create(:register) }
    let(:params) { { operator_id: '123' } }
    let(:c4s3) { create(:case) }
    let!(:link) { put_cases_into_register(register, c4s3) }
    let!(:attrs) { create(:case_attributes, **args) }
    let(:args) { { case_id: c4s3.id, status: 'pending' } }

    it 'should set `exported` attribute of the register to `true`' do
      subject
      expect(register.exported).to be_truthy
    end

    it 'should set `exported_at` attribute of the register to now' do
      subject
      expect(register.exported_at).to be_within(1).of(Time.now)
    end

    it 'should set `exporter_id` attribute of the register by params' do
      subject
      expect(register.exporter_id)
        .to be == params[:operator_id] || params[:exporter_id]
    end

    it 'should set `docs_sent_at` attribute of register\'s cases' do
      subject
      expect(case_docs_sent_at(c4s3)).to be_within(1).of(Time.now)
    end

    it 'should set `processor_person_id` attribute of register\'s cases' do
      subject
      expect(case_processor_person_id(c4s3))
        .to be == params[:operator_id] || params[:exporter_id]
    end

    it 'should set case status to `processing`' do
      subject
      expect(case_status(c4s3)).to be == 'processing'
    end

    context 'when case has `issue_location_type` attribute' do
      context 'when the value of the attribute is `institution`' do
        let!(:more_attrs) { create(:case_attributes, **traits) }
        let(:traits) { { case_id: c4s3.id, issue_location_type: location } }
        let(:location) { 'institution' }

        it 'should set case status to `closed`' do
          subject
          expect(case_status(c4s3)).to be == 'closed'
        end
      end
    end

    context 'when case has `added_to_rejecting_at` attribute' do
      context 'when the value of the attribute is present' do
        let!(:more_attrs) { create(:case_attributes, **traits) }
        let(:traits) { { case_id: c4s3.id, added_to_rejecting_at: Time.now } }

        it 'should set case status to `closed`' do
          subject
          expect(case_status(c4s3)).to be == 'closed'
        end
      end
    end

    context 'when there is attributeless case in the register' do
      let!(:attrs) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when there is case in the register with absent status' do
      let!(:attrs) { create(:case_attributes, case_id: c4s3.id, stat: '') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when there is case in the register with invalid status' do
      let!(:attrs) { create(:case_attributes, **traits) }
      let(:traits) { { case_id: c4s3.id, status: 'invalid' } }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
