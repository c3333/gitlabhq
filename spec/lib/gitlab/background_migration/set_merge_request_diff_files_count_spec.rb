# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::SetMergeRequestDiffFilesCount, schema: 20200807152315 do
  let(:merge_request_diff_files) { table(:merge_request_diff_files) }
  let(:merge_request_diffs) { table(:merge_request_diffs) }
  let(:merge_requests) { table(:merge_requests) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }

  let(:namespace) { namespaces.create!(name: 'foo', path: 'foo') }
  let(:project) { projects.create!(namespace_id: namespace.id) }
  let(:merge_request) { merge_requests.create!(source_branch: 'x', target_branch: 'master', target_project_id: project.id) }

  it 'fills the files_count column' do
    empty_diff = merge_request_diffs.create!(merge_request_id: merge_request.id)
    filled_diff = merge_request_diffs.create!(merge_request_id: merge_request.id)

    3.times do |n|
      merge_request_diff_files.create!(
        merge_request_diff_id: filled_diff.id,
        relative_order: n,
        new_file: false,
        renamed_file: false,
        deleted_file: false,
        too_large: false,
        a_mode: '',
        b_mode: '',
        old_path: '',
        new_path: ''
      )
    end

    described_class.new.perform(empty_diff.id, filled_diff.id)

    expect(empty_diff.reload.files_count).to eq(0)
    expect(filled_diff.reload.files_count).to eq(3)
  end
end
