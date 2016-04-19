module AmazonSignature
  extend self

  def signature
    Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha1'),
          Rails.application.secrets.aws_s3_key, self.policy
        )
      ).gsub("\n", "")
  end

  def policy
    Base64.encode64(self.policy_data.to_json).gsub("\n", "")
  end

  def policy_data
    {
      expiration: 10.hours.from_now.utc.iso8601,
      conditions: [
        ["starts-with", "$key", 'froala/uploads/'],
        ["starts-with", "$x-requested-with", "xhr"],
        ["content-length-range", 0, 20.megabytes],
        ["starts-with", "$content-type", ""],
        {bucket: Rails.application.secrets.aws_s3_bucket},
        {acl: 'public-read'},
        {success_action_status: "201"}
      ]
    }
  end

  def data_hash
    {
      :signature => self.signature, 
      :policy => self.policy, 
      :bucket => Rails.application.secrets.aws_s3_bucket, 
      :acl => 'public-read', 
      :key_start => 'froala/uploads/', 
      :access_key => Rails.application.secrets.aws_s3_id}
  end
end