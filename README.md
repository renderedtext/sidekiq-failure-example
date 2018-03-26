# Example of failing jobs in Sidekiq

Sidekiq, by design pops a job from Redis and returns it to the Redis queue if
an error or a stop action is triggered. This works great if we can guarantee
graceful shutdown of Sidekiq workers.

Ideally, this would mean sending the Sidekiq process a `kill -15 switch` when we
want to stop it.

However, Sidekiq can't handle other more serious crashes. For example:

- OOM errors
- hardware failure
- network issue
- killing the process with a `kill -9` switch.

### Example with graceful shutdown (job is not lost)

1) Start the Sidekiq worker: `docker-compose up --build`
2) Enqueue a job: `docker-compose run worker ruby enqueue.rb`
3) Wait for Sidekiq to start processing the job
4) Trigger a graceful shutdown: `docker-compose stop worker` (this effectively
sends a `kill -15` to the sidekiq worker)
5) Sidekiq will wait for a while, and then return the job to Redis
6) Hit ctlr+c in the terminal that is running `docker-compose up --build`
7) Restart the worker: `docker-compose up --build`

The enqueued job should retry its execution.

### Example with crashes (job is lost)

1) Start the Sidekiq worker: `docker-compose up --build`
2) Enqueue a job: `docker-compose run worker ruby enqueue.rb`
3) Wait for Sidekiq to start processing the job
4) Trigger a crash of the process: `docker-compose killworker` (this effectively sends a `kill -9` to the sidekiq worker)
5) Sidekiq will die immidiately without returning the job to Redis.
6) Hit ctlr+c in the terminal that is running `docker-compose up --build`
7) Restart the worker: `docker-compose up --build`

The job is forever lost. :'(
