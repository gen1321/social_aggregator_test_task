# frozen_string_literal: true

require_relative '../fetch_socials_service'
require_relative '../api_client'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.describe FetchSocialsService do
  include Dry::Monads[:result]
  let(:service) { described_class.new }

  describe '#call' do
    context 'with all socials respond succesfuly' do
      let(:resp) do
        Success({
          facebook: ["Here's some photos of my holiday. Look how much more fun I'm having than you are!",
                     'I am in a hospital. I will not tell you anything about why I am here.'],
          twitter: [
            'line too long',
            "STOP TELLING ME YOUR NEWBORN'S WEIGHT AND LENGTH I DON'T KNOW WHAT TO DO WITH THAT INFORMATION."
          ]
        })
      end

      it 'succeeds' do
        VCR.use_cassette('successs') do
          expect(service.call).to eq(resp)
        end
      end
    end

    context 'with one social responds with incorect json && error' do
      let(:resp) do
        Success({
          errors: [{ facebook: :third_party_error }],
          twitter: ['line too long',
                    "STOP TELLING ME YOUR NEWBORN'S WEIGHT AND LENGTH I DON'T KNOW WHAT TO DO WITH THAT INFORMATION."]
        })
      end

      it 'succeeds' do
        VCR.use_cassette('fails') do
          expect(service.call).to eq(resp)
        end
      end
    end
  end
end
