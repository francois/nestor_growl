require "nestor/machine"
require "ruby-growl"

module Nestor
  class Machine
    state_machine do
      after_transition  :to => :run_focused, :do => :announce_number_of_failures
      after_transition  :to => :green,       :do => :announce_green
      before_transition :to => [:run_multi_pending, :run_focused],
        :do => :announce_run_pending
      before_transition :to => [:running_all, :running_multi, :running_focused],
        :do => :announce_running
    end

    private

    def announce_running
      if focuses.length.zero? && focused_files.length.zero? then
        growl "Nestor Running", "Running all tests for the project"
      elsif focuses.length.zero? then
        growl "Nestor Running", "Running #{focuses.length} test(s) in #{focused_files.length} file(s)"
      else
        growl "Nestor Running", "Running #{focused_files.length} file(s)"
      end
    end

    def announce_run_pending
      growl "Nestor Run Pending", "Waiting for more changes before running"
    end

    def announce_number_of_failures
      growl "Nestor Failures", "#{focuses.length} failure(s) in the last run"
    end

    def announce_green
      growl "Nestor Happy", "All green: proceed with more features"
    end

    def growl(title, message)
      `growlnotify -n Nestor --message #{message.inspect} #{title.inspect}`
    end

    def growl_instance
      @growl_instance ||= Growl.new("127.0.0.1", "nestor", ["Nestor Notification"])
    end
  end
end

