require 'spec_helper'

describe Slnky::Hipchat::Service do
  subject do
    s = described_class.new
    s.client = Slnky::Hipchat::Mock.new
    s
  end
  let(:test_event) { slnky_event('test') }
  let(:chat_event) { slnky_event('chat') }
  let(:test_event) { slnky_event('test') }
  let(:log_info) { slnky_event('info') }
  let(:log_warn) { slnky_event('warn') }
  let(:log_error) { slnky_event('error') }

  it 'handles event' do
    expect(subject.handle_test(test_event.name, test_event.payload)).to eq(true)
  end

  it 'handles event chat' do
    expect(subject.handle_event(chat_event.name, chat_event.payload)).to include("testing event chat message")
  end

  it 'handles info' do
    expect(subject.handle_log(log_info)).to include("INFO slnky.service.chef: node i-12345678")
  end

  it 'handles warning' do
    expect(subject.handle_log(log_warn)).to include("WARN slnky.service.chef: node i-12345678")
  end

  it 'handles error' do
    expect(subject.handle_log(log_error)).to include("ERROR slnky.service.chef: node i-12345678")
  end
end
