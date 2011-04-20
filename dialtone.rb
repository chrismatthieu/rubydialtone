require "rubygems"
require "sinatra"
require "tropo-webapi-ruby"

get "/" do
  html = '<html>
  <head>
   <link type="text/css" rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.10/themes/blitzer/jquery-ui.css"/>
   <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
   <script type="text/javascript" src="http://s.phono.com/releases/0.2/jquery.phono.js"></script>
   <script type="text/javascript" src="http://s.phono.com/addons/callme/79a53b7/jquery.callme.js"></script>
  </head>
  <body>
  <h1>Tropo Voice Dialtone</h1>
  <p>This is a Ruby/Sinatra-powered <a href="http://phono.com">Phono</a>/<a href="http://tropo.com">Tropo</a> application. Click the button below and say or enter a 10 digit number that you would like to dial and we will do the rest.</p>	
  <h2>How does it work?</h2>
  <p>Phono is a jQuery based VoIP SIP phone that runs in the browser.  When the red button is clicked, it places a SIP call into a Tropo application using the WebAPI.  The Tropo application is written in Ruby and uses the Tropo-WebAPI and Sinatra gems.  The Tropo app first asks the caller to say or enter a phone number.  The phone number is posted back to the Tropo app (/answer) where a transfer response is returned to the Tropo cloud. </p>
  <p>Check out the code at <a href="https://github.com/chrismatthieu/dialtone">https://github.com/chrismatthieu/rubydialtone</a></p>
   <script type="text/javascript">
    $("body").append(
     $("<div/>")
      .css("width","210px")
      .callme({
        apiKey: "C17D167F-09C6-4E4C-A3DD-2025D48BA243",
        numberToDial: "app:9991489870",
        buttonTextReady: "Call Someone",
        slideOpen:true
      })
    )
   </script>
  </body>
  </html>'
  return html
end

post "/" do
  
  # sessions_object = Tropo::Generator.parse request.env['rack.input'].read
  # msg = sessions_object[:session][:parameters][:msg]
  # number_to_dial = sessions_object[:session][:parameters][:to]

  tropo = Tropo::Generator.new do
     on :event => 'continue', :next => '/answer'
     say("Welcome to the Tropo voice dial tone application.")
     ask({ :name    => 'numbertodial',
           :bargein => true,
           :timeout => 30,
           :require => 'true' }) do
             say     :value => 'Please say or enter a 10 digit phone number you would like to call.'
             choices :value => '[10 DIGITS]'
           end
     end
    tropo.response

end

post "/answer" do
  
  tropo_event = Tropo::Generator.parse request.env["rack.input"].read
  
  tropo = Tropo::Generator.new do
    say("transferring call to " + tropo_event.result.actions.numbertodial.interpretation )
    transfer({ :to => "+1" + tropo_event.result.actions.numbertodial.interpretation })
  end
  tropo.response      
  
end