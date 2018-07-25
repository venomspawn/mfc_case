# frozen_string_literal: true

# Файл тестирования модуля `MFCCase`, предоставляющего обработчики событий
# бизнес-логики неавтоматизированной услуги

RSpec.shared_examples 'an attributes setter' do |names|
  names.each do |name|
    context "when attribute `#{name}` is specified in parameters" do
      let(:params) { { name => value } }
      let(:value) { create(:string) }

      it 'should set the attribute' do
        expect { subject }
          .to change { case_attributes(c4s3.id)[name] }
          .to(value)
      end
    end

    context "when attribute `#{name}` isn\'t specified in parameters" do
      let(:params) { {} }

      it 'shouldn\'t change the attribute' do
        expect { subject }.not_to change { case_attributes(c4s3.id)[name] }
      end
    end
  end
end

RSpec.shared_examples 'an attributes cleaner' do |names|
  names.each do |name|
    it "should set `#{name}` to `nil`" do
      subject
      expect(case_attributes(c4s3.id)[name]).to be_nil
    end
  end
end

RSpec.describe MFCCase do
  describe 'the module' do
    subject { described_class }

    methods = %i[change_state_to on_case_creation on_load on_unload]
    it { is_expected.to respond_to(*methods) }
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
      let(:params) { {} }
      let(:office_id) { create(:string) }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:pending])
      end

      it 'should set `pending_register_sending_date` to current time' do
        subject
        expect(case_pending_register_sending_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      attributes = %i[
        pending_register_institution_name
        pending_register_institution_office_building
        pending_register_institution_office_city
        pending_register_institution_office_country_code
        pending_register_institution_office_country_name
        pending_register_institution_office_district
        pending_register_institution_office_house
        pending_register_institution_office_index
        pending_register_institution_office_region_code
        pending_register_institution_office_region_name
        pending_register_institution_office_room
        pending_register_institution_office_settlement
        pending_register_institution_office_street
        pending_register_number
        pending_register_operator_middle_name
        pending_register_operator_name
        pending_register_operator_position
        pending_register_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `rejecting` to `pending`' do
      include MFCCase::ChangeStateTo::RejectingPendingSpecHelper

      let(:c4s3) { create_case('rejecting') }
      let(:params) { {} }
      let(:state) { 'pending' }

      it 'should set case state to `pending`' do
        expect { subject }.to change { case_state(c4s3) }.to('pending')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:pending])
      end

      it 'should set `pending_rejecting_register_sending_date` attribute' do
        subject
        expect(case_pending_rejecting_register_sending_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      attributes = %i[
        pending_rejecting_register_institution_name
        pending_rejecting_register_institution_office_building
        pending_rejecting_register_institution_office_city
        pending_rejecting_register_institution_office_country_code
        pending_rejecting_register_institution_office_country_name
        pending_rejecting_register_institution_office_district
        pending_rejecting_register_institution_office_house
        pending_rejecting_register_institution_office_index
        pending_rejecting_register_institution_office_region_code
        pending_rejecting_register_institution_office_region_name
        pending_rejecting_register_institution_office_room
        pending_rejecting_register_institution_office_settlement
        pending_rejecting_register_institution_office_street
        pending_rejecting_register_number
        pending_rejecting_register_operator_middle_name
        pending_rejecting_register_operator_name
        pending_rejecting_register_operator_position
        pending_rejecting_register_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `pending` to `packaging`' do
      include MFCCase::ChangeStateTo::PendingPackagingSpecHelper

      let(:c4s3) { create_case(:pending, rejecting_date) }
      let(:rejecting_date) { nil }
      let(:params) { {} }
      let(:state) { 'packaging' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('packaging')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:packaging])
      end

      attributes = %i[
        pending_register_institution_name
        pending_register_institution_office_building
        pending_register_institution_office_city
        pending_register_institution_office_country_code
        pending_register_institution_office_country_name
        pending_register_institution_office_district
        pending_register_institution_office_house
        pending_register_institution_office_index
        pending_register_institution_office_region_code
        pending_register_institution_office_region_name
        pending_register_institution_office_room
        pending_register_institution_office_settlement
        pending_register_institution_office_street
        pending_register_number
        pending_register_operator_middle_name
        pending_register_operator_name
        pending_register_operator_position
        pending_register_operator_surname
        pending_register_sending_date
      ]
      it_should_behave_like 'an attributes cleaner', attributes

      context 'when case result was rejected' do
        let(:rejecting_date) { 'yesterday' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `pending` to `rejecting`' do
      include MFCCase::ChangeStateTo::PendingRejectingSpecHelper

      let(:c4s3) { create_case(:pending, rejecting_date) }
      let(:rejecting_date) { 'yesterday' }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `packaging`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:rejecting])
      end

      attributes = %i[
        pending_rejecting_register_institution_name
        pending_rejecting_register_institution_office_building
        pending_rejecting_register_institution_office_city
        pending_rejecting_register_institution_office_country_code
        pending_rejecting_register_institution_office_country_name
        pending_rejecting_register_institution_office_district
        pending_rejecting_register_institution_office_house
        pending_rejecting_register_institution_office_index
        pending_rejecting_register_institution_office_region_code
        pending_rejecting_register_institution_office_region_name
        pending_rejecting_register_institution_office_room
        pending_rejecting_register_institution_office_settlement
        pending_rejecting_register_institution_office_street
        pending_rejecting_register_number
        pending_rejecting_register_operator_middle_name
        pending_rejecting_register_operator_name
        pending_rejecting_register_operator_position
        pending_rejecting_register_operator_surname
        pending_rejecting_register_sending_date
      ]
      it_should_behave_like 'an attributes cleaner', attributes

      context 'when case result wasn\'t rejected' do
        let(:rejecting_date) { nil }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `processing` to `issuance`' do
      include MFCCase::ChangeStateTo::ProcessingIssuanceSpecHelper

      let(:c4s3) { create_case(:processing) }
      let(:params) { {} }
      let(:state) { 'issuance' }

      it 'should set case state to `issuance`' do
        expect { subject }.to change { case_state(c4s3) }.to('issuance')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:issuance])
      end

      it 'should set `issuance_receiving_date` attribute' do
        subject
        expect(case_issuance_receiving_date(c4s3))
          .to be_within(1)
          .of(Time.now)
      end

      attributes = %i[
        issuance_office_mfc_building
        issuance_office_mfc_city
        issuance_office_mfc_country_code
        issuance_office_mfc_country_name
        issuance_office_mfc_district
        issuance_office_mfc_house
        issuance_office_mfc_index
        issuance_office_mfc_region_code
        issuance_office_mfc_region_name
        issuance_office_mfc_room
        issuance_office_mfc_settlement
        issuance_office_mfc_street
        issuance_operator_middle_name
        issuance_operator_name
        issuance_operator_position
        issuance_operator_surname
        result_id
      ]
      it_should_behave_like 'an attributes setter', attributes
    end

    context 'when case state is switching from `issuance` to `closed`' do
      include MFCCase::ChangeStateTo::IssuanceClosedSpecHelper

      let(:c4s3) { create_case(:issuance, planned_rejecting_date) }
      let(:planned_rejecting_date) { (Time.now + 86_400).strftime('%FT%T') }
      let(:params) { {} }
      let(:state) { 'closed' }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:closed])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
      end

      attributes = %i[
        closed_office_mfc_building
        closed_office_mfc_city
        closed_office_mfc_country_code
        closed_office_mfc_country_name
        closed_office_mfc_district
        closed_office_mfc_house
        closed_office_mfc_index
        closed_office_mfc_region_code
        closed_office_mfc_region_name
        closed_office_mfc_room
        closed_office_mfc_settlement
        closed_office_mfc_street
        closed_operator_middle_name
        closed_operator_name
        closed_operator_position
        closed_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `planned_rejecting_date` attribute is absent' do
        let(:c4s3) { create(:case, type: 'mfc_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when `planned_rejecting_date` attribute is nil' do
        let(:planned_rejecting_date) { nil }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when `planned_rejecting_date` attribute value is invalid' do
        let(:planned_rejecting_date) { 'invalid' }

        it 'should set case state to `closed`' do
          expect { subject }.to change { case_state(c4s3) }.to('closed')
        end
      end

      context 'when now date is more than value of `planned_rejecting_date`' do
        let(:planned_rejecting_date) { Time.now - 24 * 60 * 60 }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `issuance` to `rejecting`' do
      include MFCCase::ChangeStateTo::IssuanceRejectingSpecHelper

      let(:c4s3) { create_case(:issuance, planned_rejecting_date) }
      let(:planned_rejecting_date) { Time.now - 24 * 60 * 60 }
      let(:params) { {} }
      let(:state) { 'rejecting' }

      it 'should set case state to `rejecting`' do
        expect { subject }.to change { case_state(c4s3) }.to('rejecting')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:rejecting])
      end

      it 'should set `rejecting_date` attribute value to now time' do
        subject
        expect(case_rejecting_date(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when `planned_rejecting_date` attribute is absent' do
        let(:c4s3) { create(:case, type: 'mfc_case') }
        let!(:attrs) { create(:case_attributes, **args) }
        let(:args) { { case_id: c4s3.id, state: 'issuance' } }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `planned_rejecting_date` attribute is nil' do
        let(:planned_rejecting_date) { nil }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `planned_rejecting_date` attribute value is invalid' do
        let(:planned_rejecting_date) { 'invalid' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when now date is less than value of `planned_rejecting_date`' do
        let(:planned_rejecting_date) { Time.now + 24 * 60 * 60 }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when case state is switching from `pending` to `closed`' do
      include MFCCase::ChangeStateTo::PendingClosedSpecHelper

      let(:c4s3) { create_case('pending', *args) }
      let(:state) { 'closed' }
      let(:args) { [issue_method, rejecting_date] }
      let(:issue_method) { 'institution' }
      let(:rejecting_date) { nil }
      let(:params) { { operator_id: 'operator_id' } }

      it 'should set case state to `closed`' do
        expect { subject }.to change { case_state(c4s3) }.to('closed')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:closed])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_closed_date(c4s3)).to be_within(1).of(Time.now)
      end

      attributes = %i[
        closed_office_mfc_building
        closed_office_mfc_city
        closed_office_mfc_country_code
        closed_office_mfc_country_name
        closed_office_mfc_district
        closed_office_mfc_house
        closed_office_mfc_index
        closed_office_mfc_region_code
        closed_office_mfc_region_name
        closed_office_mfc_room
        closed_office_mfc_settlement
        closed_office_mfc_street
        closed_operator_middle_name
        closed_operator_name
        closed_operator_position
        closed_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `issue_method` value isn\'t `institution`' do
        let(:issue_method) { '' }

        context 'when `rejecting_date` value is nil' do
          it 'should raise RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end
      end
    end

    context 'when case state is switching from `pending` to `processing`' do
      include MFCCase::ChangeStateTo::PendingProcessingSpecHelper

      let(:c4s3) { create_case('pending', issue_method, rejecting_date) }
      let(:state) { 'processing' }
      let(:issue_method) { 'mfc' }
      let(:rejecting_date) { nil }
      let(:params) { {} }

      it 'should set case state to `processing`' do
        expect { subject }.to change { case_state(c4s3) }.to('processing')
      end

      it 'should set `case_status` attribute value to appropriate value' do
        expect { subject }
          .to change { case_status(c4s3) }
          .to(described_class::ChangeStateTo::CASE_STATUS[:processing])
      end

      it 'should set `closed_date` attribute value to now time' do
        subject
        expect(case_processing_sending_date(c4s3)).to be_within(1).of(Time.now)
      end

      attributes = %i[
        processing_institution_name
        processing_institution_office_building
        processing_institution_office_city
        processing_institution_office_country_code
        processing_institution_office_country_name
        processing_institution_office_district
        processing_institution_office_house
        processing_institution_office_index
        processing_institution_office_region_code
        processing_institution_office_region_name
        processing_institution_office_room
        processing_institution_office_settlement
        processing_institution_office_street
        processing_number
        processing_operator_middle_name
        processing_operator_name
        processing_operator_position
        processing_operator_surname
      ]
      it_should_behave_like 'an attributes setter', attributes

      context 'when `issue_method` value is `institution`' do
        let(:issue_method) { 'institution' }

        it 'should raise RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when `rejecting_date` value is present' do
        let(:rejecting_date) { Time.now.strftime('%FT%T') }

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

    it 'should set `case_id` attribute value to case id value' do
      expect { subject }.to change { case_id(c4s3) }.to(c4s3.id)
    end

    it 'should set `case_status` attribute value to appropriate value' do
      expect { subject }
        .to change { case_status(c4s3) }
        .to(described_class::ChangeStateTo::CASE_STATUS[:packaging])
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

  describe '.on_load' do
    subject { described_class.on_load }

    it 'should create Rufus::Scheduler instance and save it' do
      subject
      expect(described_class.instance_variable_get('@scheduler'))
        .to be_a(Rufus::Scheduler)
    end

    context 'when there already is an instance of Rufus::Scheduler running' do
      before do
        scheduler = Rufus::Scheduler.new
        described_class.instance_variable_set('@scheduler', scheduler)
      end

      it 'should create new instance' do
        expect { subject }
          .to change { described_class.instance_variable_get('@scheduler') }
      end
    end

    describe 'started Rufus::Scheduler instance' do
      subject(:sched) do
        described_class.on_load
        described_class.instance_variable_get('@scheduler')
      end

      it 'should have just one cron job' do
        expect(subject.jobs.size).to be == 1
        expect(subject.jobs.first).to be_a(Rufus::Scheduler::CronJob)
      end

      describe 'the cron job' do
        subject { sched.jobs.first }

        it 'should run every day' do
          expect(subject.brute_frequency.delta_min).to be == 86_400
          expect(subject.brute_frequency.delta_max).to be == 86_400
        end

        it 'should start tomorrow' do
          expect(subject.next_time.strftime('%F'))
            .to be == Date.today.succ.to_s
        end
      end
    end
  end

  describe '.on_unload' do
    subject { described_class.on_unload }

    it 'should stop saved Rufus::Scheduler instance' do
      described_class.on_load
      scheduler = described_class.instance_variable_get('@scheduler')
      subject
      expect(scheduler.down?).to be_truthy
    end

    it 'should clear saved Rufus::Scheduler instance' do
      subject
      expect(described_class.instance_variable_get('@scheduler')).to be_nil
    end

    context 'when there is no instance' do
      it 'should be a\'ight' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
