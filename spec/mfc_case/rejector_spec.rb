# frozen_string_literal: true

# Файл тестирования модуля `MFCCase::Rejector`

RSpec.describe MFCCase::Rejector do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:reject) }
  end

  describe '.reject' do
    include described_class::SpecHelper

    subject { described_class.reject }

    let!(:rotten_case) { create_case('issuance', **rotten_args) }
    let!(:another_rotten_case) { create_case('issuance', **rotten_args) }
    let(:rotten_args) { { planned_rejecting_date: yesterday.to_s } }
    let(:yesterday) { Date.today - 1 }
    let!(:fresh_case) { create_case('issuance', **fresh_args) }
    let(:fresh_args) { { planned_rejecting_date: tomorrow.to_s } }
    let(:tomorrow) { Date.today + 1 }
    let!(:other_case) { create_case('processing', {}) }

    context 'when there are cases with outdated result' do
      it 'should change state of all of the cases to `rejecting`' do
        subject
        expect(case_state(rotten_case)).to be == 'rejecting'
        expect(case_state(another_rotten_case)).to be == 'rejecting'
      end

      it 'should set `rejecting_date` attribute of all of the cases' do
        subject
        expect(case_rejecting_date(rotten_case))
          .to be_within(1).of(Time.now)
        expect(case_rejecting_date(another_rotten_case))
          .to be_within(1).of(Time.now)
      end
    end

    context 'when there are cases with non-outdated result' do
      it 'shouldn\'t touch\'em' do
        subject
        expect(case_state(fresh_case)).to be == 'issuance'
        expect(case_rejecting_date(fresh_case)).to be_nil
      end
    end

    context 'when there are cases in non-issuance state' do
      it 'shouldn\'t touch\'em' do
        subject
        expect(case_state(other_case)).to be == 'processing'
        expect(case_rejecting_date(other_case)).to be_nil
      end
    end
  end
end
