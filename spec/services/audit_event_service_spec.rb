# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEventService do
  let(:project) { create(:project) }
  let(:user) { create(:user, :with_sign_ins) }
  let(:project_member) { create(:project_member, user: user) }
  let(:service) { described_class.new(user, project, { action: :destroy }) }
  let(:logger) { instance_double(Gitlab::AuditJsonLogger) }

  describe '#security_event' do
    before do
      stub_licensed_features(admin_audit_log: false)
    end

    it 'creates an event and logs to a file' do
      expect(service).to receive(:file_logger).and_return(logger)
      expect(logger).to receive(:info).with(author_id: user.id,
                                            author_name: user.name,
                                            entity_id: project.id,
                                            entity_type: "Project",
                                            action: :destroy)

      expect { service.security_event }.to change(AuditEvent, :count).by(1)
    end

    it 'formats from and to fields' do
      service = described_class.new(
        user, project,
        {
          from: true,
          to: false,
          action: :create,
          target_id: 1
        })
      expect(service).to receive(:file_logger).and_return(logger)
      expect(logger).to receive(:info).with(author_id: user.id,
                                            author_name: user.name,
                                            entity_type: 'Project',
                                            entity_id: project.id,
                                            from: 'true',
                                            to: 'false',
                                            action: :create,
                                            target_id: 1)

      expect { service.security_event }.to change(AuditEvent, :count).by(1)

      details = AuditEvent.last.details
      expect(details[:from]).to be true
      expect(details[:to]).to be false
      expect(details[:action]).to eq(:create)
      expect(details[:target_id]).to eq(1)
    end
  end

  describe '#log_security_event_to_file' do
    it 'logs security event to file' do
      expect(service).to receive(:file_logger).and_return(logger)
      expect(logger).to receive(:info).with(author_id: user.id,
                                            author_name: user.name,
                                            entity_type: 'Project',
                                            entity_id: project.id,
                                            action: :destroy)

      service.log_security_event_to_file
    end
  end
end
