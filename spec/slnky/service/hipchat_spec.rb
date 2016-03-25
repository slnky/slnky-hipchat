require 'spec_helper'

describe Slnky::Service::Hipchat do
  subject { described_class.new("http://localhost:3000", test_config) }
  let(:chat_event) { event_load('chat') }
  let(:test_event) { event_load('test') }
  let(:log_info) { event_load('info') }
  let(:log_warn) { event_load('warn') }
  let(:log_error) { event_load('error') }

  it 'handles event' do
    expect(subject.handler(test_event.name, test_event.payload)).to eq(true)
  end

  it 'handles event chat' do
    expect(subject.handle_event(chat_event.name, chat_event.payload)).to eq(true)
  end

  it 'handles info' do
    expect(subject.logline(log_info)).to eq(true)
  end

  it 'handles warning' do
    expect(subject.logline(log_warn)).to eq(true)
  end

  it 'handles error' do
    expect(subject.logline(log_error)).to eq(true)
  end
end
