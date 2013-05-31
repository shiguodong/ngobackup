Bluepill.application("itbackup", log_file: "/var/log/bluepill_itbackup.log") do 
  RAILS_ROOT = '/itbackup/web/current/'

  uid = gid = "www"
  working_dir = RAILS_ROOT
  rails_env = ENV['RAILS_ENV'] || 'production'
 

  process("unicorn") do
    pid_file '/itbackup/web/shared/pids/unicorn.pid'
    
    start_command "bundle exec unicorn_rails -D -c #{working_dir}config/unicorn.rb -E #{rails_env}"
    stop_command "kill -QUIT {{PID}}"
    restart_command "kill -USR2 {{PID}}"

    start_grace_time 3.seconds
    stop_grace_time 5.seconds
    restart_grace_time 13.seconds

    monitor_children do
      stop_command "kill -QUIT {{PID}}"
      term_command "kill -TERM {{PID}}"
      kill_command "kill -KILL {{PID}}"
      
      checks :mem_usage, every: 5.seconds, below: 500.megabytes, times: [3, 5], fires: [:stop, :term, :kill]
      checks :cpu_usage, every: 5.seconds, below: 80, times: [3, 5], fires: [:stop, :term, :kill]
      checks :flapping, times: 2, within: 30.seconds, retry_in: 7.seconds
    end
  end
end
