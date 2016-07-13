class OrderLogger < Logger
    def format_message severity, timestamp, progname, msg
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
    end
end

logfile = File.open("#{Rails.root}/log/order.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
OrderLog = OrderLogger.new(logfile)  # constant accessible anywhere