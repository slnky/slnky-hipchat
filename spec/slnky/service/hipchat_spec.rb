require 'spec_helper'

describe Slnky::Service::Hipchat do
  subject { described_class.new("http://localhost:3000", test_config) }
  let(:test_event) { event_load('test') }
  let(:log_event) { event_load('log') }

  it 'handles event' do
    expect(subject.handler(test_event.name, test_event.payload)).to eq(true)
  end

  it 'handles warning' do
    expect(subject.logline(log_event)).to eq(true)
  end
end
