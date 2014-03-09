require 'spec_helper'

describe InkFilePicker::Policy do
  let(:secret) { '6U5CWAU57NAHDC2ICXQKMXYZ4Q' }

  subject do
    described_class.new(
      secret: secret,
      call: 'read',
      expiry: 1394363896
    )
  end

  its(:policy) { should eq 'eyJleHBpcnkiOjEzOTQzNjM4OTYsImNhbGwiOiJyZWFkIn0=' }
  its(:signature) { should eq '4c50ca71d9e123274a01eb00a7facd52069e07c2e9312517f55bf1b94447792e' }
end
