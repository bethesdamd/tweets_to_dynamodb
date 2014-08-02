#

module Myaws
	require 'AWS'
	def Myaws.get_client
		return AWS::DynamoDB.new(:access_key_id => 'AKIAIEOCOOLQSZQS5HPA', 
			:secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
	end
end

