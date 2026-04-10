require 'rails_helper'

RSpec.describe JwtService do
  let(:payload) { { user_id: 1 } }

  describe '.encode' do
    it 'returns a JWT string' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it 'embeds the payload' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'sets expiry to 24 hours by default' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:exp]).to be_within(5).of(24.hours.from_now.to_i)
    end

    it 'accepts a custom expiry' do
      token = described_class.encode(payload, 1.hour.from_now)
      decoded = described_class.decode(token)
      expect(decoded[:exp]).to be_within(5).of(1.hour.from_now.to_i)
    end
  end

  describe '.decode' do
    it 'decodes a valid token' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(1)
    end

    it 'raises JWT::DecodeError for an invalid token' do
      expect { described_class.decode("not.a.token") }.to raise_error(JWT::DecodeError)
    end

    it 'raises JWT::ExpiredSignature for an expired token' do
      token = described_class.encode(payload, 1.second.ago)
      expect { described_class.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end
  end
end
