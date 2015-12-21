# aws_sns_to_hipchat.rb
require 'net/http'
require 'sinatra'
require 'json'
require 'hipchat-api'

get '/' do
  'AWS SNS to HIPCHAT!'
end

post '/hipchat/snstopic/:roomid' do
  begin
    puts params[:roomid]
    data = JSON.parse(request.body.read)
    data.each do |d|
      puts d
    end
  rescue JSON::ParserError
    halt 400, 'JSON is required'
  end

  @hipchat_message = data['Message']
  @message_color = 'yellow'

  puts "message is - #{@hipchat_message}"

  # Json Structure for SNS is a bit hacky, child json within the Message can have many meanings which you need to work out, nothings easy in life it seems.
  begin
    @jsonMessage = JSON.parse(data['Message'])
  rescue
    puts "Couldn't Parse Message Data from SNS :- #{data['Message']}"
  end

  unless data['SubscribeURL'].nil?
    puts 'Attempting to Auto-Subscribe to SNS Notifications...'

    url = URI.parse("#{data['SubscribeURL']}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host) {|http|http.request(req)}
    puts res.body
    return
  end

  unless @jsonMessage.nil?
    # AutoScalling Messages have a 'cause' section in the message json
    unless @jsonMessage['Cause'].nil?
      @hipchat_message = "#{@jsonMessage['AutoScalingGroupName']} - #{@jsonMessage['Description']} - #{@jsonMessage['Cause'][0, @jsonMessage['Cause'].index(".")]}"
    end

    # Pretty Alarm messages received from SNS
    unless @jsonMessage['AlarmName'].nil?
      @hipchat_message = "#{@jsonMessage['NewStateValue']} - #{@jsonMessage['AlarmName']} - #{@jsonMessage['NewStateReason']} - #{@jsonMessage['StateChangeTime']}"
    end

    unless @jsonMessage['Event'].nil?
      if @jsonMessage['Event'].include? 'EC2_INSTANCE_LAUNCH'
        @message_color = 'green'
      end
      if @jsonMessage['Event'].include? 'EC2_INSTANCE_TERMINATE'
        @message_color = 'red'
      end
    end
  end

  puts "Writing Message: #{@hipchat_message} to room id #{params[:roomid]}"
  hipchat_api = HipChat::API.new("#{ENV['HIPCHAT_AUTH_TOKEN']}")
  @status = hipchat_api.rooms_message(params[:roomid], 'Sns Topic', @hipchat_message, notify = 1, color = @message_color, message_format = 'html')
  puts @status
end
