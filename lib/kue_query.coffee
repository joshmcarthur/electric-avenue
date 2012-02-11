# This class is really bad - I'm treating Redis as a relational database, which
# is a bad idea - this is not what Redis is optimized to do
# See documentation for warning about permormance: http://redis.io/commands/keys
#

Job = require('kue/lib/queue/job')

class KueQuery
  constructor: (@queue) ->

  all: (callback) ->
    @jobs = []
    @queue.client.keys("q:job:*", (error, replies) =>
      job_ids = (parseInt(job_id.replace(/\D*/, '')) for job_id in replies when job_id.match(/\d+/))
      return this.sortAndReturn(callback, job_ids) if job_ids.length == 0
      this.addJob(job_id, job_id == job_ids[job_ids.length - 1], callback) for job_id in job_ids
    )

  addJob: (job_id, is_last, callback) ->
    Job.get(job_id, (error, job) =>
      @jobs.push(job) if job
      this.sortAndReturn(callback, @jobs) if is_last
    )

  sortAndReturn: (callback, jobs) ->
    callback(
      jobs.sort( (a, b) ->
        return if b.created_at < a.created_at then 1 else -1
      )
    )

exports.KueQuery = KueQuery
