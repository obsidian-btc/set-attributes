class SetAttributes
  module Attribute
    class Error < RuntimeError; end

    def self.set(receiver, attribute, value, log_black_list_regex=nil, strict: nil)
      logger = Telemetry::Logger.build self

      strict ||= false

      log_black_list_regex ||= Defaults.log_black_list_regex

      setter = :"#{attribute}="

      if log_black_list_regex && !(attribute =~ log_black_list_regex).nil?
        log_value = '(value cannot be logged)'
      else
        log_value = value
      end

      if receiver.respond_to? setter
        logger.opt_trace "Setting #{attribute}"

        receiver.send setter, value

        logger.opt_debug "Set #{attribute}"
        logger.opt_data "#{attribute}: #{log_value}"
      else
        error_msg = "#{receiver} has no setter for #{attribute}"
        if strict
          logger.error error_msg
          raise Error, error_msg
        else
          logger.opt_debug "#{receiver} has no setter for #{attribute}"
        end
      end

      value
    end

    module Defaults
      def self.log_black_list_regex
        logger = Telemetry::Logger.build self
        logger.opt_trace "Getting default attribute black list regex"
        /\A(password|api_key|data|metadata)\z|token\z/.tap do |instance|
          logger.opt_debug "Got default attribute black list regex (#{instance})"
        end
      end
    end
  end
end
