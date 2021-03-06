# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AppLogger do
  subject { described_class }

  it 'builds a Gitlab::Logger object twice' do
    expect(Gitlab::Logger).to receive(:new)
      .exactly(described_class.loggers.size)
      .and_call_original

    subject.info('Hello World!')
  end

  it 'logs info to AppLogger and AppJsonLogger' do
    expect_any_instance_of(Gitlab::AppTextLogger).to receive(:info).and_call_original
    expect_any_instance_of(Gitlab::AppJsonLogger).to receive(:info).and_call_original

    subject.info('Hello World!')
  end

  it 'logs info to only the AppJsonLogger when unstructured logs are disabled' do
    stub_env('UNSTRUCTURED_RAILS_LOG', 'false')
    expect_any_instance_of(Gitlab::AppTextLogger).not_to receive(:info).and_call_original
    expect_any_instance_of(Gitlab::AppJsonLogger).to receive(:info).and_call_original

    subject.info('Hello World!')
  end
end
